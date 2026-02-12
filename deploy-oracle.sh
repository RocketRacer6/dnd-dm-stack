#!/bin/bash
set -e

echo "🚀 D&D AI DM - Oracle Deployment Helper"
echo "========================================="
echo ""
echo "This script helps transfer the stack to your Oracle server."
echo ""
echo "📋 Prerequisites:"
echo "  1. You have SSH access to your Oracle server"
echo "  2. You have a Telegram Bot Token (get from @BotFather)"
echo "  3. Groq API key is already configured ✅"
echo ""

# Prompt for Oracle server details
read -p "🖥️  Oracle server username (default: ubuntu): " ORACLE_USER
ORACLE_USER=${ORACLE_USER:-ubuntu}

read -p "🌐 Oracle server IP address: " ORACLE_IP

if [ -z "$ORACLE_IP" ]; then
    echo "❌ Oracle server IP is required!"
    exit 1
fi

echo ""
echo "📤 Transferring files to $ORACLE_USER@$ORACLE_IP..."

# Create tarball with everything except backups/data
tar -czf dnd-dm-stack.tar.gz \
    --exclude='backups/*' \
    --exclude='data/*' \
    --exclude='.git' \
    .

# Transfer via scp
scp dnd-dm-stack.tar.gz $ORACLE_USER@$ORACLE_IP:~/

echo "✅ Files transferred!"
echo ""
echo "📥 On Oracle server, run these commands:"
echo ""
echo "   # Extract files"
echo "   tar -xzf dnd-dm-stack.tar.gz"
echo ""
echo "   # Enter directory"
echo "   cd dnd-dm-stack"
echo ""
echo "   # Edit .env to add Telegram Bot Token"
echo "   nano .env"
echo "   # Change: TELEGRAM_BOT_TOKEN=YOUR_TELEGRAM_BOT_TOKEN_HERE"
echo "   # To: TELEGRAM_BOT_TOKEN=your_actual_token_here"
echo ""
echo "   # Also change DB_PASSWORD from default!"
echo ""
echo "   # Start the stack"
echo "   ./setup.sh"
echo ""
echo "🧹 Cleaning up local tarball..."
rm dnd-dm-stack.tar.gz

echo ""
echo "✅ Deployment files ready!"
echo ""
echo "🎲 Next step: SSH into Oracle server and run the commands above!"
