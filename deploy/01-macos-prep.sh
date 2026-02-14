#!/bin/bash
# ============================================================================
# 01-macos-prep.sh — Overclocked Technologies
# Mac Mini Client Deployment: macOS Preparation
#
# Run this FIRST on a fresh Mac Mini. Prepares the system for OpenClaw.
# Must be run as the logged-in user (will prompt for sudo when needed).
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() { echo -e "\n${BLUE}▸ $1${NC}"; }
print_ok()   { echo -e "${GREEN}  ✓ $1${NC}"; }
print_warn() { echo -e "${YELLOW}  ⚠ $1${NC}"; }
print_err()  { echo -e "${RED}  ✗ $1${NC}"; }

echo ""
echo "============================================"
echo "  Overclocked Technologies — OC-AI"
echo "  Deployment — Step 1: macOS Prep"
echo "============================================"
echo ""

# -----------------------------------------------------------
# Verify we're on macOS
# -----------------------------------------------------------
if [[ "$(uname)" != "Darwin" ]]; then
    print_err "This script must be run on macOS."
    exit 1
fi

# -----------------------------------------------------------
# Client name for computer naming
# -----------------------------------------------------------
read -p "What does the client want to name their AI assistant? " AI_NAME
if [[ -z "$AI_NAME" ]]; then
    print_err "Assistant name is required."
    exit 1
fi

# Save the AI name for later scripts to use
echo "$AI_NAME" > ~/.openclaw/.ai-name
COMPUTER_NAME="${AI_NAME}"
echo ""
print_step "Setting computer name to '${COMPUTER_NAME}'"
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$COMPUTER_NAME"
sudo scutil --set LocalHostName "$COMPUTER_NAME"
print_ok "Computer name set"

# -----------------------------------------------------------
# Energy Settings — Never sleep
# -----------------------------------------------------------
print_step "Configuring energy settings (never sleep)"
# Disable system sleep
sudo pmset -a sleep 0
# Disable display sleep
sudo pmset -a displaysleep 0
# Disable disk sleep
sudo pmset -a disksleep 0
# Wake on network access (for SSH)
sudo pmset -a womp 1
# Restart after power failure
sudo pmset -a autorestart 1
print_ok "Energy settings configured — Mac will never sleep"
print_ok "Auto-restart on power failure enabled"

# -----------------------------------------------------------
# Enable Auto-Login
# -----------------------------------------------------------
print_step "Configuring auto-login"
CURRENT_USER=$(whoami)
print_warn "Auto-login must be set manually for security reasons."
print_warn "Go to: System Settings → Users & Groups → Auto Login → Select '$CURRENT_USER'"
echo ""
read -p "Press Enter once auto-login is configured (or 's' to skip): " AUTO_RESPONSE
if [[ "$AUTO_RESPONSE" == "s" ]]; then
    print_warn "Skipped — remember to set this before leaving!"
else
    print_ok "Auto-login confirmed"
fi

# -----------------------------------------------------------
# Enable Firewall
# -----------------------------------------------------------
print_step "Enabling macOS firewall"
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
print_ok "Firewall enabled with stealth mode"

# -----------------------------------------------------------
# Enable Remote Login (SSH)
# -----------------------------------------------------------
print_step "Enabling SSH (Remote Login)"
sudo systemsetup -setremotelogin on 2>/dev/null || {
    print_warn "Could not enable SSH via command line."
    print_warn "Go to: System Settings → General → Sharing → Remote Login → ON"
    read -p "Press Enter once SSH is enabled (or 's' to skip): " SSH_RESPONSE
}
print_ok "SSH enabled for remote maintenance"

# -----------------------------------------------------------
# Disable unnecessary services
# -----------------------------------------------------------
print_step "Disabling unnecessary services for a headless server"
# Disable screen saver
defaults -currentHost write com.apple.screensaver idleTime 0
print_ok "Screen saver disabled"

# Reduce Spotlight indexing (saves CPU)
sudo mdutil -i off / 2>/dev/null && print_ok "Spotlight indexing disabled" || print_warn "Could not disable Spotlight"

# Disable Notification Center widgets
defaults write com.apple.ncprefs.plist dnd_prefs -data 62706C6973743030D60102030405060708080A08085B646E644D6972726F726564025F100F646E64446973706C6179536C65657009596461746556616C7565095F101E72657065617465644661636574696D6543616C6C73427265616B73444E4409080B101B21263135393A00000000000000010100000000000000060000000000000000000000000000003B 2>/dev/null
print_ok "Notifications minimized"

# -----------------------------------------------------------
# Install Homebrew
# -----------------------------------------------------------
print_step "Installing Homebrew"
if command -v brew &>/dev/null; then
    print_ok "Homebrew already installed"
else
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon
    if [[ -f /opt/homebrew/bin/brew ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    print_ok "Homebrew installed"
fi

# -----------------------------------------------------------
# Install Node.js
# -----------------------------------------------------------
print_step "Installing Node.js LTS"
if command -v node &>/dev/null; then
    NODE_VER=$(node --version)
    print_ok "Node.js already installed ($NODE_VER)"
else
    brew install node@22
    print_ok "Node.js installed ($(node --version))"
fi

# -----------------------------------------------------------
# Install useful utilities
# -----------------------------------------------------------
print_step "Installing utilities"
brew install jq curl wget 2>/dev/null
print_ok "jq, curl, wget installed"

# -----------------------------------------------------------
# Enable automatic macOS updates
# -----------------------------------------------------------
print_step "Enabling automatic updates"
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates -bool true
print_ok "Automatic macOS updates enabled"

# -----------------------------------------------------------
# Create directory structure
# -----------------------------------------------------------
print_step "Preparing directory structure"
mkdir -p ~/.openclaw/workspace/memory
print_ok "OC-AI directories ready"

# -----------------------------------------------------------
# Summary
# -----------------------------------------------------------
echo ""
echo "============================================"
echo "  ✅ macOS Preparation Complete!"
echo "============================================"
echo ""
echo "  Computer Name:  $COMPUTER_NAME"
echo "  User:           $CURRENT_USER"
echo "  Node.js:        $(node --version 2>/dev/null || echo 'pending')"
echo "  Homebrew:       $(brew --version 2>/dev/null | head -1 || echo 'pending')"
echo "  Firewall:       ON (stealth mode)"
echo "  SSH:            ON"
echo "  Sleep:          DISABLED"
echo "  Auto-restart:   ON"
echo ""
echo "  Next: Run 02-ocai-install.sh"
echo ""
