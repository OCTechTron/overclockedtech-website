#!/bin/bash
# ============================================================================
# OC-AI Deployment Installer
# Overclocked Technologies — Mac Mini AI Assistant Setup
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "============================================"
echo "  🔵 Overclocked Technologies — OC-AI"
echo "  Mac Mini AI Assistant Deployment"
echo "============================================"
echo ""

# Create deployment directory
DEPLOY_DIR="$HOME/oc-ai-deployment"
mkdir -p "$DEPLOY_DIR"
cd "$DEPLOY_DIR"

echo -e "${BLUE}📥 Downloading deployment scripts...${NC}"

# Download all deployment scripts
curl -fsSL https://raw.githubusercontent.com/OCTechTron/overclockedtech-website/main/deploy/01-macos-prep.sh > 01-macos-prep.sh
curl -fsSL https://raw.githubusercontent.com/OCTechTron/overclockedtech-website/main/deploy/02-openclaw-install.sh > 02-openclaw-install.sh
curl -fsSL https://raw.githubusercontent.com/OCTechTron/overclockedtech-website/main/deploy/03-telegram-setup.sh > 03-telegram-setup.sh
curl -fsSL https://raw.githubusercontent.com/OCTechTron/overclockedtech-website/main/deploy/04-gmail-setup.sh > 04-gmail-setup.sh
curl -fsSL https://raw.githubusercontent.com/OCTechTron/overclockedtech-website/main/deploy/05-personalize.sh > 05-personalize.sh
curl -fsSL https://raw.githubusercontent.com/OCTechTron/overclockedtech-website/main/deploy/06-harden.sh > 06-harden.sh
curl -fsSL https://raw.githubusercontent.com/OCTechTron/overclockedtech-website/main/deploy/README.md > README.md

# Make scripts executable
chmod +x *.sh

echo -e "${GREEN}✅ Deployment scripts downloaded successfully!${NC}"
echo ""
echo "📂 Scripts location: $DEPLOY_DIR"
echo ""
echo "🚀 Next steps:"
echo "  1. cd $DEPLOY_DIR"
echo "  2. ./01-macos-prep.sh"
echo "  3. Follow the deployment guide"
echo ""
echo "📖 Full guide: cat README.md"
echo ""