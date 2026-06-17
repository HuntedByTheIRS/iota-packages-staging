export XORG_PREFIX=\"/usr\"
export XORG_CONFIG=\"--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static\"
$IOTA_SUPERUSER printf 'XORG_PREFIX=\"%s\"\nXORG_CONFIG=\"--prefix=%s --sysconfdir=/etc --localstatedir=/var --disable-static\"\nexport XORG_PREFIX XORG_CONFIG\\n' \"$XORG_PREFIX\" \"$XORG_PREFIX\" > /etc/profile.d/xorg.sh
$IOTA_SUPERUSER chmod 644 /etc/profile.d/xorg.sh
