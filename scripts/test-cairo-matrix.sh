#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
matrix_dir="$repo_root/scripts/matrix"
lane=all
no_cache=0

usage() {
  cat <<'EOF'
Usage: scripts/test-cairo-matrix.sh [all|host|cairo-1.15.10|cairo-1.18.4] [--no-cache]

Runs release evidence locally. The Docker lane mounts the checkout read-only
and tests a disposable copy, so configure-link-flags cannot modify host files.
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
  "$repo_root/scripts/configure-link-flags.sh" --check
  "$repo_root/scripts/verify.sh"
}

run_cairo_lane() {
  local version="$1"
  local url="$2"
  local sha256="$3"
  local image="cairoon-local:cairo-${version}-moon-0.10.4-4f2e8f7dc"

  printf '\n==> Linux Cairo %s lane\n' "$version"
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
