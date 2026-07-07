cd nss
./build.sh --opt --system-sqlite --system-nspr --with-nspr-prefix=/usr
$IOTA_SUPERUSER cp -r ../dist/Release/lib/* /usr/lib/
$IOTA_SUPERUSER cp -r ../dist/Release/bin/* /usr/bin/
$IOTA_SUPERUSER cp -r ../dist/public/nss/* /usr/include/nss/
