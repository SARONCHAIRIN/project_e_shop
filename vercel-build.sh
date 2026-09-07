#!/bin/bash
set -e

echo "Installing Flutter SDK..."
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

echo "Running flutter doctor..."
flutter doctor

echo "Getting dependencies..."
flutter pub get

echo "Building web release..."
flutter build web --release

echo "Build complete!"
