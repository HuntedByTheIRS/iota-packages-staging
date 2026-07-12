git clone --branch linux-rolling-stable --single-branch --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git || {
  echo "git failed"
  exit 1
}
cd linux || {
  echo "Could not enter directory"
  exit 1
}

version=$(git tag)

wget "https://github.com/zen-kernel/zen-kernel/releases/download/${version}-zen1/linux-${version}-zen1.patch.zst"
unzstd "linux-${version}-zen1.patch.zst"

patch -p1 <"linux-${version}-zen1.patch"
