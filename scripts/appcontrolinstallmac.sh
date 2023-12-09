#!/bin/bash

# Ask the user for input
echo -n "Enter the gateway name: " 
read X4B_GATEWAY_NAME
echo -n "Enter the access key: " 
read ACCESS_KEY
echo -n "Enter the secret access key: " 
read SECRET_ACCESS_KEY

# Set variables
AGENT_BINARY_NAME=
AGENT_DOWNLOAD_URL=
# Check processor architecture
ARCHITECTURE=$(uname -m)

if [ "$ARCHITECTURE" == "arm64" ]; then
    # M1 (arm64) specific actions
    echo "Running on M1 processor"
    AGENT_BINARY_NAME=xcAgent_macm1
	AGENT_DOWNLOAD_URL=https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/xcAgent_macm1.zip
else
    # Intel (x86_64) specific actions
    echo "Running on Intel processor"
    AGENT_BINARY_NAME=xcAgent_macintel
	AGENT_DOWNLOAD_URL=https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/xcagent_macintel.zip
fi

GATEWAY_DOWNLOAD_URL=https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/x4bgateway.zip

INSTALL_DIR="/usr/local/bin/appcontrol/"
AGENT_DAEMON_LABEL="com.appcontrol.agent"
AGENT_PLIST_FILE="/Library/LaunchDaemons/${AGENT_DAEMON_LABEL}.plist"

# Check if the agent is loaded and unload it if necessary
if sudo launchctl list | grep -q "$AGENT_DAEMON_LABEL"; then
    sudo launchctl unload "$AGENT_PLIST_FILE"
    echo "Unloaded existing agent."
fi


# Create installation and configuration directories
sudo mkdir -p "$INSTALL_DIR"

# Download and unzip the agent
DOWNLOAD_PATH="/tmp/${AGENT_BINARY_NAME}.zip"
curl -Ls -o "$DOWNLOAD_PATH" "$AGENT_DOWNLOAD_URL"
sudo unzip -o "$DOWNLOAD_PATH" -d "$INSTALL_DIR"
# Clean up - remove the downloaded zip file
rm -f "$DOWNLOAD_PATH"

GATEWAY_DAEMON_LABEL="com.appcontrol.gateway"
GATEWAY_PLIST_FILE="/Library/LaunchDaemons/${GATEWAY_DAEMON_LABEL}.plist"

# Check if the agent is loaded and unload it if necessary
if sudo launchctl list | grep -q "$GATEWAY_DAEMON_LABEL"; then
    sudo launchctl unload "$GATEWAY_PLIST_FILE"
    echo "Unloaded existing gateway."
fi

# Download and unzip the gateway
DOWNLOAD_PATH="/tmp/x4bgateway.zip"
curl -Ls -o "$DOWNLOAD_PATH" "$GATEWAY_DOWNLOAD_URL"
sudo unzip -o "$DOWNLOAD_PATH" -d "$INSTALL_DIR"


# Set permissions for the installation directory
sudo chown -R root:wheel "$INSTALL_DIR"
sudo chmod -R 755 "$INSTALL_DIR"

# Boost, libssh2, and OpenSSL versions
BOOST_VERSION="1.83"

# Install Boost
brew install boost@$BOOST_VERSION

# Install libssh2
brew install libssh2

# Install OpenSSL@3
brew install openssl@3

brew install mono

# Set environment variables for the build process
export LDFLAGS="-L/usr/local/opt/openssl@3/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@3/include"

# Copy configuration files to the configuration directory
#cp -r "${INSTALL_DIR}configmac.dat" "$CONFIG_DIR"

sudo chown -R root:wheel ${INSTALL_DIR}
sudo chmod -R 755 ${INSTALL_DIR}

# Create the launchd plist file
cat <<EOF | sudo tee "$AGENT_PLIST_FILE" > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${AGENT_DAEMON_LABEL}</string>
    <key>RunAtLoad</key>
    <true/>
	<key>ProgramArguments</key>
    <array>
        <string>${INSTALL_DIR}${AGENT_BINARY_NAME}</string>
        <string>--file</string>
        <string>${INSTALL_DIR}configmac.dat</string>
    </array>
</dict>
</plist>
EOF

# Set permissions for the plist file
sudo chown root:wheel "$AGENT_PLIST_FILE"
sudo chmod 644 "$AGENT_PLIST_FILE"

# Load the launchd daemon
sudo launchctl load "$AGENT_PLIST_FILE"

# Start the daemon
sudo launchctl start "$AGENT_DAEMON_LABEL"

echo "Agent is now running on port 12567"


#Create the launchd plist file
cat <<EOF | sudo tee "$GATEWAY_PLIST_FILE" > /dev/null
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${GATEWAY_DAEMON_LABEL}</string>
    <key>RunAtLoad</key>
    <true/>
	<key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/mono</string>
        <string>${INSTALL_DIR}x4b.exe</string>
        <string>run</string>
        <string>gateway</string>
        <string>-a</string>
        <string>${ACCESS_KEY}</string>
        <string>-k</string>
        <string>${SECRET_ACCESS_KEY}</string>
        <string>-g</string>
        <string>${X4B_GATEWAY_NAME}</string>
        <string>-l</string>
        <string>Trace</string>
    </array>
</dict>
</plist>
EOF

# Set permissions for the plist file
sudo chown root:wheel "$GATEWAY_PLIST_FILE"
sudo chmod 644 "$GATEWAY_PLIST_FILE"

# Load the launchd daemon
sudo launchctl load "$GATEWAY_PLIST_FILE"

# Start the daemon
sudo launchctl start "$GATEWAY_PLIST_FILE"

echo "Gateway is up and running"



