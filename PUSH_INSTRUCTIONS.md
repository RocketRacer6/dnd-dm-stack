# 🚀 Push to GitHub - Manual Steps

## Issue with API Authentication

GitHub now requires a **Personal Access Token** for API authentication, not your password.

## Two Options:

### Option 1: Create Repo Manually (Recommended)

1. Go to https://github.com/new
2. Repository name: `dnd-dm-stack`
3. Description: `D&D AI Dungeon Master Telegram Bot with auto-backup system`
4. Make it **Public** (or Private if you prefer)
5. Click **Create repository**

Then push your local files:
```bash
cd /root/.openclaw/workspace/dnd-dm-stack

# Add remote (replace with your repo URL)
git remote add origin https://github.com/RocketRacer6/dnd-dm-stack.git

# Push
git push -u origin master
```

### Option 2: Create Personal Access Token

1. Go to https://github.com/settings/tokens
2. Click **Generate new token** → **Generate new token (classic)**
3. Give it a name (e.g., "D&D Bot Deployment")
4. Check **repo** permissions
5. Click **Generate token**
6. **Copy the token** (you won't see it again!)

Then update `.env.github`:
```bash
GITHUB_USERNAME=RocketRacer6
GITHUB_PASSWORD=ghp_YOUR_TOKEN_HERE
```

And run the setup script again:
```bash
./setup-github.sh
```

---

## On Oracle Server (After Push)

```bash
# Clone the repo
git clone https://github.com/RocketRacer6/dnd-dm-stack.git
cd dnd-dm-stack

# Create env file
cp .env.example .env
nano .env

# Add your:
# - TELEGRAM_BOT_TOKEN (from @BotFather)
# - AI_API_KEY (from Groq)
# - DB_PASSWORD (change from default!)

# Start the stack
./setup.sh
```

---

## Current Status

✅ Git repository initialized locally
✅ Initial commit created
✅ All files ready to push

⏳ Waiting for GitHub repo to be created

---

Let me know which option you choose, and I'll help with the next step! 🧡
