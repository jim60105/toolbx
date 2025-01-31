#!/bin/bash

# Set fixed path
download_path="/tmp/azure-functions-core-tools.zip"
install_dir="/azure-functions-core-tools"

# Get the latest release download link
download_url=$(curl -s https://api.github.com/repos/Azure/azure-functions-core-tools/releases/latest | \
  jq -r '.assets[] | select(.name | test("Azure\\.Functions\\.Cli\\.linux-x64\\.[0-9]+\\.[0-9]+\\.[0-9]+\\.zip")) | .browser_download_url' | \
  head -n 1)

# Check if the download link is found
if [ -z "$download_url" ]; then
  echo "Error: No matching download file found."
  exit 1
fi

# Download the file to the specified path
echo "Downloading $download_url..."
if ! wget -q "$download_url" -O "$download_path"; then
  echo "Download failed"
  exit 1
fi

# Check if the file was downloaded successfully
if [ ! -f "$download_path" ]; then
  echo "Error: Downloaded file does not exist"
  exit 1
fi

# Create the installation directory (requires admin privileges)
echo "Creating installation directory $install_dir..."
mkdir -p "$install_dir"

# Unzip the file to the installation directory (requires admin privileges)
echo "Unzipping file..."
if ! unzip -q -o "$download_path" -d "$install_dir"; then
  echo "Unzip failed"
  exit 1
fi

# Set executable permissions (requires admin privileges)
echo "Setting executable permissions..."
find "$install_dir" -type f \( -name "func" -o -name "gozip" \) -exec chmod +x {} \;

# Clean up temporary files (optional)
sudo rm "$download_path"

echo "Installation complete!"
echo "Executable files location: $install_dir"
echo "Please add the following path to the PATH environment variable: $install_dir"
