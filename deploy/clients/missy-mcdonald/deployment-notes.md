# Missy McDonald — Deployment Notes

**Client #:** 001
**Date:** 2026-02-13
**Product:** OC-AI Personal
**AI Name:** Mila
**Hardware:** M4 Mac Mini 16GB

## Pre-Deployment Checklist

- [ ] Create Telegram bot via BotFather (name: Mila)
- [ ] Get Missy's Telegram user ID
- [ ] Create Anthropic account for Missy (or use shared family account?)
- [ ] Get Anthropic API key
- [ ] Get Brave Search API key (use ours)
- [ ] Have Missy's Gmail address ready for email integration

## Deployment Steps

1. Run `01-macos-prep.sh` — AI name: "Mila"
2. Run `02-openclaw-install.sh` — Enter Anthropic key + Brave key
3. Run `03-telegram-setup.sh` — Bot token + Missy's user ID
4. Run `04-gmail-setup.sh` — Missy's Gmail, she clicks Allow
5. Copy config files from `clients/missy-mcdonald/` to `~/.openclaw/workspace/`
6. Run `06-harden.sh` — Auto-start, SSH key, firewall
7. Test: Have Missy send "Hey Mila!" in Telegram
8. Walk her through 3-5 example interactions
9. Hand her the quick card

## Post-Deployment

- [ ] Verify Mila responds correctly
- [ ] Verify morning briefing works next day
- [ ] Verify email checking works
- [ ] Set billing alert on Anthropic account
- [ ] Log deployment in client tracker
