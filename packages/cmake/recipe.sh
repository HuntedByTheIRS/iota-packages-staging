./bootstrap --prefix=/usr -- -DCMAKE_BUILD_TYPE=Release -DCMAKE_USE_OPENSSL=ON
make -j$JOBOPTS
$IOTA_SUPERUSER make install
