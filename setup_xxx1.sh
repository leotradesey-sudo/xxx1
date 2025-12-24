#!/bin/bash

# 1. Install dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y git build-essential automake libssl-dev libcurl4-openssl-dev libjansson-dev libgmp-dev

# 2. Clone or Enter directory
# 2. Clone or Enter directory
if [ -f "build.sh" ] && [ -f "ccminer.cpp" ]; then
    echo "Files found. Running in current directory."
elif [ -d "ccminer" ]; then
    echo "Directory ccminer exists, entering..."
    cd ccminer
else
    echo "Cloning ccminer..."
    git clone https://github.com/monkins1010/ccminer.git
    cd ccminer
fi

# 3. Check for sse2neon (Required for ARM builds)
if [ ! -f "verus/sse2neon/sse2neon.h" ]; then
    echo "sse2neon.h not found. Creating directory and downloading..."
    mkdir -p verus/sse2neon
    wget -O verus/sse2neon/sse2neon.h https://raw.githubusercontent.com/DLTcollab/sse2neon/master/sse2neon.h
    echo "sse2neon.h downloaded."
fi

# 4. Apply Patch for v4 Alias
# We check if v4 is already in algos.h to avoid double insertion
if ! grep -q '"v4"' algos.h; then
    echo "Applying v4 alias patch to algos.h..."
    sed -i '/i = ALGO_ZR5;/a \
		else if (!strcasecmp("v4", arg))\
			i = ALGO_EQUIHASH;' algos.h
    echo "Patch applied."
else
    echo "v4 alias already present in algos.h, skipping patch."
fi

# 4. Build
echo "Building..."
chmod +x build.sh
./build.sh

# 5. Rename Binary
if [ -f ccminer ]; then
    mv ccminer xxx1
    echo "----------------------------------------------------------------"
    echo "Build successful. Binary renamed to: xxx1"
    echo "You can now run:"
    echo "./xxx1 -a v4 -o stratum+tcp://sg.vipor.net:5040 -u RTTcgMmzVR9JBYmYs33WQKeFDK6TsfEbE3.stev2 -p x -t 1"
    echo "----------------------------------------------------------------"
else
    echo "Build failed. ccminer binary not found."
fi
