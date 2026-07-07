./configure --prefix=/usr \
            --enable-gold \
            --enable-ld=default \
            --enable-plugins \
            --enable-shared \
            --disable-werror
make tooldir=/usr -j$JOBOPTS
$IOTA_SUPERUSER make tooldir=/usr install
