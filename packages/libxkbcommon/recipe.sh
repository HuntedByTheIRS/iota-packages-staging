patch -Np1 -i ../libxkbcommon-1.13.2-upstream_fix-1.patch
mkdir build && cd build
meson setup .. --prefix=/usr --buildtype=release -D enable-docs=false
ninja -j$JOBOPTS
$IOTA_SUPERUSER make install
