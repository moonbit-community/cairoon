#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
matrix_dir="$repo_root/scripts/matrix"
lane=all
no_cache=0
release_archive_path=""
docker_platform=""
docker_context=""
platform_image_suffix=""

usage() {
  cat <<'EOF'
Usage: scripts/test-cairo-matrix.sh [all|host|ubuntu-24.04-system|cairo-1.15.10|cairo-1.18.4] [--no-cache] [--platform PLATFORM] [--docker-context CONTEXT]

Runs release evidence locally. The Docker lane mounts the checkout read-only
and tests a disposable copy, so generated constants cannot modify host files.
PLATFORM must be linux/amd64 or linux/arm64. CONTEXT selects an isolated Docker
daemon, for example a Rosetta-backed Colima profile on Apple Silicon.
EOF
}

missing_option_value() {
  printf 'error: %s requires a non-empty value\n' "$1" >&2
  usage >&2
  exit 2
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    all|host|ubuntu-24.04-system|cairo-1.15.10|cairo-1.18.4)
      lane="$1"
      shift
      ;;
    --no-cache)
      no_cache=1
      shift
      ;;
    --platform)
      if [[ "$#" -lt 2 || -z "$2" || "$2" == --* ]]; then
        missing_option_value "$1"
      fi
      docker_platform="$2"
      shift 2
      ;;
    --platform=*)
      docker_platform="${1#*=}"
      if [[ -z "$docker_platform" ]]; then
        missing_option_value --platform
      fi
      shift
      ;;
    --docker-context)
      if [[ "$#" -lt 2 || -z "$2" || "$2" == --* ]]; then
        missing_option_value "$1"
      fi
      docker_context="$2"
      shift 2
      ;;
    --docker-context=*)
      docker_context="${1#*=}"
      if [[ -z "$docker_context" ]]; then
        missing_option_value --docker-context
      fi
      shift
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

case "$docker_platform" in
  "") ;;
  linux/amd64|linux/arm64)
    platform_image_suffix="-${docker_platform//\//-}"
    ;;
  *)
    printf 'error: unsupported Docker platform: %s\n' "$docker_platform" >&2
    usage >&2
    exit 2
    ;;
esac

docker_cli=(docker)
if [[ -n "$docker_context" ]]; then
  docker_cli+=(--context "$docker_context")
fi

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

run_matrix_image() {
  local image="$1"
  shift
  prepare_release_archive
  local build=(
    "${docker_cli[@]}" build
    --file "$matrix_dir/Dockerfile"
    --tag "$image"
  )
  if [[ -n "$docker_platform" ]]; then
    build+=(--platform "$docker_platform")
  fi
  build+=("$@")
  if [[ "$no_cache" == 1 ]]; then
    build+=(--no-cache)
  fi
  build+=("$matrix_dir")
  "${build[@]}"

  local run=("${docker_cli[@]}" run --rm --init)
  if [[ -n "$docker_platform" ]]; then
    run+=(--platform "$docker_platform")
  fi
  run+=(
    --mount "type=bind,src=$repo_root,dst=/source,readonly"
    --mount "type=bind,src=$release_archive_path,dst=/artifact/cairoon.zip,readonly"
    "$image"
  )
  "${run[@]}"
}

run_cairo_lane() {
  local version="$1"
  local url="$2"
  local sha256="$3"
  local image="cairoon-local:cairo-${version}-moon-0.10.4-4f2e8f7dc${platform_image_suffix}"

  printf '\n==> Linux Cairo %s lane\n' "$version"
  run_matrix_image \
    "$image" \
    --build-arg "CAIRO_VERSION=$version" \
    --build-arg "CAIRO_URL=$url" \
    --build-arg "CAIRO_SHA256=$sha256"
}

run_ubuntu_24_04_system() {
  local image="cairoon-local:ubuntu-24.04-system-cairo-moon-0.10.4-4f2e8f7dc${platform_image_suffix}"

  printf '\n==> Ubuntu 24.04 system Cairo lane\n'
  run_matrix_image "$image" --target system-cairo
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
    run_ubuntu_24_04_system
    run_cairo_1_18_4
    ;;
  host)
    run_host
    ;;
  cairo-1.15.10)
    run_cairo_1_15_10
    ;;
  ubuntu-24.04-system)
    run_ubuntu_24_04_system
    ;;
  cairo-1.18.4)
    run_cairo_1_18_4
    ;;
esac
