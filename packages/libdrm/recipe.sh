mkdir build &&
cd    build &&

meson setup ..              \
      --prefix=/usr         \
      --buildtype=release   \
      -D tests=false        \
      -D udev=true          &&
ninja
sudo ninja install || doas ninja install
