# Makefile for YAML Quick Look Extension (Modern macOS)

APP_NAME = YamlQuickLook
INSTALL_PATH = /Applications

all: fix-project build install register test-ready

# Fix the corrupted Xcode project by removing missing file references
fix-project:
	@echo "🔧 Fixing Xcode project file..."
	@cp YAMLQuickLook.xcodeproj/project.pbxproj YAMLQuickLook.xcodeproj/project.pbxproj.backup
	@sed -i '' '/YAMLParser\.swift/d' YAMLQuickLook.xcodeproj/project.pbxproj
	@sed -i '' '/HTMLGenerator\.swift/d' YAMLQuickLook.xcodeproj/project.pbxproj
	@echo "✓ Project file cleaned"

build:
	@echo "🏗️  Building modern Quick Look extension..."
	@rm -rf build
	xcodebuild -configuration Release clean build
	@echo "✓ Build complete"

install:
	@echo "📦 Installing to $(INSTALL_PATH)..."
	@rm -rf $(INSTALL_PATH)/$(APP_NAME).app
	@if [ -d "build/Release/$(APP_NAME).app" ]; then \
		cp -R build/Release/$(APP_NAME).app $(INSTALL_PATH)/; \
	else \
		echo "❌ Build output not found at build/Release/$(APP_NAME).app"; \
		echo "Searching for build output..."; \
		find ~/Library/Developer/Xcode/DerivedData -name "$(APP_NAME).app" -type d 2>/dev/null | head -1 | xargs -I {} cp -R {} $(INSTALL_PATH)/; \
	fi
	@echo "✓ Installed to $(INSTALL_PATH)/$(APP_NAME).app"

register:
	@echo "🔌 Registering extension with system..."
	@pluginkit -a $(INSTALL_PATH)/$(APP_NAME).app/Contents/PlugIns/YamlQuickLookExtension.appex || true
	@pluginkit -m -v | grep -i yaml || echo "⚠️  Extension not found in pluginkit"
	@echo "✓ Registration attempted"

reset:
	@echo "🔄 Resetting Quick Look..."
	@qlmanage -r
	@qlmanage -r cache
	@killall Finder 2>/dev/null || true
	@killall quicklookd 2>/dev/null || true
	@echo "✓ Quick Look reset"

test-ready: reset
	@echo ""
	@echo "✅ Ready to test!"
	@echo "   Press SPACE on a YAML file in Finder"
	@echo ""
	@echo "📋 To view logs, run:"
	@echo "   log stream --predicate 'subsystem CONTAINS \"yamlquicklook\"' --level debug"
	@echo ""

test-logs:
	@echo "📊 Watching extension logs..."
	@echo "   Press SPACE on a YAML file now..."
	@log stream --predicate 'subsystem CONTAINS "yamlquicklook"' --level debug --style compact

check:
	@echo "🔍 Checking extension status..."
	@echo ""
	@echo "Extension registration:"
	@pluginkit -m -v | grep -A3 -i yaml || echo "   ❌ Not registered"
	@echo ""
	@echo "Installed location:"
	@ls -la $(INSTALL_PATH)/$(APP_NAME).app/Contents/PlugIns/*.appex 2>/dev/null || echo "   ❌ Not found"
	@echo ""
	@echo "Test file:"
	@ls -la ~/test-yaml.yaml 2>/dev/null || echo "   ⚠️  ~/test-yaml.yaml not found"
	@echo ""

clean:
	@echo "🧹 Cleaning build artifacts..."
	@rm -rf build
	@rm -rf ~/Library/Developer/Xcode/DerivedData/YAMLQuickLook-*
	@echo "✓ Clean complete"

uninstall: clean
	@echo "🗑️  Uninstalling..."
	@rm -rf $(INSTALL_PATH)/$(APP_NAME).app
	@pluginkit -r $(INSTALL_PATH)/$(APP_NAME).app/Contents/PlugIns/YamlQuickLookExtension.appex 2>/dev/null || true
	@$(MAKE) reset
	@echo "✓ Uninstalled"

.PHONY: all fix-project build install register reset test-ready test-logs check clean uninstall
