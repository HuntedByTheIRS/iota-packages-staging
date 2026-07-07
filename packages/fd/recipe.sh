cargo build --release
strip target/release/fd
$IOTA_SUPERUSER cp target/release/fd "${IOTA_ROOT_PATH}/usr/bin/"
