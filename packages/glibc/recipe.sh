mkdir -p build && cd build
echo "slibdir=/usr/lib" >> ../configparms
../configure --prefix=/usr              \
             --disable-werror           \
             --enable-kernel=6.0        \
             --enable-stack-protector=strong \
             --with-headers="${IOTA_ROOT_PATH}/usr/include" \
             libc_cv_slibdir=/usr/lib
make -j$JOBOPTS
$IOTA_SUPERUSER make install
