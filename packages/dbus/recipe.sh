mkdir build 
cd build
ninja
ninja test
sudo ninja install || doas ninja install
ln -sfv /etc/machine-id /var/lib/dbus
