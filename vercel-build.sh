#!/bin/bash
set -e

echo "Creating .env file..."
cat > .env << ENVEOF
APP_NAME=${APP_NAME}
APP_ENV=${APP_ENV}
API_BASE_URL=${API_BASE_URL}
TIMEOUT=${TIMEOUT}
MAPBOX_TOKEN=${MAPBOX_TOKEN}
ENVEOF

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
