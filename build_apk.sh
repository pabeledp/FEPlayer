#!/bin/bash
set -e

echo "=========================================="
echo "🤖 Building FE Player Android APK"
echo "=========================================="

cd "$(dirname "$0")"

# Build Android Release APK
flutter pub get
flutter build apk --release

mkdir -p apk_output
cp build/app/outputs/flutter-apk/app-release.apk apk_output/FEPlayer-Android.apk

echo "=========================================="
echo "✅ Android APK Build Complete!"
echo "📍 Location: $(pwd)/apk_output/FEPlayer-Android.apk"
echo "=========================================="
