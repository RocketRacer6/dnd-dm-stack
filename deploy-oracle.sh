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

# Oracle server details (pre-configured)
ORACLE_USER="opc"
ORACLE_IP="64.181.201.232"
SSH_KEY="/root/ssh_key.txt"

echo "🖥️  Oracle Server:"
echo "   User: $ORACLE_USER"
echo "   IP: $ORACLE_IP"
echo "   SSH Key: $SSH_KEY"
echo ""
echo "📤 Transferring files to $ORACLE_USER@$ORACLE_IP..."

# Create tarball with everything except backups/data
tar -czf dnd-dm-stack.tar.gz \
    --exclude='backups/*' \
    --exclude='data/*' \
    --exclude='.git' \
    .

# Transfer via scp
scp -i $SSH_KEY dnd-dm-stack.tar.gz $ORACLE_USER@$ORACLE_IP:~/

echo "✅ Files transferred!"
echo ""
echo "📥 On Oracle server, run these commands:"
echo ""
echo "   # SSH into Oracle server"
echo "   ssh -i $SSH_KEY $ORACLE_USER@$ORACLE_IP"
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
