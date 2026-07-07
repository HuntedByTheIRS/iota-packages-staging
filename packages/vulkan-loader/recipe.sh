mkdir -p build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr \
         -DBUILD_TESTS=OFF
make -j$JOBOPTS
$IOTA_SUPERUSER make install
