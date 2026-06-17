patch -Np1 -i ../libxkbcommon-1.13.2-upstream_fix-1.patch
mkdir build && cd build
meson setup .. --prefix=/usr --buildtype=release -D enable-docs=false
ninja -j$(( $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 / 1024 / 2 ))
sudo ninja install || doas ninja install
