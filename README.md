# D&D AI DM - Telegram Bot + Auto-Backup

A Dungeon Master bot that runs D&D campaigns via Telegram, powered by AI. Automatically backs up game state daily at 23:59:59 CST and restarts the stack.

## 🎯 Features

- **AI Dungeon Master** - Powered by LLaMA 3.1 70B (via Groq API or your cluster)
- **Telegram Interface** - No app download needed for players
- **Persistent Game State** - PostgreSQL database stores campaigns, characters, sessions
- **Auto-Backup** - Daily backups at midnight CST
- **Dice Rolling** - Built-in dice command (`/roll 2d6+3`)
- **Multi-Player** - Support multiple campaigns and players

## 📦 Stack

- **Database:** PostgreSQL 15
- **Bot:** Python 3.11 + python-telegram-bot
- **AI:** Groq API (or your local LLaMA 3.1 cluster)
- **Backup:** Automated via cron container
- **Orchestration:** Docker Compose

## 🚀 Quick Start

### 1. Get a Telegram Bot Token

1. Open Telegram and search for [@BotFather](https://t.me/botfather)
2. Send `/newbot` and follow the prompts
3. Copy the API token
4. Save it to your `.env` file

### 2. Get AI API Key (Groq - Free & Fast)

1. Go to [console.groq.com](https://console.groq.com)
2. Sign up for free (no credit card required)
3. Generate an API key
4. Add to `.env` file

**Alternative:** Use your local LLaMA 3.1 cluster - see `.env.example`

### 3. Configure Environment

```bash
# Copy the example env file
cp .env.example .env

# Edit with your credentials
nano .env
```

Required variables:
- `TELEGRAM_BOT_TOKEN` - From BotFather
- `AI_API_KEY` - From Groq (or your cluster)
- `DB_PASSWORD` - Change from default!

### 4. Start the Stack

```bash
# Build and start all services
docker-compose up -d --build

# Check logs
docker-compose logs -f bot

# Verify all containers are running
docker-compose ps
```

### 5. Test the Bot

1. Open Telegram and search for your bot
2. Send `/start`
3. Start a campaign: `/newgame Curse of Strahd`
4. Roll some dice: `/roll d20`

## 💾 Backup System

### Automatic Daily Backup

Every night at **23:59:59 CST**:
1. Bot container stops (clean state)
2. PostgreSQL dumps to `/backups/dnd_backup_YYYY-MM-DD_HHMMSS.sql.gz`
3. Game state archives to `/backups/dnd_state_YYYY-MM-DD_HHMMSS.tar.gz`
4. Old backups (older than 7 days) are auto-deleted
5. Bot container restarts

### Manual Backup

```bash
# Trigger backup manually
docker-compose exec backup /scripts/backup.sh
```

### Restore from Backup

```bash
# List available backups
ls -lh backups/

# Restore database
gunzip -c backups/dnd_backup_2026-02-12_055959.sql.gz | docker-compose exec -T db psql -U dnd_master -d dnd_game

# Restore game state
tar -xzf backups/dnd_state_2026-02-12_055959.tar.gz -C data/
```

## 🎮 Bot Commands

| Command | Description |
|---------|-------------|
| `/start` | Welcome message & quick start |
| `/help` | All available commands |
| `/newgame <name>` | Start a new campaign |
| `/roll <dice>` | Roll dice (e.g., `/roll 2d6+3`) |
| `/dm <action>` | Tell DM what you want to do |
| `/status` | Check your character & campaign |

### Dice Examples

```
/roll d20          → Rolls 1d20
/roll 2d6+3        → Rolls 2d6, adds 3
/roll 4d8          → Rolls 4d8
```

## 🛠️ Management Commands

```bash
# View logs
docker-compose logs -f bot          # Bot logs
docker-compose logs -f db            # Database logs
docker-compose logs -f backup        # Backup logs

# Restart services
docker-compose restart bot           # Restart bot only
docker-compose restart               # Restart everything

# Stop stack
docker-compose down                  # Stop and remove containers
docker-compose down -v               # Stop and remove volumes (⚠️ deletes data!)

# Access database
docker-compose exec db psql -U dnd_master -d dnd_game

# Access bot container
docker-compose exec bot bash
```

## 📊 Database Schema

**Tables:**
- `campaigns` - Campaign info, DM, settings
- `characters` - Player characters, stats, inventory
- `sessions` - Game sessions, message history
- `dice_rolls` - Roll history for audit

## 🎨 Customization

### Change AI Provider

Edit `.env`:

**Groq (default - free & fast):**
```bash
AI_API_KEY=gsk_your_key
AI_API_URL=https://api.groq.com/openai/v1
AI_MODEL=llama-3.1-70b-versatile
```

**Your Local LLaMA 3.1 Cluster:**
```bash
AI_API_KEY=unused
AI_API_URL=http://your-cluster-ip:11434/v1
AI_MODEL=llama-3.1:70b
```

**OpenAI:**
```bash
AI_API_KEY=sk-your-key
AI_API_URL=https://api.openai.com/v1
AI_MODEL=gpt-4-turbo
```

### Change Backup Schedule

Edit `docker-compose.yml`:
```yaml
backup:
  environment:
    # Change to custom time (UTC format)
    # Format: MM HH DD MM DOW
    # Example: Every day at 03:30 UTC = "30 3 * * *"
```

## 🔧 Troubleshooting

### Bot not responding

```bash
# Check bot logs
docker-compose logs bot

# Verify token
docker-compose exec bot env | grep TELEGRAM_BOT_TOKEN

# Restart bot
docker-compose restart bot
```

### Database connection errors

```bash
# Check if DB is healthy
docker-compose ps db

# Test DB connection
docker-compose exec db pg_isready -U dnd_master

# Restart DB
docker-compose restart db
```

### Backup not running

```bash
# Check backup container logs
docker-compose logs backup

# Manually trigger backup
docker-compose exec backup /scripts/backup.sh
```

## 📂 Directory Structure

```
dnd-dm-stack/
├── bot/
│   ├── Dockerfile
│   ├── bot.py              # Main bot code
│   └── requirements.txt
├── scripts/
│   ├── backup-entrypoint.sh # Cron loop
│   └── backup.sh           # Backup logic
├── data/                   # Game state files (created at runtime)
├── backups/                # Backup storage (created at runtime)
├── docker-compose.yml
├── .env                    # Your credentials (create from .env.example)
└── README.md
```

## 🔒 Security

- **Never commit `.env`** - Contains sensitive keys
- **Change `DB_PASSWORD`** from default
- **Limit bot access** - Only invite trusted players
- **Backups are unencrypted** - Secure your server

## 🚀 Next Steps

1. **Customize the DM personality** - Edit `bot.py` system prompt
2. **Add more commands** - `/inventory`, `/character`, `/map`, etc.
3. **Build a web dashboard** - See campaign progress visually
4. **Add voice integration** - Use TTS for dramatic DM moments
5. **Connect to external tools** - D&D Beyond, Roll20, etc.

## 🎭 Happy Gaming!

Made with 🧡 by Ian & Alice

---

*The adventure awaits! Every session is a new story.*
