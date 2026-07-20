# Testing Evidence History, Part 5

Historical snapshot of `TESTING.md` lines 2096-2662 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

  The later Context documentation slice added `context.mbt.md` with eight
  executable examples covering construction/state, transforms, paths,
  fill/stroke output, clipping, groups, text/glyphs, and checked context
  errors, raising the native suite to 285 tests. ASan/LSan was not rerun for
  that slice because it did not change C glue or ownership code.
  The later Font documentation slice added `font.mbt.md` with seven executable
  examples covering FontOptions state/copy/merge, color palettes, toy font
  faces, Surface/Context font options, ScaledFont matrices/metrics,
  text-to-glyphs, and checked font errors, raising the native suite to 292
  tests. ASan/LSan was not rerun for that slice because it did not change C
  glue or ownership code.
  The later Backend Surface documentation slice added `backend_surfaces.mbt.md`
  with eight executable examples covering PDF/PS/SVG stream output and writer
  errors, PDF metadata/outlines, PS DSC, SVG document units, recording replay,
  Tee fanout, script devices/surfaces, and checked backend-specific errors,
  raising the native suite to 300 tests. ASan/LSan was not rerun for that slice
  because it did not change C glue or ownership code.
  The later PDF tag-output marker slice added two pure MoonBit white-box tests
  covering named destinations and document structure tags, raising the native
  suite to 302 tests. ASan/LSan was not rerun for that slice because it did not
  change C glue or ownership code.
  The later Cairo float image-format slice added two pure MoonBit black-box
  tests covering `Rgb96F` and `Rgba128F` construction/readback for ordinary and
  buffer-backed image surfaces, raising the native suite to 304 tests.
  ASan/LSan was not rerun for that slice because it did not change C glue or
  ownership code.
  The later format-stride slice added one pure MoonBit black-box test covering
  `Rgb16_565`, `Rgb30`, `Rgb96F`, `Rgba128F`, and negative-width
  `Format::stride_for_width`, raising the native suite to 305 tests. ASan/LSan
  was not rerun for that slice because it did not change C glue or ownership
  code.
  The later raster-source finished-surface slice added one black-box
  failure-injection test and C-side surface-finished tracking for callbacks,
  raising the native suite to 306 tests. Targeted ASan with leak detection
  disabled passed for `pattern_test.mbt`.
  The later ordinary image-surface finished-status slice added one pure
  MoonBit black-box test covering idempotent `finish()` and `SurfaceFinished`
  mapping for `flush`, `copy_page`, and `show_page`, raising the native suite
  to 307 tests. ASan/LSan was not rerun for that slice because it did not
  change C glue or ownership code.
  The later raster-source optional-callback slice added release-only callback
  state APIs and one black-box test, raising the native suite to 308 tests.
  Targeted ASan with leak detection disabled passed for `pattern_test.mbt`.
  The later backend MIME support matrix slice added one pure MoonBit black-box
  test, raising the native suite to 309 tests. ASan/LSan was not rerun for
  that slice because it did not change C glue or ownership code.
  The later spaced-ASCII text-to-glyph slice added one pure MoonBit black-box
  test and expanded the existing ScaledFont direct C oracle case set, raising
  the native suite to 310 tests. ASan/LSan was not rerun for that slice because
  it did not change C glue or ownership code.
  The later glyph-index width slice promoted `Glyph.index` and glyph marshal
  arrays to `UInt64`, added one pure value-type max-index test, and raised the
  native suite to 311 tests. Targeted ASan/LSan validation is recorded above.
  The later pure value-type numeric-limit slice added one black-box test for
  pycairo `Rectangle`, `TextExtents`, and `TextCluster` boundary values,
  raising the native suite to 312 tests. ASan/LSan was not rerun for that slice
  because it did not change C glue or ownership code.
  The later surface numeric-limit slice added one black-box test for pycairo
  `Surface::set_device_offset`, `Surface::set_device_scale`, and
  `Surface::create_for_rectangle` extreme numeric cases, raising the native
  suite to 313 tests. ASan/LSan was not rerun for that slice because it did not
  change C glue or ownership code.
  The later PDF combined vector-output marker slice added one pure MoonBit
  white-box test covering metadata, custom metadata, page labels, outlines, URI
  links, named destinations, and document-structure tags across a two-page PDF,
  raising the native suite to 314 tests. ASan/LSan was not rerun for that slice
  because it did not change C glue or ownership code.
  The later PS DSC multi-page vector-output marker slice added one pure MoonBit
  white-box test covering language-level restriction, setup DSC comments,
  page-setup DSC comments, and two-page drawing markers, raising the native
  suite to 315 tests. The later backend-feature oracle slice upgraded this test
  with a direct C Cairo output oracle.
  The later SVG version-unit multi-page vector-output marker slice added one
  pure MoonBit white-box test covering SVG 1.2 version restriction, `SvgUnitPx`
  state, px width/height output, and two-page drawing markers, raising the
  native suite to 316 tests. The later backend-feature oracle slice upgraded
  this test with a direct C Cairo output oracle.
  The later PDF thumbnail vector-output marker slice added one pure MoonBit
  white-box test covering `Surface::pdf_set_thumbnail_size` output through
  `/Thumb` image markers and thumbnail dimensions, raising the native suite to
  317 tests. ASan/LSan was not rerun for that slice because it did not change C
  glue or ownership code.
  The later UTF-8 string-boundary slice added two pure MoonBit black-box tests
  covering embedded-NUL rejection for `FontFace::toy`,
  `Context::select_font_face`, and `ScaledFont::text_extents`, raising the
  native suite to 319 tests. ASan/LSan was not rerun for that slice because it
  did not change C glue or ownership code.
  The later Surface finished-status slice added one pure MoonBit black-box test
  covering `Surface::has_show_text_glyphs`, dirty markers, device offset/scale
  wrappers, and fallback-resolution wrappers after `finish()`, raising the
  native suite to 320 tests. ASan/LSan was not rerun for that slice because it
  did not change C glue or ownership code.
  The later backend surface error-path slice added three pure MoonBit
  black-box tests covering extended PDF custom-metadata/thumbnail/outline
  subtype mismatches, PS size/setup/page-setup subtype mismatches, and SVG
  document-unit getters after `finish()`, raising the native suite to 323
  tests. ASan/LSan was not rerun for that slice because it did not change C
  glue or ownership code.
  The later ImageData owner-status slice fixed ordinary `ImageData` views to
  check their retained base `Surface` wrapper before byte access and added two
  black-box tests for ordinary, buffer-backed, and PNG-loaded `get_data` after
  `finish()` plus retained-view base-finish invalidation, raising the native
  suite to 325 tests. ASan/LSan validation is recorded above.
  The later raster-source acquire-only release-trampoline slice changed C glue
  to install `cairoon_raster_source_release` whenever an acquire callback is
  installed, so acquired surface owners retained by C are released even without
  a user release closure. This changed no public API and kept the native suite
  at 325 tests. ASan/LSan validation is recorded above.
  The later external-object trait slice added pure MoonBit `Eq`/`Hash`
  implementations for hashable Cairo external objects, `Compare` for `Path`,
  `Eq` for unhashable `Region`, and three black-box tests, raising the native
  suite to 328 tests. ASan/LSan was not rerun for that slice because it did not
  change C glue or ownership code.
  The later complex vector oracle slice added five private direct C vector
  scenes covering clip, dash, repeated surface patterns, mask surfaces, and
  mesh patterns across PDF/PS/SVG, plus SVG dynamic `source-*` id
  normalization. This changed only test-helper C glue and one white-box test,
  raising the native suite to 329 tests. ASan/LSan validation is recorded
  above.
  The later PDF tag oracle slice added three private PDF-only direct C vector
  scenes covering URI links, named destinations, and Document/Sect/H1/P
  structure tags. This changed only test-helper C glue and one white-box test,
  raising the native suite to 330 tests. ASan/LSan validation is recorded
  above.
  The later image-surface checked-getter slice changed public
  width/height/stride/format getters to `raise CairoError`, added status
  plumbing for copied-data readback, and covered `SurfaceFinished` plus
  non-image `SurfaceTypeMismatch`, raising the native suite to 331 tests.
  ASan/LSan validation is recorded above.
  The later PDF document-feature oracle slice added one private PDF-only
  direct C vector scene covering metadata, custom metadata, page labels,
  outlines, URI links, named destinations, and Document/Sect/P structure tags
  across two pages. This changed only test-helper C glue and one white-box
  test, raising the native suite to 332 tests. ASan/LSan validation is
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
  suite to 333 tests. ASan/LSan was not rerun because no C glue, finalizer,
  callback, or retained-owner code changed.
  The later raster-source owner-count slice added a private C test probe and
  one white-box test asserting that acquire-only repeated same-surface paints
  release cairoon's retained owner back to zero after each paint. This raised
  the native suite to 334 tests. The full ASan/LSan runner still failed only
  during the known macOS FontRegistry/CoreText/ColorSync leak class; grep of
  `/tmp/cairoon-raster-owner-count-asan.txt` found no raster-owner invalid
  access terms, and the ASan-compiled white-box owner-count executable exited
  0 with leak detection disabled.
  The later Surface scoped-lifecycle slice added public
  `Surface::with_finished` and `MappedImageSurface::with_unmapped` helpers,
  black-box success/error cleanup coverage, two executable Surface reference
  examples, and regenerated `pkg.generated.mbti`, raising the native suite to
  338 tests. The targeted `surface_context_test.mbt surface_mapped_test.mbt
  surface.mbt.md` run passed 32 tests. ASan/LSan was not rerun because this
  slice changed only MoonBit wrappers, tests, docs, and generated interface
  metadata, with no C glue, finalizer, callback trampoline, or retained-owner
  code change.
  The later Device scoped-lifecycle slice added public `Device::with_finished`,
  black-box success/error cleanup coverage, one executable Backend Surface docs
  example, and regenerated `pkg.generated.mbti`, raising the native suite to
  340 tests. The targeted `device_test.mbt backend_surfaces.mbt.md` run passed
  17 tests. ASan/LSan was not rerun because this slice changed only MoonBit
  wrappers, tests, docs, and generated interface metadata, with no C glue,
  finalizer, callback trampoline, or retained-owner code change.
  The later dashed-stroke image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from sixteen to seventeen scenes,
  adding dash and round-cap stroke-state coverage without adding a new test
  case. The targeted `image_oracle_wbtest.mbt` run passed 2 tests, the targeted
  ASan build passed 2 tests with leak detection disabled, and the full native
  suite remained at 340 tests.
  The later clipped-output image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from seventeen to eighteen scenes,
  adding clipped paint/fill output coverage without adding a new test case. The
  targeted `image_oracle_wbtest.mbt` run passed 2 tests, the targeted ASan
  build passed 2 tests with leak detection disabled, and the full native suite
  remained at 340 tests.
  The later operator-output image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from eighteen to nineteen scenes,
  adding `OperatorClear` compositing output coverage without adding a new test
  case. The targeted `image_oracle_wbtest.mbt` run passed 2 tests, the targeted
  ASan build passed 2 tests with leak detection disabled, and the full native
  suite remained at 340 tests.
  The later surface-pattern-combo image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from nineteen to twenty scenes,
  adding `Reflect`/`Nearest`/`DitherBest`/matrix surface-pattern coverage
  without adding a new test case. The targeted `image_oracle_wbtest.mbt` run
  passed 2 tests, and the targeted ASan build passed 2 tests with leak detection
  disabled.
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
  run passed 2 tests, and the then-current full native suite remained at 485
  tests.
  The later pattern-stack image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from thirty-four to thirty-five
  scenes, adding nested surface/linear/radial/mask pattern-stack
  clip/save/restore/OperatorAtop output coverage without changing the public
  API. The targeted `src/tests/oracle/image` run passed 2 tests.
  The later mesh-mask group-compositing image oracle slice expanded the
  ordinary and buffer-backed direct C ARGB32 image oracle from thirty-five to
  thirty-six scenes, adding mesh-pattern source rendering over a transformed
  linear pattern inside a clipped group, then applying a transformed
  surface-pattern mask. This broadens pattern-stack parity without changing
  the public API. The targeted `src/tests/oracle/image` run passed 2 tests.
  The later surface-source/radial-mask group-compositing image oracle slice
  expanded the ordinary and buffer-backed direct C ARGB32 image oracle from
  thirty-six to thirty-seven scenes, combining non-zero
  `set_source_surface`, repeated surface-pattern painting, `OperatorMultiply`,
  clipped groups, and a transformed radial mask. The targeted
  `src/tests/oracle/image` run passed 2 tests.
  The later hairline image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from thirty-seven to thirty-eight
  scenes, adding `Context::set_hairline` stroke output parity against direct C
  Cairo. The targeted `src/tests/oracle/image` run passed 2 tests.
  The later surface-mask screen group-compositing image oracle slice expanded
  the ordinary and buffer-backed direct C ARGB32 image oracle from
  thirty-eight to thirty-nine scenes, combining a surface-pattern mask with
  device offset, transformed pattern matrix, clipped group compositing, and
  `OperatorScreen` output. The targeted `src/tests/oracle/image` run passed 2
  tests without changing public API or total test count.
  The later gradient/surface overlay image oracle slice expanded the ordinary
  and buffer-backed direct C ARGB32 image oracle from thirty-nine to forty
  scenes, combining a transformed reflected surface pattern, repeated radial
  gradient, `OperatorOverlay`, clipped group compositing, and a transformed
  linear mask. The targeted `src/tests/oracle/image` run passed 2 tests
  without changing public API or total test count.
  The later mesh/surface/linear soft-light image oracle slice expanded the
  ordinary and buffer-backed direct C ARGB32 image oracle from forty to
  forty-one scenes, combining a mesh pattern, transformed surface pattern,
  repeated linear gradient, radial mask, clipped group compositing, and
  `OperatorSoftLight`. The targeted `src/tests/oracle/image` run passed 2
  tests without changing public API or total test count.
  The later difference-stroke image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from forty-one to forty-two
  scenes, combining a transformed linear pattern, dashed transformed repeated
  surface-pattern stroke, clipped group compositing, radial mask, translucent
  fill, and `OperatorDifference`. The targeted `src/tests/oracle/image` run
  passed 2 tests without changing public API or total test count.
  The later radial color-dodge image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from forty-two to forty-three
  scenes, adding a separate pattern-operator oracle file that combines a
  transformed reflected surface pattern with a transformed radial gradient
  through `OperatorColorDodge`. The targeted `src/tests/oracle/image` run
  passed 2 tests without changing public API or total test count.
  The later HSL hue group-mask image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from forty-three to forty-four
  scenes, combining a transformed repeated surface pattern, a transformed
  reflected linear gradient through `OperatorHslHue` inside a group, and a
  transformed radial mask. The targeted `moon test src/tests/oracle/image
  --target native -v --deny-warn` run passed 2 tests without changing public
  API or total test count.
  The later HSL saturation group-mask image oracle slice expanded the ordinary
  and buffer-backed direct C ARGB32 image oracle from forty-four to forty-five
  scenes, combining a transformed padded surface pattern, a transformed
  repeated linear gradient through `OperatorHslSaturation` inside a color-alpha
  group, and a transformed radial mask. The targeted
  `moon test src/tests/oracle/image --target native --deny-warn -v` run passed
  2 tests without changing public API or total test count.
  The later HSL color group-mask image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from forty-five to forty-six
  scenes, combining a transformed reflected surface pattern, a transformed
  repeated radial gradient through `OperatorHslColor` inside a color-alpha
  group, and a transformed linear mask. The targeted
  `moon test src/tests/oracle/image --target native --deny-warn -v` run passed
  2 tests without changing public API or total test count.
  The later HSL luminosity group-mask image oracle slice expanded the ordinary
  and buffer-backed direct C ARGB32 image oracle from forty-six to forty-seven
  scenes, combining a transformed repeated surface pattern, a transformed
  reflected linear gradient through `OperatorHslLuminosity` inside a
  color-alpha group, and a transformed radial mask. The targeted
  `moon test src/tests/oracle/image --target native --deny-warn -v` run passed
  2 tests without changing public API or total test count.
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
  The later pycairo append-path string equivalence slice added one black-box
  Context path test proving `append_path` preserves the copied path's
  pycairo-style string after the source context has been cleared. This raised
  `context_path_test.mbt` to 10 tests and the full native suite to 360 tests.
  The later PDF/PS stream target lifetime slice added one black-box Context
  lifetime test proving `Context::new` keeps vector stream targets alive after
  the original surface wrapper leaves scope, and added `context_lifetime_test.mbt`
  to the normal and ASan verification gates. This raised
  `context_lifetime_test.mbt` to 9 tests and the full native suite to 361 tests.
  The later TeeSurface positive out-of-range status slice added one black-box
  test proving a valid tee surface preserves Cairo's positive out-of-range
  `NoMemory` status as `CairoMemoryError(NoMemory, _)`, matching pycairo's
  `MemoryError` path, and added `surface_tee_test.mbt` to the normal and ASan
  verification gates. This raised `surface_tee_test.mbt` to 4 tests and the
  full native suite to 362 tests.
  The later mapped-image scoped-error upload slice added one black-box test
  proving `MappedImageSurface::with_unmapped` uploads painted data before
  propagating a Cairo error, and added `surface_mapped_test.mbt` to the normal
  and ASan verification gates. This raised `surface_mapped_test.mbt` to 6 tests
  and the full native suite to 363 tests.
  The later pycairo polygon fill-extents slice added one black-box Context
  extents test proving Cairo's line-to-created polygon fill bounds match
  pycairo's `(0, 0, 1, 1)` expectation, and added context state/matrix/extents
  tests to the normal and ASan verification gates. This raised
  `context_extents_test.mbt` to 5 tests and the full native suite to 364 tests.
  The later pycairo mesh curve-first patch slice added one black-box
  MeshPattern test proving a patch can start with `curve_to` before any
  explicit `move_to`, added the missing `set_corner_color_rgb` construction
  error check, and added gradient/mesh pattern tests to the normal and ASan
  verification gates. This raised `pattern_mesh_test.mbt` to 6 tests and the
  full native suite to 365 tests.
  The later pycairo empty-path clip slice added one black-box Context clip
  test proving `clip()` with no current path makes `in_clip` false until
  `reset_clip()` restores the surface clip, and added `context_clip_test.mbt`
  to the normal and ASan verification gates. This raised
  `context_clip_test.mbt` to 6 tests and the full native suite to 366 tests.
  The later pycairo source RGBA round-trip slice added one black-box Context
  painting test proving `set_source_rgb/rgba` installs a solid pattern whose
  RGBA values are visible through `get_source().get_rgba()`, and added
  `context_painting_test.mbt` to the normal and ASan verification gates. This
  raised `context_painting_test.mbt` to 7 tests and the full native suite to
  367 tests.
  The later pycairo rectangle path-extents slice added one black-box Context
  path test proving `rectangle(1, 2, 4, 5)` yields path extents
  `(1, 2, 5, 7)`, and added `context_path_test.mbt` to the normal and ASan
  verification gates. This raised `context_path_test.mbt` to 11 tests and the
  full native suite to 368 tests.
  The later pycairo group-target stack-restoration slice added one black-box
  Context group test proving `get_group_target()` switches away from the
  original target inside `push_group()` and restores to the original target
  after both `pop_group()` and `pop_group_to_source()`, and added
  `context_group_test.mbt` to the normal and ASan verification gates. This
  raised `context_group_test.mbt` to 4 tests and the full native suite to 369
  tests.
  The later pycairo context font-extents parity slice added one black-box
  Context text test proving `Context::font_extents()` matches the current
  `ScaledFont::extents()`, and added `context_text_test.mbt` and
  `glyph_array_test.mbt` to the normal and ASan verification gates. This raised
  `context_text_test.mbt` to 6 tests and the full native suite to 370 tests.
  The later ScaledFont returned-object lifetime slice added one black-box test
  proving `ScaledFont::get_font_face()` and `get_font_options()` remain usable
  after the source scaled-font scope exits, and added `font_options_test.mbt`,
  `font_face_test.mbt`, `scaled_font_test.mbt`, and `lifetime_stress_test.mbt`
  to the normal and ASan verification gates. This raised
  `scaled_font_test.mbt` to 8 tests and the full native suite to 371 tests.
  The later Path/Region lifetime gate slice added black-box tests proving a
  copied `Path` remains usable after its source `Context` scope exits and a
  copied `Region` remains usable after its source `Region` scope exits, then
  added `path_test.mbt` and `region_test.mbt` to the normal and ASan
  verification gates. This raised `path_test.mbt` to 7 tests,
  `region_test.mbt` to 10 tests, and the full native suite to 373 tests.
  The later Surface/Device targeted gate slice refactored `scripts/verify.sh`
  to drive the normal and ASan target lists from one shared array, then added
  `surface_context_test.mbt`, `image_data_test.mbt`,
  `surface_subsurface_test.mbt`, `surface_recording_test.mbt`,
  `surface_mime_test.mbt`, `surface_pdf_test.mbt`, `surface_ps_test.mbt`,
  `surface_svg_test.mbt`, `device_test.mbt`, and `object_traits_test.mbt` to
  both gates. This did not add public API or new tests; it makes the existing
  67 surface/device/object-trait tests part of the routine ASan reliability
  sweep.
  The later raw FFI split slice moved the `FontOptions`, `FontFace`,
  `ScaledFont`, and text-to-glyphs extern declarations from the 2580-line
  `ffi.mbt` into `ffi_font.mbt`, added that file to the native target list, and
  reduced `ffi.mbt` to 2226 lines. This did not change public API or test
  count.
  The later Font raw FFI family split slice moved FontOptions, FontFace,
  ScaledFont, and text-to-glyphs result extern declarations from the 353-line
  `ffi_font.mbt` into `ffi_font_options.mbt`, `ffi_font_face.mbt`,
  `ffi_scaled_font.mbt`, and `ffi_text_to_glyphs.mbt`, added all four files to
  the native target list, and removed the now-empty aggregate `ffi_font.mbt`.
  This did not change public API or test count.
  The later pattern raw FFI split slice moved raw `Pattern`, mesh-pattern, and
  raster-source-pattern extern declarations from `ffi.mbt` into
  `ffi_pattern.mbt`, added that file to the native target list, and reduced
  `ffi.mbt` to 1866 lines. This did not change public API or test count.
  The later Pattern raw FFI family split slice moved mesh-pattern and
  raster-source-pattern extern declarations from the 359-line
  `ffi_pattern.mbt` into `ffi_pattern_mesh.mbt` and
  `ffi_pattern_raster_source.mbt`, added both files to the native target list,
  and left `ffi_pattern.mbt` as the 184-line base/surface/solid/gradient extern
  file. This did not change public API or test count.
  The later Path/Region raw FFI split slice moved raw `Path` and `Region`
  extern declarations from `ffi.mbt` into `ffi_path.mbt` and
  `ffi_region.mbt`, added both files to the native target list, and reduced
  `ffi.mbt` to 1683 lines. This did not change public API or test count.
  The later Device raw FFI split slice moved raw `Device`, script-device,
  script-surface, and surface-get-device extern declarations from `ffi.mbt`
  into `ffi_device.mbt`, added that file to the native target list, and
  reduced `ffi.mbt` to 1578 lines. This did not change public API or test
  count.
  The later PDF surface raw FFI split slice moved raw PDF surface extern
  declarations from `ffi.mbt` into `ffi_pdf_surface.mbt`, added that file to
  the native target list, and reduced `ffi.mbt` to 1481 lines. This did not
  change public API or test count.
  The later PostScript surface raw FFI split slice moved raw PostScript surface
  extern declarations from `ffi.mbt` into `ffi_ps_surface.mbt`, added that file
  to the native target list, and reduced `ffi.mbt` to 1404 lines. This did not
  change public API or test count.
