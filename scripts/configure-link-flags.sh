#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
public_package_config="$repo_root/src/moon.pkg"
native_package_config="$repo_root/src/native/moon.pkg"
package_root="$repo_root/src"
constants_file="$repo_root/src/constants.mbt"
feature_const_names=(
  HAS_ATSUI_FONT
  HAS_FT_FONT
  HAS_GLITZ_SURFACE
  HAS_IMAGE_SURFACE
  HAS_MIME_SURFACE
  HAS_PDF_SURFACE
  HAS_PNG_FUNCTIONS
  HAS_PS_SURFACE
  HAS_QUARTZ_SURFACE
  HAS_RECORDING_SURFACE
  HAS_SCRIPT_SURFACE
  HAS_SVG_SURFACE
  HAS_TEE_SURFACE
  HAS_USER_FONT
  HAS_WIN32_FONT
  HAS_WIN32_SURFACE
  HAS_XCB_SURFACE
  HAS_XLIB_SURFACE
  HAS_DWRITE_FONT
)

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
cairo_version_string="$("$pkg_config" --modversion cairo)"
if [[ ! "$cairo_version_string" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+) ]]; then
  printf 'error: could not parse cairo version from pkg-config: %s\n' \
    "$cairo_version_string" >&2
  exit 1
fi
cairo_version_major="${BASH_REMATCH[1]}"
cairo_version_minor="${BASH_REMATCH[2]}"
cairo_version_micro="${BASH_REMATCH[3]}"
cairo_version_number=$((10#$cairo_version_major * 10000 + 10#$cairo_version_minor * 100 + 10#$cairo_version_micro))

detect_cairo_feature_flags() {
  local cc_bin="${CC:-${MOON_CC:-cc}}"
  local tmp_dir tmp_c tmp_exe
  if ! command -v "$cc_bin" >/dev/null 2>&1; then
    printf 'error: no C compiler found for Cairo feature probe; set CC or MOON_CC\n' >&2
    exit 1
  fi

  tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/cairoon-feature-probe.XXXXXX")"
  tmp_c="$tmp_dir/probe.c"
  tmp_exe="$tmp_dir/probe"
  cat > "$tmp_c" <<'C'
#include <cairo.h>
#include <stdio.h>

int main(void) {
#ifdef CAIRO_HAS_ATSUI_FONT
  puts("HAS_ATSUI_FONT=true");
#else
  puts("HAS_ATSUI_FONT=false");
#endif
#ifdef CAIRO_HAS_FT_FONT
  puts("HAS_FT_FONT=true");
#else
  puts("HAS_FT_FONT=false");
#endif
#ifdef CAIRO_HAS_GLITZ_SURFACE
  puts("HAS_GLITZ_SURFACE=true");
#else
  puts("HAS_GLITZ_SURFACE=false");
#endif
#ifdef CAIRO_HAS_IMAGE_SURFACE
  puts("HAS_IMAGE_SURFACE=true");
#else
  puts("HAS_IMAGE_SURFACE=false");
#endif
#ifdef CAIRO_HAS_MIME_SURFACE
  puts("HAS_MIME_SURFACE=true");
#else
  puts("HAS_MIME_SURFACE=false");
#endif
#ifdef CAIRO_HAS_PDF_SURFACE
  puts("HAS_PDF_SURFACE=true");
#else
  puts("HAS_PDF_SURFACE=false");
#endif
#ifdef CAIRO_HAS_PNG_FUNCTIONS
  puts("HAS_PNG_FUNCTIONS=true");
#else
  puts("HAS_PNG_FUNCTIONS=false");
#endif
#ifdef CAIRO_HAS_PS_SURFACE
  puts("HAS_PS_SURFACE=true");
#else
  puts("HAS_PS_SURFACE=false");
#endif
#ifdef CAIRO_HAS_QUARTZ_SURFACE
  puts("HAS_QUARTZ_SURFACE=true");
#else
  puts("HAS_QUARTZ_SURFACE=false");
#endif
#ifdef CAIRO_HAS_RECORDING_SURFACE
  puts("HAS_RECORDING_SURFACE=true");
#else
  puts("HAS_RECORDING_SURFACE=false");
#endif
#ifdef CAIRO_HAS_SCRIPT_SURFACE
  puts("HAS_SCRIPT_SURFACE=true");
#else
  puts("HAS_SCRIPT_SURFACE=false");
#endif
#ifdef CAIRO_HAS_SVG_SURFACE
  puts("HAS_SVG_SURFACE=true");
#else
  puts("HAS_SVG_SURFACE=false");
#endif
#ifdef CAIRO_HAS_TEE_SURFACE
  puts("HAS_TEE_SURFACE=true");
#else
  puts("HAS_TEE_SURFACE=false");
#endif
#ifdef CAIRO_HAS_USER_FONT
  puts("HAS_USER_FONT=true");
#else
  puts("HAS_USER_FONT=false");
#endif
#ifdef CAIRO_HAS_WIN32_FONT
  puts("HAS_WIN32_FONT=true");
#else
  puts("HAS_WIN32_FONT=false");
#endif
#ifdef CAIRO_HAS_WIN32_SURFACE
  puts("HAS_WIN32_SURFACE=true");
#else
  puts("HAS_WIN32_SURFACE=false");
#endif
#ifdef CAIRO_HAS_XCB_SURFACE
  puts("HAS_XCB_SURFACE=true");
#else
  puts("HAS_XCB_SURFACE=false");
#endif
#ifdef CAIRO_HAS_XLIB_SURFACE
  puts("HAS_XLIB_SURFACE=true");
#else
  puts("HAS_XLIB_SURFACE=false");
#endif
#ifdef CAIRO_HAS_DWRITE_FONT
  puts("HAS_DWRITE_FONT=true");
#else
  puts("HAS_DWRITE_FONT=false");
#endif
  return 0;
}
C
  "$cc_bin" "${cc_parts[@]}" "$tmp_c" "${link_parts[@]}" -o "$tmp_exe"
  "$tmp_exe"
  rm -rf "$tmp_dir"
}

cairo_feature_output="$(detect_cairo_feature_flags)"

feature_value() {
  local key="$1"
  printf '%s\n' "$cairo_feature_output" |
    sed -nE "s/^${key}=(.*)$/\1/p" |
    head -n 1
}

escape_moon_string() {
  sed 's/\\/\\\\/g; s/"/\\"/g' <<< "$1"
}

escaped_cairo_version_string="$(escape_moon_string "$cairo_version_string")"

extract_field() {
  local file="$1"
  local key="$2"
  sed -nE "s/.*\"${key}\": \"([^\"]*)\".*/\1/p" "$file" | head -n 1
}

extract_const_value() {
  local file="$1"
  local key="$2"
  sed -nE "s/^pub const ${key} : [^=]+ = (.*)$/\1/p" "$file" | head -n 1
}

check_const_value() {
  local key="$1"
  local expected="$2"
  local actual
  actual="$(extract_const_value "$constants_file" "$key")"
  if [[ "$actual" != "$expected" ]]; then
    cat >&2 <<EOF
error: src/constants.mbt generated Cairo constant $key is out of sync with pkg-config.

Run:
  scripts/configure-link-flags.sh

Expected:
  $expected
Actual:
  $actual
EOF
    exit 1
  fi
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
  check_const_value CAIRO_VERSION "$cairo_version_number"
  check_const_value CAIRO_VERSION_STRING "\"$escaped_cairo_version_string\""
  check_const_value CAIRO_VERSION_MAJOR "$cairo_version_major"
  check_const_value CAIRO_VERSION_MINOR "$cairo_version_minor"
  check_const_value CAIRO_VERSION_MICRO "$cairo_version_micro"
  for key in "${feature_const_names[@]}"; do
    check_const_value "$key" "$(feature_value "$key")"
  done

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

escaped_cc_flags="$(escape_moon_string "$cc_flags")"
escaped_link_flags="$(escape_moon_string "$link_flags")"

update_const_value() {
  local key="$1"
  local value="$2"
  CAIROON_CONST_KEY="$key" \
  CAIROON_CONST_VALUE="$value" \
  perl -0pi -e \
    'my $key = $ENV{CAIROON_CONST_KEY};
     my $value = $ENV{CAIROON_CONST_VALUE};
     s/^pub const \Q$key\E : ([^=]+) = .*$/pub const $key : $1 = $value/gm' \
    "$constants_file"
}

update_constants() {
  update_const_value CAIRO_VERSION "$cairo_version_number"
  update_const_value CAIRO_VERSION_STRING "\"$escaped_cairo_version_string\""
  update_const_value CAIRO_VERSION_MAJOR "$cairo_version_major"
  update_const_value CAIRO_VERSION_MINOR "$cairo_version_minor"
  update_const_value CAIRO_VERSION_MICRO "$cairo_version_micro"
  for key in "${feature_const_names[@]}"; do
    update_const_value "$key" "$(feature_value "$key")"
  done
}

update_public_config() {
  local file="$1"
  CAIROON_LINK_FLAGS="$escaped_link_flags" perl -0pi -e \
    's/"cc-link-flags": "[^"]*"/q("cc-link-flags": ") . $ENV{CAIROON_LINK_FLAGS} . q(")/ge' \
    "$file"
}

update_native_config() {
  local file="$1"
  CAIROON_CC_FLAGS="$escaped_cc_flags" \
  CAIROON_LINK_FLAGS="$escaped_link_flags" \
  perl -0pi -e \
    's/"stub-cc-flags": "[^"]*"/q("stub-cc-flags": ") . $ENV{CAIROON_CC_FLAGS} . q(")/ge;
     s/"cc-link-flags": "[^"]*"/q("cc-link-flags": ") . $ENV{CAIROON_LINK_FLAGS} . q(")/ge' \
    "$file"
}

update_dependent_config() {
  local file="$1"
  update_native_config "$file"
}

update_constants
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

if command -v moon >/dev/null 2>&1; then
  moon fmt
else
  printf 'moon not found; run moon fmt after installing MoonBit.\n'
fi

printf 'Updated Cairo link/stub flags from pkg-config in %s moon.pkg files.\n' "$updated"
