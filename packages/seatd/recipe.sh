mkdir build &&
cd    build &&

meson setup --prefix=/usr           \
            --buildtype=release     \
            -Dserver=enabled        \
            -Dbuiltin=enabled       \
            .. &&
ninja
sudo ninja install || doas ninja install
sudo echo '#!/sbin/openrc-run

description="Seat management daemon"
supervisor="supervise-daemon"
command="/usr/bin/seatd"
command_args="-g seat"

depend() {
    need dev
    before localmount
}' > /etc/init.d/seatd || doas '#!/sbin/openrc-run

description="Seat management daemon"
supervisor="supervise-daemon"
command="/usr/bin/seatd"
command_args="-g seat"

depend() {
    need dev
    before localmount
}' > /etc/init.d/seatd
 
