# YamlQuickLook

YamlQuickLook is a macOS Quick Look extension for YAML files that provides syntax highlighting, validation, and a refined preview interface.

## Features

- **Syntax Highlighting**: Color-coded YAML rendered with consistent typography
- **YAML Validation**: Detects and displays parsing errors with contextual messages
- **Dark Mode Support**: Automatically adapts to the system appearance
- **Structure Analysis**: Summarizes key statistics, depth, and hierarchy
- **Modern Design**: Provides a clean, readable layout aligned with macOS guidelines
- **Fast Performance**: Parses and renders YAML content with minimal latency

## Supported File Types

- `.yaml` files
- `.yml` files
- Files with YAML MIME types (`application/x-yaml`, `text/yaml`, `text/x-yaml`)

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later (for building from source)

## Installation

### Option 1: Build from Source

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd yamlQuickLook
   ```

2. **Open in Xcode**:
   ```bash
   open YAMLQuickLook.xcodeproj
   ```

3. **Build the project**:
   - Select the `YamlQuickLook` scheme
   - Build and run the project (⌘+R)
   - The app will build and install the Quick Look extension

4. **Enable the extension**:
   - Go to **System Preferences** > **Privacy & Security** > **Extensions** > **Quick Look**
   - Enable "YAML Quick Look"

### Option 2: Manual Installation

1. Build the project as described above
2. Copy the built app to your Applications folder
3. Run the app once to register the extension
4. Enable the extension in System Preferences

## Usage

1. Navigate to any YAML file in Finder
2. Select the file and press **Space** for Quick Look preview
3. Or right-click the file and select **Quick Look**

The extension displays:
- Syntax-highlighted YAML content
- File statistics such as key counts and nesting depth
- Validation status for valid and invalid YAML documents
- Error messages with source context when parsing fails
- Parsed structure representation

## Development

### Project Structure

```
YamlQuickLook/
├── YamlQuickLook/              # Main application
│   ├── AppDelegate.swift       # App entry point
│   ├── ContentView.swift       # Main app UI
│   ├── Main.storyboard         # Interface builder file
│   └── Assets.xcassets         # App assets
├── YamlQuickLookExtension/     # Quick Look extension
│   ├── PreviewProvider.swift   # Main extension logic
│   ├── YAMLParser.swift        # YAML parsing utilities
│   └── HTMLGenerator.swift     # HTML generation for preview
└── YAMLQuickLook.xcodeproj     # Xcode project file
```

### Key Components

- **PreviewProvider**: Main Quick Look extension class that handles preview generation
- **YAMLParser**: Handles YAML parsing using the Yams library, provides validation and structure analysis
- **HTMLGenerator**: Creates modern, responsive HTML previews with syntax highlighting

### Dependencies

- **Yams**: Swift YAML parser library for parsing and validating YAML content

### Building

The project uses Swift Package Manager for dependency management. Yams will be automatically downloaded and built when you build the project.

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