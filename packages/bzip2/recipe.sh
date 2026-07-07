make -f Makefile-libbz2_so
make -j$JOBOPTS
$IOTA_SUPERUSER make PREFIX="${IOTA_ROOT_PATH}/usr" install
