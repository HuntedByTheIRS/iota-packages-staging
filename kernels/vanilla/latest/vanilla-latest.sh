if [[ $1 == "start" ]]; then
  git clone --branch linux-rolling-stable --single-branch --depth 1 https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git || echo "yo git failed"
  cd linux || echo "wtf"
elif [[ $1 == "build" ]]; then
  make -j4
elif [[ $1 == "install" ]]; then
  make modules_install
  make install
fi
