./configure --prefix=/usr --enable-shared --disable-cli
make -j$JOBOPTS
$IOTA_SUPERUSER make install
