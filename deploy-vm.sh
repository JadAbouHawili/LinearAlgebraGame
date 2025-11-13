#!/bin/bash
set -e

# Linear Algebra Game Docker Compose Deployment for Duke VM
# Uses the same devcontainer setup as local development

echo "=== Linear Algebra Game VM Deployment (Docker Compose) ==="
echo "VM: vcm-48491.vm.duke.edu"
echo

# Configuration
GAME_DIR="$HOME/LinearAlgebraGame"
GAME_PORT=3000

echo "1. Checking Docker and Docker Compose..."
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please run the Docker installation first."
    echo "You can use: curl -fsSL https://get.docker.com | sh"
    echo "Then: sudo usermod -aG docker $USER"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo "Docker Compose is not installed or not working."
    exit 1
fi

echo "2. Ensuring we're in the game directory..."
cd "$GAME_DIR"

echo "3. Building and starting the game container..."
echo "This will take 2-15 minutes on first run..."

# Use docker compose to build and run
cd .devcontainer
sudo docker compose down 2>/dev/null || true
sudo docker compose build
sudo docker compose up -d

echo "4. Waiting for services to start..."
echo "The game server will be starting in the background."
echo "This can take a few minutes to complete the initial setup."

# Create a systemd service for auto-restart
echo "5. Creating systemd service for auto-restart after VM reboot..."
sudo tee /etc/systemd/system/linear-algebra-game.service > /dev/null <<EOF
[Unit]
Description=Linear Algebra Game Docker Compose
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$GAME_DIR/.devcontainer
ExecStart=/usr/bin/docker compose up -d
ExecStop=/usr/bin/docker compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable linear-algebra-game.service

echo "6. Setting up monitoring script..."
sudo tee /usr/local/bin/check-game-status.sh > /dev/null <<'EOF'
#!/bin/bash
echo "Checking Linear Algebra Game status..."
cd /home/rz169/LinearAlgebraGame/.devcontainer

# Check if containers are running
if docker compose ps | grep -q "Up"; then
    echo "✓ Game container is running"
    echo "Checking if game server is responding..."
    
    # Try to connect to the game server
    if curl -s http://localhost:3000 > /dev/null; then
        echo "✓ Game server is responding on port 3000"
        echo "Game is accessible at: http://vcm-48491.vm.duke.edu:3000"
    else
        echo "⚠ Game server is not responding yet. It may still be starting up."
        echo "Check logs with: cd ~/.devcontainer && docker compose logs"
    fi
else
    echo "✗ Game container is not running"
    echo "Start it with: cd ~/.devcontainer && docker compose up -d"
fi
EOF
sudo chmod +x /usr/local/bin/check-game-status.sh

echo
echo "=== Deployment Started ==="
echo
echo "The game is starting up. This process takes 2-15 minutes."
echo "Check status with: check-game-status.sh"
echo "View logs with: cd .devcontainer && sudo docker compose logs -f"
echo
echo "Once ready, access your game at:"
echo "  http://vcm-48491.vm.duke.edu:3000"
echo "  or locally: http://localhost:3000"
echo
echo "The game will auto-restart after VM reboots."
echo
echo "Useful commands:"
echo "  check-game-status.sh                    # Check if game is running"
echo "  cd .devcontainer && sudo docker compose logs -f  # View logs"
echo "  cd .devcontainer && sudo docker compose restart  # Restart game"
echo "  cd .devcontainer && sudo docker compose down     # Stop game"
echo "  cd .devcontainer && sudo docker compose up -d    # Start game"