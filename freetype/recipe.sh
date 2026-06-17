sed -ri \"s:.*(AUX_MODULES.*valid):\\1:\" modules.cfg
sed -r \"s:.*(#.*SUBPIXEL_RENDERING) .*:\\1:\" -i include/freetype/config/ftoption.h
./configure --prefix=/usr --disable-static --enable-freetype-config --with-harfbuzz=dynamic
make -j$(( $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 / 1024 / 2 ))
sudo make install || doas make install
