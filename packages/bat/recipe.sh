cargo build --release
strip target/release/bat
$IOTA_SUPERUSER cp target/release/bat "${IOTA_ROOT_PATH}/usr/bin/"
