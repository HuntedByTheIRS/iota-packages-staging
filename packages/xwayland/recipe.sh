sed -i '/install_man/,$d' meson.build

mkdir build &&
cd    build &&

meson setup ..                            \
      --prefix=/usr                       \
      --buildtype=release                 \
      -D glamor=false                     \
      -D glx=false                        \
      -D xdmcp=false                      \
      -D secure-rpc=false                 \
      -D systemd_notify=false             \
      -D xvfb=false                       \
      -D xinerama=false                   \
      -D xv=false                         \
      -D xres=false                       \
      -D dpms=false                       \
      -D screensaver=false                \
      -D xace=false                       \
      -D xf86bigfont=false                \
      -D dri3=false                       \
      -D libdecor=false                   \
      -D xwayland_ei=false                \
      -D sha1=libcrypto                   \
      -D docs=false                       \
      -D devel-docs=false                 \
      -D docs-pdf=false                   \
      -D ipv6=false                       \
      -D default_font_path=""             \
      -D xkb_output_dir=/var/lib/xkb

ninja
sudo ninja install || doas ninja install
