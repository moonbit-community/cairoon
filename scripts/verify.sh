#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

run() {
  printf '\n+'
  printf ' %q' "$@"
  printf '\n'
  "$@"
}

run moon fmt --check
run ./scripts/configure-link-flags.sh --check
run moon check --target native

run moon test image_oracle_wbtest.mbt --target native -v
run moon test scaled_font_oracle_wbtest.mbt --target native -v
run moon test vector_output_wbtest.mbt --target native -v
run moon test surface_stream_test.mbt --target native -v
run moon test surface_stream_wbtest.mbt --target native -v
run moon test surface_mapped_test.mbt --target native -v
run moon test surface_tee_test.mbt --target native -v
run moon test context_lifetime_test.mbt --target native -v
run moon test context_state_test.mbt --target native -v
run moon test context_matrix_test.mbt --target native -v
run moon test context_extents_test.mbt --target native -v
run moon test context_clip_test.mbt --target native -v
run moon test pattern_test.mbt --target native -v
run moon test pattern_gradient_test.mbt --target native -v
run moon test pattern_mesh_test.mbt --target native -v
run moon test pattern_raster_owner_wbtest.mbt --target native -v

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
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test image_oracle_wbtest.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test vector_output_wbtest.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test surface_stream_test.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test surface_stream_wbtest.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test surface_mapped_test.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test surface_tee_test.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test context_lifetime_test.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test context_state_test.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test context_matrix_test.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test context_extents_test.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test context_clip_test.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test pattern_test.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test pattern_gradient_test.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test pattern_mesh_test.mbt --target native -v
    run env \
      "MOON_CC=$clang_path" \
      "MOON_AR=$moon_ar" \
      "ASAN_OPTIONS=$asan_options" \
      moon test pattern_raster_owner_wbtest.mbt --target native -v
  else
    printf '\nSkipping targeted ASan: set MOON_CC to an ASan-capable clang, or set CAIROON_VERIFY_ASAN=0 to silence this message.\n'
  fi
fi
