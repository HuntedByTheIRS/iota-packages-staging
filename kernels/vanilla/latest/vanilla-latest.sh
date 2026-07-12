#!/usr/bin/env bash
# linux (mainline) — Linus Torvalds tree
# Called via %EXTERNAL-SOURCES% when prometheus downloads and runs this script.
# The %KERNEL_GIT% + %KERNEL-SOURCE% handles cloning in the normal pipeline.

echo "linux mainline: all steps handled by prometheus pipeline"
echo "  – git clone torvalds/linux.git (master)"
echo "  – config: defconfig | build: make | install: modules_install + install"
