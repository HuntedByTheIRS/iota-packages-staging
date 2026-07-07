./configure --prefix=/usr --disable-static \
    --without-jpeg --without-tiff --without-zlib
make -j$JOBOPTS
$IOTA_SUPERUSER make install
