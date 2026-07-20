# Migration Audit History, Part 5

Historical snapshot of `AUDIT.md` lines 2085-2653 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the image glyph-oracle helper slice. The full runner still failed
  during the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer class
  before launching the white-box executable. A grep of
  `/tmp/cairoon-image-glyph-oracle-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, double-free,
  `cairoon_test_render_argb32_scene_bytes`,
  `cairoon_test_draw_argb32_scene`,
  `cairoon_test_argb32_scene_oracle`, `cairoon_test_copy_image_bytes`, or
  `image_oracle` entries. Summary:
  `56037 byte(s) leaked in 415 allocation(s)`.
  The ASan-instrumented white-box executable was then run directly with leak
  detection disabled using
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; it exited 0 and
  `/tmp/cairoon-image-glyph-oracle-whitebox-asan.txt` shows the image oracle
  test executed without any AddressSanitizer invalid-access report.
  The previous ASan record covers the image text-oracle helper slice, where
  the full runner still failed during the same known macOS LeakSanitizer class
  with the same summary while direct whitebox ASan exited 0.
  The earlier ASan record covers the two-page vector oracle helper slice. The
  full runner still
  failed during the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer
  class before the white-box executable launched. A grep of
  `/tmp/cairoon-vector-multipage-asan.txt` found no `ERROR: AddressSanitizer`,
  heap-use-after-free, heap-buffer-overflow, global-buffer-overflow,
  double-free, `cairoon_test_render_vector_scene_oracle`,
  `cairoon_test_draw_vector_scene`, `cairoon_test_render_vector_surface`, or
  `cairoon_test_vector` entries. Summary:
  `56037 byte(s) leaked in 415 allocation(s)`.
  The ASan-instrumented white-box executable was then run directly with leak
  detection disabled using
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; it exited 0 and
  `/tmp/cairoon-vector-multipage-whitebox-asan.txt` shows the vector output
  oracle test executed without any AddressSanitizer invalid-access report.
  The previous equality/hash rerun found no invalid access and no
  `cairoon_surface_equal`, `cairoon_surface_hash`, `cairoon_context_equal`,
  `cairoon_context_hash`, `cairoon_pattern_equal`, or `cairoon_pattern_hash`
  entries in the visible leak roots; it still failed during the same known
  macOS LeakSanitizer reporting class. Summary:
  `56037 byte(s) leaked in 415 allocation(s)`.
  The previous vector scene oracle rerun found no invalid access and no
  `cairoon_test_render_vector_scene_oracle`,
  `cairoon_test_draw_vector_scene`, or
  `cairoon_test_render_vector_surface` entries in the visible leak roots; it still
  failed during the known macOS LeakSanitizer reporting class documented in
  `TESTING.md`. Summary:
  `55445 byte(s) leaked in 407 allocation(s)`.
  An earlier retained-owner stress
  ASan run found a heap-use-after-free in `cairoon_copy_image_surface_data` reached from
  `lifetime_stress_test.mbt` when a returned target surface outlived a context
  created from a mapped image. The fixed rerun, and the later TeeSurface rerun,
  and this latest rerun no longer report that invalid access and fail during
  LeakSanitizer reporting.
  The reported allocations are rooted in
  `cairo_toy_font_face_create`, `cairo_select_font_face`, macOS
  FontRegistry/CoreGraphics frames, and scaled-font Quartz/CoreText paths such
  as `cairo_scaled_font_create`, `CGFontCopyURL`, and
  `CTFontCreateWithGraphicsFont`, plus toy-text rendering caches reached
  through `cairo_show_text`, and glyph rendering/path caches reached through
  `cairo_show_glyphs`, `cairo_glyph_path`, and `cairo_show_text_glyphs`,
  `CTFontDrawGlyphs`, CoreGraphics, and ColorSync;
  no AddressSanitizer invalid-access report appeared before LSan failed and no
  text-to-glyphs native result finalizer, glyph/cluster marshaling helper,
  RecordingSurface helper, PDFSurface helper, PSSurface helper, SVGSurface
  helper, PDF outline helper, MeshPattern/Pattern helper,
  Device/ScriptSurface helper, RasterSourcePattern helper, Context
  text/tag/group, MIME-data stub, or
  Surface `create_for_rectangle` helper, retained-parent subsurface
  helper/finalizer stack, retained target/group-target helper stack,
  mapped-image lifetime helper stack, Context `set_source_surface` helper,
  Context hairline helper, TeeSurface helper stack, compile-time constant
  helper stack, vector-output file-scan helper stack, direct C image oracle
  helper stack, vector-output direct C oracle helper stack,
  ImageData helper/finalizer stack, or mapped-image data helper
  stack appeared in the visible leak roots of the latest rerun. The first
  stream-writer ASan run exposed a real `moonbit_make_bytes` leak rooted at
  `cairoon_stream_write`; the fixed rerun removed all `cairoon_stream` leak
  roots. A grep of `/tmp/cairoon-png-stream-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after, or
  `cairoon_surface_write_to_png_stream` / `cairoon_stream` entries.
  Summary: `64909 byte(s) leaked in 399 allocation(s)`. The PNG stream-read
  slice then added exact-length read callbacks and two black-box tests; a grep
  of `/tmp/cairoon-png-read-stream-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  global-buffer-overflow, `cairoon_image_surface_create_from_png_stream`,
  `cairoon_stream_read`, or `cairoon_stream` entries. Summary:
  `55397 byte(s) leaked in 405 allocation(s)`. The script stream-device slice
  then added device-retained write callbacks and two black-box tests; a grep of
  `/tmp/cairoon-script-stream-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  global-buffer-overflow, `cairoon_script_device_create_for_stream`,
  `cairoon_stream_attach_device`, or `cairoon_stream` entries. Summary:
  `64765 byte(s) leaked in 396 allocation(s)`. The helper still emits
  a `moon.mod.json` lookup warning because this package uses `moon.mod`, but it
  correctly patched and restored the DSL `moon.pkg` and MoonBit runtime object
  for this package.
  The preceding tag-nesting slice is pure MoonBit test coverage and raised the
  native suite to 206 tests; ASan was not rerun for that non-C change.
  The later PDF link-tag output marker slice is pure MoonBit test coverage and
  raised the native suite to 208 tests; ASan was not rerun for that non-C
  change.
  The later ImageData slice added C glue, a new external object, and four
  black-box tests; ASan/LSan was rerun as described above.
  The later mapped-image ImageData slice added three black-box tests and reused
  the same external object with a mapped-wrapper owner check; ASan/LSan was
  rerun as described above.
  The later PDF/PS/SVG stream-writer slice added C callback state, copied-byte
  trampolines, and four black-box tests; ASan/LSan was rerun as described above.
  The later PNG stream-write slice reused the copied-byte writer trampoline and
  added two black-box tests; ASan/LSan was rerun as described above.
  The later PNG stream-read slice added exact-length reader callbacks and two
  black-box tests; ASan/LSan was rerun as described above.
  The later script stream-device slice added device-retained write callbacks
  and two black-box tests; ASan/LSan was rerun as described above.
  The later RasterSourcePattern slice added retained acquire/release callbacks,
  acquired-surface owner tracking, focused behavior/lifetime tests, README
  coverage, and retained-owner stress-loop coverage; ASan/LSan was rerun as
  described above. The later get-acquire slice returned retained MoonBit
  acquire/release closures and added optional/clear/subtype tests.
  The later PS/SVG Link tag inertness slice added two pure MoonBit vector-output
  tests, raising the native suite to 233 tests; ASan/LSan was not rerun for that
  non-C change.
  The later image oracle slice added C helper scenes and was checked with the
  ASan runner at `/tmp/cairoon-image-oracle-asan.txt`: the full `moon test`
  ASan/LSan run still failed during the known macOS LeakSanitizer class before
  Moon could launch the white-box executable, with the same
  `55365 byte(s) leaked in 405 allocation(s)` summary and no
  AddressSanitizer invalid-access report. The ASan-instrumented white-box
  executable was then run directly with leak detection disabled and exited 0;
  `/tmp/cairoon-image-oracle-whitebox-asan.txt` shows the image oracle test
  executed, and greps found no `ERROR: AddressSanitizer`, heap-use-after-free,
  stack-use-after, global-buffer-overflow, heap-buffer-overflow, or double-free
  report.
  The later `ScaledFont::text_to_glyphs_only` slice is pure MoonBit API
  coverage for pycairo's `with_clusters=False` path; the native suite stayed at
  233 tests and ASan/LSan was not rerun for that non-C change.
  The later ScaledFont text-to-glyph oracle slice added a private C helper and
  a second white-box ScaledFont oracle test, raising the native suite to 249
  tests; ASan/LSan validation is recorded in `Last Verified` above.
  The later ScaledFont text-to-glyph matrix slice expanded that same white-box
  oracle test to cover empty, ASCII, precomposed Latin UTF-8, CJK UTF-8, and
  varied baseline coordinates without changing public API or test count; ASan
  was not rerun because no C glue changed.
  The later vector scene oracle slice broadened the private C vector oracle
  from a paint-only fixture to seven deterministic PDF/PS/SVG scenes covering
  paint, stroke, fill/stroke rectangles, Bezier paths, transforms, and
  linear/radial gradients, raising the native suite to 234 tests. The full
  ASan/LSan runner wrote `/tmp/cairoon-vector-scenes-asan.txt` and failed only
  in the known macOS LeakSanitizer class summarized above; greps found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, double-free, or new vector scene
  helper entries. The ASan-instrumented white-box executable was then run
  directly with leak detection disabled; it exited 0, and
  `/tmp/cairoon-vector-scenes-whitebox-asan.txt` shows the vector output scene
  oracle test executed without any AddressSanitizer invalid-access report.
  The later toy-font text-path and `show_text` oracle slices expanded those
  fixtures to nine scenes, and the later two-page oracle slice expanded them to
  ten scenes without changing the number of tests. The latest sanitizer
  validation is recorded in `Last Verified` above.
  The later Surface invalid-size slice added pure MoonBit black-box coverage for
  `create_similar`, `create_similar_image`, and `create_for_rectangle` mapping
  negative dimensions to `CairoInvalidArgument(InvalidSize, _)`, raising the
  native suite to 251 tests; ASan was not rerun because no C glue changed.
  The later ScaledFont matrix-composition slice added pure MoonBit black-box
  coverage for sheared font matrices, sheared CTMs, CTM translation suppression,
  and scale-matrix composition, raising the native suite to 252 tests; ASan was
  not rerun because no C glue changed.
  The later Region documentation slice added `region.mbt.md` with three
  executable examples, raising the native suite to 256 tests; ASan was not
  rerun because no C glue changed.
  The later Matrix documentation slice added `matrix.mbt.md` with four
  executable examples, raising the native suite to 260 tests; ASan was not
  rerun because no C glue changed.
  The later Matrix property-test slice added `matrix_property_test.mbt` with
  four deterministic property checks for multiplication associativity, inverse
  identity, composed point/distance transforms, and distance-vs-point-delta
  behavior, raising the native suite to 392 tests. The file is included in the
  targeted normal and ASan verification gate because it exercises value-level
  transform semantics used throughout drawing code.
  The later Path documentation slice added `path.mbt.md` with four executable
  examples covering typed segments, pycairo-style string formatting, flattened
  append behavior, copied-path ownership, and checked invalid-matrix errors,
  raising the native suite to 264 tests; ASan was not rerun because no C glue
  changed.
  The later Pattern documentation slice added `pattern.mbt.md` with six
  executable examples covering solid/shared state, surface patterns, gradients,
  mesh patches, raster-source callbacks, and checked subtype/index/lifecycle
  errors, raising the native suite to 270 tests; ASan was not rerun because no
  C glue changed.
  The later buffer-backed image oracle slice expanded `image_oracle_wbtest.mbt`
  so `Surface::image_for_data` renders the same ARGB32 scenes against the
  existing direct C Cairo oracle and verifies backing-buffer bytes match
  `copy_data`, raising the native suite to 271 tests; ASan was not rerun
  because no C glue changed. The later source/mask offset oracle slice expanded
  that image oracle helper to fifteen scenes covering non-zero
  `set_source_surface` and `mask_surface` offsets on ordinary and
  buffer-backed image surfaces. The later raster-source image oracle slice
  expanded it to sixteen scenes by comparing `Pattern::raster_source` repeat
  rendering against direct C Cairo. The later dashed-stroke image oracle slice
  expanded it to seventeen scenes by comparing dash and round-cap stroke state
  against direct C Cairo. The later clipped-output image oracle slice expanded
  it to eighteen scenes by comparing clipped paint/fill output against direct C
  Cairo. The later operator-output image oracle slice expanded it to nineteen
  scenes by comparing `OperatorClear` compositing output against direct C Cairo.
  The later surface-pattern-combo image oracle slice expanded it to twenty
  scenes by comparing surface-pattern `Reflect`/`Nearest`/`DitherBest`/matrix
  combination output against direct C Cairo.
  The later Surface documentation slice added `surface.mbt.md` with six
  executable examples covering image properties, buffer-backed data,
  similar/subsurface constructors, mapped images, PNG/MIME helpers, and checked
  surface errors, raising the native suite to 277 tests; ASan was not rerun
  because no C glue changed.
  The later Context documentation slice added `context.mbt.md` with eight
  executable examples covering construction/state, transforms, paths,
  fill/stroke output, clipping, groups, text/glyphs, and checked context
  errors, raising the native suite to 285 tests; ASan was not rerun because no
  C glue changed.
  The later Font documentation slice added `font.mbt.md` with seven executable
  examples covering FontOptions state/copy/merge, color palettes, toy font
  faces, Surface/Context font options, ScaledFont matrices/metrics,
  text-to-glyphs, and checked font errors, raising the native suite to 292
  tests; ASan was not rerun because no C glue changed.
  The later Backend Surface documentation slice added `backend_surfaces.mbt.md`
  with eight executable examples covering PDF/PS/SVG stream output and writer
  errors, PDF metadata/outlines, PS DSC, SVG document units, recording replay,
  Tee fanout, script devices/surfaces, and checked backend-specific errors,
  raising the native suite to 300 tests; ASan was not rerun because no C glue
  changed.
  The later PDF tag-output marker slice added two pure MoonBit white-box tests
  covering named destinations and document structure tags, raising the native
  suite to 302 tests; ASan was not rerun because no C glue changed.
  The later Cairo float image-format slice added two pure MoonBit black-box
  tests covering `Rgb96F` and `Rgba128F` construction/readback for ordinary and
  buffer-backed image surfaces, raising the native suite to 304 tests; ASan was
  not rerun because no C glue changed.
  The later format-stride slice added one pure MoonBit black-box test covering
  `Rgb16_565`, `Rgb30`, `Rgb96F`, `Rgba128F`, and negative-width
  `Format::stride_for_width`, raising the native suite to 305 tests; ASan was
  not rerun because no C glue changed.
  The later raster-source finished-surface slice added one black-box
  failure-injection test and C-side surface-finished tracking for callbacks,
  raising the native suite to 306 tests; targeted ASan with leak detection
  disabled passed for `pattern_test.mbt`.
  The later ordinary image-surface finished-status slice added one pure
  MoonBit black-box test covering idempotent `finish()` and `SurfaceFinished`
  mapping for `flush`, `copy_page`, and `show_page`, raising the native suite
  to 307 tests; ASan was not rerun because no C glue changed.
  The later raster-source optional-callback slice added release-only callback
  state APIs and one black-box test, raising the native suite to 308 tests;
  targeted ASan with leak detection disabled passed for `pattern_test.mbt`.
  The later backend MIME support matrix slice added one pure MoonBit black-box
  test, raising the native suite to 309 tests; ASan was not rerun because no C
  glue changed.
  The later spaced-ASCII text-to-glyph slice added one pure MoonBit black-box
  test and expanded the existing ScaledFont direct C oracle case set, raising
  the native suite to 310 tests; ASan was not rerun because no C glue changed.
  The later glyph-index width slice promoted `Glyph.index` and glyph marshal
  arrays to `UInt64`, added one pure value-type max-index test, and raised the
  native suite to 311 tests; targeted ASan validation is recorded above.
  The later pure value-type numeric-limit slice added one black-box test for
  pycairo `Rectangle`, `TextExtents`, and `TextCluster` boundary values,
  raising the native suite to 312 tests; ASan was not rerun because no C glue
  changed.
  The later surface numeric-limit slice added one black-box test for pycairo
  `Surface::set_device_offset`, `Surface::set_device_scale`, and
  `Surface::create_for_rectangle` extreme numeric cases, raising the native
  suite to 313 tests; ASan was not rerun because no C glue changed.
  The later PDF combined vector-output marker slice added one pure MoonBit
  white-box test covering metadata, custom metadata, page labels, outlines, URI
  links, named destinations, and document-structure tags across a two-page PDF,
  raising the native suite to 314 tests; ASan was not rerun because no C glue
  changed.
  The later PS DSC multi-page vector-output marker slice added one pure MoonBit
  white-box test covering language-level restriction, setup DSC comments,
  page-setup DSC comments, and two-page drawing markers, raising the native
  suite to 315 tests; the later backend-feature oracle slice upgraded this test
  with a direct C Cairo output oracle.
  The later SVG version-unit multi-page vector-output marker slice added one
  pure MoonBit white-box test covering SVG 1.2 version restriction, `SvgUnitPx`
  state, px width/height output, and two-page drawing markers, raising the
  native suite to 316 tests; the later backend-feature oracle slice upgraded
  this test with a direct C Cairo output oracle.
  The later PDF thumbnail vector-output marker slice added one pure MoonBit
  white-box test covering `Surface::pdf_set_thumbnail_size` output through
  `/Thumb` image markers and thumbnail dimensions, raising the native suite to
  317 tests; ASan was not rerun because no C glue changed.
  The later UTF-8 string-boundary slice added two pure MoonBit black-box tests
  covering embedded-NUL rejection for `FontFace::toy`,
  `Context::select_font_face`, and `ScaledFont::text_extents`, raising the
  native suite to 319 tests; ASan was not rerun because no C glue changed.
  The later Surface finished-status slice added one pure MoonBit black-box test
  covering `Surface::has_show_text_glyphs`, dirty markers, device offset/scale
  wrappers, and fallback-resolution wrappers after `finish()`, raising the
  native suite to 320 tests; ASan was not rerun because no C glue changed.
  The later backend surface error-path slice added three pure MoonBit
  black-box tests covering extended PDF custom-metadata/thumbnail/outline
  subtype mismatches, PS size/setup/page-setup subtype mismatches, and SVG
  document-unit getters after `finish()`, raising the native suite to 323
  tests; ASan was not rerun because no C glue changed.
  The later ImageData owner-status slice fixed ordinary `ImageData` views to
  check their retained base `Surface` wrapper before byte access and added two
  black-box tests for ordinary, buffer-backed, and PNG-loaded `get_data` after
  `finish()` plus retained-view base-finish invalidation, raising the native
  suite to 325 tests; ASan validation is recorded above.
  The later raster-source acquire-only release-trampoline slice changed C glue
  to install `cairoon_raster_source_release` whenever an acquire callback is
  installed, so acquired surface owners retained by C are released even without
  a user release closure. This changed no public API and kept the native suite
  at 325 tests; ASan/LSan validation is recorded above.
  The later external-object trait slice added pure MoonBit `Eq`/`Hash`
  implementations for hashable Cairo external objects, `Compare` for `Path`,
  `Eq` for unhashable `Region`, and three black-box tests, raising the native
  suite to 328 tests; ASan was not rerun because no C glue, finalizer, callback
  trampoline, or retained owner code changed.
  The later complex vector oracle slice added five private direct C vector
  scenes covering clip, dash, repeated surface patterns, mask surfaces, and
  mesh patterns across PDF/PS/SVG, plus SVG dynamic `source-*` id
  normalization. This changed only test-helper C glue and one white-box test,
  raising the native suite to 329 tests; ASan/LSan validation is recorded
  above.
  The later PDF tag oracle slice added three private PDF-only direct C vector
  scenes covering URI links, named destinations, and Document/Sect/H1/P
  structure tags. This changed only test-helper C glue and one white-box test,
  raising the native suite to 330 tests; ASan/LSan validation is recorded
  above.
  The later image-surface checked-getter slice changed public
  width/height/stride/format getters to `raise CairoError`, added status
  plumbing for copied-data readback, and covered `SurfaceFinished` plus
  non-image `SurfaceTypeMismatch`, raising the native suite to 331 tests;
  ASan/LSan validation is recorded above.
  The later PDF document-feature oracle slice added one private PDF-only
  direct C vector scene covering metadata, custom metadata, page labels,
  outlines, URI links, named destinations, and Document/Sect/P structure tags
  across two pages. This changed only test-helper C glue and one white-box
  test, raising the native suite to 332 tests; ASan/LSan validation is
  recorded above.
  The later PDF combined text document-feature oracle slice upgraded the
  combined metadata/custom-metadata/page-label/outline/URI/named-destination/
  document-structure marker test with a second private PDF-only direct C
  vector scene that includes text under Link, Dest, and Document/Sect/P tags.
  This changed only test-helper C glue and one existing white-box test.
  The later Region chainable-mutator slice changed public Region boolean
  methods to return the mutated receiver, matching pycairo's
  `intersect`/`subtract`/`union`/`xor` return semantics for both region and
  rectangle operands, and added one black-box test. This raised the native
  suite to 333 tests; ASan/LSan was not rerun because no C glue, finalizer,
  callback, or retained-owner code changed.
  The later raster-source owner-count slice added a private C test probe and
  one white-box test asserting that acquire-only repeated same-surface paints
  release cairoon's retained owner back to zero after each paint. This raised
  the native suite to 334 tests; ASan/LSan validation is recorded above.
  The later Surface scoped-lifecycle slice added public
  `Surface::with_finished` and `MappedImageSurface::with_unmapped`, matching
  pycairo surface and mapped-image context-manager cleanup with success and
  Cairo-error coverage, plus two executable Surface docs examples and refreshed
  generated interface metadata. This raised the native suite to 338 tests;
  ASan/LSan was not rerun because no C glue, finalizer, callback trampoline,
  or retained-owner code changed.
  The later Device scoped-lifecycle slice added public
  `Device::with_finished`, matching pycairo device context-manager cleanup with
  success and Cairo-error coverage, plus one executable Backend Surface docs
  example and refreshed generated interface metadata. This raised the native
  suite to 340 tests; ASan/LSan was not rerun because no C glue, finalizer,
  callback trampoline, or retained-owner code changed.
  The later dashed-stroke image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from sixteen to seventeen scenes,
  adding dash and round-cap stroke-state coverage without changing the public
  API or adding a new test case. The targeted `image_oracle_wbtest.mbt` run
  passed 2 tests, the targeted ASan build passed 2 tests with leak detection
  disabled, and the full native suite remained at 340 tests.
  The later clipped-output image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from seventeen to eighteen scenes,
  adding clipped paint/fill output coverage without changing the public API or
  adding a new test case. The targeted `image_oracle_wbtest.mbt` run passed 2
  tests, the targeted ASan build passed 2 tests with leak detection disabled,
  and the full native suite remained at 340 tests.
  The later operator-output image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from eighteen to nineteen scenes,
  adding `OperatorClear` compositing output coverage without changing the
  public API or adding a new test case. The targeted `image_oracle_wbtest.mbt`
  run passed 2 tests, the targeted ASan build passed 2 tests with leak
  detection disabled, and the full native suite remained at 340 tests.
  The later surface-pattern-combo image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from nineteen to twenty scenes,
  adding `Reflect`/`Nearest`/`DitherBest`/matrix surface-pattern coverage
  without changing the public API or adding a new test case. The targeted
  `image_oracle_wbtest.mbt` run passed 2 tests, and the targeted ASan build
  passed 2 tests with leak detection disabled.
  The later transformed-gradient-pattern image oracle slice expanded the
  ordinary and buffer-backed direct C ARGB32 image oracle from twenty to
  twenty-one scenes, adding transformed repeated linear-gradient
  `Repeat`/`Nearest`/`DitherFast`/matrix coverage without changing the public
  API or adding a new test case. The targeted `image_oracle_wbtest.mbt` run
  passed 2 tests, and the targeted ASan build passed 2 tests with leak detection
  disabled. The full native suite remained at 457 tests.
  The later mesh-pattern image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from twenty-one to twenty-two
  scenes, adding mesh-pattern fill output coverage by reusing the existing
  direct C vector-oracle mesh helper. The targeted `image_oracle_wbtest.mbt`
  run passed 2 tests, the targeted ASan build passed 2 tests with leak
  detection disabled, and the full native suite remained at 457 tests.
  The later group-compositing image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from twenty-two to twenty-three
  scenes, adding `push_group_with_content`/`pop_group_to_source`/
  `paint_with_alpha` output coverage without changing the public API or adding
  a new test case. The targeted `image_oracle_wbtest.mbt` run passed 2 tests,
  the targeted ASan build passed 2 tests with leak detection disabled, and the
  full native suite remained at 457 tests.
  The later mask-pattern image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from twenty-three to twenty-four
  scenes, adding `Context::mask(Pattern)` alpha-mask compositing output
  coverage without changing the public API or adding a new test case. The
  targeted `image_oracle_wbtest.mbt` run passed 2 tests, the targeted ASan
  build passed 2 tests with leak detection disabled, and the full native suite
  remained at 457 tests.
  The later even-odd fill-rule image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from twenty-four to twenty-five
  scenes, adding `Context::set_fill_rule(FillEvenOdd)`/`fill` output coverage
  without changing the public API or adding a new test case. The targeted
  `image_oracle_wbtest.mbt` run passed 2 tests, the targeted ASan build passed
  2 tests with leak detection disabled, and the full native suite remained at
  457 tests.
  The later radial-pattern-combo image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from twenty-five to twenty-six
  scenes, adding transformed radial-gradient `Reflect`/`Nearest`/`DitherGood`
  matrix output coverage without changing the public API or adding a new test
  case. The targeted `image_oracle_wbtest.mbt` run passed 2 tests, the targeted
  ASan build passed 2 tests with leak detection disabled, and the full native
  suite remained at 457 tests.
  The later expanded-pattern-combo image oracle slice expanded the ordinary
  and buffer-backed direct C ARGB32 image oracle from twenty-six to thirty
  scenes, adding surface-pattern `Pad`/`Bilinear`/`DitherDefault`/matrix,
  surface-pattern `ExtendNone`/`Nearest`/`DitherNone`/matrix, transformed
  linear-gradient `Pad`/`Bilinear`/`DitherBest`/matrix, and transformed
  radial-gradient `Repeat`/`Bilinear`/`DitherFast`/matrix output coverage
  without changing the public API or adding a new test case. The targeted
  `image_oracle_wbtest.mbt` run passed 2 tests, and the current full native
  suite remains at 485 tests.
  The later pattern-combo continuation slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from thirty to thirty-four scenes,
  adding surface-pattern `Repeat`/`Bilinear`/`DitherGood`/matrix, transformed
  linear-gradient `ExtendNone`/`Good`/`DitherNone`/matrix with duplicate-offset
  stops, transformed radial-gradient `Pad`/`Good`/`DitherDefault`/matrix, and
  curve/multi-patch mesh-pattern matrix output coverage without changing the
  public API or adding a new test case. The targeted `image_oracle_wbtest.mbt`
  run passed 2 tests, and the current full native suite remains at 485 tests.
  The later pattern-stack image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from thirty-four to thirty-five
  scenes, adding nested surface/linear/radial/mask pattern-stack
  clip/save/restore/OperatorAtop output coverage without changing the public
  API. The targeted `src/tests/oracle/image` run passed 2 tests.
  The later raster-source acquire-replacement recovery slice added one
  black-box test proving that a finished-surface acquire failure maps to
  `NoMemory` for that paint, does not permanently poison the raster-source
  pattern, and allows a replaced acquire/release pair to paint and release
  correctly. This raised the native suite to 341 tests. `./scripts/verify.sh`
  passed, including the 18-test `pattern_test.mbt` run and targeted
  ASan-compiled pattern run with leak detection disabled.
  The later context source-pattern lifetime slice added one black-box test
  proving that a `Context::get_source` surface pattern remains usable after the
  original source wrapper and context scope have exited. This closed the
  `Sources` sub-row as Done and raised the native suite to 342 tests.
  `./scripts/verify.sh` passed, including the full 342-test native suite.
  The later context group-target lifetime slice changed `get_group_target`
  returned surfaces to retain the `Context` wrapper, added one black-box test
  proving the returned group target remains readable after its creating context
  helper scope exits, and closed the `Construction and target lifetime` sub-row
  as Done. This raised the native suite to 343 tests. `./scripts/verify.sh`
  passed, including the full 343-test native suite.
  The later ScriptDevice product-scope slice marked `ScriptDevice` /
  `ScriptSurface` Done by recording that Python file-like object adapters are
  represented by explicit MoonBit stream callbacks rather than Python objects;
  the existing 23-test device/backend/lifetime target passed.
  The later PS/SVG Link tag oracle slice upgraded backend inertness checks with
  a direct C Cairo oracle comparison for the shared Link tag scene on PS and
  SVG outputs. This raised `vector_output_wbtest.mbt` to 23 tests and the full
  native suite to 344 tests.
  The later ScaledFont UTF-8 oracle slice expanded the existing direct C Cairo
  ScaledFont oracle inputs to cover decomposed Latin text extents plus
  decomposed Latin, Arabic RTL, and emoji/non-BMP `text_to_glyphs` cases. This
  did not add public API or a new test case; the targeted 2-test
  `scaled_font_oracle_wbtest.mbt` run passed, including an ASan-compiled rerun
  with leak detection disabled.
  The later raster-source compatible-extents slice ported pycairo's acquire
  pattern that creates a compatible image from callback target/extents, applies
  the extents device offset, paints into it, and balances release callbacks.
  This raised `pattern_test.mbt` to 19 tests and the full native suite to 345
  tests.
  The later PDF text-tag oracle slice added three direct C Cairo oracle scenes
  for URI-link, named-destination, and document-structure tags drawn with
  `show_text`. This raised `vector_output_wbtest.mbt` to 24 tests and the full
  native suite to 346 tests.
  The later backend tag/text-tag oracle slice expanded that check to normalized
  direct C Cairo comparisons for PS and SVG destination and shared
  Document/Sect/H1/P rectangle and text tag scenes. This raised
  `vector_output_wbtest.mbt` to 25 tests and the full native suite to 347
  tests.
  The later tagged multi-page text oracle slice added one cross-backend direct C
  Cairo comparison covering URI links on page one and named-destination plus
  Document/Sect/P text tags on page two. This raised
  `vector_output_wbtest.mbt` to 26 tests and the full native suite to 348
  tests.
  The later raster-source deterministic callback fuzz slice added a 25-step
  replacement/failure/recovery test covering temporary release-only state,
  callback clearing, finished-surface failure injection, dynamic compatible
  source-surface returns from acquire callbacks, manual callback retrieval, and
  final post-clear recovery. This raised `pattern_test.mbt` to 20 tests and the
  full native suite to 349 tests.
  The later PDF tagged multi-page text marker slice added a structural marker
  check for the existing two-page Link/Dest/Document/Sect/P text scene,
  asserting page count, page objects, annotations, URI/destination entries, and
  StructTreeRoot elements in the emitted PDF. This raised
  `vector_output_wbtest.mbt` to 27 tests and the full native suite to 350
  tests.
  The later PS/SVG tagged multi-page text inertness slice added negative marker
  checks for the same two-page Link/Dest/Document/Sect/P text scene on
  PostScript and SVG, proving those backends do not emit PDF-only annotations,
  destinations, URI strings, or structure-tree metadata for the scene.
  The later PDF rectangle tag marker slice added stable marker assertions for
  the direct-C URI-link, named-destination, and Document/Sect/H1/P rectangle
  tag scenes, covering annotations, destination names, and structure-tree
  output from the compact geometry fixtures.
  The later PDF text tag marker slice tightened the direct-C text-tag fixtures
  to compact in-page text geometry, added stable marker assertions for
  URI-link, named-destination, and Document/Sect/H1/P text tag output, and
  extended PS/SVG negative marker checks to the URI-link text tag scene.
  The later PDF direct document-feature marker slice added stable marker
  assertions for the direct-C document-feature scene, covering metadata, custom
  metadata, page labels, outlines, URI/destination links, and Document/Sect/P
  structure output.
  The later PS/SVG tag metadata absence slice added negative marker checks for
  destination and document-structure rectangle/text tag scenes, proving those
  backends do not emit PDF-only annotations, destinations, structure-tree
  markers, or link metadata for those tags. This raised
  `vector_output_wbtest.mbt` to 28 tests and the full native suite to 351
  tests.
  The later mixed vector/tag/text oracle slice added a single-page
  cross-backend scene combining clip, dash, regular drawing, toy-font text, URI
  links, named destinations, and Document/Sect/P structure tags. This raised
  `vector_output_wbtest.mbt` to 29 tests and the full native suite to 352
  tests.
  The later mixed vector/tag/text marker slice added PDF combined tag marker
  assertions and PS/SVG negative PDF-metadata marker assertions for that mixed
  scene. This raised `vector_output_wbtest.mbt` to 31 tests and the full
  native suite to 354 tests.
  The later raster-source acquire-only owner fuzz slice added a 64-step
  replacement fuzz for retained-owner balancing and added that white-box file
  to the normal and ASan verification gates. This raised the full native suite
  to 355 tests.
  The later stream vector output equivalence slice added a white-box
  PDF/PS/SVG stream-vs-file normalized equality test for a deterministic
  two-page scene and added stream black-box/white-box files to the normal and
  ASan verification gates. This raised the full native suite to 356 tests.
  The later raster-source stale-release replacement slice added one white-box
  owner-count test proving release-only to acquire-only callback replacement
  drops the stale release closure while cairoon's internal release trampoline
  still balances retained owners. This raised
  `pattern_raster_owner_wbtest.mbt` to 3 tests and the full native suite to
  357 tests.
  The later gradient color-stop ordering/snapshot slice added one black-box
  test proving duplicate-offset color stops preserve cairo insertion order and
  `get_color_stops_rgba` returns a copied MoonBit snapshot that does not grow
  after later pattern mutation. This raised `pattern_gradient_test.mbt` to 5
  tests and the full native suite to 358 tests.
  The later pycairo close-path stringification slice added one black-box Path
  test proving `Path::to_string` matches pycairo's `close path` line plus the
  continuation `move_to` segment emitted by cairo after closing a subpath. This
  raised `path_test.mbt` to 6 tests and the full native suite to 359 tests.
