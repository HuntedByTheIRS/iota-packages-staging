./configure --prefix=/usr \
            --disable-makeinstall-chown \
            --disable-makeinstall-setuid
make -j$JOBOPTS
$IOTA_SUPERUSER make install
