#!/bin/bash
# VPS-Secure Installation Script
# This script downloads and executes the SSH security hardening script

set -e

SCRIPT_URL="https://raw.githubusercontent.com/Recoba86/VPS-Secure/main/secure-ssh.sh"
SCRIPT_NAME="secure-ssh.sh"

echo "[*] Downloading SSH security script..."

# Download the script
if command -v curl &> /dev/null; then
    curl -fsSL "$SCRIPT_URL" -o "$SCRIPT_NAME"
elif command -v wget &> /dev/null; then
    wget -q "$SCRIPT_URL" -O "$SCRIPT_NAME"
else
    echo "[!] Error: Neither curl nor wget found. Please install one of them."
    exit 1
fi

echo "[*] Setting executable permission..."
chmod +x "$SCRIPT_NAME"

echo "[*] Running the script..."
echo ""

# Execute the script
sudo "./$SCRIPT_NAME"

# Clean up
echo ""
echo "[*] Cleaning up temporary file..."
rm -f "$SCRIPT_NAME"

echo "[+] Done!"
