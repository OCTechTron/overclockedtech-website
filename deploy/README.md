# OC-AI — Mac Mini Deployment Guide

*Overclocked Technologies — Client Deployment Playbook v1.0*

## Overview

Turn a fresh M4 Mac Mini into a fully configured personal AI assistant in under an hour. The Mac Mini runs OpenClaw as an always-on gateway, with Claude Opus handling the intelligence via API.

**Design Principles:**
- Client never touches a terminal
- No developer accounts, code projects, or OAuth headaches for the client
- We handle ALL technical setup during deployment
- Client walks away with a chat link and a quick-start guide

## Product Tiers

| Product | Target | Setup Fee |
|---|---|---|
| **OC-AI Companion** | Seniors, companionship | $1,000-1,500 |
| **OC-AI Personal** | Individuals | $1,500 |
| **OC-AI Home** | Families / Smart Home | $2,000 |
| **OC-AI Professional** | Freelancers / Consultants | $2,500 |
| **OC-AI Small Business** | Small businesses | $3,500+ |

## Business Model

- **One-time setup fee:** $1,000–3,500+ (depending on tier)
- **Hardware:** Client purchases Mac Mini ($599 for M4 16GB) or we source + markup
- **LLM costs:** Client pays their own Anthropic API usage directly (~$20-50/month typical)
- **Optional:** Ongoing support retainer ($200-500/month)

## V1 Integration Stack

Chosen for simplicity — no client developer accounts required.

| Integration | Purpose | Client Action Required |
|---|---|---|
| **Telegram** | Primary messaging | Install app, tap a link |
| **Gmail** | Email monitoring | Click "Allow" on one screen |
| **Brave Search** | Web research | None (our API key) |
| **Weather** | Forecasts & alerts | None (built-in) |

**Future upsells (V2+):**
- Home Assistant (smart home)
- Google Calendar
- WhatsApp (when Meta makes it easier)
- Custom skills & workflows

## What the Client Gets

- Always-on personal AI assistant they talk to via Telegram
- Email monitoring — AI reads, summarizes, and flags important messages
- Web search and research on demand
- Weather and daily briefings
- Reminders and scheduling assistance
- Customized personality and preferences
- 24/7 availability — the Mac Mini never sleeps

---

## Deployment Checklist

### Pre-Visit Preparation (~10 min)
- [ ] Generate a Telegram bot via BotFather (have token ready)
- [ ] Have a Brave Search API key ready
- [ ] Prepare USB drive with setup script (if no internet initially)
- [ ] Print client quick-start guide
- [ ] Confirm client has Anthropic account + API key (or help them create one ahead of time)

### Phase 1: Hardware & macOS Setup (~15 min)
- [ ] Unbox and power on Mac Mini
- [ ] Complete macOS initial setup (Apple ID, Wi-Fi)
- [ ] Run `01-macos-prep.sh`:
  - Set computer name
  - Enable auto-login
  - Disable sleep/screen saver
  - Enable SSH (Remote Login) for remote maintenance
  - Enable firewall
  - Enable automatic macOS updates
  - Install Homebrew + Node.js

### Phase 2: OpenClaw Installation (~10 min)
- [ ] Run `02-openclaw-install.sh`:
  - Install OpenClaw globally
  - Run initial setup wizard
  - Enter client's Anthropic API key
  - Set default model to Claude Opus
  - Configure Brave Search API key
  - Verify gateway starts

### Phase 3: Telegram Setup (~5 min)
- [ ] Run `03-telegram-setup.sh`:
  - Configure Telegram bot token
  - Set client's Telegram user ID for authentication
  - Test message send/receive
  - Send client the bot link to tap on their phone

### Phase 4: Gmail Integration (~10 min)
- [ ] Run `04-gmail-setup.sh`:
  - Set up Gmail CLI tool
  - Walk client through one-time Google consent screen ("Allow" button)
  - Verify email access
  - Configure email checking in heartbeat

### Phase 5: Personalization (~10 min)
- [ ] Run `05-personalize.sh` (interactive):
  - Client's name, timezone, location
  - Assistant personality preferences (professional, casual, etc.)
  - What they want help with (email, scheduling, research, etc.)
  - Generates SOUL.md, USER.md, AGENTS.md, HEARTBEAT.md

### Phase 6: Lockdown & Auto-Start (~5 min)
- [ ] Run `06-harden.sh`:
  - Create launchd service (OpenClaw starts on boot)
  - Configure auto-restart on crash
  - Lock down SSH (key-only, our maintenance key)
  - Disable unnecessary macOS services
  - Test power cycle recovery (reboot and verify)

### Phase 7: Client Handoff (~15 min)
- [ ] Disconnect monitor — verify headless operation
- [ ] Open Telegram on client's phone, send first message
- [ ] Walk through 3-5 example interactions:
  - "Check my email"
  - "What's the weather this week?"
  - "Remind me to call John at 3pm"
  - "Search for [something relevant to their work]"
- [ ] Hand over printed quick-start guide
- [ ] Explain API billing: show them console.anthropic.com usage page
- [ ] Set up billing alerts on their Anthropic account
- [ ] Exchange contact info for support

## Total Deployment Time: ~60-80 minutes

---

## Scripts

| Script | Purpose | Status |
|---|---|---|
| `01-macos-prep.sh` | Homebrew, Node, energy settings, SSH, firewall | ✅ Done |
| `02-openclaw-install.sh` | Install and configure OpenClaw + API keys | ✅ Done |
| `03-telegram-setup.sh` | Bot token, user auth, test messaging | ✅ Done |
| `04-gmail-setup.sh` | Gmail CLI + OAuth consent flow | ✅ Done |
| `05-personalize.sh` | Interactive client profile → config files | ✅ Done |
| `06-harden.sh` | launchd, auto-restart, SSH lockdown | ✅ Done |
| `client-quick-start.md` | Printable guide for the client | ✅ Done |
| `google-oauth-setup.md` | One-time Google Cloud OAuth setup | ✅ Done |

---

## Remote Maintenance

After deployment, all maintenance is done via SSH:
- `ssh openclaw@<client-mini-ip>` (using our maintenance key)
- Update OpenClaw: `openclaw update`
- Check status: `openclaw status`
- View logs: `openclaw gateway logs`
- Restart: `openclaw gateway restart`

For clients on a support retainer, we can proactively:
- Monitor for errors
- Update OpenClaw and skills
- Tune personality and integrations
- Optimize API usage

---

## Hardware Specs

**Minimum:** M4 Mac Mini, 16GB RAM, 256GB SSD — $599
**Recommended:** Same (OpenClaw is lightweight, no need to upsell hardware)

**Power consumption:** ~5-10W idle — costs about $1/month in electricity
**Size:** 5" × 5" — fits anywhere
**Noise:** Silent — no fan under normal OpenClaw load

---

## Pricing Worksheet

| Item | Our Cost | Client Price |
|---|---|---|
| Mac Mini M4 16GB | $599 | $599-699 (optional markup if we source) |
| Setup & Configuration | Our time (~1.5hr) | $1,500-2,500 |
| Anthropic API (monthly) | $0 | $20-50/month (client pays direct) |
| Brave Search API | ~$0 (free tier) | Included in setup |
| **Total first month** | | **~$2,150-3,250** |
| **Ongoing monthly** | | **~$20-50 (API only)** |
| **With support retainer** | | **~$220-550/month** |

---

## Notes

- All scripts must be idempotent (safe to re-run)
- Test every deployment script on our own Mac Mini first
- Keep a deployment log for each client (serial number, config, date)
- Client data stays on THEIR Mac Mini — we never store it
- Our SSH key is for maintenance only — document this in the service agreement
