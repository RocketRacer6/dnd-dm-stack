# 🎲 D&D AI DM - Quick Start for Ian

## 3 Steps to Gaming Bliss

### 1️⃣ Get Your Bot Token (Telegram)
- Open Telegram, search **@BotFather**
- Send `/newbot`
- Name it (e.g., "Ian's D&D DM")
- Copy the **API token**
- Paste it into `.env` file

### 2️⃣ Get Your AI Key (Groq - FREE & FAST)
- Go to **console.groq.com**
- Sign up (no credit card needed)
- Generate an API key
- Paste it into `.env` file

### 3️⃣ Start the Stack
```bash
cd /root/.openclaw/workspace/dnd-dm-stack
./setup.sh
```

---

## What Happens Every Night?

**23:59:59 CST** → Automatic backup:
- Bot stops (clean state)
- DB dumps to `/backups/`
- Game state archived
- Old backups (7+ days) deleted
- Bot restarts fresh

---

## First Game

1. **Open Telegram**, find your bot
2. Send `/start`
3. Create campaign: `/newgame The Lost Mine of Phandelver`
4. Roll dice: `/roll d20`
5. Play: `/dm I want to search the room`

---

## Daily Commands

```bash
# Check status
docker-compose ps

# View logs
docker-compose logs -f bot

# Restart bot
docker-compose restart bot

# Manual backup
docker-compose exec backup /scripts/backup.sh
```

---

## Backup Location

All backups in: `/root/.openclaw/workspace/dnd-dm-stack/backups/`

Format: `dnd_backup_YYYY-MM-DD_HHMMSS.sql.gz`

---

## That's It! 🎮

You're ready to run D&D sessions from Telegram. The AI DM handles the story, you and Jordyn handle the dice rolling and choices.

**Auto-backup means you never lose progress.**

---

Need more? Check `README.md` for full documentation.

Made with 🧡
