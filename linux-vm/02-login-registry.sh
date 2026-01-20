#!/bin/bash

echo "Logging into Azure Container Registry..."
echo ""
docker login kanvaimages.azurecr.io -u KanvaPilot

if [ $? -eq 0 ]; then
    echo ""
    echo "Login successful!"
    echo "You can now proceed to the next step."
else
    echo ""
    echo "Login failed. Please check your credentials and try again."
    exit 1
fi
