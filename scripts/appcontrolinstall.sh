#!/bin/bash

ROOT_DOWNLOAD_URL="https://github.com/xcomponent/appcontrol-documentation/releases/latest/download"

ARCHIVE_NAME_ALMA_LINUX="almalinux.tar.gz"
ARCHIVE_NAME_ALPINE_LINUX="alpine.tar.gz"
ARCHIVE_NAME__ROCKY_LINUX="rockylinux.tar.gz"
ARCHIVE_NAME__DEBIAN_LINUX="debian.tar.gz"
BINARY_NAME="xcAgent.bin"
APP_FOLDER="x4bagent"
ARCHIVE_NAME=""

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -a|--alma)
            ARCHIVE_NAME="$ARCHIVE_NAME_ALMA_LINUX"
            shift
            ;;
        -r|--rocky)
            ARCHIVE_NAME="$ARCHIVE_NAME__ROCKY_LINUX"
            shift
            ;;
        -d|--debian)
            ARCHIVE_NAME="$ARCHIVE_NAME__DEBIAN_LINUX"
            shift
            ;;
        -p|--alpine)
            ARCHIVE_NAME="$ARCHIVE_NAME_ALPINE_LINUX"
            shift
            ;;
        *)
            echo "Invalid option: $key"
            exit 1
            ;;
    esac
done

if [ -z "$ARCHIVE_NAME" ]; then
    read -p "Which version of the binary do you want ? (alma/alpine/rocky/debian): " choice

    case "$choice" in
        alma)
            ARCHIVE_NAME="$ARCHIVE_NAME_ALMA_LINUX"
            ;;
        rocky)
            ARCHIVE_NAME="$ARCHIVE_NAME__ROCKY_LINUX"
            ;;
        debian)
            ARCHIVE_NAME="$ARCHIVE_NAME__DEBIAN_LINUX"
            ;;
        alpine)
            ARCHIVE_NAME="$ARCHIVE_NAME_ALPINE_LINUX"
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
fi



# Create the appcontrol folder
mkdir -p "$APP_FOLDER"

# Download the tar.gz archive
ARCHIVE_FULL_PATH="$APP_FOLDER/$ARCHIVE_NAME"
curl -s -L "$ROOT_DOWNLOAD_URL/$ARCHIVE_NAME" -o "$ARCHIVE_FULL_PATH" 
if [ $? -eq 0 ]; then
    echo "Archive downloaded successfully."
else
    echo "Failed to download archive."
    exit 1
fi

# Extract the archive
tar -xzvf "$ARCHIVE_FULL_PATH" -C "$APP_FOLDER"
if [ $? -eq 0 ]; then
    echo "Archive extracted successfully."
else
    echo "Failed to extract archive."
    exit 1
fi

# Make the binary executable (if needed)
chmod +x "$APP_FOLDER/$BINARY_NAME"

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$APP_FOLDER/libs

# Start the binary
"$APP_FOLDER/$BINARY_NAME"