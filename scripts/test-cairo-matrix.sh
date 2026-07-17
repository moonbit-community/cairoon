#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
matrix_dir="$repo_root/scripts/matrix"
lane=all
no_cache=0
release_archive_path=""

usage() {
  cat <<'EOF'
Usage: scripts/test-cairo-matrix.sh [all|host|cairo-1.15.10|cairo-1.18.4] [--no-cache]

Runs release evidence locally. The Docker lane mounts the checkout read-only
and tests a disposable copy, so generated constants cannot modify host files.
EOF
}

for argument in "$@"; do
  case "$argument" in
    all|host|cairo-1.15.10|cairo-1.18.4)
      lane="$argument"
      ;;
    --no-cache)
      no_cache=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
done

run_host() {
  printf '\n==> host Cairo lane\n'
  "$repo_root/scripts/configure-cairo-constants.sh" --check
  "$repo_root/scripts/verify.sh"
}

prepare_release_archive() {
  if [[ -n "$release_archive_path" && -f "$release_archive_path" ]]; then
    return
  fi

  local module_name module_version archive_name
  module_name="$(sed -nE 's/^name[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$repo_root/moon.mod" | head -n 1)"
  module_version="$(sed -nE 's/^version[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$repo_root/moon.mod" | head -n 1)"
  if [[ -z "$module_name" || -z "$module_version" ]]; then
    printf 'error: could not read module name and version from moon.mod\n' >&2
    exit 1
  fi
  archive_name="${module_name//\//-}-${module_version}.zip"
  release_archive_path="$repo_root/_build/publish/$archive_name"
  if ! package_output="$(moon package --list 2>&1)"; then
    printf '%s\n' "$package_output" >&2
    exit 1
  fi
  if [[ ! -f "$release_archive_path" ]]; then
    printf 'error: moon package did not create %s\n' "$release_archive_path" >&2
    exit 1
  fi
}

run_cairo_lane() {
  local version="$1"
  local url="$2"
  local sha256="$3"
  local image="cairoon-local:cairo-${version}-moon-0.10.4-4f2e8f7dc"

  printf '\n==> Linux Cairo %s lane\n' "$version"
  prepare_release_archive
  local build=(
    docker build
    --file "$matrix_dir/Dockerfile"
    --tag "$image"
    --build-arg "CAIRO_VERSION=$version"
    --build-arg "CAIRO_URL=$url"
    --build-arg "CAIRO_SHA256=$sha256"
  )
  if [[ "$no_cache" == 1 ]]; then
    build+=(--no-cache)
  fi
  build+=("$matrix_dir")
  "${build[@]}"

  docker run --rm --init \
    --mount "type=bind,src=$repo_root,dst=/source,readonly" \
    --mount "type=bind,src=$release_archive_path,dst=/artifact/cairoon.zip,readonly" \
    "$image"
}

run_cairo_1_15_10() {
  run_cairo_lane \
    "1.15.10" \
    "https://cairographics.org/snapshots/cairo-1.15.10.tar.xz" \
    "62ca226134cf2f1fd114bea06f8b374eb37f35d8e22487eaa54d5e9428958392"
}

run_cairo_1_18_4() {
  run_cairo_lane \
    "1.18.4" \
    "https://cairographics.org/releases/cairo-1.18.4.tar.xz" \
    "445ed8208a6e4823de1226a74ca319d3600e83f6369f99b14265006599c32ccb"
}

case "$lane" in
  all)
    run_host
    run_cairo_1_15_10
    run_cairo_1_18_4
    ;;
  host)
    run_host
    ;;
  cairo-1.15.10)
    run_cairo_1_15_10
    ;;
  cairo-1.18.4)
    run_cairo_1_18_4
    ;;
esac
