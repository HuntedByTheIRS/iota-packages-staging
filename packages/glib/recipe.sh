mkdir build && cd build

meson setup .. \
	--prefix=/usr \
	--buildtype=release \
	-D introspection=disabled \
	-D glib_debug=disabled \
	-D man-pages=enabled \
	-D sysprof=disabled
ninja
