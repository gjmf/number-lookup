# CallerLookup - iOS Caller Identification App

An elegant iOS app that uses Twilio's Lookup API to identify unknown callers in real-time, helping you decide whether to answer incoming calls.

## Features

- 🔍 **Real-time Caller Identification**: Automatically identifies incoming calls using iOS CallKit
- 📱 **Manual Number Lookup**: Search any phone number to get detailed information
- 📊 **Lookup History**: Keep track of all your previous lookups
- 🔒 **Privacy-Focused**: All data is processed locally on your device
- 🎨 **Modern SwiftUI Interface**: Clean, intuitive design that follows iOS design guidelines
- ☁️ **Twilio Integration**: Uses Twilio's powerful Lookup API for accurate caller information

## What Information Can You Get?

- **Caller Name**: Identify who is calling
- **Carrier Information**: See which carrier the number belongs to
- **Line Type**: Mobile, landline, or VoIP
- **Location**: Country and region information
- **Additional Data**: Optional add-on services for enhanced information

## Requirements

- iOS 16.0 or later
- Xcode 15.0 or later
- A Twilio account (free tier available)
- Apple Developer Account (for installation on your device)

## Getting Started

### 1. Set Up Twilio Account

1. Go to [Twilio Console](https://console.twilio.com)
2. Sign up for a free account (no credit card required for testing)
3. Navigate to your dashboard
4. Copy your **Account SID** and **Auth Token**

**Important**: Twilio provides free trial credits, but each lookup may incur charges. Check [Twilio's pricing](https://www.twilio.com/lookup/pricing) for details.

### 2. Build and Install the App

#### Option A: Build with Xcode

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd number-lookup/CallerLookup
   ```

2. Open the project in Xcode:
   ```bash
   open CallerLookup.xcodeproj
   ```

3. Update the bundle identifiers:
   - Select the `CallerLookup` target
   - Go to "Signing & Capabilities"
   - Change the Bundle Identifier to something unique (e.g., `com.yourname.callerlookup`)
   - Select your Team from your Apple Developer Account
   - Repeat for the `CallerLookupExtension` target

4. Enable App Groups:
   - In "Signing & Capabilities", ensure "App Groups" capability is enabled
   - Make sure `group.com.callerlookup.shared` is listed (or update to match your bundle ID)

5. Connect your iPhone via USB

6. Select your iPhone as the build destination

7. Click the "Play" button to build and install

#### Option B: Archive for Distribution

1. In Xcode, select **Product > Archive**
2. Once archived, click **Distribute App**
3. Choose **Development** or **Ad Hoc**
4. Follow the wizard to export the IPA file
5. Use Apple Configurator or Xcode to install on your device

### 3. Configure the App

1. Open the CallerLookup app on your iPhone
2. Tap the "Settings" button (gear icon)
3. Enter your Twilio **Account SID** and **Auth Token**
4. Tap "Save Credentials"

### 4. Enable Call Identification

To enable automatic caller identification for incoming calls:

1. Open your iPhone's **Settings** app
2. Scroll down and tap **Phone**
3. Tap **Call Blocking & Identification**
4. Toggle **ON** the switch next to "CallerLookup"

⚠️ **Note**: You must enable this setting for the app to automatically identify incoming calls.

### 5. Refresh the Call Directory

After performing manual lookups, tap the "Refresh" button in the main app to update the Call Directory Extension with new numbers.

## How It Works

### Architecture

The app consists of two main components:

1. **Main App** (`CallerLookup`):
   - SwiftUI-based user interface
   - Twilio API integration
   - Settings and history management
   - Manual phone number lookups

2. **Call Directory Extension** (`CallerLookupExtension`):
   - Runs automatically when calls are received
   - Provides caller identification to iOS
   - Uses cached lookup results from the main app
   - Shares data via App Groups

### Data Flow

```
Incoming Call
    ↓
iOS CallKit checks Call Directory Extension
    ↓
Extension looks up number in local cache
    ↓
If found, displays caller info
    ↓
If not found, shows as "Unknown"
```

For manual lookups:
```
User enters number in app
    ↓
App queries Twilio Lookup API
    ↓
Result displayed and saved to history
    ↓
Result cached for Call Directory Extension
    ↓
Extension can now identify this number
```

## App Structure

```
CallerLookup/
├── CallerLookup/                 # Main app
│   ├── CallerLookupApp.swift     # App entry point
│   ├── ContentView.swift         # Main interface
│   ├── Views/
│   │   ├── SettingsView.swift    # Configuration screen
│   │   └── LookupHistoryView.swift # History list
│   ├── Models/
│   │   └── LookupResult.swift    # Data model
│   └── Services/
│       ├── TwilioService.swift   # API integration
│       └── CallDirectoryManager.swift # Extension manager
│
└── CallerLookupExtension/        # Call Directory Extension
    └── CallDirectoryHandler.swift # Extension logic
```

## Usage Tips

### Manual Lookups

1. Open the app
2. Enter a phone number with country code (e.g., `+12223334444`)
3. Tap "Lookup Number"
4. View detailed information about the caller

### Managing History

- View all past lookups by tapping the "History" button
- Swipe left on any entry to delete it
- Clear all history in Settings

### Cost Considerations

- Each Twilio lookup API call may incur charges
- Lookups are cached locally to avoid duplicate charges
- The Call Directory Extension uses cached data (no additional API calls)
- Consider performing manual lookups selectively to manage costs

## Troubleshooting

### Call Identification Not Working

1. Verify the extension is enabled in Settings > Phone > Call Blocking & Identification
2. Tap "Refresh" in the app after performing lookups
3. Restart your iPhone
4. Make sure you've performed at least one manual lookup for the number

### API Errors

- **"Not Configured"**: Enter your Twilio credentials in Settings
- **"Invalid Phone Number"**: Ensure you include the country code (e.g., +1)
- **401 Unauthorized**: Check your Twilio Account SID and Auth Token
- **429 Too Many Requests**: You've exceeded Twilio's rate limits

### Build Errors

- Ensure you're using Xcode 15.0 or later
- Check that all bundle identifiers are unique
- Verify your Apple Developer Account is properly configured
- Make sure App Groups capability is enabled for both targets

## Privacy & Security

- **Local Processing**: All lookups are processed locally on your device
- **Secure Storage**: Twilio credentials are stored securely in iOS keychain equivalent
- **No Third-Party Tracking**: The app doesn't collect or share your data
- **HTTPS Only**: All API communication is encrypted

## Customization

### Adding Twilio Add-ons

To enable additional lookup services (may cost extra):

1. Open `CallerLookup/Services/TwilioService.swift`
2. Uncomment the lines for OpenCNAM or Trestle lookups in the `lookupPhoneNumber` function
3. Rebuild the app

### Changing App Colors

1. Open the Xcode project
2. Modify colors in the SwiftUI views
3. Adjust `AccentColor` in Assets catalog

### Adjusting Cache Size

In `TwilioService.swift`, find the `saveResultForExtension` function and adjust:
```swift
if savedResults.count > 1000 {  // Change this number
    savedResults = Array(savedResults.suffix(1000))
}
```

## Known Limitations

- **Requires Manual Lookup First**: Numbers must be looked up manually before automatic identification works
- **iOS Restrictions**: Call identification works only for calls, not SMS
- **Cache Limit**: The Call Directory Extension can store a limited number of entries
- **API Costs**: Each lookup may incur Twilio charges

## Future Enhancements

- [ ] Automatic background refreshing of common spam numbers
- [ ] Integration with spam databases
- [ ] Batch number import
- [ ] Export lookup history
- [ ] Support for Twilio v2 Lookup API
- [ ] Widget support for quick lookups

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues.

## License

See LICENSE file in the repository root.

## Support

For issues or questions:
- Check the Troubleshooting section above
- Review [Twilio Lookup API documentation](https://www.twilio.com/docs/lookup)
- Open an issue on GitHub

## Credits

Original concept based on the bash script by graham@freeman-family.us

Built with:
- SwiftUI
- CallKit
- Twilio Lookup API

---

**Disclaimer**: This app requires a Twilio account and may incur charges based on usage. Please review Twilio's pricing before extensive use.
