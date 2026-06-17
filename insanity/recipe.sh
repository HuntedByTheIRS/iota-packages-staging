export XORG_PREFIX=\"/usr\"
export XORG_CONFIG=\"--prefix=$XORG_PREFIX --sysconfdir=/etc --localstatedir=/var --disable-static\"
doas printf 'XORG_PREFIX=\"%s\"\nXORG_CONFIG=\"--prefix=%s --sysconfdir=/etc --localstatedir=/var --disable-static\"\nexport XORG_PREFIX XORG_CONFIG\\n' \"$XORG_PREFIX\" \"$XORG_PREFIX\" > /etc/profile.d/xorg.sh
doas chmod 644 /etc/profile.d/xorg.sh
