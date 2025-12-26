# YAML Quick Look Build Notes

## Icon Integration (macOS Tahoe)

The app now uses the modern **Icon Composer** `.icon` format introduced in macOS Tahoe (macOS 26).

### Icon File Location
- Source: `/Users/rod/Documents/yamlQuickLook.icon`
- Project: `YamlQuickLook/yamlQuickLook.icon`

### How It Works
1. The `.icon` file is created using Icon Composer (Xcode > Open Developer Tool > Icon Composer)
2. During build, Xcode automatically:
   - Converts the `.icon` to `.icns` for backward compatibility
   - Places it in the app bundle's Resources folder
   - Sets `CFBundleIconFile` and `CFBundleIconName` in Info.plist to "yamlQuickLook"

### Icon Features
- Liquid Glass material support
- Multi-layer depth rendering
- Platform and appearance variants (iOS, macOS, dark mode, mono)
- Automatic size generation for all required dimensions

## Dynamic Versioning (YYYY.MM.DD)

The app version is **automatically updated at build time** using the current date.

### Implementation
1. **Build Script**: A "Update Version" run script phase executes before compilation:
   ```bash
   VERSION=$(date +%Y.%m.%d)
   xcrun agvtool new-marketing-version "$VERSION"
   ```

2. **Info.plist Configuration**: All three Info.plist files reference the build setting:
   ```xml
   <key>CFBundleShortVersionString</key>
   <string>$(MARKETING_VERSION)</string>
   <key>CFBundleVersion</key>
   <string>$(MARKETING_VERSION)</string>
   ```

3. **Result**: Every build automatically gets the current date as its version (e.g., 2025.12.25)

### How to Update Manually
If you need to set a specific version:
```bash
cd /Users/rod/Developer/yamlQuickLook
xcrun agvtool new-marketing-version "2025.12.25"
```

## Building for Distribution

### Signed and Notarized Build
```bash
cd /Users/rod/Developer/yamlQuickLook

# Build with Developer ID
xcodebuild -scheme YamlQuickLook \
  -configuration Release \
  -derivedDataPath build \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="Developer ID Application: Emily Carr University of Art and Design (7TF6CSP83S)" \
  DEVELOPMENT_TEAM="7TF6CSP83S" \
  CODE_SIGN_INJECT_BASE_ENTITLEMENTS=NO \
  OTHER_CODE_SIGN_FLAGS="--timestamp --options runtime" \
  clean build

# Create ZIP
cd build/Build/Products/Release
ditto -c -k --keepParent YamlQuickLook.app yamlQuickLook.zip

# Submit for notarization
xcrun notarytool submit yamlQuickLook.zip \
  --keychain-profile notarization_credentials \
  --wait

# Staple the ticket
xcrun stapler staple YamlQuickLook.app

# Create final package
rm yamlQuickLook.zip
ditto -c -k --keepParent YamlQuickLook.app yamlQuickLook-notarized.zip
```

### Verification
```bash
# Check signature
codesign -dvv YamlQuickLook.app

# Verify notarization
xcrun stapler validate YamlQuickLook.app

# Check version and icon
/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" YamlQuickLook.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Print CFBundleIconFile" YamlQuickLook.app/Contents/Info.plist
```

## Current Build Status

✅ **Latest Build**: December 25, 2025
- **Version**: 2025.12.25 (automatically set)
- **Icon**: yamlQuickLook.icon (Liquid Glass, macOS Tahoe format)
- **Signature**: Developer ID Application (Emily Carr University)
- **Notarization**: Accepted and stapled
- **Distribution**: `yamlQuickLook-notarized.zip` (2.1 MB)

## Notes

- The build script warning about "Update Version" having no outputs is expected and harmless
- The `.icon` file provides better rendering quality than legacy `.icns` on macOS Tahoe and later
- For older macOS versions, Xcode automatically generates compatible icon assets
- Version is always current date - no manual updates needed for releases
