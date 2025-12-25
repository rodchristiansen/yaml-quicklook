# Makefile for YAML Quick Look Extension

APP_NAME = YamlQuickLook
INSTALL_PATH = /Applications

all: build install register reset

build:
	@echo "Building Quick Look extension..."
	@rm -rf build
	xcodebuild -scheme YamlQuickLook -configuration Release -derivedDataPath build clean build
	@echo "Build complete"

install:
	@echo "Installing to $(INSTALL_PATH)..."
	@rm -rf $(INSTALL_PATH)/$(APP_NAME).app
	@cp -R build/Build/Products/Release/$(APP_NAME).app $(INSTALL_PATH)/
	@echo "Installed to $(INSTALL_PATH)/$(APP_NAME).app"

register:
	@echo "Registering extension with system..."
	@pluginkit -a $(INSTALL_PATH)/$(APP_NAME).app/Contents/PlugIns/YamlQuickLookExtension.appex || true
	@pluginkit -a $(INSTALL_PATH)/$(APP_NAME).app/Contents/PlugIns/YamlQuickLookThumbnailExtension.appex || true
	@echo "Registration complete"

reset:
	@echo "Resetting Quick Look..."
	@qlmanage -r
	@qlmanage -r cache
	@killall Finder 2>/dev/null || true
	@killall quicklookd 2>/dev/null || true
	@echo "Quick Look reset"
	@echo ""
	@echo "Ready to test. Press Space on a YAML file in Finder."

check:
	@echo "Checking extension status..."
	@echo ""
	@echo "Extension registration:"
	@pluginkit -m -v | grep -A3 -i yaml || echo "Not registered"
	@echo ""
	@echo "Installed location:"
	@ls -la $(INSTALL_PATH)/$(APP_NAME).app/Contents/PlugIns/*.appex 2>/dev/null || echo "Not found"
	@echo ""

clean:
	@echo "Cleaning build artifacts..."
	@rm -rf build
	@rm -rf ~/Library/Developer/Xcode/DerivedData/YAMLQuickLook-*
	@echo "Clean complete"

uninstall: clean
	@echo "Uninstalling..."
	@rm -rf $(INSTALL_PATH)/$(APP_NAME).app
	@pluginkit -r $(INSTALL_PATH)/$(APP_NAME).app/Contents/PlugIns/YamlQuickLookExtension.appex 2>/dev/null || true
	@$(MAKE) reset
	@echo "Uninstalled"

.PHONY: all build install register reset check clean uninstall
