#!/usr/bin/env bash
# linux-rt — PREEMPT_RT real-time kernel
_kerneldir="linux"

if [[ $1 == "start" ]]; then
  git clone --branch linux-rolling-stable --single-branch --depth 1 \
    https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git "$_kerneldir" || exit 1
  cd "$_kerneldir" || exit 1

  version=$(make kernelversion 2>/dev/null)
  basekernel="$(echo "$version" | cut -d. -f1).$(echo "$version" | cut -d. -f2)"
  echo "Building PREEMPT_RT $version (series: $basekernel)"

  RT_BASE="https://cdn.kernel.org/pub/linux/kernel/projects/rt/${basekernel}"
  wget -q "${RT_BASE}/" -O rt-index.html 2>/dev/null
  rt_patch=$(grep -o "patch-${version}-rt[0-9]*\.patch\.xz" rt-index.html 2>/dev/null | sort -V | tail -1)
  [[ -z "$rt_patch" ]] && rt_patch="patch-${version}-rt1.patch.xz"

  wget -q "${RT_BASE}/${rt_patch}" -O rt.patch.xz || exit 1
  xzcat rt.patch.xz | patch -p1

  scripts/config -e PREEMPT_RT
  scripts/config -e PREEMPT_RT_FULL
  scripts/config -e HZ_1000
  scripts/config --set-val HZ 1000
  scripts/config -e HIGH_RES_TIMERS
  scripts/config -e NO_HZ_FULL
  scripts/config --disable DEBUG_LOCKDEP
  scripts/config --disable DEBUG_PREEMPT
  scripts/config --set-str LOCALVERSION "-rt"
  make olddefconfig

elif [[ $1 == "build" ]]; then
  cd "$_kerneldir" 2>/dev/null || exit 1
  make -j$(nproc)
elif [[ $1 == "install" ]]; then
  cd "$_kerneldir" 2>/dev/null || exit 1
  make modules_install
  make install
fi
