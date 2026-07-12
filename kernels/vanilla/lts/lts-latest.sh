#!/usr/bin/env bash
# linux-lts — latest LTS kernel from linux-rolling-lts tree
# Cloning and build handled by prometheus %KERNEL_GIT% pipeline.

echo "linux-lts: all steps handled by prometheus pipeline"
echo "  – git clone stable/linux.git (linux-rolling-lts)"
echo "  – config: defconfig | build: make | install: modules_install + install"
