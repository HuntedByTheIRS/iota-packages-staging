./configure $XORG_CONFIG --without-doxygen --docdir='${datadir}'/doc/libxcb-1.17.0
LC_ALL=en_US.UTF-8 make -j$(( $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 / 1024 / 2 ))
sudo make install || doas make install
