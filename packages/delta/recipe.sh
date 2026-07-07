cargo build --release
strip target/release/delta
$IOTA_SUPERUSER cp target/release/delta "${IOTA_ROOT_PATH}/usr/bin/"
