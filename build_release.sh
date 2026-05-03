#!/bin/bash
echo "==> Cleaning project..."
flutter clean
echo "==> Getting dependencies..."
flutter pub get
echo "==> Generating launcher icons..."
flutter pub run flutter_launcher_icons
echo "==> Building release AAB..."
flutter build appbundle --release
echo "==> Done! AAB location:"
echo "build/app/outputs/bundle/release/app-release.aab"
