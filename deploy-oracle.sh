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
echo "📦 Creating tarball..."
tar -czf dnd-dm-stack.tar.gz \
    --exclude='backups/*' \
    --exclude='data/*' \
    --exclude='.git' \
    .

# Verify tarball was created
if [ ! -f dnd-dm-stack.tar.gz ]; then
    echo "❌ Failed to create tarball!"
    exit 1
fi

# Show tarball size
TAR_SIZE=$(ls -lh dnd-dm-stack.tar.gz | awk '{print $5}')
echo "✅ Tarball created (size: $TAR_SIZE)"
echo ""

# Transfer via scp
echo "📤 Transferring to Oracle server..."
scp -i $SSH_KEY dnd-dm-stack.tar.gz $ORACLE_USER@$ORACLE_IP:~/

# Verify transfer completed
if [ $? -eq 0 ]; then
    echo "✅ Transfer completed successfully"
else
    echo "❌ Transfer failed!"
    exit 1
fi

echo "✅ Files transferred!"
echo ""
echo "📥 On Oracle server, run these commands:"
echo ""
echo "   # SSH into Oracle server"
echo "   ssh -i $SSH_KEY $ORACLE_USER@$ORACLE_IP"
echo ""
echo "   # Clean up old directories"
echo "   rm -rf dnd-dm-stack dnd-dm-ai-dm bot compose dnd-dm dnd-dm-stack.tar.gz"
echo ""
echo "   # Clone repo (specify main branch!)"
echo "   git clone -b main https://github.com/RocketRacer6/dnd-dm-stack.git"
echo ""
echo "   # Enter directory"
echo "   cd dnd-dm-stack"
echo ""
echo "   # Start stack (all credentials already configured!)"
echo "   ./setup.sh"
echo ""
echo ""
echo "🧹 Cleaning up local tarball..."
rm -f dnd-dm-stack.tar.gz
echo "✅ Cleanup complete"
echo ""
echo "🎲 Next step: SSH into Oracle server and run the commands above!"
