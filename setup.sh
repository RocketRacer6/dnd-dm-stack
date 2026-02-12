#!/bin/bash
set -e

echo "🎲 D&D AI DM Stack Setup"
echo "========================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed (old or new version)
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
    echo "✅ Docker Compose (standalone) found"
elif docker compose version &> /dev/null 2>&1; then
    DOCKER_COMPOSE="docker compose"
    echo "✅ Docker Compose (plugin) found"
else
    echo "❌ Docker Compose is not installed."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

echo ""

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp .env.example .env
    echo "✅ .env file created"
    echo ""
    echo "⚠️  IMPORTANT: Edit .env and add your:"
    echo "   - TELEGRAM_BOT_TOKEN (get from @BotFather on Telegram)"
    echo "   - AI_API_KEY (get from console.groq.com or use your cluster)"
    echo "   - DB_PASSWORD (change from default!)"
    echo ""
    echo "   Run: nano .env"
    echo ""
else
    echo "✅ .env file already exists"
    echo ""
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p data backups
echo "✅ Directories ready"
echo ""

# Ask if ready to build
read -p "Ready to build and start the stack? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔨 Building Docker images..."
    $DOCKER_COMPOSE build

    echo ""
    echo "🚀 Starting services..."
    $DOCKER_COMPOSE up -d

    echo ""
    echo "⏳ Waiting for services to be healthy..."
    sleep 5

    echo ""
    echo "✅ Setup complete!"
    echo ""
    echo "📊 Container Status:"
    $DOCKER_COMPOSE ps
    echo ""
    echo "📝 Next Steps:"
    echo "   1. Find your bot on Telegram and send /start"
    echo "   2. Create a campaign: /newgame <name>"
    echo "   3. Roll some dice: /roll d20"
    echo ""
    echo "📖 View logs: $DOCKER_COMPOSE logs -f bot"
    echo ""
else
    echo ""
    echo "⏸️  Setup paused. Edit .env and run:"
    echo "   $DOCKER_COMPOSE up -d --build"
fi
