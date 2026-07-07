make PREFIX=/usr libudev.so.1 libudev.pc
sudo make PREFIX=/usr install-shared || doas make PREFIX=/usr install-shared
