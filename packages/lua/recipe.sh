make posix -j"${JOBOPTS:-$(nproc)}"
make INSTALL_TOP="${IOTA_ROOT_PATH}/usr" install
