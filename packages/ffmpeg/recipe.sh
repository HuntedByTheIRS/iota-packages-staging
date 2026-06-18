patch -Np1 -i ../ffmpeg-8.1.1-chromium_method-1.patch
./configure --prefix=/usr        \
            --enable-gpl         \
            --enable-version3    \
            --enable-nonfree     \
            --disable-static     \
            --enable-shared      \
            --disable-debug      \
            --enable-libaom      \
            --enable-libass      \
            --enable-libfdk-aac  \
            --enable-libfreetype \
            --enable-libmp3lame  \
            --enable-libopus     \
            --enable-libvorbis   \
            --enable-libvpx      \
            --enable-libx264     \
            --enable-libx265     \
            --enable-openssl     \
            --enable-libdav1d    \
            --enable-libsvtav1   \
            --ignore-tests=enhanced-flv-av1,enhanced-flv-multitrack \
            --docdir=/usr/share/doc/ffmpeg-8.1.1 &&

make &&

gcc tools/qt-faststart.c -o tools/qt-faststart

sudo  make install &&

install -v -m755    tools/qt-faststart /usr/bin &&
install -v -m755 -d           /usr/share/doc/ffmpeg-8.1.1 &&
install -v -m644    doc/*.txt /usr/share/doc/ffmpeg-8.1.1 || doas make install &&

install -v -m755    tools/qt-faststart /usr/bin &&
install -v -m755 -d           /usr/share/doc/ffmpeg-8.1.1 &&
install -v -m644    doc/*.txt /usr/share/doc/ffmpeg-8.1.1
