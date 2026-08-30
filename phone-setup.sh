#!/bin/bash
# Harley Phone Setup - Run this in Termux
# Usage: bash phone-setup.sh

echo "=== HARLEY PHONE SETUP ==="
echo "Downloading correct opencode config..."

# Create config directory
mkdir -p ~/.config/opencode

# Download the config
curl -fsSL "https://raw.githubusercontent.com/JimmyLee80601/harley-opencode-config/main/.config/opencode/opencode.json" -o ~/.config/opencode/opencode.json

if [ $? -eq 0 ]; then
    echo "Config downloaded successfully!"
    echo ""
    echo "Verifying..."
    cat ~/.config/opencode/opencode.json | head -5
    echo "..."
    echo ""
    echo "=== SETUP COMPLETE ==="
    echo "Restart opencode to use Dell's Ollama models"
    echo "Models available: harley:latest, qwen2.5:7b, Qwen3.5-4B-Uncensored"
else
    echo "Download failed. Check your internet connection."
fi
