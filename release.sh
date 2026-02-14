#!/bin/bash
# Release script for Backup Manager
# Usage: ./release.sh [version]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
    # Try to get version from skill.json
    VERSION=$(grep '"version"' skill.json | head -1 | sed 's/.*: "\([^"]*\)".*/\1/')
    echo "Using version from skill.json: $VERSION"
fi

if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Version must be in format X.Y.Z (e.g., 1.0.0)"
    echo "Usage: ./release.sh 1.0.1"
    exit 1
fi

echo "🚀 Creating release v$VERSION..."

# Update version in files
echo "📄 Updating version in files..."
sed -i "s/\"version\": \"[0-9.]\+\"/\"version\": \"$VERSION\"/" skill.json
sed -i "s/v[0-9.]\+ - Initial release/v$VERSION - Release/" CHANGELOG.md

# Git operations
echo "📝 Committing version bump..."
git add skill.json CHANGELOG.md
git commit -m "Bump version to $VERSION" || echo "No changes to commit"

echo "🏷️  Creating tag..."
git tag -a "v$VERSION" -m "Release version $VERSION" || {
    echo "Tag v$VERSION already exists. Delete it with: git tag -d v$VERSION"
    exit 1
}

# Create release archives
echo "📦 Creating release archives..."
RELEASE_DIR="releases"
mkdir -p "$RELEASE_DIR"

# Tar.gz
tar -czf "$RELEASE_DIR/backup-manager-skill-v$VERSION.tar.gz" \
    --exclude='.git' \
    --exclude='releases' \
    --exclude='config/backup.conf' \
    .

# Zip
zip -r "$RELEASE_DIR/backup-manager-skill-v$VERSION.zip" \
    . \
    -x '.git/*' \
    -x 'releases/*' \
    -x 'config/backup.conf'

echo ""
echo "✅ Release v$VERSION created successfully!"
echo ""
echo "Next steps:"
echo "  1. Push to GitHub:"
echo "     git push origin main"
echo "     git push origin v$VERSION"
echo ""
echo "  2. Create GitHub release:"
echo "     - Go to https://github.com/YOUR_USERNAME/backup-manager-skill/releases"
echo "     - Click 'Draft a new release'"
echo "     - Choose tag: v$VERSION"
echo "     - Upload files from: $RELEASE_DIR/"
echo ""
echo "  3. Share the release URL with your friends!"
echo ""
echo "📦 Release files:"
ls -lh "$RELEASE_DIR/"
