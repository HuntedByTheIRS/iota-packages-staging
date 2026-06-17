set -euo pipefail
checksum="1153d3d50e0ac764b447adfe05c2bcf08e889d42a02e0fe0259bd47f6733ad7f  go1.26.4.linux-amd64.tar.gz"
# test for preexisting go installation
if [ -d /usr/local/go ]
	echo "Go installation detected. Deleting now..."
	rm -rf /usr/local/go
fi

# Download Go and verify package
wget "https://go.dev/dl/go1.26.4.linux-amd64.tar.gz"
echo $checksum | sha256sum -c -

# Extract Go to /usr/local
tar -xzf "go1.26.4.linux-amd64.tar.gz" -C /usr/local

# Add /usr/local/go/bin to PATH
echo "PATH=$PATH:/usr/local/go/bin" >> /etc/profile
echo "To use go, please source /etc/profile (or restart your shell). Thank you :)"
