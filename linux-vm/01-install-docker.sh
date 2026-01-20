#!/bin/bash

# Install Docker using the convenience script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Start and enable Docker service (usually already done by the script)
sudo systemctl start docker
sudo systemctl enable docker

# Add current user to docker group to run docker without sudo
sudo usermod -aG docker $USER

# Verify installation
docker --version

echo ""
echo "Docker installed successfully!"
echo ""
echo "IMPORTANT: You need to refresh your user groups for docker to work without sudo."
echo "Choose one of the following options:"
echo ""
echo "  1. Run 'newgrp docker' now (affects current terminal only)"
echo "  2. Log out and log back in (recommended for permanent effect)"
echo ""
echo "After refreshing groups, proceed to the next step:"
echo "  ./02-login-registry.sh"
echo ""

# Optionally activate the docker group in the current shell
read -p "Do you want to run 'newgrp docker' now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Starting new shell with docker group activated..."
    echo "You can now proceed with: ./02-login-registry.sh"
    echo "Type 'exit' to return to your previous shell when done."
    echo ""
    exec newgrp docker
else
    echo ""
    echo "Skipped. Remember to either run 'newgrp docker' or log out and back in before continuing."
fi