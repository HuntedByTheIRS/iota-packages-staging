./Configure -des -Dprefix=/usr -Dcc=gcc -Duseshrplib -Dusethreads
make -j$JOBOPTS
$IOTA_SUPERUSER make install
