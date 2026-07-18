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

run moon fmt --check
run python3 -m unittest discover -s scripts/tests -p 'test_*.py'
run python3 ./scripts/check-project-layout.py
run python3 ./scripts/check-source-size-budget.py
run ./scripts/configure-cairo-constants.sh --check
run python3 ./scripts/check-ffi-ownership.py
run python3 ./scripts/check-external-owners.py
run python3 ./scripts/check-stream-cleanup.py
run python3 ./scripts/check-api-inventory.py
run python3 ./scripts/check-public-docs.py
run python3 ./scripts/check-public-coverage.py
run python3 ./scripts/check-pycairo-test-parity.py
run python3 ./scripts/check-reliability-ledger.py
run python3 ./scripts/check-vector-backend-scenes.py
run moon check --target native --deny-warn --warn-list +73
run ./scripts/check-downstream-consumer.sh
run_support_packages
run_external_test_packages

run moon test --target native --deny-warn
run moon info --target native

asan_mode="${CAIROON_VERIFY_ASAN:-auto}"
if [[ "$asan_mode" != "0" ]]; then
  run python3 ./scripts/sanitizers/run.py
fi
