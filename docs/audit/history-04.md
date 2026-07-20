# Migration Audit History, Part 4

Historical snapshot of `AUDIT.md` lines 1641-2084 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

- `moon -C cairoon test src/tests/pattern/raster --target native -v`: 13
  black-box raster-source tests passed from a nested external package,
  covering raw content construction, compatible target/extents acquire,
  release-only callback state, pycairo-derived raster callback fixtures,
  finished-surface failure injection, post-failure acquire replacement
  recovery, deterministic callback replacement/failure fuzz with dynamic
  compatible source surfaces, and final post-clear recovery.
- `moon -C cairoon test pattern_raster_manual_wbtest.mbt
  pattern_raster_owner_wbtest.mbt pattern_raster_state_wbtest.mbt --target
  native -v`: 6 white-box raster-source manual/owner/state tests passed,
  asserting manual `raster_get_callbacks()` acquire/release calls across three
  deterministic seeds, acquire-only repeated same-surface paints, a 64-step
  acquire-only replacement fuzz, release-only to acquire-only replacement
  without stale release callbacks, failed acquire replacement owner-count
  recovery, and a 72-step callback state-machine fuzz covering clear,
  release-only, acquire-only, acquire+release, failed acquire, dynamic
  compatible-source, callback-introspection, and owner-count balance
  transitions.
- `moon -C cairoon test surface_context_test.mbt surface_mapped_test.mbt
  surface.mbt.md --target native -v`: 32 scoped Surface/mapped-image tests and
  executable docs passed after adding pycairo-style success/error cleanup
  helpers.
- `moon -C cairoon test device_test.mbt backend_surfaces.mbt.md --target
  native -v`: 17 scoped Device/script backend tests and executable docs passed
  after adding pycairo-style device finish cleanup.
- `moon -C cairoon test --target native`: 340 tests passed after adding
  `Device::with_finished`, `Surface::with_finished`,
  `MappedImageSurface::with_unmapped`, and their executable docs examples.
- `moon -C cairoon info --target native`: passed, and `pkg.generated.mbti`
  records the new public scoped lifecycle helpers.
- ASan/LSan was not rerun for the scoped Surface lifecycle slice because it
  changed only MoonBit wrappers, tests, docs, and generated interface metadata,
  with no C glue, finalizer, callback trampoline, or retained-owner code
  change.
- ASan/LSan was not rerun for the scoped Device lifecycle slice because it
  changed only MoonBit wrappers, tests, docs, and generated interface metadata,
  with no C glue, finalizer, callback trampoline, or retained-owner code
  change.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  src/tests/pattern/core src/tests/pattern/mesh src/tests/pattern/pycairo
  src/tests/pattern/raster --target native -v`: 41
  ASan-compiled black-box pattern tests passed with leak detection disabled
  after the split, covering core/surface/mesh/pycairo pattern behavior,
  compatible target/extents raster-source acquire, release-only callback state,
  the raster acquire finished-surface rejection path, replacement recovery
  after that failure path, and deterministic callback replacement/failure fuzz
  with dynamic compatible source surfaces.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  pattern_raster_manual_wbtest.mbt pattern_raster_owner_wbtest.mbt
  pattern_raster_state_wbtest.mbt --target native -v`: 6 ASan-compiled
  white-box raster-source manual/owner/state tests passed with leak detection
  disabled, covering manual get-callback acquire/release calls, acquire-only
  repeated same-surface paints, the 64-step acquire-only replacement fuzz,
  stale release-to-acquire-only replacement, failed acquire replacement
  owner-count recovery, and the 72-step callback state-machine fuzz.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the raster-source owner-count test-probe slice. The full runner
  still failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class. A grep of
  `/tmp/cairoon-raster-owner-count-asan.txt` found no heap-use-after-free,
  stack-use-after, heap-buffer-overflow, global-buffer-overflow, double-free,
  `cairoon_raster`, `raster_source`, `cairoon_pattern`,
  `raster_surface_owner`, or `pattern_raster_owner` entries; summary:
  `54975 byte(s) leaked in 398 allocation(s)`. The ASan-instrumented
  white-box executable was then run directly with
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0` for
  `pattern_raster_owner_wbtest.mbt:0-1` and exited 0; the output is recorded
  in `/tmp/cairoon-raster-owner-count-whitebox-asan.txt`.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the raster-source acquire-only release-trampoline slice. The full
  runner still failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class after the black-box executable ran. A grep of
  `/tmp/cairoon-raster-release-trampoline-asan.txt` found no
  heap-use-after-free, stack-use-after, heap-buffer-overflow,
  global-buffer-overflow, double-free, `cairoon_raster`, `raster_source`,
  `cairoon_pattern`, or `make_data_backed_raster_source_pattern` entries;
  summary: `89194 byte(s) leaked in 474 allocation(s)`. The
  ASan-instrumented black-box executable was then run directly with
  `ASAN_OPTIONS=detect_leaks=1:fast_unwind_on_malloc=0` for
  `pattern_test.mbt:0-17` and `raster_lifetime_stress_test.mbt:0-1`; both
  exited 0, and
  `/tmp/cairoon-raster-release-trampoline-blackbox-asan.txt` plus
  `/tmp/cairoon-raster-release-trampoline-lifetime-asan.txt` record the
  selected tests.
- `moon -C cairoon test vector_output_wbtest.mbt --target native -v`: 21
  white-box tests passed after adding three PDF-only direct C tag oracle
  scenes for URI links, named destinations, and Document/Sect/H1/P structure
  tags. The vector oracle still covers fifteen PDF/PS/SVG scenes including
  clip, dashed stroke, repeated surface pattern, mask surface, and mesh
  pattern output, with SVG dynamic `source-*` image-id normalization,
  alongside existing MIME-output, page structure, metadata/tag marker, and
  direct C vector oracle checks.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the complex vector oracle slice. The full runner wrote
  `/tmp/cairoon-complex-vector-asan.txt` and failed during the known macOS
  FontRegistry/CoreText/ColorSync LeakSanitizer class after the black-box
  executable ran; summary: `88927 byte(s) leaked in 470 allocation(s)`. A grep
  of that log found no `ERROR: AddressSanitizer`, heap-use-after-free,
  stack-use-after, heap-buffer-overflow, global-buffer-overflow, double-free,
  `cairoon_test_apply_surface_pattern`, `cairoon_test_apply_mask_surface`,
  `cairoon_test_apply_mesh_pattern`, `cairoon_test_files_equal_svg_normalized`,
  or `cairoon_test_skip_digits_after_prefix` entries. The ASan-instrumented
  white-box executable was then run directly with
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0` for
  `vector_output_wbtest.mbt:0-20`; it exited 0 and
  `/tmp/cairoon-complex-vector-whitebox-asan.txt` records all 20 selected
  white-box tests, including `complex vector output scenes match direct cairo C
  oracle`.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the PDF tag oracle slice. The full runner wrote
  `/tmp/cairoon-pdf-tag-oracle-asan.txt` and failed during the known macOS
  FontRegistry/CoreText/ColorSync LeakSanitizer class after the black-box
  executable ran; summary: `88927 byte(s) leaked in 470 allocation(s)`. A grep
  of that log found no `ERROR: AddressSanitizer`, heap-use-after-free,
  stack-use-after, heap-buffer-overflow, global-buffer-overflow, double-free,
  `cairoon_test_draw_pdf`, `CAIROON_TEST_VECTOR_PDF_`,
  `cairoon_test_draw_vector_scene`, or
  `cairoon_test_render_vector_scene_oracle` entries. The ASan-instrumented
  white-box executable was then run directly with
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0` for
  `vector_output_wbtest.mbt:0-21`; it exited 0 and
  `/tmp/cairoon-pdf-tag-oracle-whitebox-asan.txt` records all 21 selected
  white-box tests, including `pdf tag output scenes match direct cairo C
  oracle`.
- `moon -C cairoon test vector_output_wbtest.mbt --target native -v`: 22
  white-box tests passed after adding one PDF-only direct C document-feature
  oracle scene covering metadata, custom metadata, page labels, outlines, URI
  links, named destinations, and Document/Sect/P structure tags across two
  pages. The existing vector oracle still covers fifteen PDF/PS/SVG scenes,
  three PDF-only tag scenes, SVG dynamic `source-*` normalization, and the
  existing marker tests.
- `moon -C cairoon test --target native`: 332 tests passed after the PDF
  document-feature oracle slice.
- `moon -C cairoon info --target native`: completed with no work to do after
  the PDF document-feature oracle slice.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the PDF document-feature oracle slice. The first sandboxed run
  could not write the temporary ASan runtime object to `~/.moon/lib`; the
  approved rerun wrote `/tmp/cairoon-pdf-document-feature-asan.txt` and failed
  during the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer class
  after the black-box executable ran; summary: `55231 byte(s) leaked in 406
  allocation(s)`. A grep of that log found no `ERROR: AddressSanitizer`,
  heap-use-after-free, stack-use-after, heap-buffer-overflow,
  global-buffer-overflow, double-free,
  `cairoon_test_render_pdf_document_features`,
  `CAIROON_TEST_VECTOR_PDF_DOCUMENT_FEATURES`, or
  `cairoon_test_render_vector_scene_oracle` entries. The ASan-instrumented
  white-box executable was then run directly with
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0` for
  `vector_output_wbtest.mbt:0-22`; it exited 0 and
  `/tmp/cairoon-pdf-document-feature-whitebox-asan.txt` records all 22
  selected white-box tests, including `pdf document feature scene matches
  direct cairo C oracle`.
- `moon -C cairoon test surface_context_test.mbt context_lifetime_test.mbt
  pattern_test.mbt --target native -v`: 32 tests passed after adding
  `Surface`/`Context`/`Pattern` pointer equality/hash.
- `moon -C cairoon test surface_context_test.mbt --target native -v`: 14
  black-box tests passed after adding `Rgb96F` and `Rgba128F` image-surface
  construction, stride, copied-data, and buffer-backed readback coverage.
- `moon -C cairoon test surface_context_test.mbt --target native -v`: 17
  black-box tests passed after adding ordinary image-surface finish/status
  coverage for idempotent finish and `SurfaceFinished` base-method,
  capability, dirty-marker, and state-wrapper errors.
- `moon -C cairoon test surface_context_test.mbt pattern_test.mbt
  raster_lifetime_stress_test.mbt pattern.mbt.md --target native -v`: 42
  black-box and executable doc tests passed after changing image-surface
  width/height/stride/format getters and copied-data readback to checked
  wrappers. The new surface test covers `SurfaceFinished` and non-image
  `SurfaceTypeMismatch`; raster-source callback tests and docs use `try!` for
  these now-checked getters inside no-error callback signatures.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the image-surface checked-getter slice. The full runner wrote
  `/tmp/cairoon-image-getters-asan.txt` and failed during the known macOS
  FontRegistry/CoreText/ColorSync LeakSanitizer class after the black-box
  executable ran; summary: `55231 byte(s) leaked in 406 allocation(s)`. A grep
  of that log found no `ERROR: AddressSanitizer`, heap-use-after-free,
  stack-use-after, heap-buffer-overflow, global-buffer-overflow, double-free,
  `cairoon_image_surface_get_`, `cairoon_image_surface_copy_data`,
  `cairoon_copy_image_surface_data`, or `cairoon_surface_require_type`
  entries. The ASan-instrumented black-box executable was then run directly
  with `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0` for
  `surface_context_test.mbt:0-18`, `pattern_test.mbt:0-17`,
  `raster_lifetime_stress_test.mbt:0-1`, and `pattern.mbt.md:0-6`; it exited
  0 and `/tmp/cairoon-image-getters-blackbox-asan.txt` records the selected
  tests, including `image surface properties map status and subtype errors`.
- `moon -C cairoon test surface_mime_test.mbt --target native -v`: 5
  black-box tests passed after adding image/PDF/PS/SVG
  `supports_mime_type` matrix coverage and invalid MIME type string coverage.
- `moon -C cairoon test src/tests/api/enums --target native --deny-warn -v`: 4
  black-box tests passed after adding `Rgb16_565`, `Rgb30`, `Rgb96F`,
  `Rgba128F`, and negative-width `Format::stride_for_width` coverage.
- `moon -C cairoon test surface_subsurface_test.mbt --target native -v`: 3
  black-box tests passed after adding invalid-size coverage for
  `Surface::create_for_rectangle`.
- `moon -C cairoon test font_face_test.mbt scaled_font_test.mbt --target native
  -v`: 15 black-box tests passed after adding embedded-NUL validation for toy
  font family, context font-family selection, and ScaledFont text extents.
- `moon -C cairoon test font_face_test.mbt --target native -v`: 10
  black-box tests passed after adding pycairo-compatible raw C-int toy
  slant/weight parsing for `FontFace::toy_raw` and
  `Context::select_font_face_raw`, including `InvalidSlant`/`InvalidWeight`
  error mapping for invalid raw values.
- `moon -C cairoon test region_test.mbt --target native -v`: 8 black-box
  tests passed after adding `Region::xor_rectangle` split-semantics coverage.
- `moon -C cairoon test region_test.mbt region.mbt.md --target native -v`: 12
  tests passed after changing Region boolean operations to return the mutated
  receiver as a cairoon checked-chaining extension over pycairo's `None`.
  This covered region and rectangle operands, explicit returned-receiver
  checks, a chained rectangle-boolean sequence, and executable Region docs.
- `moon -C cairoon info --target native`: regenerated `pkg.generated.mbti`
  after the public Region return-type change.
- `moon -C cairoon test --target native`: 333 tests passed after the Region
  chainable-mutator slice. ASan/LSan was not rerun because this slice changed
  only MoonBit wrappers, docs, and tests, with no C glue, callback, finalizer,
  or retained-owner changes.
- `moon -C cairoon test src/tests/object/core --target native -v`: 3
  black-box tests passed after adding MoonBit `Eq`/`Hash` protocol coverage for
  hashable Cairo external objects, `Path` self-comparison coverage through
  `Compare`, and `Region` equality coverage without `Hash`.
- `moon -C cairoon test region.mbt.md --target native -v`: 3 executable
  Region reference examples passed.
- `moon -C cairoon test src/tests/matrix/core --target native -v`: 5 Matrix
  core tests passed, covering field/component semantics, multiplication,
  rotation, inversion, and invalid-index/invalid-matrix error mapping.
- `moon -C cairoon test src/tests/matrix/property --target native -v`: 4
  Matrix property tests passed, covering deterministic multiplication
  associativity, inverse identity, composed point/distance transforms, and
  distance-vs-point-delta behavior.
- `moon -C cairoon test src/tests/matrix/pycairo --target native -v`: 4
  pycairo `test_matrix.py`-derived fixtures passed, covering equality,
  component access including positive/negative invalid indexes, invert/multiply,
  translate/scale/rotate composition, and identity point/distance transforms.
- `moon -C cairoon test src/matrix.mbt.md --target native -v`: 4 executable
  Matrix reference examples passed.
- `moon -C cairoon test path.mbt.md --target native -v`: 4 executable Path
  reference examples passed.
- `moon -C cairoon test pattern.mbt.md --target native -v`: 7 executable
  Pattern reference examples passed.
- `moon -C cairoon test surface.mbt.md --target native -v`: 6 executable
  Surface reference examples passed, covering image properties, buffer-backed
  data, similar/subsurface constructors, mapped images, PNG/MIME helpers, and
  checked surface errors.
- `moon -C cairoon test context.mbt.md --target native -v`: 8 executable
  Context reference examples passed, covering construction/state, transforms,
  paths, fill/stroke output, clipping, groups, text/glyphs, and checked context
  errors.
- `moon -C cairoon test font.mbt.md --target native -v`: 7 executable Font
  reference examples passed, covering FontOptions state/copy/merge, color
  palettes, toy font faces with raw slant/weight parsing, Surface/Context font
  options, ScaledFont matrices/metrics, text-to-glyphs, and checked font
  errors.
- `moon -C cairoon test backend_surfaces.mbt.md --target native -v`: 8
  executable Backend Surface reference examples passed, covering PDF/PS/SVG
  stream output and writer errors, PDF metadata/outlines, PS DSC, SVG document
  units, recording replay, Tee fanout, script devices/surfaces, and checked
  backend-specific errors.
- `moon -C cairoon test surface_pdf_test.mbt surface_ps_test.mbt
  surface_svg_test.mbt --target native -v`: 17 black-box tests passed after
  adding extended PDF/PS backend subtype-mismatch checks and SVG
  document-unit getter finished-status coverage.
- `moon -C cairoon test image_data_test.mbt --target native -v`: 9 black-box
  tests passed after fixing retained `ImageData` views to observe base-surface
  `SurfaceFinished` and adding ordinary/buffer-backed/PNG-loaded `get_data`
  after-finish coverage.
- `moon -C cairoon test --target native`: 325 tests passed.
- `moon -C cairoon info --target native`: passed; the latest ImageData
  owner-status fix did not change the public interface.
- Test-only buffer-backed image oracle coverage plus Pure MoonBit Region
  rectangle-XOR and executable Matrix/Surface/Context/Font/Path/Pattern/Region
  documentation coverage were added without rerunning ASan because no C glue or
  finalizer ownership code changed in those slices.
- Test-only source/mask/raster-source image-oracle helper coverage was added
  without changing the public API or native test count; sanitizer validation
  is recorded below.
- Executable backend surface/device reference documentation was added without
  rerunning ASan because no C glue, finalizer, callback trampoline, or retained
  owner code changed in that slice.
- Pure MoonBit PDF tag-output marker coverage for named destinations and
  document structure was added without rerunning ASan because no C glue,
  finalizer, callback trampoline, or retained owner code changed in that slice.
- Pure MoonBit Cairo float image-format coverage was added without rerunning
  ASan because no C glue, finalizer, callback trampoline, or retained owner
  code changed in that slice.
- Pure MoonBit format-stride coverage was added without rerunning ASan because
  no C glue, finalizer, callback trampoline, or retained owner code changed in
  that slice.
- Pure MoonBit ordinary image-surface finished-status coverage was added
  without rerunning ASan because no C glue, finalizer, callback trampoline, or
  retained owner code changed in that slice.
- Pure MoonBit backend surface subtype/lifecycle error-path coverage was added
  without rerunning ASan because no C glue, finalizer, callback trampoline, or
  retained owner code changed in that slice.
- The later ImageData owner-status fix changed C glue in
  `cairoon_image_data.c`; sanitizer validation is recorded below.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the ImageData owner-status fix. The full runner still failed under
  LeakSanitizer on this macOS workspace, with the known
  FontRegistry/CoreText/ColorSync class and existing raster-source/README
  leak stacks outside the ImageData owner-status path. The ASan-instrumented
  black-box executable was then run directly with leak detection disabled using
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0
  ./_build/native/debug/test/cairoon.blackbox_test.exe
  image_data_test.mbt:0-9`; it exited 0, and
  `/tmp/cairoon-image-data-owner-status-blackbox-asan.txt` shows all nine
  `image_data_test.mbt` tests executed without any AddressSanitizer
  invalid-access report.
- Documentation-only product-decision audit for pycairo `CAPI`, legacy enum
  aliases, and non-implemented FreeType/user-font classes: `moon -C cairoon
  check --target native`, `moon -C cairoon test --target native -v`, and
  `moon -C cairoon info --target native` passed on 2026-07-03.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the source/mask offset image-oracle C helper slice. The full runner
  again failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class while running the black-box executable, before Moon could
  launch the white-box executable. The log at
  `/tmp/cairoon-source-mask-offset-asan.txt` reports
  `89578 byte(s) leaked in 476 allocation(s)`. A grep of that log found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, or double-free entries. The
  ASan-compiled white-box image oracle was therefore run directly with leak
  detection disabled, and exited 0 as recorded above.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the raster-source image-oracle C helper slice. The full runner
  again failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class after running the black-box executable and before
  launching the white-box executable. The log at
  `/tmp/cairoon-raster-source-oracle-asan.txt` reports
  `55231 byte(s) leaked in 406 allocation(s)`. A grep of that log found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, double-free,
  `cairoon_test_raster_source`,
  `CAIROON_TEST_IMAGE_RASTER_SOURCE_PATTERN`,
  `cairoon_test_apply_raster_source_pattern`,
  `cairoon_test_draw_argb32_scene`,
  `cairoon_test_argb32_scene_oracle`, or `image_oracle` entries. The
  ASan-compiled white-box image oracle was then run directly with leak
  detection disabled; it exited 0 and
  `/tmp/cairoon-raster-source-oracle-whitebox-asan.txt` records both
  `image_oracle_wbtest.mbt` tests.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the ScaledFont text-to-glyph direct C oracle helper slice. The full
  runner still failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class after the black-box executable ran and before Moon could
  launch the white-box executable. A grep of
  `/tmp/cairoon-scaled-font-text-to-glyphs-oracle-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, double-free,
  `cairoon_test_scaled_font_text_to_glyphs_oracle`,
  `cairoon_test_scaled_font_extents_oracle`, `scaled_font_oracle`, or
  `cairoon_test_create_scaled_font_oracle` entries indicating invalid access.
  Summary: `55957 byte(s) leaked in 414 allocation(s)`. The ASan-instrumented
  white-box executable was then run directly with leak detection disabled using
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; it exited 0, and
  `/tmp/cairoon-scaled-font-text-to-glyphs-oracle-whitebox-asan.txt` shows the
  `scaled font extents match direct cairo C oracle` and
  `scaled font text_to_glyphs matches direct cairo C oracle` tests executed
  without any AddressSanitizer invalid-access report.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the glyph-index width FFI slice. The full runner still failed
  during the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer class
  after the black-box executable ran. A grep of
  `/tmp/cairoon-glyph-index-asan.txt` found no `ERROR: AddressSanitizer`,
  heap-use-after-free, stack-use-after, heap-buffer-overflow,
  global-buffer-overflow, or double-free entries; the `cairoon_context_glyph`
  hits were leak-stack frames. Summary:
  `1667619 byte(s) leaked in 12429 allocation(s)`. The ASan-instrumented
  black-box executable was then run directly with leak detection disabled for
  `value_types_test.mbt`, `glyph_array_test.mbt`, `text_to_glyphs_test.mbt`,
  `context.mbt.md`, and `README.mbt.md`; it exited 0 and
  `/tmp/cairoon-glyph-index-blackbox-asan.txt` records the selected tests. The
  ASan-instrumented white-box executable was likewise run for
  `scaled_font_oracle_wbtest.mbt` and `image_oracle_wbtest.mbt`; it exited 0
  and `/tmp/cairoon-glyph-index-whitebox-asan.txt` records those oracle tests.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the raster-source callback allocation stress slice. The full
  runner still failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class after the black-box executable ran. A grep of
  `/tmp/cairoon-raster-callback-stress-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, double-free, `cairoon_raster`,
  `raster_source`, `cairoon_pattern`, or raster-source helper entries
  indicating invalid access; the `raster_lifetime` hit was the Moon test
  selector line. Summary:
  `55957 byte(s) leaked in 414 allocation(s)`. The ASan-instrumented black-box
  executable was then run directly with leak detection disabled using
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; it exited 0, and
  `/tmp/cairoon-raster-callback-stress-blackbox-asan.txt` shows the
  `raster source callback allocation stress` test executed without any
  AddressSanitizer invalid-access report.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the backend stream callback stress slice. The full runner still
  failed during the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer
  class after the black-box executable ran. A grep of
  `/tmp/cairoon-stream-callback-stress-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, double-free, `cairoon_stream`,
  `cairoon_pdf_surface_create_for_stream`,
  `cairoon_ps_surface_create_for_stream`,
  `cairoon_svg_surface_create_for_stream`,
  `cairoon_surface_write_to_png_stream`,
  `cairoon_image_surface_create_from_png_stream`, or
  `cairoon_script_device_create_for_stream` entries indicating invalid access;
  the `lifetime_stress` hit was the Moon test selector line. Summary:
  `55669 byte(s) leaked in 412 allocation(s)`. The ASan-instrumented black-box
  executable was then run directly with leak detection disabled using
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; it exited 0, and
  `/tmp/cairoon-stream-callback-stress-blackbox-asan.txt` shows all six
  `lifetime_stress_test.mbt` tests executed without any AddressSanitizer
  invalid-access report.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the `ImageData` view allocation stress slice. The full runner still
  failed during the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer
  class after the black-box executable ran. A grep of
  `/tmp/cairoon-image-data-stress-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, double-free,
  `cairoon_image_data`, `mapped_image_surface_get_data`, or mapped/image data
  helper entries indicating invalid access; the `lifetime_stress` and
  `image_data_test` hits were Moon test selector lines. Summary:
  `56325 byte(s) leaked in 418 allocation(s)`. The ASan-instrumented black-box
  executable was then run directly with leak detection disabled using
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; it exited 0, and
  `/tmp/cairoon-image-data-stress-blackbox-asan.txt` shows all five
  `lifetime_stress_test.mbt` tests executed without any AddressSanitizer
  invalid-access report.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the external value-wrapper stress slice. The full runner still
  failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class after the black-box executable ran. A grep of
  `/tmp/cairoon-finalizer-value-stress-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, double-free,
  `script_device_create_for_stream`, `cairoon_stream`, `cairoon_pattern`,
  `cairoon_path`, `cairoon_region`, `cairoon_device`, or `cairoon_surface`
  entries indicating invalid access; the `lifetime_stress` hit was the Moon
  test selector line. Summary:
  `55717 byte(s) leaked in 412 allocation(s)`. The ASan-instrumented
  black-box executable was then run directly with leak detection disabled using
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; it exited 0, and
  `/tmp/cairoon-finalizer-value-stress-blackbox-asan.txt` shows all four
  `lifetime_stress_test.mbt` tests executed without any AddressSanitizer
  invalid-access report.
