cargo build --release
if command -v doas >/dev/null 2>&1; then
  run_elevated="doas"
elif command -v sudo >/dev/null 2>&1; then
  run_elevated="sudo"
else
  echo "Error: Neither doas nor sudo is installed."
  exit 1
fi

$run_elevated cp target/release/doit /usr/local/bin/doit
$run_elevated chown root:root /usr/local/bin/doit
$run_elevated chmod u+s /usr/local/bin/doit
