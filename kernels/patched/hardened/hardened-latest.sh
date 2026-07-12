#!/usr/bin/env bash
# linux-hardened — security-hardened kernel (anthraxx/linux-hardened)
_kerneldir="linux"

if [[ $1 == "start" ]]; then
  git clone --depth 1 https://github.com/anthraxx/linux-hardened.git "$_kerneldir" || exit 1
  cd "$_kerneldir" || exit 1

  version=$(make kernelversion 2>/dev/null)
  echo "Building linux-hardened $version"

  hardened_tag="v${version}-hardened1"
  patch_url="https://github.com/anthraxx/linux-hardened/releases/download/${hardened_tag}/linux-hardened-${hardened_tag}.patch"
  wget -q "$patch_url" -O hardened.patch || {
    hardened_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "v${version}-hardened1")
    wget -q "https://github.com/anthraxx/linux-hardened/releases/download/${hardened_tag}/linux-hardened-${hardened_tag}.patch" -O hardened.patch || true
  }

  if [[ -f hardened.patch ]]; then patch -p1 < hardened.patch; fi

  scripts/config -e INIT_STACK_ALL_ZERO
  scripts/config -e GCC_PLUGIN_STACKLEAK
  scripts/config -e INIT_ON_ALLOC_DEFAULT_ON
  scripts/config -e INIT_ON_FREE_DEFAULT_ON
  scripts/config -e HARDENED_USERCOPY
  scripts/config -e FORTIFY_SOURCE
  scripts/config -e RANDSTRUCT_FULL
  scripts/config -e BUG_ON_DATA_CORRUPTION
  scripts/config -e SECURITY_PERF_EVENTS_RESTRICT
  scripts/config -e SECURITY_TIOCSTI_RESTRICT
  scripts/config --set-val PERF_EVENTS_PARANOID 3
  scripts/config --set-str LOCALVERSION "-hardened"
  make olddefconfig

elif [[ $1 == "build" ]]; then
  cd "$_kerneldir" 2>/dev/null || exit 1
  make -j$(nproc)
elif [[ $1 == "install" ]]; then
  cd "$_kerneldir" 2>/dev/null || exit 1
  make modules_install
  make install
fi
