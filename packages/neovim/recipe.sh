cmake -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build -j$JOBOPTS
$IOTA_SUPERUSER cmake --install build
