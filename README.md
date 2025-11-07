# Phone Number Lookup Tools

Tools for researching phone numbers using Twilio's Lookup API.

Typical use-case: Determine if unknown callers are legitimate or potential scammers.

## Available Tools

### 1. Bash Script (`twilio-lookup-number-extra.sh`)

A command-line script for manual phone number lookups on macOS.

**Features:**
- Queries Twilio Lookup API for carrier and caller name information
- Includes optional OpenCNAM and Trestle reverse phone lookups
- Returns detailed JSON output

**Requirements:**
- Twilio account with credentials set as environment variables
- macOS with Homebrew
- `jq`, `curl`, and `shellcheck` binaries

**Usage:**
```bash
export TWILIO_ACCOUNT_SID="your_account_sid"
export TWILIO_AUTH_TOKEN="your_auth_token"
./twilio-lookup-number-extra.sh 12223334444
```

### 2. iOS App (`CallerLookup/`)

**NEW**: A native iOS app that provides real-time caller identification on your iPhone.

**Features:**
- 🔍 Automatic caller identification using iOS CallKit
- 📱 Manual phone number lookup interface
- 📊 Lookup history tracking
- 🔒 Privacy-focused - all data stored locally
- 🎨 Modern SwiftUI interface
- ☁️ Twilio API integration

**Requirements:**
- iOS 16.0 or later
- Xcode 15.0 or later (for building)
- Twilio account
- Apple Developer Account

**Quick Start:**
```bash
cd CallerLookup
open CallerLookup.xcodeproj
```

See [CallerLookup/README.md](CallerLookup/README.md) for full documentation.

See [CallerLookup/SETUP.md](CallerLookup/SETUP.md) for detailed setup instructions.

## Cost Considerations

Both tools use Twilio's Lookup API, which incurs charges:
- Basic carrier lookup: ~$0.005 per request
- Caller name lookup: ~$0.01 per request
- Add-on services: Additional costs

Twilio provides free trial credits for new accounts.

## Contributing

Lots of room for improvement. Pull requests welcome!

## Contact

graham@freeman-family.us

## License

GPL 3.0 - See LICENSE file for details
