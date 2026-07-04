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

targeted_tests=(
  image_oracle_wbtest.mbt
  scaled_font_oracle_wbtest.mbt
  font_options_test.mbt
  font_face_test.mbt
  scaled_font_test.mbt
  vector_output_wbtest.mbt
  vector_output_oracle_wbtest.mbt
  surface_context_test.mbt
  image_data_test.mbt
  surface_stream_test.mbt
  surface_stream_wbtest.mbt
  surface_mapped_test.mbt
  surface_subsurface_test.mbt
  surface_recording_test.mbt
  surface_mime_test.mbt
  surface_pdf_test.mbt
  surface_ps_test.mbt
  surface_svg_test.mbt
  surface_tee_test.mbt
  device_test.mbt
  object_traits_test.mbt
  context_lifetime_test.mbt
  context_state_test.mbt
  context_matrix_test.mbt
  context_path_test.mbt
  path_test.mbt
  context_group_test.mbt
  context_text_test.mbt
  glyph_array_test.mbt
  context_extents_test.mbt
  context_clip_test.mbt
  context_painting_test.mbt
  pattern_test.mbt
  pattern_raster_source_test.mbt
  pattern_gradient_test.mbt
  pattern_mesh_test.mbt
  pattern_raster_owner_wbtest.mbt
  region_test.mbt
  lifetime_stress_test.mbt
  lifetime_value_stress_test.mbt
  lifetime_image_data_stress_test.mbt
  lifetime_stream_stress_test.mbt
)

for test_file in "${targeted_tests[@]}"; do
  run moon test "$test_file" --target native -v
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
    for test_file in "${targeted_tests[@]}"; do
      run env \
        "MOON_CC=$clang_path" \
        "MOON_AR=$moon_ar" \
        "ASAN_OPTIONS=$asan_options" \
        moon test "$test_file" --target native -v
    done
  else
    printf '\nSkipping targeted ASan: set MOON_CC to an ASan-capable clang, or set CAIROON_VERIFY_ASAN=0 to silence this message.\n'
  fi
fi
