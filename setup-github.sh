#!/bin/bash
set -e

echo "🔧 Setting up GitHub Repository for D&D AI DM Stack"
echo "===================================================="
echo ""

# Load GitHub credentials
source /root/.openclaw/workspace/.env.github

if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_PASSWORD" ]; then
    echo "❌ GitHub credentials not found!"
    exit 1
fi

# Repo name
REPO_NAME="dnd-dm-stack"
REPO_DESC="D&D AI Dungeon Master Telegram Bot with auto-backup system"

echo "📦 Repository: $REPO_NAME"
echo "👤 User: $GITHUB_USERNAME"
echo ""

# Initialize git repo if not already initialized
cd /root/.openclaw/workspace/dnd-dm-stack

if [ ! -d .git ]; then
    echo "🔨 Initializing git repository..."
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

# Create .gitignore
echo "📝 Creating .gitignore..."
cat > .gitignore << 'EOF'
# Environment variables (contain secrets)
.env

# Python cache
__pycache__/
*.pyc
*.pyo
*.pyd
.Python

# Backup files
backups/*.sql.gz
backups/*.tar.gz

# Data directories (runtime data)
data/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
EOF

echo "✅ .gitignore created"

# Add all files
echo "📦 Adding files to git..."
git add .
echo "✅ Files added"

# Initial commit
echo "💾 Creating initial commit..."
git commit -m "Initial commit: D&D AI DM Stack with auto-backup"
echo "✅ Commit created"

# Create GitHub repository via API
echo "🌐 Creating GitHub repository..."
RESPONSE=$(curl -s -X POST \
    -u "$GITHUB_USERNAME:$GITHUB_PASSWORD" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/user/repos" \
    -d "{
        \"name\": \"$REPO_NAME\",
        \"description\": \"$REPO_DESC\",
        \"private\": false,
        \"auto_init\": false
    }")

# Check if repo was created
if echo "$RESPONSE" | grep -q '"id"'; then
    CLONE_URL="https://$GITHUB_USERNAME:$GITHUB_PASSWORD@github.com/$GITHUB_USERNAME/$REPO_NAME.git"
    echo "✅ Repository created: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
else
    echo "❌ Failed to create repository"
    echo "Response: $RESPONSE"
    exit 1
fi

# Add remote
echo "🔗 Adding remote..."
git remote add origin "$CLONE_URL" 2>/dev/null || git remote set-url origin "$CLONE_URL"
echo "✅ Remote configured"

# Push to GitHub
echo "🚀 Pushing to GitHub..."
git push -u origin master 2>/dev/null || git push -u origin main
echo "✅ Push complete!"

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "📍 Repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo ""
echo "📥 On Oracle Server, run:"
echo "   git clone https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
echo "   cd $REPO_NAME"
echo "   cp .env.example .env"
echo "   nano .env  # Add your API keys"
echo "   ./setup.sh"
echo ""
