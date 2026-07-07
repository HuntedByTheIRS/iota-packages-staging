./configure --prefix=/usr \
            -release \
            -opensource \
            -confirm-license \
            -nomake examples \
            -nomake tests \
            -skip qtwebengine \
            -skip qtwebchannel \
            -skip qtwebview \
            -skip qtdoc
cmake --build . --parallel $JOBOPTS
$IOTA_SUPERUSER cmake --install .
