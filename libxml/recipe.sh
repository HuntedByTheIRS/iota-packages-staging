sed -i "/'git'/,+3d" meson.build
mkdir build &&
cd    build &&

meson setup ..           \
      --prefix=/usr      \
      -D history=enabled \
      -D icu=enabled     &&
ninja
sed -e "/^dir_doc/s/\$/ + '-' + meson.project_version()/" \
    -i ../meson.build                                     &&
meson configure -D docs=enabled                           &&
sudo ninja install || doas ninja install
