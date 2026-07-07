make release -j"${JOBOPTS:-$(nproc)}"
make DESTDIR="${IOTA_ROOT_PATH}" PREFIX=/usr install
