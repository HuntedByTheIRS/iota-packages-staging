#!/usr/bin/env bash
# linux-bore — BORE (Burst-Oriented Response Enhancer) scheduler kernel
_kerneldir="linux"

if [[ $1 == "start" ]]; then
  git clone --branch linux-rolling-stable --single-branch --depth 1 \
    https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git "$_kerneldir" || exit 1
  cd "$_kerneldir" || exit 1

  version=$(make kernelversion 2>/dev/null)
  basekernel="$(echo "$version" | cut -d. -f1).$(echo "$version" | cut -d. -f2)"
  echo "Building linux-bore $version"

  BORE_REPO="https://github.com/firelzrd/bore-scheduler/raw/main/patches"
  wget -q "${BORE_REPO}/stable/linux-${basekernel}-bore/0001-linux${basekernel}-rc1-bore-6.6.3.patch" -O bore.patch || {
    wget -q "https://raw.githubusercontent.com/cachyos/kernel-patches/master/${basekernel}/sched/0001-bore-cachy.patch" -O bore.patch || exit 1
  }

  patch -p1 < bore.patch
  scripts/config -e SCHED_BORE
  scripts/config --set-val MIN_BASE_SLICE_NS 2000000
  scripts/config -e HZ_1000
  scripts/config --set-val HZ 1000
  scripts/config -e PREEMPT
  scripts/config --set-str LOCALVERSION "-bore"
  make olddefconfig

elif [[ $1 == "build" ]]; then
  cd "$_kerneldir" 2>/dev/null || exit 1
  make -j$(nproc)
elif [[ $1 == "install" ]]; then
  cd "$_kerneldir" 2>/dev/null || exit 1
  make modules_install
  make install
fi
