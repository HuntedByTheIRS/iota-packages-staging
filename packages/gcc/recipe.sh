mkdir -p objdir
cd objdir
../configure --prefix=/usr/local/gcc-build --enable-languages=c,c++ --disable-multilib
make -j$JOBOPTS
$IOTA_SUPERUSER make install
