# CallerLookup - Complete Setup Guide

This guide will walk you through setting up the CallerLookup iOS app from scratch.

## Prerequisites Checklist

Before you begin, make sure you have:

- [ ] A Mac with macOS 13.0 or later
- [ ] Xcode 15.0 or later installed
- [ ] An iPhone with iOS 16.0 or later
- [ ] An Apple Developer Account (free or paid)
- [ ] A Twilio account (sign up at https://www.twilio.com)

## Part 1: Twilio Account Setup

### Step 1: Create Twilio Account

1. Visit https://www.twilio.com/try-twilio
2. Fill out the registration form
3. Verify your email address
4. Complete phone verification
5. You'll receive free trial credits (typically $15-20)

### Step 2: Get Your Credentials

1. Log in to https://console.twilio.com
2. You should see your Dashboard
3. Look for the "Account Info" section
4. Copy these two values (you'll need them later):
   - **Account SID** (starts with "AC...")
   - **Auth Token** (click "show" to reveal it)

**Security Note**: Keep these credentials private. Anyone with them can make API calls and incur charges on your account.

### Step 3: Understand Pricing

1. Go to https://www.twilio.com/lookup/pricing
2. Basic lookups typically cost:
   - Carrier lookup: ~$0.005 per request
   - Caller Name: ~$0.01 per request
3. Your trial credits should be enough for hundreds of lookups

## Part 2: Xcode Project Setup

### Step 1: Get the Code

```bash
# Clone the repository
git clone <repository-url>
cd number-lookup/CallerLookup
```

### Step 2: Open in Xcode

```bash
# Open the project
open CallerLookup.xcodeproj
```

Wait for Xcode to fully load and index the project.

### Step 3: Configure Signing (Main App)

1. In Xcode's left sidebar, click the **CallerLookup** project (blue icon at top)
2. In the main editor, select the **CallerLookup** target (under TARGETS)
3. Click the **Signing & Capabilities** tab
4. Configure signing:

   **Option A: Automatic Signing (Recommended)**
   - Check "Automatically manage signing"
   - Select your Team from the dropdown
   - Xcode will automatically create a provisioning profile

   **Option B: Manual Signing**
   - Uncheck "Automatically manage signing"
   - Select your provisioning profile
   - Select your certificate

5. Change the **Bundle Identifier** to something unique:
   - Click on the current identifier (com.callerlookup.CallerLookup)
   - Change it to: `com.[yourname].callerlookup`
   - Example: `com.john.callerlookup`

### Step 4: Configure Signing (Extension)

1. Still in the project settings, select the **CallerLookupExtension** target
2. Click the **Signing & Capabilities** tab
3. Repeat the signing configuration from Step 3
4. Change the Bundle Identifier to: `com.[yourname].callerlookup.extension`
   - ⚠️ Important: The extension ID must start with your app's ID

### Step 5: Configure App Groups

App Groups allow the main app and extension to share data.

**For CallerLookup target:**
1. Select the **CallerLookup** target
2. Click **Signing & Capabilities**
3. Verify you see "App Groups" capability
4. Click the (+) under App Groups if it's not there
5. Check the box next to `group.com.callerlookup.shared`
6. If it doesn't exist, click (+) and create it

**For CallerLookupExtension target:**
1. Select the **CallerLookupExtension** target
2. Repeat steps 2-6 above
3. Ensure both targets use the SAME App Group identifier

### Step 6: Update App Group IDs (if needed)

If you changed the bundle identifiers significantly, you should update the App Group ID to match:

1. Go to **Signing & Capabilities** for both targets
2. Update the App Group to: `group.com.[yourname].callerlookup.shared`
3. Update these code files:

**In TwilioService.swift** (line ~30):
```swift
if let groupDefaults = UserDefaults(suiteName: "group.com.yourname.callerlookup.shared") {
```

**In CallDirectoryHandler.swift** (line ~40):
```swift
guard let groupDefaults = UserDefaults(suiteName: "group.com.yourname.callerlookup.shared"),
```

**In CallDirectoryManager.swift** (line ~15):
```swift
withIdentifier: "com.yourname.callerlookup.extension"
```

## Part 3: Build and Install

### Step 1: Connect Your iPhone

1. Connect your iPhone to your Mac via USB cable
2. Unlock your iPhone
3. If prompted, tap "Trust This Computer" on your iPhone
4. Enter your iPhone passcode

### Step 2: Select Your Device

1. In Xcode, look at the top toolbar
2. Click the device selector (next to the play/stop buttons)
3. Select your iPhone from the list

### Step 3: Build and Run

1. Click the **Play** button (▶) in the top-left of Xcode
   - Or press `⌘R`
2. Xcode will:
   - Compile the code
   - Sign the app
   - Install it on your iPhone
   - Launch the app

3. **First-time installation**: You may see "Untrusted Developer"
   - On your iPhone, go to: Settings > General > VPN & Device Management
   - Tap your Apple ID
   - Tap "Trust [Your Apple ID]"
   - Go back and launch the app again

### Step 4: Verify Installation

The app should launch on your iPhone. You should see:
- A phone icon at the top
- "Caller Lookup" title
- "Configuration Required" warning
- Phone number input field

## Part 4: App Configuration

### Step 1: Enter Twilio Credentials

1. In the app, tap the **Settings** button (gear icon at bottom)
2. Enter your **Account SID** from Twilio
3. Enter your **Auth Token** from Twilio
4. Tap **Save Credentials**
5. You should see "Credentials saved successfully!"
6. Tap **Done**

### Step 2: Enable Call Identification

This is crucial for automatic caller ID:

1. Exit the CallerLookup app
2. Open your iPhone's **Settings** app (gray icon with gears)
3. Scroll down and tap **Phone**
4. Tap **Call Blocking & Identification**
5. Find **CallerLookup** in the list
6. Toggle it **ON** (switch turns green)

### Step 3: Test Manual Lookup

1. Open the CallerLookup app
2. Enter a test number with country code:
   - US example: `+14155552671` (Twilio test number)
   - Your own number: `+1[your-number]`
3. Tap **Lookup Number**
4. You should see:
   - Caller information (if available)
   - Carrier details
   - Line type
5. This number is now in your lookup history!

### Step 4: Refresh Call Directory

1. Tap the **Refresh** button (circular arrow icon)
2. This updates the Call Directory Extension
3. Now when this number calls, it will be automatically identified

## Part 5: Testing Caller ID

### Option A: Test with a Friend

1. Ask a friend to call you (preferably from a number you've looked up)
2. When the call comes in, you should see the caller info above the answer/decline buttons
3. If it doesn't work, see Troubleshooting below

### Option B: Test with Twilio

If you have Twilio Voice service set up:
1. Use Twilio to make a test call to your number
2. The call should show the caller information

### Option C: Natural Testing

Simply wait for unknown calls and check if they're identified (after you've looked them up manually once).

## Troubleshooting

### Problem: "Configuration Required" Won't Go Away

**Solution:**
- Make sure you saved your credentials
- Verify the Account SID starts with "AC"
- Check that Auth Token is correct
- Try closing and reopening the app

### Problem: "Invalid Phone Number" Error

**Solution:**
- Always include country code (e.g., +1 for US)
- Format: +[country code][area code][number]
- Remove spaces, dashes, and parentheses
- Example: +14155551234 (not +1 (415) 555-1234)

### Problem: Build Failed - Signing Error

**Solution:**
- Check that your Apple Developer Account is signed in:
  - Xcode > Settings > Accounts
- Verify bundle identifiers are unique
- Try:
  - Product > Clean Build Folder
  - Xcode > Settings > Accounts > Download Manual Profiles

### Problem: "Untrusted Developer" on iPhone

**Solution:**
- Settings > General > VPN & Device Management
- Tap your developer account
- Tap "Trust"
- Try launching the app again

### Problem: Call Identification Not Working

**Solution:**
1. Verify extension is enabled:
   - Settings > Phone > Call Blocking & Identification
   - CallerLookup should be ON

2. Make sure you've looked up the number manually first

3. Tap Refresh in the app after manual lookups

4. Restart your iPhone:
   - This forces iOS to reload all extensions

5. Check that both app and extension have the same App Group

### Problem: API Errors (401, 403, etc.)

**Solutions:**

**401 Unauthorized:**
- Credentials are incorrect
- Re-enter Account SID and Auth Token
- Make sure you copied them completely

**429 Too Many Requests:**
- You've hit rate limits
- Wait a few minutes
- Consider caching results

**20003 Error:**
- Invalid phone number format
- Check country code is correct

### Problem: Extension Not Found

**Solution:**
- Verify extension bundle ID: Settings > General > VPN & Device Management
- Rebuild the project
- Check CallDirectoryManager.swift has correct extension identifier

## Advanced Configuration

### Enable Twilio Add-ons (Optional)

For enhanced caller information (additional costs apply):

1. Open `CallerLookup/Services/TwilioService.swift` in Xcode
2. Find the `lookupPhoneNumber` function (around line 75)
3. Uncomment these lines:
```swift
let opencnamResult = try? await performLookup(
    url: baseURL + "?AddOns=telo_opencnam",
    accountSID: sid,
    authToken: token
)
```
4. Rebuild and reinstall the app

### Increase Cache Size

To store more numbers for identification:

1. Open `TwilioService.swift`
2. Find `saveResultForExtension` function
3. Change the limit:
```swift
if savedResults.count > 1000 {  // Increase this number
```
4. Rebuild

## Cost Management Tips

To minimize Twilio costs:

1. **Look up numbers selectively**: Don't lookup every unknown number
2. **Use the history**: Check if you've already looked up a number
3. **Set up alerts**: In Twilio Console, set up usage alerts
4. **Monitor spending**: Check your Twilio usage dashboard regularly
5. **Cache results**: The app already does this - don't delete history unnecessarily

## Next Steps

Now that your app is set up:

1. Start performing manual lookups on unknown numbers
2. Build your caller ID database over time
3. Customize the app appearance if desired
4. Check your Twilio usage periodically
5. Consider enabling add-ons for enhanced data

## Getting Help

If you're still having issues:

1. Check the main README.md for more information
2. Review Twilio's documentation: https://www.twilio.com/docs/lookup
3. Check Apple's CallKit documentation
4. Open an issue on GitHub with:
   - iOS version
   - Xcode version
   - Error messages
   - Steps you've tried

## Useful Resources

- **Twilio Console**: https://console.twilio.com
- **Twilio Lookup Docs**: https://www.twilio.com/docs/lookup/v1-api
- **CallKit Documentation**: https://developer.apple.com/documentation/callkit
- **App Groups Guide**: https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups

---

**Congratulations!** You now have a working caller identification app. Enjoy identifying those unknown callers!
