# ✅ D&D AI DM - Ready to Deploy!

## All Credentials Configured ✅

- **Telegram Bot Token:** `8540431490:AAGifeB8iG5bc78aOaqMFYLbWy0iEncow0E`
- **Groq API Key:** Configured and ready
- **Database Password:** Updated from default

---

## 🚀 One-Step Deployment to Oracle

Run this on your local machine (where you have the stack):

```bash
cd /root/.openclaw/workspace/dnd-dm-stack
./deploy-oracle.sh
```

**Then follow prompts to:**
1. Enter Oracle server username (default: ubuntu)
2. Enter Oracle server IP address

**Script will:**
- Transfer all files to Oracle server
- Display exact commands to run on Oracle
- Clean up temporary files

---

## 📥 On Oracle Server (After Transfer)

```bash
# Extract files
tar -xzf dnd-dm-stack.tar.gz
cd dnd-dm-stack

# All credentials are already configured! ✅
# Just verify if needed:
nano .env

# Start the stack
./setup.sh
```

---

## 🎲 First Game

Once stack is running:

1. **Open Telegram** and search for **@DnDgameBot**
2. **Send:** `/start`
3. **Create campaign:** `/newgame The Lost Mine of Phandelver`
4. **Roll dice:** `/roll d20`
5. **Play:** `/dm I want to search the room`

---

## 📊 Verify Everything Works

```bash
# Check all containers
docker-compose ps

# View bot logs
docker-compose logs -f bot

# Test bot response
# Open Telegram, search for @DnDgameBot, send /help
```

---

## 🔑 Security Notes

- `.env` file contains secrets - **NEVER** commit to GitHub
- `.env` is in `.gitignore` (safe)
- Database password changed from default
- Telegram bot token configured
- Groq API key configured

---

## 🆘 Troubleshooting

### Bot Not Responding
```bash
docker-compose logs bot
docker-compose restart bot
```

### Container Won't Start
```bash
docker-compose ps
docker-compose logs db
docker-compose restart db
```

### Check All Status
```bash
docker-compose ps
docker-compose logs
```

---

**Ready to roll the dice! 🎲🧡**
