cmake -G Ninja -S llvm -B build \
      -DCMAKE_BUILD_TYPE=Release \
      -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
      -DLLVM_TARGETS_TO_BUILD="X86" \
      -DLLVM_INCLUDE_TESTS=OFF \
      -DLLVM_INCLUDE_EXAMPLES=OFF \
      -DLLVM_INCLUDE_DOCS=OFF \
      -DCMAKE_INSTALL_PREFIX=/usr
ninja -C build -j$JOBOPTS
$IOTA_SUPERUSER ninja -C build install
