mkdir build &&
cd    build &&

meson setup ..               \
      --prefix=/usr          \
      --buildtype=release    \
      -D examples=false      &&
ninja
sudo ninja install || doas ninja install
