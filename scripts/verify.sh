#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
package_root="src"
support_packages=()
external_test_packages=()

if [[ -f "$package_root/native/moon.pkg" ]]; then
  support_packages+=("$package_root/native")
fi

if [[ -d "$package_root/core" ]]; then
  while IFS= read -r support_pkg_config; do
    support_packages+=("$(dirname "$support_pkg_config")")
  done < <(find "$package_root/core" -name moon.pkg -type f -print | sort)
fi

if [[ -d "$package_root/internal" ]]; then
  while IFS= read -r support_pkg_config; do
    support_packages+=("$(dirname "$support_pkg_config")")
  done < <(find "$package_root/internal" -name moon.pkg -type f -print | sort)
fi

if [[ -d "$package_root/tests" ]]; then
  while IFS= read -r test_pkg_config; do
    external_test_packages+=("$(dirname "$test_pkg_config")")
  done < <(find "$package_root/tests" -name moon.pkg -type f -print | sort)
fi

run() {
  printf '\n+'
  printf ' %q' "$@"
  printf '\n'
  "$@"
}

run_support_packages() {
  local support_pkg
  for support_pkg in "${support_packages[@]}"; do
    run moon test "$support_pkg" --target native --deny-warn -v
  done
}

run_external_test_packages() {
  local test_pkg
  for test_pkg in "${external_test_packages[@]}"; do
    if [[ "$#" -gt 0 ]]; then
      run "$@" moon test "$test_pkg" --target native --deny-warn -v
    else
      run moon test "$test_pkg" --target native --deny-warn -v
    fi
  done
}

resolve_executable() {
  local candidate="$1"
  if [[ "$candidate" == */* ]]; then
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
    fi
  else
    command -v "$candidate" 2>/dev/null || true
  fi
}

run moon fmt --check
run python3 ./scripts/check-project-layout.py
run ./scripts/configure-link-flags.sh --check
run python3 ./scripts/check-ffi-ownership.py
run python3 ./scripts/check-api-inventory.py
run python3 ./scripts/check-reliability-ledger.py
run moon check --target native --deny-warn
run_support_packages
run_external_test_packages

run moon test --target native --deny-warn
run moon info --target native

asan_mode="${CAIROON_VERIFY_ASAN:-auto}"
if [[ "$asan_mode" != "0" ]]; then
  clang_path=""
  if [[ -n "${MOON_CC:-}" ]]; then
    clang_path="$(resolve_executable "$MOON_CC")"
  fi
  if [[ -z "$clang_path" && -x /opt/homebrew/opt/llvm/bin/clang ]]; then
    clang_path=/opt/homebrew/opt/llvm/bin/clang
  fi

  if [[ -n "$clang_path" ]]; then
    asan_options="${ASAN_OPTIONS:-detect_leaks=0:fast_unwind_on_malloc=0}"
    moon_ar="${MOON_AR:-/usr/bin/ar}"
    run_external_test_packages env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options"
  else
    printf '\nSkipping targeted ASan: set MOON_CC to an ASan-capable clang, or set CAIROON_VERIFY_ASAN=0 to silence this message.\n'
  fi
fi
