mkdir build &&
cd    build &&

meson setup ..                 \
      --prefix=/usr            \
      --buildtype=release      \
      -D documentation=disabled \
      -D tests=disabled        &&
ninja
sudo ninja install || doas ninja install
