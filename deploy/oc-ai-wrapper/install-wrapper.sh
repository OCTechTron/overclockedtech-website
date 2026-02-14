#!/bin/bash
# ============================================================================
# install-wrapper.sh — Install OC-AI branding wrapper
# Run during deployment after OpenClaw is installed.
# ============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Installing OC-AI wrapper...${NC}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install the ocai CLI command
if [[ -w /usr/local/bin ]]; then
    cp "$SCRIPT_DIR/ocai" /usr/local/bin/ocai
    chmod +x /usr/local/bin/ocai
    echo -e "${GREEN}  ✓ ocai installed to /usr/local/bin/ocai${NC}"
else
    mkdir -p "$HOME/.local/bin"
    cp "$SCRIPT_DIR/ocai" "$HOME/.local/bin/ocai"
    chmod +x "$HOME/.local/bin/ocai"
    
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
    fi
    echo -e "${GREEN}  ✓ ocai installed to ~/.local/bin/ocai${NC}"
fi

# Add a shell alias so 'ocai' always works
grep -q "alias ocai=" ~/.zprofile 2>/dev/null || {
    echo '# OC-AI CLI' >> ~/.zprofile
    echo 'alias ocai="ocai"' >> ~/.zprofile
}

echo -e "${GREEN}  ✓ OC-AI wrapper installed${NC}"
echo ""
echo "  Run 'ocai status' to verify."
echo ""
