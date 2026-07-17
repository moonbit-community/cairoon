#!/usr/bin/env bash
set -euo pipefail

source_root=/source
work_root=/work

if [[ ! -f "$source_root/moon.mod" ]]; then
  printf 'matrix source mount is missing moon.mod: %s\n' "$source_root" >&2
  exit 2
fi

mkdir -p "$work_root"
tar \
  --exclude='./.git' \
  --exclude='./.mooncakes' \
  --exclude='./_build' \
  -C "$source_root" -cf - . \
  | tar -C "$work_root" -xf -

cd "$work_root"

actual_cairo="$(pkg-config --modversion cairo)"
if [[ "$actual_cairo" != "$CAIROON_MATRIX_CAIRO_VERSION" ]]; then
  printf 'expected Cairo %s, found %s\n' \
    "$CAIROON_MATRIX_CAIRO_VERSION" "$actual_cairo" >&2
  exit 2
fi

printf 'Matrix lane: Linux, Cairo %s\n' "$actual_cairo"
moon version --all
moon update
./scripts/configure-link-flags.sh
python3 ./scripts/check-public-coverage.py --analyze

CAIROON_VERIFY_ASAN=1 \
CAIROON_ASAN_CC=clang \
CAIROON_ASAN_AR=llvm-ar \
CAIROON_SANITIZER_LEAKS=on \
./scripts/verify.sh
