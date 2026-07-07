cargo build --release
strip target/release/rg
$IOTA_SUPERUSER cp target/release/rg "${IOTA_ROOT_PATH}/usr/bin/"
