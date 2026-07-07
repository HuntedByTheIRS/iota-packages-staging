./configure --prefix=/usr --disable-static
make -j$JOBOPTS
$IOTA_SUPERUSER make install
