#!/bin/bash

# ตั้งค่าตัวแปร
DOCKER_USERNAME="luxaubons"
IMAGE_NAME="gh-laravel-app"
VERSION_FILE="VERSION"

# อ่าน version ปัจจุบัน
if [ -f "$VERSION_FILE" ]; then
    CURRENT_VERSION=$(cat $VERSION_FILE)
else
    CURRENT_VERSION="0.0.0"
    echo $CURRENT_VERSION > $VERSION_FILE
fi

echo "Current version: $CURRENT_VERSION"

# ถาม version ใหม่
echo "Enter new version (or press enter to auto-increment patch version):"
read NEW_VERSION

if [ -z "$NEW_VERSION" ]; then
    # Auto increment patch version
    IFS='.' read -r major minor patch <<< "$CURRENT_VERSION"
    NEW_VERSION="$major.$minor.$((patch + 1))"
fi

echo "Building version: $NEW_VERSION"

# Build image
docker build -t $DOCKER_USERNAME/$IMAGE_NAME:$NEW_VERSION -f Dockerfile .

# Tag as latest
docker tag $DOCKER_USERNAME/$IMAGE_NAME:$NEW_VERSION $DOCKER_USERNAME/$IMAGE_NAME:latest

# Push to Docker Hub
echo "Pushing to Docker Hub..."
docker push $DOCKER_USERNAME/$IMAGE_NAME:$NEW_VERSION
docker push $DOCKER_USERNAME/$IMAGE_NAME:latest

# Update version file
echo $NEW_VERSION > $VERSION_FILE

echo "Successfully pushed version $NEW_VERSION"

# แสดง version history
echo ""
echo "Available versions on Docker Hub:"
docker images $DOCKER_USERNAME/$IMAGE_NAME --format "table {{.Tag}}\t{{.CreatedAt}}\t{{.Size}}"