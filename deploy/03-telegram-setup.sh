#!/bin/bash
# ============================================================================
# 03-telegram-setup.sh — Overclocked Technologies
# Mac Mini Client Deployment: Telegram Messaging Integration
#
# Run AFTER 02-openclaw-install.sh. Sets up Telegram as the primary
# messaging channel between the client and their AI.
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

echo ""
echo "============================================"
echo "  Overclocked Technologies — OC-AI"
echo "  Deployment — Step 3: Telegram"
echo "============================================"
echo ""

# -----------------------------------------------------------
# Pre-setup: Create the Telegram bot
# -----------------------------------------------------------
print_step "Telegram Bot Setup"
echo ""
echo "  We need to create a Telegram bot for $AI_NAME."
echo ""
echo "  If you haven't already:"
echo "  1. Open Telegram and search for @BotFather"
echo "  2. Send: /newbot"
echo "  3. Name it: $AI_NAME"
echo "  4. Username: $(echo "$AI_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '_')_ai_bot (or similar)"
echo "  5. Copy the bot token BotFather gives you"
echo ""
read -p "  Enter the Telegram bot token: " BOT_TOKEN

if [[ -z "$BOT_TOKEN" ]]; then
    print_err "Bot token is required."
    exit 1
fi

# Basic format validation (numbers:alphanumeric)
if [[ ! "$BOT_TOKEN" =~ ^[0-9]+:.+$ ]]; then
    print_warn "Token format looks unusual. Double check with BotFather."
    read -p "  Continue anyway? (y/N): " CONTINUE
    if [[ "$CONTINUE" != "y" && "$CONTINUE" != "Y" ]]; then
        exit 1
    fi
fi

print_ok "Bot token accepted"

# -----------------------------------------------------------
# Verify the bot token works
# -----------------------------------------------------------
print_step "Verifying bot token with Telegram API"

BOT_INFO=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getMe" 2>/dev/null)

if echo "$BOT_INFO" | grep -q '"ok":true'; then
    BOT_USERNAME=$(echo "$BOT_INFO" | python3 -c "import sys,json;print(json.load(sys.stdin)['result']['username'])" 2>/dev/null || echo "unknown")
    BOT_DISPLAY=$(echo "$BOT_INFO" | python3 -c "import sys,json;print(json.load(sys.stdin)['result']['first_name'])" 2>/dev/null || echo "$AI_NAME")
    print_ok "Bot verified: @${BOT_USERNAME} (${BOT_DISPLAY})"
else
    print_err "Bot token is invalid. Check with BotFather and try again."
    exit 1
fi

# -----------------------------------------------------------
# Get client's Telegram user ID
# -----------------------------------------------------------
print_step "Client Telegram Authentication"
echo ""
echo "  We need the client's Telegram user ID to restrict access."
echo "  Only they should be able to talk to their AI."
echo ""
echo "  Option A: Have the client send any message to the bot now,"
echo "            then we'll grab their user ID from the updates."
echo ""
echo "  Option B: Enter the user ID manually if you already have it."
echo ""
read -p "  Wait for client message (w) or enter ID manually (m)? " ID_METHOD

if [[ "$ID_METHOD" == "w" || "$ID_METHOD" == "W" ]]; then
    echo ""
    echo "  Have the client open Telegram and send any message to @${BOT_USERNAME}"
    read -p "  Press Enter once they've sent a message..."
    
    # Fetch updates to get the user ID
    UPDATES=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?limit=5" 2>/dev/null)
    
    USER_ID=$(echo "$UPDATES" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data.get('ok') and data.get('result'):
    # Get the most recent message's user ID
    for update in reversed(data['result']):
        msg = update.get('message', {})
        user = msg.get('from', {})
        if user.get('id'):
            print(user['id'])
            break
" 2>/dev/null)
    
    if [[ -z "$USER_ID" ]]; then
        print_warn "Couldn't detect the message. Let's enter the ID manually."
        read -p "  Enter the client's Telegram user ID: " USER_ID
    else
        USER_NAME=$(echo "$UPDATES" | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data.get('ok') and data.get('result'):
    for update in reversed(data['result']):
        msg = update.get('message', {})
        user = msg.get('from', {})
        if user.get('id'):
            name = user.get('first_name', '')
            if user.get('last_name'):
                name += ' ' + user['last_name']
            print(name)
            break
" 2>/dev/null)
        print_ok "Detected user: $USER_NAME (ID: $USER_ID)"
    fi
else
    read -p "  Enter the client's Telegram user ID: " USER_ID
fi

if [[ -z "$USER_ID" ]]; then
    print_err "User ID is required for security."
    exit 1
fi

print_ok "Client user ID: $USER_ID"

# -----------------------------------------------------------
# Configure OC-AI Telegram channel
# -----------------------------------------------------------
print_step "Configuring OC-AI Telegram channel"

# Save config for later scripts
mkdir -p ~/.openclaw
cat > ~/.openclaw/.telegram-config <<EOF
BOT_TOKEN=$BOT_TOKEN
BOT_USERNAME=$BOT_USERNAME
USER_ID=$USER_ID
EOF

# Configure via CLI
openclaw config set channels.telegram.botToken "$BOT_TOKEN" 2>/dev/null || true
openclaw config set channels.telegram.allowedUsers "$USER_ID" 2>/dev/null || true

# If CLI config doesn't work, provide manual instructions
print_warn "Verify Telegram is configured in OC-AI config:"
echo "  openclaw config edit"
echo ""
echo "  Telegram section should contain:"
echo "    telegram:"
echo "      botToken: \"$BOT_TOKEN\""
echo "      allowedUsers:"
echo "        - \"$USER_ID\""
echo ""

print_ok "Telegram configuration saved"

# -----------------------------------------------------------
# Test messaging
# -----------------------------------------------------------
print_step "Testing Telegram messaging"
echo "  Starting OC-AI to test..."

openclaw gateway start &>/dev/null &
sleep 8

echo ""
echo "  Ask the client to send a test message to @${BOT_USERNAME}"
echo "  Something like: \"Hello $AI_NAME\""
echo ""
read -p "  Did the AI respond? (y/n): " TEST_RESULT

if [[ "$TEST_RESULT" == "y" || "$TEST_RESULT" == "Y" ]]; then
    print_ok "Telegram integration working!"
else
    print_warn "Telegram may need manual configuration."
    print_warn "Check: ocai logs"
fi

# Stop gateway for now
openclaw gateway stop &>/dev/null 2>&1 || true

# -----------------------------------------------------------
# Clear bot update history (security)
# -----------------------------------------------------------
print_step "Clearing bot message history"
# Get the latest update ID and acknowledge it to clear the queue
LAST_UPDATE=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates" 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
if data.get('ok') and data.get('result'):
    print(data['result'][-1]['update_id'] + 1)
" 2>/dev/null)

if [[ -n "$LAST_UPDATE" ]]; then
    curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?offset=${LAST_UPDATE}" &>/dev/null
    print_ok "Bot message queue cleared"
fi

# -----------------------------------------------------------
# Summary
# -----------------------------------------------------------
echo ""
echo "============================================"
echo "  ✅ Telegram Setup Complete!"
echo "============================================"
echo ""
echo "  Bot:            @${BOT_USERNAME}"
echo "  Bot Name:       ${BOT_DISPLAY}"
echo "  Client ID:      ${USER_ID}"
echo "  Access:         Restricted to client only"
echo ""
echo "  Client link:    https://t.me/${BOT_USERNAME}"
echo ""
echo "  Next: Run 04-gmail-setup.sh"
echo ""
