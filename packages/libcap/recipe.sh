make -j$JOBOPTS
make install RAISE_SETFCAP=no prefix="${IOTA_ROOT_PATH}/usr"
