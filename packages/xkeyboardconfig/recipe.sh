mkdir build && cd build
meson setup --prefix=$XORG_PREFIX --buildtype=release ..
ninja -j$(( $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 / 1024 / 2 ))
sudo ninja install || doas ninja install
