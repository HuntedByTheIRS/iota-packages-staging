prepare() {
  git clone --branch linux-rolling-stable --single-branch --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git || {
    echo "git failed"
    exit 1
  }

  cd linux || {
    echo "Could not enter directory"
    in_linux=false
    exit 1
  }
  in_linux=true

  version=$(git tag)
}

patch() {
  wget "https://github.com/zen-kernel/zen-kernel/releases/download/${version}-zen1/linux-${version}-zen1.patch.zst"
  unzstd "linux-${version}-zen1.patch.zst"

  patch -p1 <"linux-${version}-zen1.patch"
}

build() {
  echo "just testing"
}

install() {
  echo "reached install"
}

clean() {
  if [[ "$(basename "$PWD")" == "linux" ]]; then
    cd ..
  fi
  rm -rf linux/
  rm "$0"
}

case "$1" in
"prepare")
  prepare
  ;;
"patch")
  if [[ $in_linux == true ]]; then
    patch
  fi
  ;;
"build")
  if [[ $in_linux == true ]]; then
    build
  fi
  ;;
"install")
  if [[ $in_linux == true ]]; then
    install
  fi
  ;;
"clean")
  clean
  ;;
*)
  echo "Usage: $0 {prepare|build|install|clean}"
  ;;
esac
