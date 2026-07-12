#!/usr/bin/env bash
# linux-cachyos — performance-tuned kernel with CachyOS patches
_cpusched="${_cpusched:-bore}"

_kerneldir="linux"

if [[ $1 == "start" ]]; then
  git clone --depth 1 https://github.com/CachyOS/linux.git "$_kerneldir" || exit 1
  cd "$_kerneldir" || exit 1

  version=$(make kernelversion 2>/dev/null)
  basekernel="$(echo "$version" | cut -d. -f1).$(echo "$version" | cut -d. -f2)"
  echo "Building CachyOS $version (scheduler: $_cpusched)"

  case "$_cpusched" in
    bore|cachyos)
      wget -q "https://raw.githubusercontent.com/cachyos/kernel-patches/master/${basekernel}/sched/0001-bore-cachy.patch" -O bore.patch
      patch -p1 < bore.patch
      scripts/config -e SCHED_BORE ;;
    bmq|pds)
      wget -q "https://raw.githubusercontent.com/cachyos/kernel-patches/master/${basekernel}/sched/0001-prjc-cachy.patch" -O prjc.patch
      patch -p1 < prjc.patch
      scripts/config --disable SCHED_BORE ;;
    *) scripts/config --disable SCHED_BORE ;;
  esac

  scripts/config -e CACHY
  scripts/config --set-str LOCALVERSION "-cachyos"
  scripts/config -e PREEMPT_BORE 2>/dev/null || scripts/config -e PREEMPT
  make olddefconfig

elif [[ $1 == "build" ]]; then
  cd "$_kerneldir" 2>/dev/null || exit 1
  make -j$(nproc)
elif [[ $1 == "install" ]]; then
  cd "$_kerneldir" 2>/dev/null || exit 1
  make modules_install
  make install
fi
