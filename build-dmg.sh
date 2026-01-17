#!/bin/bash

# Build script for Yiddish Klal keyboard layout installers (DMG)
# Usage: ./build-dmg.sh [bundle-name]
# Example: ./build-dmg.sh "Yiddish-Klal"
# Example: ./build-dmg.sh "Yiddish-Klal-Ligatur"

set -e  # Exit on error

# Check for fileicon tool
if ! command -v fileicon &> /dev/null; then
    echo "Installing fileicon..."
    brew install fileicon
fi

# Get bundle directory name from argument or use default
BUNDLE_DIR="${1:-Yiddish-Klal}"

# Determine bundle filename based on directory
if [[ "$BUNDLE_DIR" == "Yiddish-Klal-Ligatur" ]]; then
    BUNDLE_NAME="Yiddish Klal Ligatur.bundle"
    DMG_NAME="YiddishKlalLigatur.dmg"
    VOLUME_NAME="Yiddish Klal Ligatur - Installer"
else
    BUNDLE_NAME="Yiddish Klal.bundle"
    DMG_NAME="YiddishKlal.dmg"
    VOLUME_NAME="Yiddish Klal - Installer"
fi

BACKGROUND_IMAGE="dmg-background.png"
KEYBOARD_ICON="Yiddish Klal.icns"

echo "Building DMG for: $BUNDLE_NAME"
echo "Output: $DMG_NAME"

# Verify required files exist
if [ ! -d "$BUNDLE_DIR/$BUNDLE_NAME" ]; then
    echo "Error: Bundle not found at $BUNDLE_DIR/$BUNDLE_NAME"
    exit 1
fi

if [ ! -f "$BACKGROUND_IMAGE" ]; then
    echo "Error: Background image not found at $BACKGROUND_IMAGE"
    exit 1
fi

if [ ! -f "$KEYBOARD_ICON" ]; then
    echo "Error: Keyboard icon not found at $KEYBOARD_ICON"
    exit 1
fi

# Create staging directory
STAGING_DIR=$(mktemp -d)
echo "Creating staging directory at $STAGING_DIR"

# Copy bundle to staging
cp -R "$BUNDLE_DIR/$BUNDLE_NAME" "$STAGING_DIR/"

# Set the bundle's icon using fileicon
echo "Setting bundle icon..."
fileicon set "$STAGING_DIR/$BUNDLE_NAME" "$KEYBOARD_ICON"

# Create symlink to system Keyboard Layouts folder
echo "Creating Keyboard Layouts symlink..."
ln -s /Library/Keyboard\ Layouts "$STAGING_DIR/Keyboard Layouts"

# Remove old DMG if exists
rm -f "$DMG_NAME"

# Create the DMG
echo "Creating DMG..."
create-dmg \
  --volname "$VOLUME_NAME" \
  --volicon "$KEYBOARD_ICON" \
  --background "$BACKGROUND_IMAGE" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 80 \
  --icon "$BUNDLE_NAME" 300 70 \
  --icon "Keyboard Layouts" 300 280 \
  --hide-extension "$BUNDLE_NAME" \
  "$DMG_NAME" \
  "$STAGING_DIR"

# Clean up
rm -rf "$STAGING_DIR"

echo "✓ DMG created successfully: $DMG_NAME"