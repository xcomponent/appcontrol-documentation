#!/bin/bash


# Set variables
BINARY_NAME=
DOWNLOAD_URL=
# Check processor architecture
ARCHITECTURE=$(uname -m)

if [ "$ARCHITECTURE" == "arm64" ]; then
    # M1 (arm64) specific actions
    echo "Running on M1 processor"
    BINARY_NAME=xcAgent_macm1
	DOWNLOAD_URL=https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/xcAgent_macm1.zip
else
    # Intel (x86_64) specific actions
    echo "Running on Intel processor"
    BINARY_NAME=xcAgent_macintel
	DOWNLOAD_URL=https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/xcagent_macintel.zip
fi



INSTALL_DIR="/usr/local/bin/${BINARY_NAME}/"
CONFIG_DIR="/etc/${BINARY_NAME}/"
DAEMON_LABEL="com.appcontrol.agent"
PLIST_FILE="/Library/LaunchDaemons/${DAEMON_LABEL}.plist"


DOWNLOAD_PATH="/tmp/${BINARY_NAME}.zip"

# Create installation and configuration directories
sudo mkdir -p "$INSTALL_DIR"

# Download and unzip the binary
curl -L -o "$DOWNLOAD_PATH" "$DOWNLOAD_URL"
unzip -o "$DOWNLOAD_PATH" -d "$INSTALL_DIR"

# Set permissions for the installation directory
sudo chown -R root:wheel "$INSTALL_DIR"
sudo chmod -R 755 "$INSTALL_DIR"

# Assuming config.dat is directly within the extracted contents, move it to the installation directory
mv "${INSTALL_DIR}config.dat" "$INSTALL_DIR"

# Boost, libssh2, and OpenSSL versions
BOOST_VERSION="1.83.0"
LIBSSH2_VERSION="1.11.0_1"
OPENSSL_VERSION="3.1.3"

# Install Boost
brew install boost@$BOOST_VERSION

# Install libssh2
brew install libssh2@$LIBSSH2_VERSION

# Install OpenSSL@3
brew install openssl@3@$OPENSSL_VERSION

# Set environment variables for the build process
export LDFLAGS="-L/usr/local/opt/openssl@3/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@3/include"

# Copy configuration files to the configuration directory
cp -r "${INSTALL_DIR}configmac.dat" "$CONFIG_DIR"

# Create the launchd plist file
cat <<EOF | sudo tee "$PLIST_FILE" > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${DAEMON_LABEL}</string>
    <key>Program</key>
    <string>${INSTALL_DIR}${BINARY_NAME}</string>
    <key>RunAtLoad</key>
    <true/>
	<key>ProgramArguments</key>
    <array>
        <string>${INSTALL_DIR}${BINARY_NAME}</string>
        <string>--file</string>
        <string>$(CONFIG_DIR)/configmac.dat</string>
    </array>
</dict>
</plist>
EOF

# Set permissions for the plist file
sudo chown root:wheel "$PLIST_FILE"
sudo chmod 644 "$PLIST_FILE"

# Load the launchd daemon
sudo launchctl load "$PLIST_FILE"

# Start the daemon
sudo launchctl start "$DAEMON_LABEL"

# Clean up - remove the downloaded zip file
rm -f "$DOWNLOAD_PATH"

echo "Deployment complete. Daemon is now running."