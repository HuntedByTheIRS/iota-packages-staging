./configure --prefix=/usr \
            --enable-shared \
            --disable-static \
            --enable-gpl \
            --enable-libx264 \
            --enable-libx265 \
            --enable-openssl
make -j$JOBOPTS
$IOTA_SUPERUSER make install
