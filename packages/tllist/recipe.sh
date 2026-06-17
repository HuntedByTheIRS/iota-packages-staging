mkdir build && cd build
meson --prefix=/usr --buildtype=release ..
ninja
sudo ninja install || doas ninja install
