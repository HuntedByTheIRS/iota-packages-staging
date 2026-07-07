mkdir build &&
cd    build &&

meson setup ..                    \
      --prefix=/usr               \
      --buildtype=release         \
      -D b_ndebug=true            \
      -D b_lto=true               \
      -D platforms=drm            \
      -D gallium-drivers=softpipe \
      -D vulkan-drivers=[]        \
      -D dri-drivers=[]           \
      -D gbm=enabled              \
      -D egl=enabled              \
      -D egl-native-platform=drm  \
      -D gles2=enabled            \
      -D gles1=disabled           \
      -D opengl=false             \
      -D glx=disabled             \
      -D shared-glapi=enabled     \
      -D llvm=disabled            \
      -D glvnd=disabled           \
      -D osmesa=false             \
      -D valgrind=disabled        \
      -D libunwind=disabled       \
      -D gallium-nine=false       \
      -D gallium-omx=disabled     \
      -D gallium-va=disabled      \
      -D gallium-vdpau=disabled   \
      -D gallium-xa=disabled      \
      -D gallium-xvmc=disabled    \
      -D gallium-opencl=disabled  \
      -D gallium-extra-hud=false  \
      -D zstd=disabled            \
      -D zlib=enabled             \
      -D expat=enabled            \
      -D xmlconfig=enabled        \
      -D tools=[]                 \
      -D video-codecs=[]          \
      -D microsoft-clc=disabled   \
      -D shader-cache=enabled

ninja -j$JOBOPTS
sudo ninja install || doas ninja install
