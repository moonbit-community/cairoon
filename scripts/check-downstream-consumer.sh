#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
consumer_root="$repo_root/integration/consumer"
consumer_package="src/smoke"
artifact_workspace=""

cleanup() {
  if [[ -n "$artifact_workspace" && -d "$artifact_workspace" ]]; then
    rm -rf "$artifact_workspace"
  fi
}
trap cleanup EXIT

run() {
  printf '\n+'
  printf ' %q' "$@"
  printf '\n'
  "$@"
}

cd "$repo_root"
module_name="$(sed -nE 's/^name[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' moon.mod | head -n 1)"
module_version="$(sed -nE 's/^version[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' moon.mod | head -n 1)"
if [[ -z "$module_name" || -z "$module_version" ]]; then
  printf 'error: could not read module name and version from moon.mod\n' >&2
  exit 1
fi
archive_name="${module_name//\//-}-${module_version}.zip"
archive_path="$repo_root/_build/publish/$archive_name"

if ! package_listing="$(moon package --list 2>&1)"; then
  printf '%s\n' "$package_listing" >&2
  exit 1
fi
if grep -Eq '^(\./)?integration(/|$)' <<< "$package_listing"; then
  printf 'error: integration fixture leaked into the publication archive\n' >&2
  exit 1
fi
if [[ ! -f "$archive_path" ]]; then
  printf 'error: moon package did not create %s\n' "$archive_path" >&2
  exit 1
fi
run python3 "$repo_root/scripts/check-publication-archive.py" "$archive_path"
printf 'Publication archive excludes the integration fixture.\n'

run moon -C "$consumer_root" fmt --check "$consumer_package"
run moon -C "$consumer_root" check "$consumer_package" --target native --deny-warn
run moon -C "$consumer_root" test "$consumer_package" --target native --deny-warn -v

temp_root="${TMPDIR:-/tmp}"
artifact_workspace="$(mktemp -d "${temp_root%/}/cairoon-package-consumer.XXXXXX")"
published_root="$artifact_workspace/published"
artifact_consumer_root="$artifact_workspace/consumer"
run mkdir -p "$published_root" "$artifact_consumer_root/src/smoke"
run python3 -m zipfile -e "$archive_path" "$published_root"
run cp "$consumer_root/moon.mod" "$artifact_consumer_root/moon.mod"
run cp \
  "$consumer_root/src/smoke/moon.pkg" \
  "$consumer_root/src/smoke/consumer_smoke_test.mbt" \
  "$artifact_consumer_root/src/smoke/"
printf '%s\n' \
  'members = [' \
  '  "./published",' \
  '  "./consumer",' \
  ']' > "$artifact_workspace/moon.work"

run moon -C "$artifact_consumer_root" fmt --check "$consumer_package"
run moon -C "$artifact_consumer_root" check "$consumer_package" --target native --deny-warn
run moon -C "$artifact_consumer_root" test "$consumer_package" --target native --deny-warn -v
printf 'Published archive passes the isolated consumer test.\n'
