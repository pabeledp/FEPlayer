#!/bin/bash
set -e

echo "=========================================="
echo "🚀 Building FE Player macOS App & DMG"
echo "=========================================="

cd "$(dirname "$0")"

# 1. Check & Install CocoaPods if needed
if ! command -v pod &> /dev/null; then
    echo "📦 CocoaPods not found. Installing CocoaPods..."
    sudo gem install cocoapods || brew install cocoapods
fi

# 2. Check & Install create-dmg
if ! command -v create-dmg &> /dev/null; then
    echo "📦 create-dmg not found. Installing via Homebrew..."
    brew install create-dmg || true
fi

# 3. Build Flutter macOS Release App
echo "🔨 Building Flutter macOS Release application..."
flutter pub get
flutter build macos --release

# 4. Create DMG Package
APP_PATH="build/macos/Build/Products/Release/fe_player.app"
DMG_DIR="dmg_output"
DMG_NAME="FEPlayer-macOS.dmg"

mkdir -p "$DMG_DIR"
rm -f "$DMG_DIR/$DMG_NAME"

echo "💿 Packaging DMG..."
if command -v create-dmg &> /dev/null; then
    create-dmg \
      --volname "FE Player" \
      --window-pos 200 120 \
      --window-size 600 400 \
      --icon-size 100 \
      --icon "fe_player.app" 150 190 \
      --hide-extension "fe_player.app" \
      --app-drop-link 450 185 \
      "$DMG_DIR/$DMG_NAME" \
      "$APP_PATH"
else
    # Fallback native hdiutil DMG creation
    hdiutil create -volname "FE Player" -srcfolder "$APP_PATH" -ov -format UDZO "$DMG_DIR/$DMG_NAME"
fi

echo "=========================================="
echo "✅ DMG Build Complete!"
echo "📍 Location: $(pwd)/$DMG_DIR/$DMG_NAME"
echo "=========================================="
