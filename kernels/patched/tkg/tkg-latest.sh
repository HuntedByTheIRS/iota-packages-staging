#!/usr/bin/env bash
# linux-tkg — Tk-Glitch custom/gaming kernel
_tkg_cpusched="${_tkg_cpusched:-bore}"
_tkg_compiler="${_tkg_compiler:-gcc}"

if [[ $1 == "start" ]]; then
  git clone --depth 1 https://github.com/Frogging-Family/linux-tkg.git || exit 1
  cd linux-tkg || exit 1

  cat > customization.cfg << CFGEOF
_distro="Generic"
_NUKR="true"
_cpusched="${_tkg_cpusched}"
_compiler="${_tkg_compiler}"
_compileroptlevel="2"
_debugdisable="true"
_tickless="2"
_timer_freq="1000"
_force_all_threads="true"
_menunconfig="0"
CFGEOF

  echo "TKG build system ready."

elif [[ $1 == "build" ]]; then
  cd linux-tkg 2>/dev/null || exit 1
  ./install.sh install 2>&1 | tee /tmp/tkg-build.log
elif [[ $1 == "install" ]]; then
  echo "linux-tkg: install handled by TKG build system."
fi
