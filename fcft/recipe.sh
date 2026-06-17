meson build --buildtype=release
ninja -c build -j $IOTA_SUPERUSER
$IOTA_SUPERUSER ninja -C build install
