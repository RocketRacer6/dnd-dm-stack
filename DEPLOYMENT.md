# 🚀 Deployment Guide - Oracle Server

## ✅ Status
- **GitHub Repository:** https://github.com/RocketRacer6/dnd-dm-stack
- **Status:** Pushed and ready
- **Token Expiry:** May 13, 2026 (reminder set for May 10)

---

## 📥 Deploy to Oracle Server

### Step 1: Transfer Files to Oracle

**Option A: Use deployment helper (Easiest)**
```bash
# On local machine (where you have the stack)
cd /root/.openclaw/workspace/dnd-dm-stack
./deploy-oracle.sh
# Oracle server details are pre-configured (opc@64.181.201.232)
```

**Option B: Manual transfer**
```bash
# SSH into your Oracle server
ssh ubuntu@your-oracle-ip

# Clone the repo
git clone https://github.com/RocketRacer6/dnd-dm-stack.git
cd dnd-dm-stack
```

### Step 2: Configure Environment
```bash
# Edit env file (Groq key is already configured!)
nano .env
```

**Add these values:**
```bash
# Telegram Bot Token (from @BotFather) - ADD THIS
TELEGRAM_BOT_TOKEN=your_bot_token_here

# Groq API Key - ALREADY CONFIGURED ✅
# (Pre-configured in .env file - ready to use!)

# Database Password - CHANGE FROM DEFAULT! ⚠️
DB_PASSWORD=your_secure_password_here
```

### Step 3: Start the Stack
```bash
# Run setup script
./setup.sh
```

That's it! The bot will:
- Build Docker images
- Start PostgreSQL
- Start Telegram bot
- Configure auto-backups

---

## ✅ Pre-Configured

**Groq API Key:** Already configured in `.env` file
- Ready to use LLaMA 3.1 70B model
- Free tier, fast inference
- No action needed

**Still need:**
- Telegram Bot Token (from @BotFather)
- Change `DB_PASSWORD` from default

---

## 🔑 GitHub Token Renewal

**Your GitHub token expires: May 13, 2026**

### Automatic Reminder
A reminder is scheduled for **May 10, 2026** (3 days before expiry).

### Manual Renewal Steps
```bash
1. Go to https://github.com/settings/tokens
2. Click "Generate new token" → "Generate new token (classic)"
3. Name: "D&D Bot Deployment (Renewed)"
4. Check "repo" permissions
5. Click "Generate token"
6. Copy the new token

# Update on local machine
nano /root/.openclaw/workspace/.env.github
# Replace GITHUB_TOKEN= with new token

# Update reminder cron
# Contact Alice to renew the reminder for another 90 days
```

### Why Can't This Be Auto-Renewed?
GitHub Personal Access Tokens cannot be automatically refreshed. The token is a secret that must be manually regenerated. This is a security feature - tokens expire to limit the window of compromise.

---

## 🧪 Verify Deployment

On Oracle server:
```bash
# Check all containers running
docker-compose ps

# Check bot logs
docker-compose logs -f bot

# Test bot
# Open Telegram, search for @DnDgameBot, send /start
```

---

## 📊 Daily Operations

### Check Stack Status
```bash
docker-compose ps
```

### View Logs
```bash
# All services
docker-compose logs -f

# Bot only
docker-compose logs -f bot

# Database only
docker-compose logs -f db

# Backup service
docker-compose logs -f backup
```

### Restart Services
```bash
# Restart entire stack
docker-compose restart

# Restart bot only
docker-compose restart bot
```

### Manual Backup
```bash
docker-compose exec backup /scripts/backup.sh
```

### Stop Stack
```bash
docker-compose down
```

### Stop + Delete Volumes (⚠️ DELETES DATA)
```bash
docker-compose down -v
```

---

## 💾 Backups

**Location:** `/root/dnd-dm-stack/backups/` (on Oracle server)

**Naming:**
- Database: `dnd_backup_YYYY-MM-DD_HHMMSS.sql.gz`
- State: `dnd_state_YYYY-MM-DD_HHMMSS.tar.gz`

**Retention:** 7 days (auto-deleted)

**Automatic Schedule:** 23:59:59 CST (05:59:59 UTC)

---

## 🔄 Updates

### To Pull Changes from GitHub
```bash
cd dnd-dm-stack
git pull origin master
docker-compose down
docker-compose up -d --build
```

### To Push Changes from Development
```bash
# Make changes locally
git add .
git commit -m "Description of changes"
git push origin master

# Then on Oracle server, pull and rebuild
cd dnd-dm-stack
git pull origin master
docker-compose down
docker-compose up -d --build
```

---

## 🐛 Troubleshooting

### Bot Not Responding
```bash
# Check bot is running
docker-compose ps bot

# Check logs
docker-compose logs bot

# Restart bot
docker-compose restart bot

# Verify token
docker-compose exec bot env | grep TELEGRAM_BOT_TOKEN
```

### Database Connection Issues
```bash
# Check DB health
docker-compose ps db

# Test connection
docker-compose exec db pg_isready -U dnd_master

# Restart DB
docker-compose restart db
```

### Tar.gz Extraction Failed
If you see "gzip: stdin: unexpected end of file":
```bash
# The tarball was corrupted or incomplete. Re-run deployment:

# On local machine
cd /root/.openclaw/workspace/dnd-dm-stack
./deploy-oracle.sh

# Then on Oracle server
ssh -i /root/ssh_key.txt opc@64.181.201.232
tar -xzf dnd-dm-stack.tar.gz
cd dnd-dm-stack
./setup.sh
```

### Backup Not Running
```bash
# Check backup container
docker-compose ps backup

# Check backup logs
docker-compose logs backup

# Manually trigger backup
docker-compose exec backup /scripts/backup.sh
```

---

## 📞 Need Help?

- **Check README.md** - Full documentation
- **Check QUICKSTART.md** - Quick reference
- **View logs** - `docker-compose logs -f`
- **Ask Alice** - I'm here to help! 🧡

---

**Happy Gaming! 🎲**
