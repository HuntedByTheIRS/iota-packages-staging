#!/usr/bin/env bash
# linux-libre — GNU Linux-libre deblobbed kernel
_kerneldir="linux"

if [[ $1 == "start" ]]; then
  git clone --branch linux-rolling-stable --single-branch --depth 1 \
    https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git "$_kerneldir" || exit 1
  cd "$_kerneldir" || exit 1

  version=$(make kernelversion 2>/dev/null)
  major_ver="$(echo "$version" | cut -d. -f1)"
  echo "Building Linux-libre $version"

  LIBRE_URL="https://linux-libre.fsfla.org/pub/linux-libre/releases/${version}-gnu"
  wget -q "$LIBRE_URL/deblob-${major_ver}" -O deblob-script 2>/dev/null || {
    LIBRE_URL="https://linux-libre.fsfla.org/pub/linux-libre/releases/LATEST-${major_ver}.N"
    wget -q "$LIBRE_URL/deblob-${major_ver}" -O deblob-script 2>/dev/null || true
  }
  wget -q "$LIBRE_URL/deblob-check" -O deblob-check 2>/dev/null || true
  chmod +x deblob-script deblob-check 2>/dev/null

  if [[ -x deblob-script ]]; then
    cd ..
    PYTHON="${PYTHON:-python3}" bash "$_kerneldir/deblob-script" 2>/dev/null || true
    cd "$_kerneldir" 2>/dev/null || exit 1
  fi

  scripts/config --set-str LOCALVERSION "-libre"
  make olddefconfig

elif [[ $1 == "build" ]]; then
  cd "$_kerneldir" 2>/dev/null || exit 1
  make -j$(nproc)
elif [[ $1 == "install" ]]; then
  cd "$_kerneldir" 2>/dev/null || exit 1
  make modules_install
  make install
fi
