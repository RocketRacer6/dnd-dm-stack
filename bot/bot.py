#!/usr/bin/env python3
"""
D&D AI DM Telegram Bot
A dungeon master that runs games via Telegram, powered by AI.
"""

import os
import logging
from datetime import datetime
from typing import Optional

from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import (
    Application,
    CommandHandler,
    MessageHandler,
    CallbackQueryHandler,
    filters,
    ContextTypes
)
import psycopg2
from psycopg2.extras import Json
from openai import OpenAI

# Configure logging
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# Database setup
DATABASE_URL = os.getenv('DATABASE_URL')

# AI Setup
AI_API_KEY = os.getenv('AI_API_KEY')
AI_API_URL = os.getenv('AI_API_URL', 'https://api.groq.com/openai/v1')
AI_MODEL = os.getenv('AI_MODEL', 'llama-3.1-70b-versatile')

client = OpenAI(
    api_key=AI_API_KEY,
    base_url=AI_API_URL
)

# Game state database operations
def get_db_connection():
    """Get database connection"""
    return psycopg2.connect(DATABASE_URL)

def init_db():
    """Initialize database tables"""
    conn = get_db_connection()
    cur = conn.cursor()

    # Campaigns table
    cur.execute("""
        CREATE TABLE IF NOT EXISTS campaigns (
            id SERIAL PRIMARY KEY,
            name VARCHAR(255) NOT NULL,
            dungeon_master VARCHAR(255),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            settings JSONB DEFAULT '{}'
        )
    """)

    # Characters table
    cur.execute("""
        CREATE TABLE IF NOT EXISTS characters (
            id SERIAL PRIMARY KEY,
            campaign_id INTEGER REFERENCES campaigns(id) ON DELETE CASCADE,
            player_id VARCHAR(255) NOT NULL,
            player_name VARCHAR(255),
            character_name VARCHAR(255) NOT NULL,
            class_level VARCHAR(255),
            stats JSONB DEFAULT '{}',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # Sessions table
    cur.execute("""
        CREATE TABLE IF NOT EXISTS sessions (
            id SERIAL PRIMARY KEY,
            campaign_id INTEGER REFERENCES campaigns(id) ON DELETE CASCADE,
            session_number INTEGER,
            started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            ended_at TIMESTAMP,
            messages JSONB DEFAULT '[]'
        )
    """)

    # Dice rolls table
    cur.execute("""
        CREATE TABLE IF NOT EXISTS dice_rolls (
            id SERIAL PRIMARY KEY,
            campaign_id INTEGER REFERENCES campaigns(id) ON DELETE CASCADE,
            player_id VARCHAR(255),
            roll_type VARCHAR(100),
            result INTEGER,
            details VARCHAR(255),
            rolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)

    conn.commit()
    cur.close()
    conn.close()
    logger.info("Database initialized")

# AI Functions
def generate_dm_response(
    campaign_name: str,
    player_message: str,
    game_context: str,
    session_history: list
) -> str:
    """Generate AI DM response"""

    system_prompt = f"""You are an expert Dungeon Master for a Dungeons & Dragons campaign called "{campaign_name}".
You are running the game via Telegram. Be engaging, descriptive, and fair.
Keep responses concise but vivid. Handle dice rolls when players request them.
Focus on storytelling and player agency."""

    # Build conversation history
    messages = [
        {"role": "system", "content": system_prompt},
    ]

    # Add recent session history (last 10 exchanges)
    for exchange in session_history[-10:]:
        if exchange.get('role'):
            messages.append({
                "role": exchange['role'],
                "content": exchange.get('content', '')
            })

    # Add current player message
    messages.append({
        "role": "user",
        "content": player_message
    })

    try:
        response = client.chat.completions.create(
            model=AI_MODEL,
            messages=messages,
            temperature=0.8,
            max_tokens=1000
        )
        return response.choices[0].message.content
    except Exception as e:
        logger.error(f"AI generation error: {e}")
        return "I apologize, but I'm having trouble processing that. Could you rephrase?"

# Telegram Command Handlers
async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /start command"""
    welcome_message = """
🎲 Welcome to D&D AI DM!

I'm your AI Dungeon Master, ready to run adventures right here in Telegram.

**Commands:**
/newgame - Start a new campaign
/join <code> - Join an existing game
/roll <dice> - Roll dice (e.g., /roll 2d6+3)
/status - Check your character and campaign
/help - See all commands

Ready to adventure? Let's begin! 🧙‍♂️
"""
    await update.message.reply_text(welcome_message, parse_mode='Markdown')

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /help command"""
    help_text = """
**D&D AI DM Commands:**

🎮 Game Commands:
/newgame - Start a new campaign
/join <code> - Join an existing game
/status - Check your character and campaign
/characters - List all characters in campaign

🎲 Dice & Actions:
/roll <dice> - Roll dice (e.g., /roll 2d6+3, /roll d20)
/attack - Make an attack roll
/skill <skill> - Roll a skill check

🗺️ Game Flow:
/dm <message> - Speak to the DM directly
/description - Ask for more scene details
/inventory - Check your inventory

Need more help? Just ask me anything! 🧙‍♂️
"""
    await update.message.reply_text(help_text, parse_mode='Markdown')

async def roll_dice(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle dice rolling"""
    if not context.args:
        await update.message.reply_text(
            "Usage: /roll <dice>\nExample: /roll 2d6+3, /roll d20"
        )
        return

    dice_expression = " ".join(context.args)

    # Simple dice parsing (can be expanded)
    try:
        import re
        # Match pattern like 2d6+3, d20, 4d8
        match = re.match(r'^(\d*)d(\d+)([+-]\d+)?$', dice_expression.lower())

        if not match:
            await update.message.reply_text(
                f"Invalid dice format: {dice_expression}\nTry: /roll 2d6+3"
            )
            return

        num_dice = int(match.group(1)) if match.group(1) else 1
        die_type = int(match.group(2))
        modifier = int(match.group(3)) if match.group(3) else 0

        # Roll the dice
        import random
        rolls = [random.randint(1, die_type) for _ in range(num_dice)]
        total = sum(rolls) + modifier

        # Format result
        rolls_str = " + ".join(map(str, rolls))
        result = f"🎲 {dice_expression}: `{rolls_str}`"
        if modifier != 0:
            result += f" {modifier:+d}"
        result += f" = **{total}**"

        await update.message.reply_text(result, parse_mode='Markdown')

        # Log roll to database
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("""
            INSERT INTO dice_rolls (player_id, roll_type, result, details)
            VALUES (%s, %s, %s, %s)
        """, (str(update.effective_user.id), dice_expression, total, str(rolls)))
        conn.commit()
        cur.close()
        conn.close()

    except Exception as e:
        logger.error(f"Roll error: {e}")
        await update.message.reply_text(f"Error rolling dice: {e}")

async def newgame(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Start a new campaign"""
    if not context.args:
        await update.message.reply_text(
            "Usage: /newgame <campaign name>\nExample: /newgame The Lost Mine of Phandelver"
        )
        return

    campaign_name = " ".join(context.args)

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute("""
        INSERT INTO campaigns (name, dungeon_master, settings)
        VALUES (%s, %s, %s)
        RETURNING id
    """, (campaign_name, update.effective_user.username or str(update.effective_user.id), '{}'))

    campaign_id = cur.fetchone()[0]
    conn.commit()
    cur.close()
    conn.close()

    await update.message.reply_text(
        f"🏰 **New Campaign Created!**\n\n"
        f"Campaign: {campaign_name}\n"
        f"ID: {campaign_id}\n"
        f"DM: {update.effective_user.first_name}\n\n"
        f"Use /join {campaign_id} to add your character!"
    )

async def dm(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Speak to the DM directly"""
    if not context.args:
        await update.message.reply_text(
            "Usage: /dm <your message or action>\n"
            "Example: /dm I want to search the room for traps"
        )
        return

    player_message = " ".join(context.args)
    user_id = str(update.effective_user.id)

    # Get user's active campaign (simplified - gets most recent)
    conn = get_db_connection()
    cur = conn.cursor()

    # Get campaign
    cur.execute("""
        SELECT c.name, c.settings
        FROM campaigns c
        JOIN characters ch ON c.id = ch.campaign_id
        WHERE ch.player_id = %s
        ORDER BY ch.created_at DESC
        LIMIT 1
    """, (user_id,))

    result = cur.fetchone()

    if not result:
        cur.close()
        conn.close()
        await update.message.reply_text(
            "You're not in any campaign yet. Use /newgame to start one!"
        )
        return

    campaign_name = result[0]

    # Get recent session history
    cur.execute("""
        SELECT messages
        FROM sessions
        WHERE campaign_id = (SELECT id FROM campaigns ORDER BY id DESC LIMIT 1)
        ORDER BY id DESC
        LIMIT 1
    """)
    session_result = cur.fetchone()
    session_history = session_result[0] if session_result and session_result[0] else []

    cur.close()
    conn.close()

    # Generate AI response
    await update.message.reply_text("🧙‍♂️ *The DM considers your action...*", parse_mode='Markdown')

    dm_response = generate_dm_response(
        campaign_name=campaign_name,
        player_message=player_message,
        game_context="",
        session_history=session_history
    )

    await update.message.reply_text(dm_response)

# Main function
def main():
    """Run the bot"""
    # Initialize database
    init_db()

    # Get bot token
    bot_token = os.getenv('TELEGRAM_BOT_TOKEN')
    if not bot_token:
        logger.error("TELEGRAM_BOT_TOKEN not set!")
        return

    # Create application
    application = Application.builder().token(bot_token).build()

    # Register handlers
    application.add_handler(CommandHandler("start", start))
    application.add_handler(CommandHandler("help", help_command))
    application.add_handler(CommandHandler("roll", roll_dice))
    application.add_handler(CommandHandler("newgame", newgame))
    application.add_handler(CommandHandler("dm", dm))

    # Run the bot
    logger.info("Starting D&D AI DM Bot...")
    application.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == "__main__":
    main()
