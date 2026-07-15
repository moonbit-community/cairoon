#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
consumer_root="$repo_root/integration/consumer"
consumer_package="src/smoke"

run() {
  printf '\n+'
  printf ' %q' "$@"
  printf '\n'
  "$@"
}

cd "$repo_root"
if ! package_listing="$(moon package --list 2>&1)"; then
  printf '%s\n' "$package_listing" >&2
  exit 1
fi
if grep -Eq '^(\./)?integration(/|$)' <<< "$package_listing"; then
  printf 'error: integration fixture leaked into the publication archive\n' >&2
  exit 1
fi
printf 'Publication archive excludes the integration fixture.\n'

run moon -C "$consumer_root" fmt --check "$consumer_package"
run moon -C "$consumer_root" check "$consumer_package" --target native --deny-warn
run moon -C "$consumer_root" test "$consumer_package" --target native --deny-warn -v
