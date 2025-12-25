# YAML Quick Look

A native macOS Quick Look extension for previewing YAML files. Provides the same clean, scrollable plain-text preview experience as built-in file types like `.txt` and `.plist`.

## Features

- Native plain-text Quick Look preview for YAML files
- Scrollable content view for large files
- Thumbnail generation for Finder icons
- Dark mode support
- Supports `.yaml` and `.yml` file extensions

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later (for building from source)

## Installation

### Option 1: Download Release

1. Download the latest `YAMLQuickLook.zip` from [Releases](https://github.com/rodchristiansen/yaml-quicklook/releases)
2. Unzip and move `YamlQuickLook.app` to `/Applications`
3. Open the app once to register the extension
4. Go to System Settings > Privacy and Security > Extensions > Quick Look
5. Enable "YAML Quick Look"

Note: The release build is not notarized. On first launch, you may need to:
- Right-click the app and select "Open", or
- Run: `xattr -cr /Applications/YamlQuickLook.app`

### Option 2: Build from Source

See [Building from Source](#building-from-source) below.

## Usage

1. Select any `.yaml` or `.yml` file in Finder
2. Press Space to preview with Quick Look
3. Or view in Finder's preview pane (right sidebar)

## Building from Source

### Prerequisites

- macOS 14.0 or later
- Xcode 15.0 or later
- An Apple Developer account (for signing and notarization)

### Basic Build

```bash
git clone https://github.com/rodchristiansen/yaml-quicklook.git
cd yaml-quicklook
xcodebuild -scheme YamlQuickLook -configuration Release build
```

### Install Locally

```bash
# Build
xcodebuild -scheme YamlQuickLook -configuration Release \
  -derivedDataPath build clean build

# Install
cp -R build/Build/Products/Release/YamlQuickLook.app /Applications/

# Register extension
pluginkit -a /Applications/YamlQuickLook.app/Contents/PlugIns/YamlQuickLookExtension.appex

# Reset Quick Look
qlmanage -r && qlmanage -r cache
```

### Signing with Your Developer ID

To distribute the app outside the Mac App Store, you need to sign and notarize it.

#### 1. Configure Signing in Xcode

Open `YAMLQuickLook.xcodeproj` in Xcode and configure signing for all three targets:

- **YamlQuickLook** (main app)
- **YamlQuickLookExtension** (Quick Look preview)
- **YamlQuickLookThumbnailExtension** (thumbnail generator)

For each target:
1. Select the target in the project navigator
2. Go to "Signing and Capabilities"
3. Select your Team
4. Choose "Developer ID Application" for distribution outside the App Store

#### 2. Build Signed Release

```bash
xcodebuild -scheme YamlQuickLook \
  -configuration Release \
  -derivedDataPath build \
  CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAM_ID)" \
  DEVELOPMENT_TEAM="TEAM_ID" \
  clean build
```

#### 3. Notarize the App

```bash
# Create a ZIP for notarization
cd build/Build/Products/Release
zip -r YamlQuickLook.zip YamlQuickLook.app

# Submit for notarization
xcrun notarytool submit YamlQuickLook.zip \
  --apple-id "your@email.com" \
  --team-id "TEAM_ID" \
  --password "app-specific-password" \
  --wait

# Staple the notarization ticket
xcrun stapler staple YamlQuickLook.app
```

#### 4. Create Distribution ZIP

```bash
# Re-zip with stapled ticket
VERSION=$(date -u +"%Y.%m.%d.%H%M")
zip -r YAMLQuickLook-${VERSION}.zip YamlQuickLook.app
```

### App Store Distribution

For Mac App Store distribution:

1. Change signing to "Apple Distribution" certificate
2. Enable App Sandbox in all targets' entitlements
3. Archive in Xcode: Product > Archive
4. Distribute via App Store Connect

Required entitlements for App Store:

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

## Project Structure

```
yaml-quicklook/
├── YamlQuickLook/                    # Main application (container)
│   ├── AppDelegate.swift
│   ├── ContentView.swift
│   └── Assets.xcassets/
├── YamlQuickLookExtension/           # Quick Look preview extension
│   ├── PreviewProvider.swift
│   └── YamlQuickLookExtension.entitlements
├── YamlQuickLookThumbnailExtension/  # Thumbnail extension
│   ├── ThumbnailProvider.swift
│   └── YamlQuickLookThumbnailExtension.entitlements
├── YAMLQuickLook.xcodeproj/
├── .github/workflows/
│   └── release.yml
├── LICENSE
└── README.md
```

## Troubleshooting

### Extension not working

1. Ensure the app is in `/Applications`
2. Check System Settings > Privacy and Security > Extensions > Quick Look
3. Reset Quick Look: `qlmanage -r && qlmanage -r cache`
4. Restart Finder: `killall Finder`

### "App is damaged" error

Run: `xattr -cr /Applications/YamlQuickLook.app`

### Preview not updating after rebuild

```bash
pluginkit -a /Applications/YamlQuickLook.app/Contents/PlugIns/YamlQuickLookExtension.appex
qlmanage -r && qlmanage -r cache
killall Finder
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome. Please open an issue or submit a pull request.

To build from command line:
```bash
xcodebuild -project YAMLQuickLook.xcodeproj -scheme YamlQuickLook -configuration Release
```

## Customization

The HTML preview can be customized by modifying the CSS styles in `HTMLGenerator.swift`. The styles automatically adapt to light and dark modes.

## Troubleshooting

### Extension not appearing
1. Make sure you've built and run the main app at least once
2. Check System Preferences > Privacy & Security > Extensions > Quick Look
3. Restart Finder: `killall Finder`

### YAML files not previewing
1. Verify the file has a `.yaml` or `.yml` extension
2. Check that the file contains valid text (not binary data)
3. Large files may take longer to process

### Build errors
1. Ensure you have Xcode 15.0 or later
2. Clean build folder (⌘+Shift+K) and rebuild
3. Check that macOS deployment target is set to 14.0

## License

Copyright © 2025 YamlQuickLook. All rights reserved.

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## Changelog

### Version 1.0.0
- Initial release
- Basic YAML syntax highlighting
- Error detection and validation
- Modern responsive UI design
- Dark mode support
- Structure analysis display