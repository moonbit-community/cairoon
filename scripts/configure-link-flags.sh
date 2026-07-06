#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
public_package_config="$repo_root/src/moon.pkg"
native_package_config="$repo_root/src/native/moon.pkg"
package_root="$repo_root/src"

usage() {
  cat <<'USAGE'
Usage:
  scripts/configure-link-flags.sh          # rewrite Cairo link flags from pkg-config
  scripts/configure-link-flags.sh --check  # verify Cairo link flags match pkg-config

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
  local file="$1"
  local key="$2"
  sed -nE "s/^[[:space:]]*\"${key}\": \"(.*)\"[,]?$/\1/p" "$file" | head -n 1
}

relative_path() {
  local file="$1"
  printf '%s' "${file#"$repo_root"/}"
}

needs_cairo_link() {
  local file="$1"
  grep -Eq '"CAIMEOX/cairoon"|"CAIMEOX/cairoon/native"' "$file"
}

has_native_stub() {
  local file="$1"
  grep -q '"native-stub"' "$file"
}

collect_dependent_configs() {
  find "$package_root" -name moon.pkg -type f -print | sort | while IFS= read -r config; do
    if [[ "$config" == "$public_package_config" ||
          "$config" == "$native_package_config" ]]; then
      continue
    fi
    printf '%s\n' "$config"
  done
}

if [[ "$mode" == "--check" ]]; then
  actual_link_flags="$(extract_field "$public_package_config" cc-link-flags)"

  if [[ "$actual_link_flags" != "$link_flags" ]]; then
    cat >&2 <<EOF
error: src/moon.pkg Cairo link flags are out of sync with pkg-config.

Run:
  scripts/configure-link-flags.sh

Expected cc-link-flags:
  $link_flags
Actual cc-link-flags:
  $actual_link_flags
EOF
    exit 1
  fi

  actual_stub_cc_flags="$(extract_field "$native_package_config" stub-cc-flags)"
  actual_link_flags="$(extract_field "$native_package_config" cc-link-flags)"

  if [[ "$actual_stub_cc_flags" != "$cc_flags" ||
        "$actual_link_flags" != "$link_flags" ]]; then
    cat >&2 <<EOF
error: src/native/moon.pkg Cairo native flags are out of sync with pkg-config.

Run:
  scripts/configure-link-flags.sh

Expected stub-cc-flags:
  $cc_flags
Actual stub-cc-flags:
  $actual_stub_cc_flags

Expected cc-link-flags:
  $link_flags
Actual cc-link-flags:
  $actual_link_flags
EOF
    exit 1
  fi

  checked=2
  while IFS= read -r config; do
    if ! needs_cairo_link "$config"; then
      continue
    fi
    actual_link_flags="$(extract_field "$config" cc-link-flags)"
    if [[ "$actual_link_flags" != "$link_flags" ]]; then
      rel="$(relative_path "$config")"
      cat >&2 <<EOF
error: $rel Cairo link flags are out of sync with pkg-config.

Run:
  scripts/configure-link-flags.sh

Expected cc-link-flags:
  $link_flags
Actual cc-link-flags:
  $actual_link_flags
EOF
      exit 1
    fi
    if has_native_stub "$config"; then
      actual_stub_cc_flags="$(extract_field "$config" stub-cc-flags)"
      if [[ "$actual_stub_cc_flags" != "$cc_flags" ]]; then
        rel="$(relative_path "$config")"
        cat >&2 <<EOF
error: $rel Cairo stub compile flags are out of sync with pkg-config.

Run:
  scripts/configure-link-flags.sh

Expected stub-cc-flags:
  $cc_flags
Actual stub-cc-flags:
  $actual_stub_cc_flags
EOF
        exit 1
      fi
    fi
    checked=$((checked + 1))
  done < <(collect_dependent_configs)

  printf 'Cairo link/stub flags match pkg-config in %s moon.pkg files.\n' "$checked"
  exit 0
fi

escape_moon_string() {
  sed 's/\\/\\\\/g; s/"/\\"/g' <<< "$1"
}

escaped_cc_flags="$(escape_moon_string "$cc_flags")"
escaped_link_flags="$(escape_moon_string "$link_flags")"

update_public_config() {
  local file="$1"
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/cairoon-moon.pkg.XXXXXX")"
  awk \
    -v link_flags="$escaped_link_flags" '
      /^[[:space:]]*"cc-link-flags": / {
        print "      \"cc-link-flags\": \"" link_flags "\","
        next
      }
      { print }
    ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

update_native_config() {
  local file="$1"
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/cairoon-moon.pkg.XXXXXX")"
  awk \
    -v cc_flags="$escaped_cc_flags" \
    -v link_flags="$escaped_link_flags" '
      /^[[:space:]]*"stub-cc-flags": / {
        print "      \"stub-cc-flags\": \"" cc_flags "\","
        next
      }
      /^[[:space:]]*"cc-link-flags": / {
        print "      \"cc-link-flags\": \"" link_flags "\","
        next
      }
      { print }
    ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

update_dependent_config() {
  local file="$1"
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/cairoon-moon.pkg.XXXXXX")"
  awk \
    -v cc_flags="$escaped_cc_flags" \
    -v link_flags="$escaped_link_flags" '
      /^[[:space:]]*"stub-cc-flags": / {
        print "      \"stub-cc-flags\": \"" cc_flags "\","
        next
      }
      /^[[:space:]]*"cc-link-flags": / {
        print "      \"cc-link-flags\": \"" link_flags "\","
        next
      }
      { print }
    ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

update_public_config "$public_package_config"
update_native_config "$native_package_config"
updated=2
while IFS= read -r config; do
  if ! needs_cairo_link "$config"; then
    continue
  fi
  update_dependent_config "$config"
  updated=$((updated + 1))
done < <(collect_dependent_configs)

printf 'Updated Cairo link/stub flags from pkg-config in %s moon.pkg files.\n' "$updated"
