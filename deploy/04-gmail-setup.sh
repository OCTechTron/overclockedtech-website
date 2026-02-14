#!/bin/bash
# ============================================================================
# 04-gmail-setup.sh — Overclocked Technologies
# Mac Mini Client Deployment: Gmail Integration
#
# Run AFTER 03-telegram-setup.sh. Sets up Gmail access so the AI can
# read, summarize, and flag important emails.
#
# The client clicks ONE "Allow" button. We handle everything else.
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
echo "  Deployment — Step 4: Gmail"
echo "============================================"
echo ""

# -----------------------------------------------------------
# Ask if client wants Gmail integration
# -----------------------------------------------------------
echo "  Gmail integration lets $AI_NAME:"
echo "  • Check for new emails and summarize them"
echo "  • Flag important messages"
echo "  • Search through email history"
echo "  • Draft replies (with client approval)"
echo ""
read -p "  Set up Gmail integration? (Y/n): " SETUP_GMAIL

if [[ "$SETUP_GMAIL" == "n" || "$SETUP_GMAIL" == "N" ]]; then
    print_warn "Gmail skipped. You can run this script later to add it."
    echo ""
    echo "  Next: Run 05-personalize.sh"
    exit 0
fi

# -----------------------------------------------------------
# Get client's Gmail address
# -----------------------------------------------------------
print_step "Client Gmail Information"
read -p "  Enter client's Gmail address: " CLIENT_EMAIL

if [[ -z "$CLIENT_EMAIL" || ! "$CLIENT_EMAIL" == *@* ]]; then
    print_err "Valid email address required."
    exit 1
fi

print_ok "Gmail: $CLIENT_EMAIL"

# -----------------------------------------------------------
# Install Gmail CLI tool
# -----------------------------------------------------------
print_step "Installing Gmail CLI tool"

# Check if pip3 is available
if ! command -v pip3 &>/dev/null; then
    print_warn "Installing Python3 pip..."
    brew install python3 2>/dev/null
fi

# Install our Gmail CLI dependencies
pip3 install --user google-auth google-auth-oauthlib google-api-python-client 2>/dev/null
print_ok "Gmail dependencies installed"

# -----------------------------------------------------------
# Set up OAuth credentials
# -----------------------------------------------------------
print_step "OAuth Credentials Setup"
echo ""
echo "  We use a pre-built OAuth client for the Gmail API."
echo "  This avoids the client needing a Google Cloud project."
echo ""

# Check for our OAuth credentials file
CREDS_DIR="$HOME/.openclaw/gmail"
mkdir -p "$CREDS_DIR"

if [[ -f "$CREDS_DIR/credentials.json" ]]; then
    print_ok "OAuth credentials already present"
else
    echo "  We need our Overclocked Technologies OAuth credentials.json file."
    echo ""
    echo "  Option A: Copy from USB drive"
    echo "  Option B: Enter the path to the file"
    echo ""
    read -p "  Path to credentials.json: " CREDS_PATH
    
    if [[ -f "$CREDS_PATH" ]]; then
        cp "$CREDS_PATH" "$CREDS_DIR/credentials.json"
        print_ok "Credentials copied"
    else
        print_err "File not found: $CREDS_PATH"
        echo ""
        echo "  To create OAuth credentials (one-time for our business):"
        echo "  1. Go to https://console.cloud.google.com"
        echo "  2. Create project: 'Overclocked AI Assistant'"
        echo "  3. Enable Gmail API"
        echo "  4. Create OAuth 2.0 Client ID (Desktop app)"
        echo "  5. Download credentials.json"
        echo "  6. Save to: $CREDS_DIR/credentials.json"
        echo ""
        read -p "  Press Enter once credentials.json is in place..."
        
        if [[ ! -f "$CREDS_DIR/credentials.json" ]]; then
            print_err "credentials.json not found. Cannot continue Gmail setup."
            exit 1
        fi
    fi
fi

# -----------------------------------------------------------
# Create the Gmail CLI tool
# -----------------------------------------------------------
print_step "Creating Gmail CLI tool"

cat > "$CREDS_DIR/gmail-cli.py" << 'GMAIL_SCRIPT'
#!/usr/bin/env python3
"""
Gmail CLI — Overclocked Technologies
Simple Gmail access for OpenClaw AI assistants.
"""

import os
import sys
import json
import pickle
import argparse
from pathlib import Path
from datetime import datetime

CREDS_DIR = Path.home() / ".openclaw" / "gmail"
TOKEN_FILE = CREDS_DIR / "token.pickle"
CREDS_FILE = CREDS_DIR / "credentials.json"

SCOPES = [
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/gmail.labels',
]

def get_service():
    """Authenticate and return Gmail API service."""
    from google.oauth2.credentials import Credentials
    from google_auth_oauthlib.flow import InstalledAppFlow
    from google.auth.transport.requests import Request
    from googleapiclient.discovery import build
    
    creds = None
    if TOKEN_FILE.exists():
        with open(TOKEN_FILE, 'rb') as f:
            creds = pickle.load(f)
    
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(str(CREDS_FILE), SCOPES)
            creds = flow.run_local_server(port=0)
        with open(TOKEN_FILE, 'wb') as f:
            pickle.dump(creds, f)
    
    return build('gmail', 'v1', credentials=creds)

def cmd_auth(args):
    """Authenticate with Gmail (triggers browser consent)."""
    print("Opening browser for Gmail authorization...")
    print("The client needs to click 'Allow' to grant email read access.")
    print()
    service = get_service()
    profile = service.users().getProfile(userId='me').execute()
    print(f"✓ Authenticated as: {profile['emailAddress']}")
    print(f"  Total messages: {profile['messagesTotal']}")

def cmd_status(args):
    """Show account status."""
    service = get_service()
    profile = service.users().getProfile(userId='me').execute()
    print(f"Account: {profile['emailAddress']}")
    print(f"Messages: {profile['messagesTotal']}")
    print(f"Threads: {profile['threadsTotal']}")

def cmd_list(args):
    """List recent emails."""
    service = get_service()
    query = args.query or "is:unread"
    max_results = args.max or 10
    
    results = service.users().messages().list(
        userId='me', q=query, maxResults=max_results
    ).execute()
    
    messages = results.get('messages', [])
    if not messages:
        print("No messages found.")
        return
    
    for msg_ref in messages:
        msg = service.users().messages().get(
            userId='me', id=msg_ref['id'], format='metadata',
            metadataHeaders=['From', 'Subject', 'Date']
        ).execute()
        
        headers = {h['name']: h['value'] for h in msg['payload']['headers']}
        snippet = msg.get('snippet', '')[:80]
        
        print(f"From:    {headers.get('From', 'Unknown')}")
        print(f"Subject: {headers.get('Subject', '(no subject)')}")
        print(f"Date:    {headers.get('Date', 'Unknown')}")
        print(f"Preview: {snippet}")
        print(f"ID:      {msg_ref['id']}")
        print("---")

def cmd_read(args):
    """Read a specific email by ID."""
    service = get_service()
    msg = service.users().messages().get(
        userId='me', id=args.id, format='full'
    ).execute()
    
    headers = {h['name']: h['value'] for h in msg['payload']['headers']}
    
    print(f"From:    {headers.get('From', 'Unknown')}")
    print(f"To:      {headers.get('To', 'Unknown')}")
    print(f"Subject: {headers.get('Subject', '(no subject)')}")
    print(f"Date:    {headers.get('Date', 'Unknown')}")
    print("---")
    
    # Extract body
    import base64
    parts = msg['payload'].get('parts', [])
    if parts:
        for part in parts:
            if part['mimeType'] == 'text/plain':
                data = part['body'].get('data', '')
                if data:
                    print(base64.urlsafe_b64decode(data).decode('utf-8', errors='replace'))
                break
    else:
        data = msg['payload']['body'].get('data', '')
        if data:
            print(base64.urlsafe_b64decode(data).decode('utf-8', errors='replace'))

def main():
    parser = argparse.ArgumentParser(description='Gmail CLI for OpenClaw')
    sub = parser.add_subparsers(dest='command')
    
    sub.add_parser('auth', help='Authenticate with Gmail')
    sub.add_parser('status', help='Show account status')
    
    list_p = sub.add_parser('list', help='List emails')
    list_p.add_argument('--query', '-q', default='is:unread', help='Gmail search query')
    list_p.add_argument('--max', '-m', type=int, default=10, help='Max results')
    
    read_p = sub.add_parser('read', help='Read an email')
    read_p.add_argument('id', help='Message ID')
    
    args = parser.parse_args()
    
    if args.command == 'auth':
        cmd_auth(args)
    elif args.command == 'status':
        cmd_status(args)
    elif args.command == 'list':
        cmd_list(args)
    elif args.command == 'read':
        cmd_read(args)
    else:
        parser.print_help()

if __name__ == '__main__':
    main()
GMAIL_SCRIPT

chmod +x "$CREDS_DIR/gmail-cli.py"

# Create a wrapper command
cat > /usr/local/bin/gmail 2>/dev/null << 'WRAPPER' || {
    # If /usr/local/bin not writable, put in user's bin
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/gmail" << 'WRAPPER2'
#!/bin/bash
python3 ~/.openclaw/gmail/gmail-cli.py "$@"
WRAPPER2
    chmod +x "$HOME/.local/bin/gmail"
    
    # Add to PATH if needed
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zprofile
        export PATH="$HOME/.local/bin:$PATH"
    fi
    print_ok "Gmail CLI installed to ~/.local/bin/gmail"
}
#!/bin/bash
python3 ~/.openclaw/gmail/gmail-cli.py "$@"
WRAPPER

if [[ -f /usr/local/bin/gmail ]]; then
    chmod +x /usr/local/bin/gmail
    print_ok "Gmail CLI installed to /usr/local/bin/gmail"
fi

# -----------------------------------------------------------
# Run OAuth flow — client clicks "Allow"
# -----------------------------------------------------------
print_step "Gmail Authorization"
echo ""
echo "  A browser window will open for the client to authorize email access."
echo "  They just need to:"
echo "    1. Select their Gmail account ($CLIENT_EMAIL)"
echo "    2. Click 'Allow'"
echo "    3. Close the browser tab when done"
echo ""
read -p "  Ready? Press Enter to open the authorization page..."

python3 "$CREDS_DIR/gmail-cli.py" auth

if [[ $? -eq 0 ]]; then
    print_ok "Gmail authorized successfully!"
else
    print_err "Gmail authorization failed. Check the browser for errors."
    echo "  You can retry later with: gmail auth"
    exit 1
fi

# -----------------------------------------------------------
# Test email access
# -----------------------------------------------------------
print_step "Testing email access"

python3 "$CREDS_DIR/gmail-cli.py" status

if [[ $? -eq 0 ]]; then
    print_ok "Email access working!"
else
    print_warn "Email test failed — may need to re-authorize"
fi

# Save client email for later scripts
echo "$CLIENT_EMAIL" > ~/.openclaw/.client-email

# -----------------------------------------------------------
# Summary
# -----------------------------------------------------------
echo ""
echo "============================================"
echo "  ✅ Gmail Setup Complete!"
echo "============================================"
echo ""
echo "  Account:     $CLIENT_EMAIL"
echo "  Access:      Read-only (emails + labels)"
echo "  CLI:         gmail status | gmail list | gmail read <id>"
echo "  Token:       ~/.openclaw/gmail/token.pickle"
echo ""
echo "  $AI_NAME can now check and summarize emails."
echo ""
echo "  Next: Run 05-personalize.sh"
echo ""
