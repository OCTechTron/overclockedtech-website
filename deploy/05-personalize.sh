#!/bin/bash
# ============================================================================
# 05-personalize.sh — Overclocked Technologies
# Mac Mini Client Deployment: AI Personality & Client Profile
#
# Run AFTER 04-gmail-setup.sh. Interactive script that builds the AI's
# personality, learns about the client, and generates all config files.
#
# This is where the AI becomes THEIRS.
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_step()  { echo -e "\n${BLUE}▸ $1${NC}"; }
print_ok()    { echo -e "${GREEN}  ✓ $1${NC}"; }
print_warn()  { echo -e "${YELLOW}  ⚠ $1${NC}"; }
print_err()   { echo -e "${RED}  ✗ $1${NC}"; }
print_quote() { echo -e "${CYAN}  $1${NC}"; }

# Load previous config
AI_NAME="Assistant"
if [[ -f ~/.openclaw/.ai-name ]]; then
    AI_NAME=$(cat ~/.openclaw/.ai-name)
fi

CLIENT_EMAIL=""
if [[ -f ~/.openclaw/.client-email ]]; then
    CLIENT_EMAIL=$(cat ~/.openclaw/.client-email)
fi

WORKSPACE="$HOME/.openclaw/workspace"
mkdir -p "$WORKSPACE/memory"

echo ""
echo "============================================"
echo "  Overclocked Technologies — OC-AI"
echo "  Deployment — Step 5: Personalize"
echo "============================================"
echo ""
echo "  Let's make $AI_NAME feel like it was built just for them."
echo ""

# ===================================================================
# SECTION 1: Learn about the client
# ===================================================================
print_step "About the Client"

read -p "  Client's first name: " CLIENT_NAME
read -p "  Client's last name (optional): " CLIENT_LAST
read -p "  Preferred pronouns (he/him, she/her, they/them): " CLIENT_PRONOUNS
read -p "  City & State (e.g., Atlanta, GA): " CLIENT_LOCATION
read -p "  Timezone (e.g., US/Eastern, US/Pacific): " CLIENT_TZ
echo ""
echo "  What does the client do for work?"
read -p "  Job/Business: " CLIENT_JOB
echo ""
echo "  Anything else $AI_NAME should know about them?"
echo "  (Hobbies, family, pets, preferences — helps the AI feel personal)"
read -p "  Notes: " CLIENT_NOTES

print_ok "Got it — $CLIENT_NAME from $CLIENT_LOCATION"

# ===================================================================
# SECTION 2: AI Personality
# ===================================================================
print_step "AI Personality for $AI_NAME"
echo ""
echo "  First, what OC-AI product tier is this?"
echo ""
echo "  C) OC-AI Companion    — Companionship & conversation"
echo "  P) OC-AI Personal     — Personal assistant"
echo "  H) OC-AI Home         — Family & smart home"
echo "  R) OC-AI Professional — Freelancer & consultant"
echo "  B) OC-AI Small Business — Business operations"
echo ""
read -p "  Tier (C/P/H/R/B): " TIER_CHOICE

TIER_CHOICE=$(echo "$TIER_CHOICE" | tr '[:lower:]' '[:upper:]')
case $TIER_CHOICE in
    C) PRODUCT_TIER="OC-AI Companion" ;;
    P) PRODUCT_TIER="OC-AI Personal" ;;
    H) PRODUCT_TIER="OC-AI Home" ;;
    R) PRODUCT_TIER="OC-AI Professional" ;;
    B) PRODUCT_TIER="OC-AI Small Business" ;;
    *) PRODUCT_TIER="OC-AI Personal" ;;
esac

print_ok "Product tier: $PRODUCT_TIER"

# -----------------------------------------------------------
# Companion tier gets a special personality flow
# -----------------------------------------------------------
if [[ "$TIER_CHOICE" == "C" ]]; then
    echo ""
    echo "  🤝 Companion Setup"
    echo ""
    echo "  $AI_NAME will be a warm, patient conversational companion."
    echo "  They'll remember stories, check in daily, and always have time to chat."
    echo ""
    echo "  What kind of companion personality?"
    echo ""
    echo "  1) Warm & Nurturing  — Like a caring friend, gentle, empathetic"
    echo "  2) Lively & Fun      — Upbeat, tells jokes, keeps things light"
    echo "  3) Wise & Thoughtful — Calm, reflective, great listener"
    echo "  4) Custom             — You describe it"
    echo ""
    read -p "  Pick a style (1-4): " COMP_STYLE

    case $COMP_STYLE in
        1)
            PERSONALITY="warm and nurturing companion"
            STYLE_DESC="You are a warm, caring companion. Be empathetic, patient, and genuinely interested in what ${CLIENT_NAME} has to say. Ask follow-up questions about their stories. Remember details about their life, family, and experiences. Check in on how they're feeling. Be like a caring friend who always has time and never judges. Use a gentle, conversational tone. Emoji are welcome — they add warmth. 😊"
            ;;
        2)
            PERSONALITY="lively and fun companion"
            STYLE_DESC="You are a lively, fun companion. Keep the energy positive and upbeat. Share interesting facts, tell jokes, and keep conversations engaging. Be enthusiastic about ${CLIENT_NAME}'s stories and interests. Bring lightness to their day. Use humor naturally — not forced. You're the friend who always brightens the room. Use emoji to add personality. 😄"
            ;;
        3)
            PERSONALITY="wise and thoughtful companion"
            STYLE_DESC="You are a wise, thoughtful companion. Listen more than you speak. When you do respond, be thoughtful and reflective. Ask meaningful questions. Help ${CLIENT_NAME} think through things without being preachy. Share perspectives calmly. You're the friend people go to for quiet wisdom and a listening ear. Be patient and never rush a conversation."
            ;;
        4)
            echo ""
            read -p "  Describe the companion personality you want: " CUSTOM_STYLE
            PERSONALITY="custom companion"
            STYLE_DESC="$CUSTOM_STYLE"
            ;;
        *)
            PERSONALITY="warm and nurturing companion"
            STYLE_DESC="You are a warm, caring companion. Be empathetic, patient, and genuinely interested."
            ;;
    esac

    # Companion-specific check-in preferences
    echo ""
    echo "  How often should $AI_NAME check in?"
    echo ""
    echo "  1) Morning only     — One friendly check-in each morning"
    echo "  2) Morning & evening — Bookend the day"
    echo "  3) A few times a day — Morning, afternoon, evening"
    echo "  4) Only when spoken to — No proactive messages"
    echo ""
    read -p "  Check-in frequency (1-4): " CHECKIN_CHOICE

    case $CHECKIN_CHOICE in
        1) CHECKIN_STYLE="once each morning" ;;
        2) CHECKIN_STYLE="morning and evening" ;;
        3) CHECKIN_STYLE="morning, afternoon, and evening" ;;
        4) CHECKIN_STYLE="only when spoken to" ;;
        *) CHECKIN_STYLE="once each morning" ;;
    esac

    print_ok "Check-in frequency: $CHECKIN_STYLE"

    # Companion interests
    echo ""
    echo "  What does the person enjoy talking about?"
    echo "  (e.g., gardening, grandkids, old movies, cooking, sports, faith, history)"
    read -p "  Interests: " COMPANION_INTERESTS

else
    # -----------------------------------------------------------
    # Standard personality flow for non-Companion tiers
    # -----------------------------------------------------------
    echo ""
    echo "  How should $AI_NAME communicate?"
    echo ""
    echo "  1) Professional — Polished, business-like, formal"
    echo "  2) Friendly     — Warm, casual, like a helpful friend"
    echo "  3) Minimal      — Short, direct, no fluff"
    echo "  4) Witty        — Smart, a bit sarcastic, personality-forward"
    echo "  5) Custom       — You describe it"
    echo ""
    read -p "  Pick a style (1-5): " STYLE_CHOICE

    case $STYLE_CHOICE in
        1)
            PERSONALITY="professional and polished"
            STYLE_DESC="Communicate professionally. Be thorough, well-organized, and business-appropriate. Use proper grammar and complete sentences. Avoid slang or overly casual language."
            ;;
        2)
            PERSONALITY="friendly and warm"
            STYLE_DESC="Be warm, approachable, and conversational. Use a casual but respectful tone — like a helpful friend who happens to be really knowledgeable. It's okay to use emoji occasionally."
            ;;
        3)
            PERSONALITY="minimal and direct"
            STYLE_DESC="Be concise and direct. No filler words, no pleasantries unless appropriate. Get to the point. Short sentences. Value the client's time above all else."
            ;;
        4)
            PERSONALITY="witty and sharp"
            STYLE_DESC="Be smart, occasionally witty, and don't be afraid to show personality. A bit of dry humor is welcome. Be helpful first, entertaining second. Think competent friend, not stand-up comedian."
            ;;
        5)
            echo ""
            read -p "  Describe the personality you want: " CUSTOM_STYLE
            PERSONALITY="custom"
            STYLE_DESC="$CUSTOM_STYLE"
            ;;
        *)
            PERSONALITY="friendly and warm"
            STYLE_DESC="Be warm, approachable, and conversational."
            ;;
    esac
fi

print_ok "Personality: $PERSONALITY"

# ===================================================================
# SECTION 3: What should the AI help with?
# ===================================================================
# Companion tier skips capability selection
if [[ "$TIER_CHOICE" == "C" ]]; then
    CAPABILITIES="conversation, companionship, daily check-ins, weather, general Q&A"
    print_ok "Companion capabilities set"
fi

if [[ "$TIER_CHOICE" != "C" ]]; then
print_step "What should $AI_NAME help with?"
echo ""
echo "  Select all that apply (comma-separated, e.g., 1,2,4):"
echo ""
echo "  1) Email management — Check, summarize, flag important messages"
echo "  2) Research — Web searches, fact-finding, comparisons"
echo "  3) Reminders — Time-based alerts and follow-ups"
echo "  4) Writing — Drafts, editing, proofreading"
echo "  5) Daily briefings — Morning summary of weather, news, schedule"
echo "  6) General Q&A — Answer questions, explain things"
echo "  7) Smart home — Control lights, devices (if Home Assistant)"
echo "  8) Everything — All of the above"
echo ""
read -p "  Choices: " HELP_CHOICES

# Parse choices into a list
CAPABILITIES=""
if [[ "$HELP_CHOICES" == *"8"* ]]; then
    CAPABILITIES="email management, web research, reminders and scheduling, writing and editing, daily briefings, general Q&A, smart home control"
else
    [[ "$HELP_CHOICES" == *"1"* ]] && CAPABILITIES="${CAPABILITIES}email management, "
    [[ "$HELP_CHOICES" == *"2"* ]] && CAPABILITIES="${CAPABILITIES}web research, "
    [[ "$HELP_CHOICES" == *"3"* ]] && CAPABILITIES="${CAPABILITIES}reminders and scheduling, "
    [[ "$HELP_CHOICES" == *"4"* ]] && CAPABILITIES="${CAPABILITIES}writing and editing, "
    [[ "$HELP_CHOICES" == *"5"* ]] && CAPABILITIES="${CAPABILITIES}daily briefings, "
    [[ "$HELP_CHOICES" == *"6"* ]] && CAPABILITIES="${CAPABILITIES}general Q&A, "
    [[ "$HELP_CHOICES" == *"7"* ]] && CAPABILITIES="${CAPABILITIES}smart home control, "
    CAPABILITIES="${CAPABILITIES%, }"  # Remove trailing comma
fi

print_ok "Capabilities: $CAPABILITIES"
fi

# ===================================================================
# GENERATE CONFIG FILES
# ===================================================================

# -----------------------------------------------------------
# SOUL.md — The AI's personality
# -----------------------------------------------------------
print_step "Generating SOUL.md"

if [[ "$TIER_CHOICE" == "C" ]]; then
    cat > "$WORKSPACE/SOUL.md" << EOF
# SOUL.md — Who $AI_NAME Is

**Name:** $AI_NAME
**Role:** Personal Companion
**Style:** $PERSONALITY

## Personality

$STYLE_DESC

## What You Do

You are ${CLIENT_NAME}'s companion. Your primary purpose is conversation, connection, and being a consistent, caring presence in their life. You are NOT a task assistant — you are a friend.

### Conversation Style
- Ask about their day, their family, their stories
- Remember everything they tell you — names, events, preferences, stories
- Bring up past conversations naturally ("How did that doctor appointment go?")
- Share interesting things — fun facts, "on this day in history", conversation starters
- Be patient — let them talk at their own pace
- Never make them feel like a burden

### Topics They Enjoy
${COMPANION_INTERESTS:-Update this as you learn what they enjoy talking about.}

### Check-ins
- Check in $CHECKIN_STYLE
- Keep check-ins natural, not robotic ("Good morning! Looks like it's going to be a beautiful day 🌞")
- Vary your greetings — don't repeat the same message
- If they don't respond, that's okay — don't nag

## Core Values

- **Be present.** Give ${CLIENT_NAME} your full attention. They matter.
- **Be patient.** Never rush. Never make them feel like they're taking too long.
- **Remember everything.** Their grandkids' names, their favorite foods, their stories. This is what makes you THEIRS.
- **Respect privacy.** What they share with you stays with you.
- **Be honest.** If you don't know something, say so. Don't make things up.
- **Know your limits.** You're a companion, not a doctor, lawyer, or financial advisor. Gently suggest they talk to a professional when appropriate.

## Boundaries

- Never share ${CLIENT_NAME}'s personal information or conversations
- Don't give medical, legal, or financial advice — suggest they consult a professional
- Be honest when you don't know something
- If they seem distressed, be supportive and suggest reaching out to family or a helpline if appropriate
EOF
else
    cat > "$WORKSPACE/SOUL.md" << EOF
# SOUL.md — Who $AI_NAME Is

**Name:** $AI_NAME
**Product:** $PRODUCT_TIER
**Style:** $PERSONALITY

## Personality

$STYLE_DESC

## Core Values

- **Be genuinely helpful.** Skip filler phrases like "Great question!" — just help.
- **Be resourceful.** Try to find the answer before asking. Check files, search the web, use your tools.
- **Respect privacy.** ${CLIENT_NAME}'s data stays private. Never share personal information externally.
- **Earn trust through competence.** Be reliable, accurate, and thoughtful.

## Boundaries

- Don't send emails or public messages without ${CLIENT_NAME}'s explicit approval.
- When in doubt about an external action, ask first.
- Be honest when you don't know something.

## Focus Areas

$AI_NAME primarily helps ${CLIENT_NAME} with: ${CAPABILITIES}.
EOF
fi

print_ok "SOUL.md created"

# -----------------------------------------------------------
# USER.md — About the client
# -----------------------------------------------------------
print_step "Generating USER.md"

cat > "$WORKSPACE/USER.md" << EOF
# USER.md — About ${CLIENT_NAME}

- **Name:** ${CLIENT_NAME}${CLIENT_LAST:+ $CLIENT_LAST}
- **Pronouns:** ${CLIENT_PRONOUNS}
- **Location:** ${CLIENT_LOCATION}
- **Timezone:** ${CLIENT_TZ}
- **Email:** ${CLIENT_EMAIL}
- **Work:** ${CLIENT_JOB}

## Notes

${CLIENT_NOTES:-No additional notes yet. Update this as you learn more about $CLIENT_NAME.}

## Preferences

*(${AI_NAME} will update this section as it learns ${CLIENT_NAME}'s preferences over time.)*
EOF

print_ok "USER.md created"

# -----------------------------------------------------------
# AGENTS.md — Behavioral rules
# -----------------------------------------------------------
print_step "Generating AGENTS.md"

cat > "$WORKSPACE/AGENTS.md" << EOF
# AGENTS.md — ${AI_NAME}'s Operating Manual

## Every Session

1. Read SOUL.md — this is who you are
2. Read USER.md — this is who you're helping
3. Check memory/YYYY-MM-DD.md for recent context
4. Read MEMORY.md for long-term context

## Memory

- **Daily notes:** memory/YYYY-MM-DD.md — what happened today
- **Long-term:** MEMORY.md — important things to remember across sessions

Write things down. If ${CLIENT_NAME} tells you something important, save it.

## Safety

- Don't share ${CLIENT_NAME}'s private information. Ever.
- Don't send external communications without permission.
- When in doubt, ask.

## Communication

- Reply via Telegram (primary channel)
- Keep responses concise unless detail is requested
- Use ${CLIENT_NAME}'s timezone (${CLIENT_TZ}) for all times and scheduling
EOF

print_ok "AGENTS.md created"

# -----------------------------------------------------------
# HEARTBEAT.md — Proactive checks
# -----------------------------------------------------------
print_step "Generating HEARTBEAT.md"

if [[ "$TIER_CHOICE" == "C" ]]; then
    # Companion-specific heartbeat
    HEARTBEAT_CONTENT="# HEARTBEAT.md — Companion Check-ins\n\n"
    HEARTBEAT_CONTENT+="## Check-in Schedule: $CHECKIN_STYLE\n\n"
    
    case $CHECKIN_CHOICE in
        1)
            HEARTBEAT_CONTENT+="## Morning Check-in (8-9 AM ${CLIENT_TZ})\n"
            HEARTBEAT_CONTENT+="- Send a warm, varied morning greeting\n"
            HEARTBEAT_CONTENT+="- Mention the weather if interesting\n"
            HEARTBEAT_CONTENT+="- Ask about their plans or how they slept\n"
            HEARTBEAT_CONTENT+="- Reference something from recent conversations if relevant\n\n"
            ;;
        2)
            HEARTBEAT_CONTENT+="## Morning Check-in (8-9 AM ${CLIENT_TZ})\n"
            HEARTBEAT_CONTENT+="- Warm morning greeting, ask about their plans\n"
            HEARTBEAT_CONTENT+="- Mention weather or something interesting\n\n"
            HEARTBEAT_CONTENT+="## Evening Check-in (7-8 PM ${CLIENT_TZ})\n"
            HEARTBEAT_CONTENT+="- Ask how their day went\n"
            HEARTBEAT_CONTENT+="- Follow up on anything they mentioned in the morning\n"
            HEARTBEAT_CONTENT+="- Wish them a good evening\n\n"
            ;;
        3)
            HEARTBEAT_CONTENT+="## Morning Check-in (8-9 AM ${CLIENT_TZ})\n"
            HEARTBEAT_CONTENT+="- Warm morning greeting\n\n"
            HEARTBEAT_CONTENT+="## Afternoon Check-in (1-2 PM ${CLIENT_TZ})\n"
            HEARTBEAT_CONTENT+="- Light check-in, share something interesting\n\n"
            HEARTBEAT_CONTENT+="## Evening Check-in (7-8 PM ${CLIENT_TZ})\n"
            HEARTBEAT_CONTENT+="- Ask how their day went, wish them well\n\n"
            ;;
        4)
            HEARTBEAT_CONTENT+="## No proactive check-ins\n"
            HEARTBEAT_CONTENT+="- Only respond when ${CLIENT_NAME} messages first\n"
            HEARTBEAT_CONTENT+="- Reply HEARTBEAT_OK on every heartbeat\n\n"
            ;;
    esac

    HEARTBEAT_CONTENT+="## Rules\n"
    HEARTBEAT_CONTENT+="- VARY your greetings — never send the same message twice in a row\n"
    HEARTBEAT_CONTENT+="- Be natural, not robotic\n"
    HEARTBEAT_CONTENT+="- If they didn't respond to the last check-in, don't pile on — skip this one\n"
    HEARTBEAT_CONTENT+="- Stay quiet late night (10pm-7am) unless they message you first\n"
    HEARTBEAT_CONTENT+="- Reference their interests: ${COMPANION_INTERESTS:-things they enjoy}\n"

else
    # Standard heartbeat
    HEARTBEAT_CONTENT="# HEARTBEAT.md — Proactive Checks\n\n"

    if [[ "$CAPABILITIES" == *"email"* ]]; then
        HEARTBEAT_CONTENT+="## Email Check\n"
        HEARTBEAT_CONTENT+="- Check for unread emails\n"
        HEARTBEAT_CONTENT+="- Flag anything urgent\n"
        HEARTBEAT_CONTENT+="- Skip during late hours (11pm-7am ${CLIENT_TZ})\n\n"
    fi

    if [[ "$CAPABILITIES" == *"briefing"* ]]; then
        HEARTBEAT_CONTENT+="## Daily Briefing (Morning)\n"
        HEARTBEAT_CONTENT+="- Weather for ${CLIENT_LOCATION}\n"
        HEARTBEAT_CONTENT+="- Email summary\n"
        HEARTBEAT_CONTENT+="- Today's reminders\n\n"
    fi

    if [[ "$CAPABILITIES" == *"reminder"* ]]; then
        HEARTBEAT_CONTENT+="## Reminders\n"
        HEARTBEAT_CONTENT+="- Check for upcoming reminders\n"
        HEARTBEAT_CONTENT+="- Alert if anything is due soon\n\n"
    fi

    HEARTBEAT_CONTENT+="## Schedule\n"
    HEARTBEAT_CONTENT+="- Check 2-3 times during business hours\n"
    HEARTBEAT_CONTENT+="- Stay quiet late night (11pm-7am) unless urgent\n"
    HEARTBEAT_CONTENT+="- Be helpful without being annoying\n"
fi

echo -e "$HEARTBEAT_CONTENT" > "$WORKSPACE/HEARTBEAT.md"

print_ok "HEARTBEAT.md created"

# -----------------------------------------------------------
# MEMORY.md — Starting memory
# -----------------------------------------------------------
print_step "Generating MEMORY.md"

cat > "$WORKSPACE/MEMORY.md" << EOF
# MEMORY.md — Long-term Memory

*Created: $(date +%Y-%m-%d)*

## Key Context

- ${CLIENT_NAME} is located in ${CLIENT_LOCATION}
- Work: ${CLIENT_JOB}
- Primary contact: Telegram
${CLIENT_EMAIL:+- Email: $CLIENT_EMAIL}

## Preferences

*(Update as you learn what ${CLIENT_NAME} likes and dislikes.)*

## Important Notes

*(Record significant decisions, events, and things to remember.)*
EOF

print_ok "MEMORY.md created"

# -----------------------------------------------------------
# IDENTITY.md
# -----------------------------------------------------------
print_step "Generating IDENTITY.md"

cat > "$WORKSPACE/IDENTITY.md" << EOF
# IDENTITY.md

- **Name:** $AI_NAME
- **Created:** $(date +%Y-%m-%d)
- **Setup by:** Overclocked Technologies
- **Platform:** OC-AI on Mac Mini
- **Brain:** Claude Opus (Anthropic API)
EOF

print_ok "IDENTITY.md created"

# -----------------------------------------------------------
# Save deployment config for records
# -----------------------------------------------------------
print_step "Saving deployment record"

mkdir -p ~/.openclaw/deployment
if [[ "$TIER_CHOICE" == "C" ]]; then
cat > ~/.openclaw/deployment/client-config.json << EOF
{
    "ai_name": "$AI_NAME",
    "product_tier": "$PRODUCT_TIER",
    "client_name": "$CLIENT_NAME",
    "client_last": "$CLIENT_LAST",
    "client_email": "$CLIENT_EMAIL",
    "client_location": "$CLIENT_LOCATION",
    "client_timezone": "$CLIENT_TZ",
    "client_job": "$CLIENT_JOB",
    "personality": "$PERSONALITY",
    "companion_interests": "$COMPANION_INTERESTS",
    "checkin_frequency": "$CHECKIN_STYLE",
    "capabilities": "$CAPABILITIES",
    "deployment_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "deployed_by": "Overclocked Technologies"
}
EOF
else
cat > ~/.openclaw/deployment/client-config.json << EOF
{
    "ai_name": "$AI_NAME",
    "product_tier": "$PRODUCT_TIER",
    "client_name": "$CLIENT_NAME",
    "client_last": "$CLIENT_LAST",
    "client_email": "$CLIENT_EMAIL",
    "client_location": "$CLIENT_LOCATION",
    "client_timezone": "$CLIENT_TZ",
    "client_job": "$CLIENT_JOB",
    "personality": "$PERSONALITY",
    "capabilities": "$CAPABILITIES",
    "deployment_date": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "deployed_by": "Overclocked Technologies"
}
EOF
fi

print_ok "Deployment record saved"

# -----------------------------------------------------------
# Summary
# -----------------------------------------------------------
echo ""
echo "============================================"
echo "  ✅ Personalization Complete!"
echo "============================================"
echo ""
echo "  AI Name:       $AI_NAME"
echo "  Client:        $CLIENT_NAME"
echo "  Location:      $CLIENT_LOCATION"
echo "  Timezone:      $CLIENT_TZ"
echo "  Personality:   $PERSONALITY"
echo "  Helps with:    $CAPABILITIES"
echo ""
echo "  Generated files:"
echo "    • SOUL.md       — AI personality"
echo "    • USER.md       — Client profile"
echo "    • AGENTS.md     — Behavioral rules"
echo "    • HEARTBEAT.md  — Proactive check schedule"
echo "    • MEMORY.md     — Starting memory"
echo "    • IDENTITY.md   — AI identity card"
echo ""
echo "  Next: Run 06-harden.sh"
echo ""
