./configure --prefix=/usr --sysconfdir=/etc --localstatedir=/var --disable-docs --docdir=/usr/share/doc/fontconfig-2.18.1
make -j$JOBOPTS
$IOTA_SUPERUSER make install 
