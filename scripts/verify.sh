#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"
package_root="src"
external_test_packages=()

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

run_external_test_packages() {
  local test_pkg
  for test_pkg in "${external_test_packages[@]}"; do
    if [[ "$#" -gt 0 ]]; then
      run "$@" moon test "$test_pkg" --target native -v
    else
      run moon test "$test_pkg" --target native -v
    fi
  done
}

run moon fmt --check
run python3 ./scripts/check-project-layout.py
run ./scripts/configure-link-flags.sh --check
run python3 ./scripts/check-ffi-ownership.py
run python3 ./scripts/check-api-inventory.py
run python3 ./scripts/check-reliability-ledger.py
run moon check --target native
run_external_test_packages

targeted_tests=(
  image_oracle_wbtest.mbt
  scaled_font_oracle_wbtest.mbt
  vector_output_wbtest.mbt
  vector_output_oracle_wbtest.mbt
  surface_stream_wbtest.mbt
  surface_stream_backend_wbtest.mbt
  surface_stream_combo_wbtest.mbt
  surface_stream_page_combo_wbtest.mbt
  surface_stream_nested_tag_wbtest.mbt
  surface_stream_page_sequence_wbtest.mbt
  surface_stream_tag_matrix_wbtest.mbt
  surface_stream_lifecycle_wbtest.mbt
  surface_stream_oracle_wbtest.mbt
  surface_stream_tag_wbtest.mbt
  object_traits_test.mbt
  context_lifetime_test.mbt
  path_test.mbt
  pattern_raster_manual_wbtest.mbt
  pattern_raster_owner_wbtest.mbt
  pattern_raster_state_wbtest.mbt
  lifetime_stress_test.mbt
  lifetime_value_stress_test.mbt
  lifetime_image_data_stress_test.mbt
  lifetime_finalizer_fuzz_test.mbt
  lifetime_stream_stress_test.mbt
)

for test_file in "${targeted_tests[@]}"; do
  run moon test "$package_root/$test_file" --target native -v
done

run moon test --target native
run moon info --target native

asan_mode="${CAIROON_VERIFY_ASAN:-auto}"
if [[ "$asan_mode" != "0" ]]; then
  clang_path="${MOON_CC:-}"
  if [[ -z "$clang_path" && -x /opt/homebrew/opt/llvm/bin/clang ]]; then
    clang_path=/opt/homebrew/opt/llvm/bin/clang
  fi

  if [[ -n "$clang_path" && -x "$clang_path" ]]; then
    asan_options="${ASAN_OPTIONS:-detect_leaks=0:fast_unwind_on_malloc=0}"
    moon_ar="${MOON_AR:-/usr/bin/ar}"
    run_external_test_packages env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options"
    for test_file in "${targeted_tests[@]}"; do
      run env \
        "MOON_CC=$clang_path" \
        "MOON_AR=$moon_ar" \
        "ASAN_OPTIONS=$asan_options" \
        moon test "$package_root/$test_file" --target native -v
    done
  else
    printf '\nSkipping targeted ASan: set MOON_CC to an ASan-capable clang, or set CAIROON_VERIFY_ASAN=0 to silence this message.\n'
  fi
fi
