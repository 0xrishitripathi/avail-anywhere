#!/bin/bash

cat << 'EOF'
                  _ _                                  _                    
                 (_) |                                | |                   
  __ ___   ____ _ _| |______ __ _ _ __  _   ___      _| |__   ___ _ __ ___  
 / _` \ \ / / _` | | |______/ _` | '_ \| | | \ \ /\ \ / / '_ \/ _ \ '__/ _ \ 
| (_| |\ V / (_| | | |     | (_| | | | | |_| |\ V  V /| | | |  __/ | |  __/ 
 \__,_| \_/ \__,_|_|_|      \__,_|_| |_|\__, | \_/\_/ |_| |_|\___|_|  \___| 
                                         __/ |                              
                                        |___/                               

EOF

# User Prompt
echo -e "Where do you want to run your avail light node? \(ᵔᵕᵔ)/ 
1. Desktop
2. Phone "
read -p "Option: " OPT

# Handling user selection
case "$OPT" in
  1)
    echo "Running on Desktop..."
    curl -sL1 avail.sh | bash
    ;;
  2)
    echo "Running on Phone..."
    ;;
  *)
    echo "Invalid option. Exiting ..."
    exit 1
    ;;
esac

# Install git, jq and manage package installations depending on environment
if command -v apt-get >/dev/null; then
    apt-get install -qq git jq -y
elif command -v pkg >/dev/null; then
    pkg install git jq -y
else
    echo "No suitable package manager found. Please install git and jq manually."
    exit 1
fi

# Install proot-distro if not already installed
if ! dpkg -s proot-distro >/dev/null 2>&1; then
    echo "Installing proot-distro..."
    apt-get install -qq proot-distro -y
fi

# Ensure the Ubuntu distro is installed and set up
if [ ! -d "/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu" ]; then
    proot-distro install ubuntu
fi

# Login to the Ubuntu container to execute further setup
proot-distro login ubuntu -- bash -c '
# Install jq if not already installed in the container
if ! command -v jq >/dev/null; then
    apt-get install -qq jq -y
fi

# Function to check and update the avail-light binary
update_avail_light() {
    # Fetch the latest release version and download URL from GitHub
    JSON=$(curl -s https://api.github.com/repos/availproject/avail-light/releases/latest)
    LATEST_VERSION=$(echo "$JSON" | jq -r ".tag_name")
    LATEST_URL=$(echo "$JSON" | jq -r ".assets[] | select(.name | test(\"linux-arm64.tar.gz\")) | .browser_download_url")

    # Check if the installed version matches the latest version
    if [ -f "avail-light-version" ] && [ "$(cat avail-light-version)" = "$LATEST_VERSION" ]; then
        echo "You are already running the latest version: $LATEST_VERSION."
        return
    fi

    echo "Updating to avail-light $LATEST_VERSION..."
    curl -LO "$LATEST_URL"
    tar -xf "avail-light-linux-arm64.tar.gz"
    
    # Update the version file
    echo "$LATEST_VERSION" > avail-light-version
}

# Check and update the avail-light package
update_avail_light

# Run the avail-light binary with the turing network
./avail-light-linux-arm64 --network turing
'
