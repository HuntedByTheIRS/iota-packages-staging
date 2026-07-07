./Configure --prefix=/usr \
            --openssldir=/etc/ssl \
            shared \
            no-ssl3 \
            no-ssl3-method \
            no-tests
make -j$JOBOPTS
$IOTA_SUPERUSER make install_sw
