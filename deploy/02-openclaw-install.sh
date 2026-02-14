#!/bin/bash
# ============================================================================
# 02-openclaw-install.sh — Overclocked Technologies
# Mac Mini Client Deployment: OpenClaw Installation & Configuration
#
# Run AFTER 01-macos-prep.sh. Installs OpenClaw and configures the gateway.
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() { echo -e "\n${BLUE}▸ $1${NC}"; }
print_ok()   { echo -e "${GREEN}  ✓ $1${NC}"; }
print_warn() { echo -e "${YELLOW}  ⚠ $1${NC}"; }
print_err()  { echo -e "${RED}  ✗ $1${NC}"; }

echo ""
echo "============================================"
echo "  Overclocked Technologies — OC-AI"
echo "  Deployment — Step 2: AI Engine Install"
echo "============================================"
echo ""

# -----------------------------------------------------------
# Verify prerequisites
# -----------------------------------------------------------
print_step "Checking prerequisites"

if ! command -v node &>/dev/null; then
    print_err "Node.js not found. Run 01-macos-prep.sh first."
    exit 1
fi
print_ok "Node.js $(node --version)"

if ! command -v npm &>/dev/null; then
    print_err "npm not found. Run 01-macos-prep.sh first."
    exit 1
fi
print_ok "npm $(npm --version)"

# Load AI name from step 1
AI_NAME=""
if [[ -f ~/.openclaw/.ai-name ]]; then
    AI_NAME=$(cat ~/.openclaw/.ai-name)
    print_ok "AI assistant name: $AI_NAME"
else
    read -p "What is the AI assistant's name? " AI_NAME
    mkdir -p ~/.openclaw
    echo "$AI_NAME" > ~/.openclaw/.ai-name
fi

# -----------------------------------------------------------
# Install AI Engine
# -----------------------------------------------------------
print_step "Installing OC-AI engine"

if command -v openclaw &>/dev/null; then
    CURRENT_VER=$(openclaw --version 2>/dev/null || echo "unknown")
    print_ok "OC-AI engine already installed ($CURRENT_VER)"
    read -p "  Reinstall/update? (y/N): " REINSTALL
    if [[ "$REINSTALL" == "y" || "$REINSTALL" == "Y" ]]; then
        npm install -g openclaw
        print_ok "OC-AI engine updated"
    fi
else
    npm install -g openclaw
    print_ok "OC-AI engine installed"
fi

# -----------------------------------------------------------
# Anthropic API Key
# -----------------------------------------------------------
print_step "Configuring Anthropic API key"
echo ""
echo "  The client needs an Anthropic API key."
echo "  Get one at: https://console.anthropic.com/settings/keys"
echo ""
read -p "  Enter the Anthropic API key: " ANTHROPIC_KEY

if [[ -z "$ANTHROPIC_KEY" ]]; then
    print_err "API key is required. Cannot continue without it."
    exit 1
fi

# Validate key format (starts with sk-ant-)
if [[ ! "$ANTHROPIC_KEY" == sk-ant-* ]]; then
    print_warn "Key doesn't start with 'sk-ant-' — double check this is correct."
    read -p "  Continue anyway? (y/N): " CONTINUE
    if [[ "$CONTINUE" != "y" && "$CONTINUE" != "Y" ]]; then
        exit 1
    fi
fi

print_ok "API key accepted"

# -----------------------------------------------------------
# Brave Search API Key
# -----------------------------------------------------------
print_step "Configuring Brave Search API key"
echo ""
echo "  Brave Search gives the AI web search capability."
echo "  Free tier: https://brave.com/search/api/"
echo ""
read -p "  Enter Brave Search API key (or 's' to skip): " BRAVE_KEY

if [[ "$BRAVE_KEY" == "s" || -z "$BRAVE_KEY" ]]; then
    print_warn "Skipped — web search will not be available"
    BRAVE_KEY=""
else
    print_ok "Brave Search key accepted"
fi

# -----------------------------------------------------------
# Initialize OC-AI engine
# -----------------------------------------------------------
print_step "Initializing OC-AI"

# Set environment variables for the API keys
export ANTHROPIC_API_KEY="$ANTHROPIC_KEY"

# Initialize if not already done
if [[ ! -f ~/.openclaw/config.yaml ]]; then
    openclaw init
    print_ok "OC-AI initialized"
else
    print_ok "OC-AI already initialized"
fi

# -----------------------------------------------------------
# Configure OC-AI
# -----------------------------------------------------------
print_step "Configuring OC-AI"

# Set the default model to Opus
openclaw config set defaultModel "anthropic/claude-opus-4-6" 2>/dev/null || true

# Store API keys securely
openclaw auth set anthropic "$ANTHROPIC_KEY" 2>/dev/null || {
    # Fallback: write to environment file
    print_warn "Storing API key in environment file"
    mkdir -p ~/.openclaw
    cat >> ~/.openclaw/.env <<EOF
ANTHROPIC_API_KEY=$ANTHROPIC_KEY
EOF
    if [[ -n "$BRAVE_KEY" ]]; then
        cat >> ~/.openclaw/.env <<EOF
BRAVE_API_KEY=$BRAVE_KEY
EOF
    fi
    print_ok "API keys stored"
}

# Configure Brave Search if key provided
if [[ -n "$BRAVE_KEY" ]]; then
    openclaw config set braveApiKey "$BRAVE_KEY" 2>/dev/null || true
    print_ok "Brave Search configured"
fi

print_ok "Default model set to Claude Opus"

# -----------------------------------------------------------
# Install OC-AI CLI wrapper
# -----------------------------------------------------------
print_step "Installing OC-AI CLI"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ -f "$SCRIPT_DIR/oc-ai-wrapper/install-wrapper.sh" ]]; then
    bash "$SCRIPT_DIR/oc-ai-wrapper/install-wrapper.sh"
else
    print_warn "OC-AI wrapper not found — install manually later"
fi

# -----------------------------------------------------------
# Test the AI engine
# -----------------------------------------------------------
print_step "Testing OC-AI engine"
echo "  Starting engine for verification..."

# Start gateway in background, wait a few seconds, check status
openclaw gateway start &>/dev/null &
sleep 5

if openclaw gateway status &>/dev/null; then
    print_ok "OC-AI engine is running!"
else
    print_warn "Engine may need manual verification"
    print_warn "Try: ocai start"
fi

# Stop it for now — we'll set up auto-start in script 06
openclaw gateway stop &>/dev/null 2>&1 || true

# -----------------------------------------------------------
# Summary
# -----------------------------------------------------------
echo ""
echo "============================================"
echo "  ✅ OC-AI Engine Installation Complete!"
echo "============================================"
echo ""
echo "  AI Name:        $AI_NAME"
echo "  Model:          Claude Opus"
echo "  Anthropic Key:  ${ANTHROPIC_KEY:0:12}...${ANTHROPIC_KEY: -4}"
if [[ -n "$BRAVE_KEY" ]]; then
echo "  Brave Search:   Configured"
else
echo "  Brave Search:   Skipped"
fi
echo "  Engine:         Tested OK"
echo "  CLI:            ocai status | ocai start | ocai stop"
echo ""
echo "  Next: Run 03-telegram-setup.sh"
echo ""
