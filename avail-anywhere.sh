#!/bin/bash

cat << 'EOF'
                  _ _                                  _                    
                 (_) |                                | |                   
  __ ___   ____ _ _| |______ __ _ _ __  _   ___      _| |__   ___ _ __ ___  
 / _` \ \ / / _` | | |______/ _` | '_ \| | | \ \ /\ \ / / '_\/ _ \ '__/ _ \ 
| (_| |\ V / (_| | | |     | (_| | | | | |_| |\ V  V /| | | |  __/ | |  __/ 
 \__,_| \_/ \__,_|_|_|      \__,_|_| |_|\__, | \_/\_/ |_| |_|\___|_|  \___| 
                                         __/ |                              
                                        |___/                               

EOF

echo -e "Where do you want to run your avail light node? \(ᵔᵕᵔ)/ \n1. Desktop\n2. Phone "
read -p "Option: " OPT

if [[ "$OPT" == "1" ]]; then
    echo "Running on Desktop..."
    curl -sL1 avail.sh | sh
    exit 0
elif [[ "$OPT" == "2" ]]; then
    echo "Running on Phone..."
else
    echo "Invalid option. Exiting ..."
    exit 1
fi

# Install git
apt-get install -qq git -y

# Install necessary packages
for pkg in proot-distro; do
    if ! dpkg -s $pkg >/dev/null 2>&1; then
        pkg install $pkg -y
    fi
done

# Install Ubuntu
if [ ! -d "/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu" ]; then
    proot-distro install ubuntu
fi

# Login to the Ubuntu container and execute the commands
proot-distro login ubuntu -- bash -c '

# Check if rust is installed
if command -v rustup &> /dev/null; then
    echo "Rust is already installed, skipping installation"
else
    echo "Installing Rust..."
    # Download and install rustup
    curl https://sh.rustup.rs -sSf | sh -s -- -y
fi

# Clone the avail-light repository
if [ ! -d "avail-light" ]; then
    git clone https://github.com/availproject/avail-light.git
fi

# Change into the newly cloned directory
cd avail-light

# Check if 'avail-light-linux-aarch64.tar.gz' already exists
if [ ! -f "avail-light-linux-aarch64.tar.gz" ]; then
    # Download the avail-light Linux aarch64 binary
    curl -LO https://github.com/availproject/avail-light/releases/download/v1.7.3-rc2/avail-light-linux-aarch64.tar.gz
fi

# Check if 'avail-light-linux-aarch64' already exists
if [ ! -f "avail-light-linux-aarch64" ]; then
    # Decompress the downloaded file
    tar -xf avail-light-linux-aarch64.tar.gz
fi
# Run the avail-light binary with biryani network
./avail-light-linux-aarch64  --network biryani'
