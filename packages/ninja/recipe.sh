mkdir build &&
cd    build &&

cmake ..                   \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/usr &&
make -j$JOBOPTS
sudo make install || doas make install
