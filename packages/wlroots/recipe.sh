mkdir build &&
cd    build &&

meson setup ..                    \
      --prefix=/usr               \
      --buildtype=release         \
      -D examples=false           \
      -D renderers="['gles2']"    \
      -D backends="['drm','libinput']" \
      -D xwayland=enabled         &&
ninja
sudo ninja install || doas ninja install
