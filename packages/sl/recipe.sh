make
mkdir -p "${IOTA_ROOT_PATH%/}/bin/"
$IOTA_SUPERUSER cp "$(realpath ./sl)" "${IOTA_ROOT_PATH%/}/bin/"
