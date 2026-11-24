#!/bin/sh
# 一键打包：sh build.sh [rootless|roothide|rootful|all]
set -eu
cd "$(dirname "$0")"

if [ "$#" -eq 0 ]; then
    set -- roothide
elif [ "$#" -eq 1 ] && [ "$1" = all ]; then
    set -- rootful rootless roothide
fi

for scheme in "$@"; do
    case "$scheme" in
        rootful|rootless|roothide) ;;
        *) printf 'Unknown scheme: %s\n' "$scheme" >&2; exit 2 ;;
    esac
done

: "${THEOS:?Set THEOS to a compatible Theos toolchain first}"

for scheme in "$@"; do
    package_scheme="$scheme"
    if [ "$scheme" = rootful ]; then package_scheme=""; fi
    printf '\n===== Building %s =====\n' "$scheme"
    make clean THEOS_PACKAGE_SCHEME="$package_scheme"
    make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME="$package_scheme"
done

echo
echo "===== packages ====="
ls -lh packages/ 2>/dev/null || true
