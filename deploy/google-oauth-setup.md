# Google OAuth Setup — One-Time for Overclocked Technologies

*Do this ONCE. The credentials.json file gets reused for every client deployment.*

## Step 1: Create Google Cloud Project

1. Go to https://console.cloud.google.com
2. Click **Select a project** → **New Project**
3. Name: `Overclocked AI Assistant`
4. Click **Create**

## Step 2: Enable Gmail API

1. Go to **APIs & Services** → **Library**
2. Search for **Gmail API**
3. Click **Enable**

## Step 3: Configure OAuth Consent Screen

1. Go to **APIs & Services** → **OAuth consent screen**
2. Select **External** → **Create**
3. Fill in:
   - **App name:** `Overclocked AI Assistant`
   - **User support email:** tron@mcdonald-net.com
   - **Developer contact:** tron@mcdonald-net.com
4. Click **Save and Continue**
5. **Scopes** → **Add or Remove Scopes**:
   - `https://www.googleapis.com/auth/gmail.readonly`
   - `https://www.googleapis.com/auth/gmail.labels`
6. Click **Save and Continue**
7. **Test users** → **Add Users**:
   - Add your own Gmail for testing
   - (Client emails get added here too, OR publish the app)
8. Click **Save and Continue**

## Step 4: Create OAuth Client ID

1. Go to **APIs & Services** → **Credentials**
2. Click **+ Create Credentials** → **OAuth client ID**
3. Application type: **Desktop app**
4. Name: `OpenClaw Gmail Integration`
5. Click **Create**
6. Click **Download JSON**
7. Save as `credentials.json`

## Step 5: Store for Deployments

1. Copy `credentials.json` to your deployment USB drive
2. Also back it up somewhere secure
3. This file is used by `04-gmail-setup.sh` for every client

## Important Notes

- **Test users limit:** While the app is in "Testing" status, you must manually add each client's Gmail to the test users list (max 100)
- **To remove the limit:** Submit the app for Google verification (takes 2-6 weeks). Requires a privacy policy URL and homepage.
- **Recommendation:** Start with test users for early clients. Submit for verification once you have 10+ clients.
- **The credentials.json does NOT contain client data** — it just identifies our app. Each client's actual email access token is stored locally on their Mac Mini only.

## Security Notes

- `credentials.json` = identifies our app (safe to carry on USB)
- `token.pickle` = client's actual Gmail access (stays on THEIR Mac Mini only, never leaves)
- Read-only scope = AI cannot send, delete, or modify emails
- Client can revoke access anytime at https://myaccount.google.com/permissions
