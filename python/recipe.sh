./configure --enable-optimizations
make
# install pip
./python -m ensurepip
sudo make install || doas make install
