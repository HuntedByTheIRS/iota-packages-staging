RUSTFLAGS="-C target-cpu=native" cargo build --release

strip target/release/starship

if command -v sudo >/dev/null; then
    sudo cp target/release/starship /usr/local/bin/
elif command -v doas >/dev/null; then
    doas cp target/release/starship /usr/local/bin/
else
    echo "Error: Neither sudo nor doas found. What the fuck are you doing?"
    exit 1
fi
