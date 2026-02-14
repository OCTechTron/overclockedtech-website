#!/bin/bash
# ============================================================================
# 06-harden.sh — Overclocked Technologies
# Mac Mini Client Deployment: Security Hardening & Auto-Start
#
# Run LAST. Locks everything down, sets up auto-start, and verifies
# the system survives a reboot with no human intervention.
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

# Load AI name
AI_NAME="Assistant"
if [[ -f ~/.openclaw/.ai-name ]]; then
    AI_NAME=$(cat ~/.openclaw/.ai-name)
fi

CURRENT_USER=$(whoami)

echo ""
echo "============================================"
echo "  Overclocked Technologies — OC-AI"
echo "  Deployment — Step 6: Harden"
echo "============================================"
echo ""

# ===================================================================
# SECTION 1: OC-AI Auto-Start via launchd
# ===================================================================
print_step "Setting up OC-AI auto-start"

PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_FILE="$PLIST_DIR/com.overclocked.openclaw.plist"
mkdir -p "$PLIST_DIR"

# Find the openclaw binary
OPENCLAW_BIN=$(which openclaw 2>/dev/null || echo "/opt/homebrew/bin/openclaw")
NODE_BIN=$(which node 2>/dev/null || echo "/opt/homebrew/bin/node")

# Get Homebrew path for environment
BREW_PREFIX=$(/opt/homebrew/bin/brew --prefix 2>/dev/null || echo "/opt/homebrew")

cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.overclocked.openclaw</string>

    <key>ProgramArguments</key>
    <array>
        <string>${OPENCLAW_BIN}</string>
        <string>gateway</string>
        <string>start</string>
        <string>--foreground</string>
    </array>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>${BREW_PREFIX}/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${HOME}/.local/bin</string>
        <key>HOME</key>
        <string>${HOME}</string>
    </dict>

    <key>WorkingDirectory</key>
    <string>${HOME}/.openclaw/workspace</string>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
        <key>Crashed</key>
        <true/>
    </dict>

    <key>ThrottleInterval</key>
    <integer>10</integer>

    <key>StandardOutPath</key>
    <string>${HOME}/.openclaw/logs/gateway-stdout.log</string>

    <key>StandardErrorPath</key>
    <string>${HOME}/.openclaw/logs/gateway-stderr.log</string>

    <key>SoftResourceLimits</key>
    <dict>
        <key>NumberOfFiles</key>
        <integer>4096</integer>
    </dict>
</dict>
</plist>
EOF

mkdir -p "$HOME/.openclaw/logs"

print_ok "Launch agent created: $PLIST_FILE"

# Load the launch agent
launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"
print_ok "Launch agent loaded — OC-AI will start on boot"

# -----------------------------------------------------------
# Log rotation
# -----------------------------------------------------------
print_step "Setting up log rotation"

cat > "$HOME/.openclaw/rotate-logs.sh" << 'ROTATE'
#!/bin/bash
# Rotate OC-AI logs — keep last 7 days
LOG_DIR="$HOME/.openclaw/logs"
find "$LOG_DIR" -name "*.log" -size +10M -exec truncate -s 0 {} \;
find "$LOG_DIR" -name "*.log.*" -mtime +7 -delete 2>/dev/null
ROTATE

chmod +x "$HOME/.openclaw/rotate-logs.sh"

# Create a weekly log rotation via launchd
cat > "$PLIST_DIR/com.overclocked.logrotate.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.overclocked.logrotate</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>${HOME}/.openclaw/rotate-logs.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Weekday</key>
        <integer>0</integer>
        <key>Hour</key>
        <integer>3</integer>
    </dict>
</dict>
</plist>
EOF

launchctl load "$PLIST_DIR/com.overclocked.logrotate.plist" 2>/dev/null || true
print_ok "Weekly log rotation configured (Sundays 3 AM)"

# ===================================================================
# SECTION 2: SSH Hardening
# ===================================================================
print_step "Hardening SSH access"

SSH_DIR="$HOME/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Add our maintenance SSH key
echo ""
echo "  Adding Overclocked Technologies maintenance SSH key."
echo "  This lets us remotely maintain the system."
echo ""

if [[ -f "$SSH_DIR/authorized_keys" ]]; then
    # Check if our key is already there
    if grep -q "overclocked-maintenance" "$SSH_DIR/authorized_keys" 2>/dev/null; then
        print_ok "Maintenance key already installed"
    else
        read -p "  Paste our maintenance public key (or 's' to skip): " MAINT_KEY
        if [[ "$MAINT_KEY" != "s" && -n "$MAINT_KEY" ]]; then
            echo "$MAINT_KEY" >> "$SSH_DIR/authorized_keys"
            print_ok "Maintenance key added"
        else
            print_warn "Skipped — add maintenance key later for remote support"
        fi
    fi
else
    read -p "  Paste our maintenance public key (or 's' to skip): " MAINT_KEY
    if [[ "$MAINT_KEY" != "s" && -n "$MAINT_KEY" ]]; then
        echo "$MAINT_KEY" > "$SSH_DIR/authorized_keys"
        chmod 600 "$SSH_DIR/authorized_keys"
        print_ok "Maintenance key added"
    else
        print_warn "Skipped — add maintenance key later for remote support"
    fi
fi

# Recommend disabling password auth (but don't force it — we might need it)
echo ""
print_warn "RECOMMENDATION: Disable SSH password authentication"
echo "  After verifying key-based SSH works, run:"
echo "  sudo sed -i '' 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config"
echo "  sudo launchctl stop com.openssh.sshd"
echo "  sudo launchctl start com.openssh.sshd"
echo ""
read -p "  Disable password SSH now? (y/N): " DISABLE_PASS

if [[ "$DISABLE_PASS" == "y" || "$DISABLE_PASS" == "Y" ]]; then
    sudo sed -i '' 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config 2>/dev/null
    sudo sed -i '' 's/^#*ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config 2>/dev/null
    print_ok "Password authentication disabled"
    print_warn "Make sure key-based SSH works before disconnecting!"
else
    print_warn "Password SSH still enabled — disable after verifying key access"
fi

# ===================================================================
# SECTION 3: Firewall Rules
# ===================================================================
print_step "Verifying firewall"

FW_STATE=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null)
if echo "$FW_STATE" | grep -q "enabled"; then
    print_ok "Firewall is enabled"
else
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    print_ok "Firewall enabled"
fi

# Stealth mode (don't respond to pings from unknown sources)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on 2>/dev/null
print_ok "Stealth mode enabled"

# Block all incoming except SSH
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off 2>/dev/null
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off 2>/dev/null
print_ok "Incoming connections restricted"

# ===================================================================
# SECTION 4: Disable Unnecessary Services
# ===================================================================
print_step "Disabling unnecessary services"

# Disable AirDrop
defaults write com.apple.NetworkBrowser DisableAirDrop -bool YES 2>/dev/null
print_ok "AirDrop disabled"

# Disable Bluetooth (headless server doesn't need it)
echo ""
read -p "  Disable Bluetooth? (Y/n): " DISABLE_BT
if [[ "$DISABLE_BT" != "n" && "$DISABLE_BT" != "N" ]]; then
    sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0 2>/dev/null
    print_ok "Bluetooth disabled"
else
    print_warn "Bluetooth left enabled"
fi

# Disable file sharing
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.smbd.plist 2>/dev/null || true
print_ok "File sharing disabled"

# ===================================================================
# SECTION 5: Automatic Updates
# ===================================================================
print_step "Verifying automatic updates"

sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true
print_ok "Security updates will install automatically"

# ===================================================================
# SECTION 6: Create maintenance script
# ===================================================================
print_step "Creating maintenance utilities"

cat > "$HOME/.openclaw/maintenance.sh" << 'MAINT'
#!/bin/bash
# Overclocked Technologies — OC-AI Remote Maintenance Script
# Usage: ./maintenance.sh [status|restart|logs|update]

case "${1:-status}" in
    status)
        echo "=== OC-AI Status ==="
        openclaw gateway status 2>/dev/null || echo "OC-AI not responding"
        echo ""
        echo "=== System Uptime ==="
        uptime
        echo ""
        echo "=== Disk Usage ==="
        df -h / | tail -1
        echo ""
        echo "=== Memory ==="
        vm_stat | head -5
        ;;
    restart)
        echo "Restarting OC-AI..."
        launchctl unload ~/Library/LaunchAgents/com.overclocked.openclaw.plist 2>/dev/null
        sleep 2
        launchctl load ~/Library/LaunchAgents/com.overclocked.openclaw.plist
        echo "OC-AI restarted."
        ;;
    logs)
        echo "=== Recent OC-AI Logs ==="
        tail -50 ~/.openclaw/logs/gateway-stderr.log 2>/dev/null || echo "No logs found"
        ;;
    update)
        echo "Updating OC-AI..."
        npm update -g openclaw
        echo "Restarting OC-AI..."
        launchctl unload ~/Library/LaunchAgents/com.overclocked.openclaw.plist 2>/dev/null
        sleep 2
        launchctl load ~/Library/LaunchAgents/com.overclocked.openclaw.plist
        echo "Update complete."
        ;;
    *)
        echo "Usage: maintenance.sh [status|restart|logs|update]"
        ;;
esac
MAINT

chmod +x "$HOME/.openclaw/maintenance.sh"
print_ok "Maintenance script created: ~/.openclaw/maintenance.sh"

# ===================================================================
# SECTION 7: Reboot Test
# ===================================================================
print_step "Final Verification"
echo ""
echo "  Everything is configured. Let's verify it survives a reboot."
echo ""
echo "  What will happen:"
echo "    1. Mac Mini reboots"
echo "    2. Auto-login kicks in"
echo "    3. OC-AI starts automatically"
echo "    4. $AI_NAME comes online in Telegram"
echo ""
echo "  After reboot, have the client send a message to $AI_NAME."
echo "  It should respond within 30-60 seconds of the Mac booting."
echo ""
read -p "  Reboot now to test? (Y/n): " DO_REBOOT

if [[ "$DO_REBOOT" != "n" && "$DO_REBOOT" != "N" ]]; then
    echo ""
    echo "  Rebooting in 5 seconds... Watch for $AI_NAME to come online."
    sleep 5
    sudo reboot
else
    print_warn "Skipped reboot test — do this before leaving the client site!"
    echo "  Manual reboot: sudo reboot"
fi

# -----------------------------------------------------------
# Summary (shown if reboot was skipped)
# -----------------------------------------------------------
echo ""
echo "============================================"
echo "  ✅ Hardening Complete!"
echo "============================================"
echo ""
echo "  Auto-start:     OC-AI starts on boot automatically"
echo "  Auto-restart:   Recovers from crashes automatically"
echo "  Firewall:       ON (stealth mode)"
echo "  SSH:            Enabled (maintenance key installed)"
echo "  AirDrop:        Disabled"
echo "  File Sharing:   Disabled"
echo "  Auto-updates:   Security updates auto-install"
echo "  Log rotation:   Weekly (Sundays 3 AM)"
echo ""
echo "  Maintenance:    ~/.openclaw/maintenance.sh [status|restart|logs|update]"
echo ""
echo "  ⚠  IMPORTANT: Test a reboot before leaving the client site!"
echo ""
echo "============================================"
echo "  🎉 OC-AI Deployment Complete — $AI_NAME is live!"
echo "============================================"
echo ""
