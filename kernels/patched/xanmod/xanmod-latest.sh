#!/usr/bin/env bash
# linux-xanmod — XanMod performance kernel
_xanmod_channel="${_xanmod_channel:-main}"
_kerneldir="linux"

if [[ $1 == "start" ]]; then
  git clone --depth 1 https://gitlab.com/xanmod/linux.git "$_kerneldir" || exit 1
  cd "$_kerneldir" || exit 1

  version=$(make kernelversion 2>/dev/null)
  echo "Building XanMod $version (channel: $_xanmod_channel)"

  wget "https://master.dl.sourceforge.net/project/xanmod/releases/${_xanmod_channel}/${version}-xanmod1/patch-${version}-xanmod1.xz" -O xanmod.patch.xz
  xzcat xanmod.patch.xz | patch -p1

  cp CONFIGS/x86_64/config .config
  scripts/config --set-str LOCALVERSION "-xanmod"
  scripts/config -e TCP_CONG_BBR
  scripts/config -e NET_SCH_FQ
  scripts/config -e AMD_3D_VCACHE
  make olddefconfig

elif [[ $1 == "build" ]]; then
  cd "$_kerneldir" 2>/dev/null || exit 1
  make -j$(nproc)
elif [[ $1 == "install" ]]; then
  cd "$_kerneldir" 2>/dev/null || exit 1
  make modules_install
  make install
fi
