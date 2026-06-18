cargo build --release

"$IOTA_SUPERUSER" cp target/release/doit "$IOTA_ROOT_PATH/doit"
"$IOTA_SUPERUSER" chown root:root "$IOTA_ROOT_PATH/doit"
"$IOTA_SUPERUSER" chmod u+s "$IOTA_ROOT_PATH/doit"
"$IOTA_SUPERUSER" tee -a /etc/doit.conf <<<"${USERNAME} permit" >/dev/null
"$IOTA_SUPERUSER" chmod 600 /etc/doit.conf
