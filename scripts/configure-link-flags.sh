#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

usage() {
  cat <<'USAGE'
Usage:
  scripts/configure-link-flags.sh          # rewrite moon.pkg from pkg-config
  scripts/configure-link-flags.sh --check  # verify moon.pkg matches pkg-config

Set PKG_CONFIG=/path/to/pkg-config to use a non-default pkg-config.
USAGE
}

mode="${1:-update}"
if [[ "$mode" == "--help" || "$mode" == "-h" ]]; then
  usage
  exit 0
fi
if [[ "$#" -gt 1 || ( "$mode" != "update" && "$mode" != "--check" ) ]]; then
  usage >&2
  exit 2
fi

pkg_config="${PKG_CONFIG:-pkg-config}"
if ! command -v "$pkg_config" >/dev/null 2>&1; then
  printf 'error: %s not found; install pkg-config or set PKG_CONFIG\n' "$pkg_config" >&2
  exit 1
fi

read -r -a pkg_flags <<< "$("$pkg_config" --cflags --libs cairo)"
cc_parts=()
link_parts=()
next_cc_arg=0

for flag in "${pkg_flags[@]}"; do
  if [[ "$next_cc_arg" == 1 ]]; then
    cc_parts+=("$flag")
    next_cc_arg=0
    continue
  fi

  case "$flag" in
    -I*|-D*|-U*|-F*)
      cc_parts+=("$flag")
      ;;
    -isystem|-include|-iframework)
      cc_parts+=("$flag")
      next_cc_arg=1
      ;;
    *)
      link_parts+=("$flag")
      ;;
  esac
done

if [[ "${#link_parts[@]}" == 0 ]]; then
  printf 'error: pkg-config --cflags --libs cairo did not produce link flags\n' >&2
  exit 1
fi

cc_flags="${cc_parts[*]}"
link_flags="${link_parts[*]}"

extract_field() {
  local key="$1"
  sed -nE "s/^[[:space:]]*\"${key}\": \"(.*)\"[,]?$/\1/p" moon.pkg | head -n 1
}

if [[ "$mode" == "--check" ]]; then
  actual_cc_flags="$(extract_field cc-flags)"
  actual_stub_cc_flags="$(extract_field stub-cc-flags)"
  actual_link_flags="$(extract_field cc-link-flags)"

  if [[ "$actual_cc_flags" != "$cc_flags" ||
        "$actual_stub_cc_flags" != "$cc_flags" ||
        "$actual_link_flags" != "$link_flags" ]]; then
    cat >&2 <<EOF
error: moon.pkg Cairo link flags are out of sync with pkg-config.

Run:
  scripts/configure-link-flags.sh

Expected cc-flags/stub-cc-flags:
  $cc_flags
Actual cc-flags:
  $actual_cc_flags
Actual stub-cc-flags:
  $actual_stub_cc_flags

Expected cc-link-flags:
  $link_flags
Actual cc-link-flags:
  $actual_link_flags
EOF
    exit 1
  fi

  printf 'moon.pkg Cairo link flags match pkg-config.\n'
  exit 0
fi

escape_moon_string() {
  sed 's/\\/\\\\/g; s/"/\\"/g' <<< "$1"
}

escaped_cc_flags="$(escape_moon_string "$cc_flags")"
escaped_link_flags="$(escape_moon_string "$link_flags")"
tmp="$(mktemp "${TMPDIR:-/tmp}/cairoon-moon.pkg.XXXXXX")"

awk \
  -v cc_flags="$escaped_cc_flags" \
  -v link_flags="$escaped_link_flags" '
    /^[[:space:]]*"cc-flags": / {
      print "      \"cc-flags\": \"" cc_flags "\","
      next
    }
    /^[[:space:]]*"stub-cc-flags": / {
      print "      \"stub-cc-flags\": \"" cc_flags "\","
      next
    }
    /^[[:space:]]*"cc-link-flags": / {
      print "      \"cc-link-flags\": \"" link_flags "\","
      next
    }
    { print }
  ' moon.pkg > "$tmp"

mv "$tmp" moon.pkg
printf 'Updated moon.pkg Cairo link flags from pkg-config.\n'
