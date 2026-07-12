version=$(make kernelversion)

wget "https://github.com/zen-kernel/zen-kernel/releases/download/v${version}-zen1/linux-v${version}-zen1.patch.zst"
unzstd "linux-v${version}-zen1.patch.zst"

patch -p1 <"linux-${version}-zen1.patch"
