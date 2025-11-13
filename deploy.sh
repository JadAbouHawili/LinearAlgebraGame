#!/bin/bash
set -e

# Linear Algebra Game Docker Deployment Script for Duke VM
# This script sets up and runs the Linear Algebra Game using Docker

echo "=== Linear Algebra Game Docker Deployment Script ==="
echo "VM: vcm-48491.vm.duke.edu"
echo

# Configuration
GAME_DIR="$HOME/LinearAlgebraGame"
GAME_PORT=8080
CONTAINER_NAME="linear-algebra-game"
SERVICE_NAME="linear-algebra-game-docker"

echo "1. Installing Docker if not present..."
if ! command -v docker &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release
    
    # Add Docker's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up the repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker Engine
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add current user to docker group
    sudo usermod -aG docker $USER
    echo "Docker installed. You may need to log out and back in for group changes to take effect."
else
    echo "Docker already installed"
fi

echo "2. Installing Git if not present..."
sudo apt-get install -y git

echo "3. Cloning/updating game repository..."
if [ -d "$GAME_DIR" ]; then
    echo "Game directory exists, pulling latest changes..."
    cd "$GAME_DIR"
    git pull
else
    echo "Cloning game repository..."
    git clone https://github.com/ZRTMRH/LinearAlgebraGame.git "$GAME_DIR"
fi

cd "$GAME_DIR"

echo "4. Pulling lean4game Docker image..."
# Try pulling without sudo first (user might be in docker group)
if docker pull ghcr.io/leanprover-community/lean4game:latest 2>/dev/null; then
    echo "Image pulled successfully"
else
    echo "Trying with sudo..."
    if sudo docker pull ghcr.io/leanprover-community/lean4game:latest 2>/dev/null; then
        echo "Image pulled successfully with sudo"
    else
        echo "Failed to pull from ghcr.io, trying Docker Hub..."
        # Try alternative Docker Hub image if it exists
        if sudo docker pull leanprovercommunity/lean4game:latest 2>/dev/null; then
            echo "Using Docker Hub image"
            IMAGE_NAME="leanprovercommunity/lean4game:latest"
        else
            echo "Warning: Could not pull lean4game image. Will try to build locally."
            echo "You may need to authenticate with GitHub Container Registry."
            echo "Run: docker login ghcr.io -u YOUR_GITHUB_USERNAME"
            echo "Then re-run this script."
            exit 1
        fi
    fi
fi

# Set image name variable for later use
IMAGE_NAME="${IMAGE_NAME:-ghcr.io/leanprover-community/lean4game:latest}"

echo "5. Stopping any existing container..."
sudo docker stop $CONTAINER_NAME 2>/dev/null || true
sudo docker rm $CONTAINER_NAME 2>/dev/null || true

echo "6. Starting the game container..."
sudo docker run -d \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    -p $GAME_PORT:8080 \
    -v "$GAME_DIR":/game \
    $IMAGE_NAME

echo "7. Creating systemd service for Docker container management..."
sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null <<EOF
[Unit]
Description=Linear Algebra Game Docker Container
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/docker start $CONTAINER_NAME
ExecStop=/usr/bin/docker stop $CONTAINER_NAME
ExecReload=/usr/bin/docker restart $CONTAINER_NAME

[Install]
WantedBy=multi-user.target
EOF

echo "8. Enabling the service..."
sudo systemctl daemon-reload
sudo systemctl enable ${SERVICE_NAME}

echo "9. Setting up auto-restart after VM power-on..."
# The Docker container with --restart unless-stopped will automatically restart
# when Docker daemon starts, but we'll add extra insurance

sudo tee /usr/local/bin/ensure-game-running.sh > /dev/null <<EOF
#!/bin/bash
# Wait for Docker to be ready
sleep 20

# Check if container exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}\$"; then
    # Start the container if it's not running
    if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}\$"; then
        docker start ${CONTAINER_NAME}
    fi
else
    # Recreate the container if it doesn't exist
    cd $GAME_DIR
    docker run -d \
        --name $CONTAINER_NAME \
        --restart unless-stopped \
        -p $GAME_PORT:8080 \
        -v "$GAME_DIR":/game \
        ghcr.io/leanprover-community/lean4game:latest
fi
EOF

sudo chmod +x /usr/local/bin/ensure-game-running.sh

# Add to root's crontab for system startup
echo "@reboot /usr/local/bin/ensure-game-running.sh" | sudo crontab -

echo
echo "=== Deployment Complete ==="
echo "The Linear Algebra Game is now running on port $GAME_PORT"
echo "Access it at: http://vcm-48491.vm.duke.edu:$GAME_PORT"
echo
echo "Useful Docker commands:"
echo "  sudo docker logs $CONTAINER_NAME           # View logs"
echo "  sudo docker restart $CONTAINER_NAME        # Restart container"
echo "  sudo docker stop $CONTAINER_NAME           # Stop container"
echo "  sudo docker start $CONTAINER_NAME          # Start container"
echo "  sudo docker ps                             # List running containers"
echo
echo "Service commands:"
echo "  sudo systemctl status ${SERVICE_NAME}      # Check service status"
echo "  sudo systemctl restart ${SERVICE_NAME}     # Restart via systemd"
echo
echo "Note: The VM powers down at 6 AM daily. The container will auto-restart when powered back on."