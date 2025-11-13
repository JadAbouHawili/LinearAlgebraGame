# Linear Algebra Game - Duke VM Deployment Guide

## VM Details
- **Hostname**: vcm-48491.vm.duke.edu
- **OS**: Ubuntu 22.04
- **Resources**: 4 GB RAM, 2 processors
- **Access**: SSH with `ssh rz169@vcm-48491.vm.duke.edu`
- **Important**: VM powers down daily at 6:00 AM and needs manual restart via VCM portal

## Deployment Method: VSCode Dev Containers

This deployment uses the recommended VSCode Dev Containers approach from the [lean4game documentation](https://github.com/leanprover-community/lean4game/blob/main/doc/running_locally.md).

### 1. Initial Setup (First Time Only)

SSH into your VM:
```bash
ssh rz169@vcm-48491.vm.duke.edu
```

Install Docker:
```bash
# Install Docker engine following official instructions
sudo apt-get update
sudo apt-get install docker.io
# Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect
```

Install VSCode Server (for remote development):
```bash
# VSCode Server will be installed automatically when you connect via Remote SSH
```

Clone the game repository:
```bash
git clone https://github.com/yourusername/LinearAlgebraGame.git
cd LinearAlgebraGame
```

### 2. Running the Game with Dev Container

Connect to the VM using VSCode Remote SSH:
1. Install "Remote - SSH" extension in your local VSCode
2. Connect to `rz169@vcm-48491.vm.duke.edu`
3. Open the `/home/rz169/LinearAlgebraGame` folder
4. Install the Dev Containers extension on the remote VSCode
5. When prompted, click "Reopen in Container" (or use Command Palette: "Dev Containers: Reopen in Container")
6. First startup takes 2-15 minutes while building the container
7. The game will automatically start on port 3000

### 3. Access the Game

Once the Dev Container is running, access your game at:
```
http://vcm-48491.vm.duke.edu:3000/
```

Or directly to the game:
```
http://vcm-48491.vm.duke.edu:3000/#/g/local/game
```

## Managing the Dev Container

### Check Container Status
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a
```

### View Container Logs
```bash
# Find the container name/ID first
docker ps
# Then view logs
docker logs [container-id]
```

### Restart the Dev Container
From VSCode:
1. Open Command Palette (Ctrl+Shift+P)
2. Run "Dev Containers: Rebuild Container"

From terminal:
```bash
# Find and restart the container
docker restart [container-id]
```

## Updating the Game

To update your game with new changes:

1. **In VSCode Dev Container terminal**:
   ```bash
   git pull  # Get latest changes
   lake build  # Rebuild the game
   ```

2. **Reload the browser** to see changes at http://vcm-48491.vm.duke.edu:3000/

Alternatively, rebuild the entire container:
- Command Palette: "Dev Containers: Rebuild Container"

## Handling Daily VM Shutdowns

The VM automatically shuts down at 6:00 AM daily. To restart:

1. Go to your VCM reservation portal
2. Click "Power On" for your VM
3. Wait 1-2 minutes for boot
4. Reconnect via VSCode Remote SSH
5. Reopen the folder in Dev Container when prompted
6. The game will start automatically on port 3000

To verify after power-on:
```bash
ssh rz169@vcm-48491.vm.duke.edu
docker ps  # Should show the Dev Container running
```

## Backup Strategy

**Important**: The VM is NOT backed up and will be destroyed at semester end!

### Recommended Backup Approach

1. **Use Git for all changes**:
   ```bash
   cd ~/LinearAlgebraGame
   git add .
   git commit -m "Your changes"
   git push origin main
   ```

2. **Regular backup to your local machine**:
   ```bash
   # From your local machine
   rsync -avz rz169@vcm-48491.vm.duke.edu:~/LinearAlgebraGame/ ~/LinearAlgebraGame-backup/
   ```

3. **Backup game progress/data** (if applicable):
   ```bash
   # On the VM
   tar -czf game-backup-$(date +%Y%m%d).tar.gz ~/LinearAlgebraGame
   # Copy to your Duke network storage or local machine
   ```

## Troubleshooting

### Dev Container won't start
```bash
# Check Docker status
sudo systemctl status docker

# Check for port conflicts
sudo netstat -tulpn | grep 3000

# Clean up old containers
docker container prune

# In VSCode, try:
# 1. Command Palette: "Dev Containers: Rebuild Container Without Cache"
# 2. If that fails, manually remove containers and rebuild
```

### Can't access the game from browser
1. Verify container is running: `docker ps`
2. Check firewall isn't blocking port 3000
3. Try accessing locally first: `curl http://localhost:3000`
4. Ensure the Dev Container is fully started (check VSCode terminal for completion)

### After VM restart, game not accessible
```bash
# SSH into VM
ssh rz169@vcm-48491.vm.duke.edu

# Check Docker service
sudo systemctl status docker

# Reconnect via VSCode Remote SSH and reopen in Dev Container
# The container should start automatically
```

## Development Workflow

For active development:

1. **Connect to VM** via VSCode Remote SSH
2. **Open in Dev Container** when prompted
3. **Make changes** directly in the Dev Container
4. **Build changes**:
   ```bash
   lake build  # In the Dev Container terminal
   ```
5. **Test changes** by refreshing browser at http://vcm-48491.vm.duke.edu:3000/
6. **Commit and push** to Git for backup:
   ```bash
   git add .
   git commit -m "Your changes"
   git push origin main
   ```

## Required Extensions

For development, ensure you have:

1. **Local VSCode**:
   - "Remote - SSH" extension
   - "Dev Containers" extension (optional, for local testing)

2. **Remote VSCode (on VM)**:
   - "Dev Containers" extension (will be prompted to install)
   - Lean 4 extension (installed automatically in Dev Container)

## Important Reminders

- **VM is temporary**: Will be destroyed at semester end
- **No backups**: You must manage your own backups
- **Daily shutdowns**: Plan around 6 AM downtime
- **Use version control**: Always commit and push changes to Git
- **Monitor resources**: With only 4GB RAM, monitor Docker memory usage
- **Port 3000**: The game runs on port 3000, not 8080
- **Dev Container**: Uses VSCode Dev Containers for consistent environment

## Support

- VCM Issues: Contact Duke OIT
- Game Issues: Check lean4game documentation
- Docker Issues: Check Dev Container logs in VSCode Output panel
- lean4game Issues: Check [lean4game documentation](https://github.com/leanprover-community/lean4game/blob/main/doc/running_locally.md)