./configure --enable-optimizations
make -j$JOBOPTS
# install pip
./python -m ensurepip
$IOTA_SUPERUSER make install
