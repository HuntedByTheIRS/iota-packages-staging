mkdir build &&
cd    build &&

meson setup ..               \
      --prefix=/usr          \
      --buildtype=release    \
      -D documentation=false \
      -D tests=false         \
      -D libwacom=false      \
      -D debug-gui=false     &&
ninja
sudo ninja install || doas ninja install
