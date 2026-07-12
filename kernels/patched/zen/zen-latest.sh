if [[ $1 == "start" ]]; then

  git clone --branch linux-rolling-stable --single-branch --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
  cd linux || exit 1

  version=$(make kernelversion)

  wget "https://github.com/zen-kernel/zen-kernel/releases/download/v${version}-zen1/linux-v${version}-zen1.patch.zst"
  unzstd "linux-v${version}-zen1.patch.zst"

  patch -p1 <"linux-v${version}-zen1.patch"
elif [[ $1 == "build" ]]; then
  make -j4
elif [[ $1 == "install" ]]; then
  make install_modules
  make install
fi
