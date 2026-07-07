mkdir build &&
cd    build &&

meson setup ..               \
      --prefix=/usr          \
      --buildtype=release    &&
ninja
sudo ninja install || doas ninja install
