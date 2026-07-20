# Testing Evidence History, Part 3

Historical snapshot of `TESTING.md` lines 962-1527 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

- `moon -C cairoon test device_pycairo_parity_test.mbt --target native -v`: 8
  pycairo-derived fixtures passed, covering script-device
  context-manager cleanup, Device equality/hash through `Surface::get_device`,
  image-surface `get_device is None`, `HAS_SCRIPT_SURFACE`, script-device
  type queries, file-path construction, acquire/release, script mode/comment
  output, and
  recording-surface replay plus post-finish `DeviceFinished`, plus pycairo
  `test_surface.py`-derived script-surface create-for-target target-paint
  parity.
- `moon -C cairoon test vector_output_wbtest.mbt
  vector_output_oracle_wbtest.mbt --target native -v`: 58 white-box vector
  tests passed after splitting marker/output checks from direct C oracle and
  cross-backend tag checks. The split set still covers layered and wide
  multi-page direct C oracle and marker checks, mixed vector/tag/text marker
  checks, PDF rectangle and text tag marker checks, PDF direct
  document-feature marker checks, the mixed vector/tag/text
  direct C oracle scene, PS/SVG destination, document-structure, and URI text
  tag metadata absence checks, PDF tagged multi-page
  text structure markers, PS/SVG tagged multi-page text tag-metadata absence
  checks, tagged `show_text_glyphs` PDF Link/structure
  markers, cross-backend tagged multi-page text, tagged `show_text_glyphs`,
  grouped multi-page glyph/tag direct C oracle and PDF marker checks,
  copy_page retained direct C oracle and PDF two-page marker checks,
  Surface::copy_page/Surface::show_page direct C oracle and PDF two-page marker
  checks, Surface::show_page direct C oracle and PDF two-page marker checks,
  PDF/PS/SVG `glyph_path` and `show_glyphs` direct C oracle checks, PS/SVG
  tagged `show_text_glyphs` and grouped glyph/tag metadata absence checks,
  and PS/SVG destination and document-structure rectangle and text tag scenes, PDF
  URI-link/named-destination/document-structure text tag scenes, PS/SVG Link
  tag inertness matched against direct C Cairo output, and the combined PDF
  metadata/custom-metadata/page-label/outline/URI/named-destination/
  document-structure test matched against a direct C Cairo output oracle that
  also draws tagged text, the PDF direct document-feature marker path, the PDF
  page-operation document-feature direct C
  oracle path, plus PDF JPEG MIME data passthrough and PDF thumbnail output
  matched against direct C Cairo output oracles.
- `moon -C cairoon test surface_stream_test.mbt --target native -v`: 11
  black-box stream callback tests passed, covering PDF/PS/SVG stream chunks,
  PDF/PS/SVG vector stream `WriteError`, PDF/PS/SVG vector stream invalid-status
  fallback to `WriteError`, PNG stream write/read, PNG write `WriteError`, PNG
  writer invalid-status fallback to `WriteError`, saved PDF/PS/SVG/PNG/script
  stream chunks after callback return and allocation pressure, and PNG short-read
  error mapping.
- `moon -C cairoon test surface_stream_wbtest.mbt --target native -v`: 7
  white-box stream equivalence tests passed, comparing PDF/PS/SVG stream output
  with file output after normalized comparison for deterministic two-page,
  copy_page retained two-page, Surface::copy_page retained two-page,
  Surface::show_page cleared two-page, standalone toy-font text_path/show_text
  vector, glyph_path/show_glyphs vector, and non-text primitive
  paint/stroke/fill/path/transform/gradient/multi-page/clip/dash/
  surface-pattern/mask/mesh scenes.
- `moon -C cairoon test surface_stream_backend_wbtest.mbt --target native -v`:
  6 white-box stream/backend marker tests passed, covering backend
  document-feature stream-vs-file equality plus stream marker checks for PDF
  metadata/custom metadata/page labels/outlines/tags, PS DSC/page markers, and
  SVG document-unit/page markers, plus PDF text document-feature, PDF
  page-operation document-feature, PDF JPEG MIME, and PDF thumbnail output.
- `moon -C cairoon test surface_stream_combo_wbtest.mbt --target native -v`: 5
  white-box backend feature/tag combo tests passed, comparing PDF/PS/SVG file
  output with stream output after normalized comparison, comparing file output
  with a direct C Cairo oracle, checking stable PDF/PS/SVG output markers, and
  checking PS/SVG file and stream negative tag-metadata markers for a
  three-page scene that combines PDF metadata/page labels/outlines, PS DSC, SVG
  version/unit, URI and named-destination tags, document-structure tags, surface
  patterns, text, and `show_text_glyphs`.
- `moon -C cairoon test surface_stream_page_combo_wbtest.mbt --target native
  -v`: 4 white-box backend surface-page feature/tag combo tests passed,
  comparing PDF/PS/SVG file output with stream output after normalized
  comparison, comparing file output with a direct C Cairo oracle, checking
  stable PDF/PS/SVG output markers, and checking PS/SVG file and stream
  negative tag-metadata markers for a three-page scene that combines
  `Surface::copy_page`, `Surface::show_page`, PDF metadata/page labels/outlines,
  PS DSC, SVG document units, URI and named-destination tags,
  document-structure tags, and `show_text_glyphs`.
- `moon -C cairoon test surface_stream_nested_tag_wbtest.mbt --target native
  -v`: 4 white-box backend nested tag/page sequence tests passed, comparing
  PDF/PS/SVG file output with stream output after normalized comparison,
  comparing file output with a direct C Cairo oracle, checking stable PDF/PS/SVG
  output markers, and checking PS/SVG file and stream negative tag-metadata
  markers for a four-page scene with deeper document-structure tags, URI and
  destination links, retained-page `Surface::copy_page`, `Surface::show_page`,
  nested PDF outlines, richer metadata/custom metadata, page labels, PS DSC,
  SVG document units, and `show_text_glyphs`.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_deep_tag_test.mbt
  --target native -v`: 5 white-box backend deep tag tree tests passed, comparing PDF/PS/SVG
  file output with a direct C Cairo oracle, checking stable PDF/PS/SVG markers,
  checking PDF stream markers, comparing PS/SVG stream output with file output
  after normalization, and checking PS/SVG file and stream negative
  tag-metadata markers for a two-page scene with `Document`/`Part`/`Sect`/
  `Div`/`P`/`Span`/`Figure`/`Table`/`TR`/`TH`/`TD` structure tags.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_metadata_outline_test.mbt
  --target native -v`: 4 white-box backend metadata-outline tests passed,
  comparing PDF/PS/SVG stream output with file output after normalization,
  comparing file output with a direct C Cairo oracle, checking stable PDF/PS/SVG
  markers, and checking PS/SVG file and stream negative tag-metadata markers
  for a three-page scene with PDF metadata/custom metadata/page labels/outlines,
  URI and named-destination links, `Document`/`Sect`/`H1` structure tags, PS DSC,
  SVG document units, retained `Surface::copy_page`, and backend page-size changes.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_page_ops_test.mbt
  --target native -v`: 4 white-box backend page-ops tests passed,
  comparing PDF/PS/SVG stream output with file output after normalization,
  comparing file output with a direct C Cairo oracle, checking stable PDF/PS/SVG
  markers, and checking PS/SVG file and stream negative tag-metadata markers
  for a four-page scene with mixed `Surface::show_page`,
  `Surface::copy_page`, `Context::copy_page`, and `Context::show_page`
  operations, PDF metadata/custom metadata/page labels/outlines, URI and
  named-destination links, document-structure tags, PS DSC, SVG document units,
  and backend page-size changes.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_tag_metadata_test.mbt
  --target native -v`: 4 white-box backend tag-metadata tests passed,
  comparing PDF/PS/SVG stream output with file output after normalization,
  comparing file output with a direct C Cairo oracle, checking stable PDF/PS/SVG
  markers, and checking PS/SVG file and stream negative tag-metadata markers
  for a three-page scene with PDF metadata/custom metadata/page labels/outlines,
  URI and named-destination links, `Document`/`Sect`/`P`/`Figure`/`Span`
  structure tags, retained `Surface::copy_page`, `Surface::show_page`,
  `Context::show_page`, PS DSC, SVG document units, and backend page-size
  changes.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_structure_sequence_test.mbt
  --target native -v`: 4 white-box backend structure-sequence tests passed,
  comparing PDF/PS/SVG stream output with file output after normalization,
  comparing file output with a direct C Cairo oracle, checking stable PDF/PS/SVG
  markers, and checking PS/SVG file and stream negative tag-metadata markers
  for a four-page scene with retained `Surface::copy_page`, retained
  `Context::copy_page`, cleared `Surface::show_page`, final
  `Context::show_page`, PDF metadata/custom metadata/page labels/outlines, URI
  and named-destination links, list/table/figure/paragraph structure tags, PS
  DSC, SVG point units, and backend page-size changes.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_outline_sequence_test.mbt
  --target native -v`: 4 white-box backend outline-sequence tests passed,
  comparing PDF/PS/SVG stream output with file output after normalization,
  comparing file output with a direct C Cairo oracle, checking stable PDF/PS/SVG
  markers, and checking PS/SVG file and stream negative PDF-metadata markers
  for a three-page scene with `Context::copy_page`, `Surface::copy_page`,
  `Surface::show_page`, PDF metadata/custom metadata/page labels/outlines, URI
  and named-destination links, Document/Sect/Figure structure tags, PS DSC, SVG
  point units, and backend page-size changes.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_oracle_test.mbt
  --target native -v`: 7 white-box stream-to-direct-C oracle tests passed,
  covering primitive/text scenes 0 through 14, tag-heavy scenes 15 through 17
  and 22 through 30, single-backend document feature scenes 18 through 21 and
  34, retained `Context::copy_page`/`glyph_path`/`show_glyphs` scenes 31
  through 33, PDF JPEG MIME/thumbnail stream output, tagged font-matrix text
  scene 43, and backend feature scenes 35 through 42 and 44 through 61, so
  these PDF/PS/SVG stream callback outputs are compared with normalized direct
  C Cairo oracle files.
- `moon -C cairoon test surface_stream_page_sequence_wbtest.mbt --target
  native -v`: 4 white-box backend resized page-sequence tests passed,
  comparing PDF/PS/SVG file output with stream output after normalized
  comparison, comparing file output with a direct C Cairo oracle, checking
  stable PDF/PS/SVG output markers, and checking PS/SVG file and stream
  negative tag-metadata markers for a four-page scene with alternating
  `Surface::copy_page`/`Surface::show_page`, PDF/PS page-size changes,
  PDF metadata/custom-metadata overwrite/removal, page labels, outline
  parent/child mixtures, URI/destination links, document-structure tags, PS
  DSC, and SVG document units.
- `moon -C cairoon test surface_stream_tag_matrix_wbtest.mbt --target native
  -v`: 4 white-box backend tag-matrix tests passed, comparing PDF/PS/SVG file
  output with stream output after normalized comparison, comparing file output
  with a direct C Cairo oracle, checking stable PDF/PS/SVG output markers, and
  checking PS/SVG file and stream negative tag-metadata markers for a four-page
  scene that combines deeper document-structure nesting, URI/destination links,
  `show_text_glyphs`, PDF metadata/custom-metadata overwrite/removal, page
  labels, outline parent/child mixtures, PDF/PS page-size changes, PS DSC, and
  SVG document units.
- `moon -C cairoon test surface_stream_lifecycle_wbtest.mbt --target native
  -v`: 4 white-box backend lifecycle-matrix tests passed, comparing PDF/PS/SVG
  file output with stream output after normalized comparison, comparing file
  output with a direct C Cairo oracle, checking stable PDF/PS/SVG output
  markers, and checking PS/SVG file and stream negative tag-metadata markers
  for a five-page scene with consecutive retained copies, cleared/fresh pages,
  PDF/PS page-size changes, PDF metadata/custom-metadata overwrite/removal,
  page labels, outline parent/child/grandchild mixtures, deeper list/table
  document-structure tags, `show_text_glyphs`, PS Level 2 DSC markers, and SVG
  millimeter document units.
- `moon -C cairoon test surface_stream_tag_wbtest.mbt --target native -v`: 7
  white-box stream equivalence tests passed, comparing PDF/PS/SVG file output
  with stream output after normalized comparison for single-page URI-link,
  named-destination, and document-structure rectangle/text tag scenes, tagged
  multi-page, mixed vector/tag/text, tagged `show_text_glyphs`, grouped
  glyph/tag multi-page, layered three-page clip/dash/surface-pattern/mask/tag/
  text, PS/SVG wide three-page tag/vector scenes, plus PDF wide three-page
  stream marker coverage for the same tag/vector scene.
- `moon -C cairoon info --target native`: completed with no work to do; these
  stream equivalence slices change no public API or generated interface
  metadata.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  vector_output_wbtest.mbt vector_output_oracle_wbtest.mbt --target native -v`:
  58 ASan-compiled white-box vector tests passed with leak detection disabled
  after the split, directly exercising the layered and wide multi-page
  marker/C-oracle paths, the PDF rectangle/text tag and direct
  document-feature marker paths, the mixed
  vector/tag/text marker and C oracle paths,
  the tagged multi-page text C-oracle/PS-SVG inert paths, the tagged
  `show_text_glyphs` marker/C-oracle/PS-SVG inert paths, the grouped
  glyph/tag marker/C-oracle/PS-SVG inert paths, the copy_page retained
  marker/C-oracle path, the Surface page primitive marker/C-oracle path, and
  the Surface show-page cleared marker/C-oracle path, plus the PDF/PS/SVG
  glyph_path/show_glyphs direct C oracle path, the PDF page-operation
  document-feature direct C oracle path, and the PDF JPEG MIME and PDF
  thumbnail direct C oracle paths.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_test.mbt --target native -v`: 11 ASan-compiled black-box
  stream callback tests passed with leak detection disabled.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_wbtest.mbt --target native -v`: 7 ASan-compiled white-box
  stream equivalence tests passed with leak detection disabled, including the
  deterministic two-page, copy_page retained, Surface::copy_page retained,
  Surface::show_page cleared, standalone toy-font text_path/show_text,
  glyph_path/show_glyphs, and non-text primitive vector stream-vs-file paths.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_backend_wbtest.mbt --target native -v`: 6 ASan-compiled
  white-box stream/backend marker tests passed with leak detection disabled,
  covering backend document-feature stream-vs-file and stream marker paths,
  PDF text document-feature, PDF page-operation document-feature, PDF JPEG
  MIME, and PDF thumbnail stream-vs-file paths.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_combo_wbtest.mbt --target native -v`: 5 ASan-compiled
  white-box backend feature/tag combo tests passed with leak detection
  disabled, covering the stream-vs-file, direct C oracle, stable marker, and
  PS/SVG file and stream negative tag-metadata marker paths for the backend-feature/tag/
  multi-page scene.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_page_combo_wbtest.mbt --target native -v`: 4 ASan-compiled
  white-box backend surface-page combo tests passed with leak detection
  disabled, covering stream-vs-file, direct C oracle, stable marker, and PS/SVG
  file/stream negative tag-metadata marker paths for the
  `Surface::copy_page`/`Surface::show_page` feature/tag scene.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_nested_tag_wbtest.mbt --target native -v`: 4 ASan-compiled
  white-box backend nested tag/page sequence tests passed with leak detection
  disabled, covering stream-vs-file, direct C oracle, stable marker, and PS/SVG
  file/stream negative tag-metadata marker paths for the deeper
  tag/metadata/page-label/outline scene.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_page_sequence_wbtest.mbt --target native -v`: 4
  ASan-compiled white-box backend resized page-sequence tests passed with leak
  detection disabled, covering stream-vs-file, direct C oracle, stable marker,
  and PS/SVG file/stream negative tag-metadata marker paths for the
  retained/resized page-sequence scene.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_tag_matrix_wbtest.mbt --target native -v`: 4 ASan-compiled
  white-box backend tag-matrix tests passed with leak detection disabled,
  covering stream-vs-file, direct C oracle, stable marker, and PS/SVG
  file/stream negative tag-metadata marker paths for the deep-tag,
  resized-page, metadata/outline/page-label matrix scene.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_lifecycle_wbtest.mbt --target native -v`: 4 ASan-compiled
  white-box backend lifecycle-matrix tests passed with leak detection disabled,
  covering stream-vs-file, direct C oracle, stable marker, and PS/SVG
  file/stream negative tag-metadata marker paths for the five-page lifecycle
  matrix scene.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_tag_wbtest.mbt --target native -v`: 7 ASan-compiled white-box
  stream equivalence tests passed with leak detection disabled, covering
  single-page tag, tagged multi-page, mixed tag/vector/text, tagged
  `show_text_glyphs`, grouped glyph/tag, layered multi-page, and wide
  multi-page tag/vector stream-vs-file paths.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_tag_wbtest.mbt --target native` repeated 50 times passed,
  covering the previous intermittent stream-tag output comparison failure path.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  src/tests/surface/{base,mime,pycairo,subsurface} --target native -v`: 27
  ASan-compiled black-box surface tests passed with leak detection disabled.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  src/tests/image/{properties,data,mapped,png,buffer} --target native -v`: 29
  ASan-compiled black-box image-family tests passed with leak detection
  disabled.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  src/tests/backend/pdf src/tests/backend/ps src/tests/backend/svg
  src/tests/backend/recording src/tests/backend/tee --target native -v`: 31
  ASan-compiled black-box backend surface tests passed with leak detection
  disabled.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  src/tests/context/state src/tests/context/matrix src/tests/context/extents
  --target native -v`: 19 ASan-compiled black-box context state/matrix/extents
  tests passed with leak detection disabled.
- `moon -C cairoon test image_oracle_wbtest.mbt --target native -v`: 2
  white-box image rendering oracle tests passed. Ordinary image surfaces and
  buffer-backed `Surface::image_for_data` surfaces both match the direct C
  ARGB32 fixture across forty-seven scenes with `glyph_path`, `show_glyphs`,
  `show_text_glyphs`, source-surface offsets, mask-surface offsets, and
  raster-source pattern repeat rendering, dashed round-cap strokes, hairline strokes, and
  clipped paint/fill output, `OperatorClear` compositing output, group
  compositing output, mask pattern compositing output, even-odd fill-rule
  output, and a surface-pattern `Reflect`/`Nearest`/`DitherBest`/matrix
  combination plus
  transformed repeated linear-gradient
  `Repeat`/`Nearest`/`DitherFast`/matrix output, transformed radial-gradient
  `Reflect`/`Nearest`/`DitherGood`/matrix output, surface-pattern
  `Pad`/`Bilinear`/`DitherDefault`/matrix and
  `ExtendNone`/`Nearest`/`DitherNone`/matrix output, transformed
  linear-gradient `Pad`/`Bilinear`/`DitherBest`/matrix output, transformed
  radial-gradient `Repeat`/`Bilinear`/`DitherFast`/matrix output,
  surface-pattern `Repeat`/`Bilinear`/`DitherGood`/matrix output, transformed
  linear-gradient `ExtendNone`/`Good`/`DitherNone`/matrix output with
  duplicate-offset stops, transformed radial-gradient
  `Pad`/`Good`/`DitherDefault`/matrix output, curve/multi-patch mesh-pattern
  matrix output, and nested surface/linear/radial/mask pattern-stack
  clip/save/restore/OperatorAtop output, and mesh/linear surface-mask
  group-compositing output, plus set_source_surface/repeated-surface-pattern/
  radial-mask group-compositing output, surface-pattern device-offset mask
  with `OperatorScreen` group-compositing output, and surface/radial-gradient
  `OperatorOverlay` group-mask output, plus mesh/surface/linear pattern-stack
  `OperatorSoftLight` group-mask output, plus surface-pattern stroke
  `OperatorDifference` group-mask output, plus radial-gradient
  `OperatorColorDodge` over transformed reflected surface-pattern output,
  HSL hue/saturation/color group-mask output, and HSL luminosity group-mask
  output.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  image_oracle_wbtest.mbt --target native -v`: 2 ASan-compiled white-box image
  oracle tests passed with leak detection disabled, directly exercising the
  source/mask offset, raster-source repeat, dashed-stroke, clipped-output,
  operator-output, surface-pattern-combo, transformed-gradient-pattern,
  radial-pattern-combo, surface-pattern pad/none/repeat-bilinear,
  linear-pattern pad/none, radial-pattern repeat/pad, curve-mesh,
  mesh-pattern, pattern-stack, mesh-mask group-compositing,
  surface-mask screen group-compositing, group-compositing,
  mask-pattern, fill-rule, and radial color-dodge and HSL hue group-mask pattern-operator C oracle helper paths.
- `moon -C cairoon test scaled_font_oracle_wbtest.mbt --target native -v`: 2
  white-box ScaledFont oracle tests passed, comparing font extents, text
  extents, glyph extents, and empty, single/multi/spaced ASCII,
  precomposed/decomposed Latin, CJK, Arabic RTL, and emoji UTF-8
  text-to-glyph coordinate cases against direct C Cairo results.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  scaled_font_oracle_wbtest.mbt --target native -v`: 2 ASan-compiled
  white-box ScaledFont oracle tests passed with leak detection disabled,
  covering the expanded UTF-8 text-extents and text-to-glyph input set.
- `moon -C cairoon test lifetime_stress_test.mbt
  lifetime_value_stress_test.mbt lifetime_image_data_stress_test.mbt
  lifetime_finalizer_fuzz_test.mbt lifetime_stream_stress_test.mbt --target
  native -v`: 8 black-box lifetime tests passed after splitting owner graph,
  external value-wrapper, image-data view, finalizer graph fuzz, backend stream
  callback stress, and backend stream callback multi-seed fuzz into separate
  files.
- `moon -C cairoon test raster_lifetime_stress_test.mbt --target native -v`: 1
  black-box raster-source callback lifetime test passed after adding the
  1000-iteration set/get/manual acquire/release/replace/clear stress case.
- `moon -C cairoon test src/tests/lifetime/context --target native -v`: 9
  black-box context lifetime tests passed, including `get_group_target`
  returning a surface that remains readable after the creating context helper
  scope exits, `get_source` returning a surface pattern that still exposes
  and paints from its source after the source wrapper and context scope exit,
  and PDF/PS stream target wrappers that remain usable after the creating
  surface helper scope exits.
- `moon -C cairoon test src/tests/stream/surface --target native -v`: 14
  black-box surface stream tests passed, covering PDF/PS/SVG stream output
  chunks, vector stream `WriteError` mapping, closed-before-finish failure
  mapping, invalid-status fallback to `WriteError`, PNG stream write/read and
  short-read errors, path-vs-stream PNG byte equality, PDF public tag markers,
  and retained callback chunks after allocation pressure.
- `moon -C cairoon test src/tests/stream/device --target native -v`: 18
  black-box script device and script surface tests passed, covering pycairo
  device parity fixtures, script file devices with path-output readback, stream
  devices, script surfaces, device/surface retained-owner behavior, raw content
  construction, and script stream write-error mapping.
- `moon -C cairoon test src/tests/pattern/core --target native -v`: 12
  black-box Pattern core tests passed, covering solid/surface/common-state
  patterns, pointer identity/hash, raw enum passthrough, surface-pattern
  lifetime, and pattern type-mismatch error mapping.
- `moon -C cairoon test src/tests/pattern/mesh --target native -v`: 6
  black-box mesh Pattern tests passed, covering mesh patch lifecycle/query APIs,
  patch and point index validation, lifecycle error propagation, and non-mesh
  subtype rejection.
- `moon -C cairoon test src/tests/pattern/pycairo --target native -v`: 11
  black-box Pattern pycairo parity tests passed, covering pycairo
  solid/surface/gradient/mesh fixtures, raw extend passthrough, and mesh
  error-state mapping.
- `moon -C cairoon test src/tests/pattern/gradient --target native -v`: 5
  black-box gradient tests passed from a nested external package, covering
  linear/radial gradient geometry, color-stop count/tuple retrieval,
  duplicate-offset insertion order, copied color-stop snapshot stability after
  later pattern mutation, pattern-type mismatch mapping, and invalid-index
  mapping.
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
  recovery, and a four-seed callback state-machine fuzz with 72 transitions per
  seed covering clear, release-only, acquire-only, acquire+release, failed
  acquire, dynamic compatible-source, callback-introspection, and owner-count
  balance transitions.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  src/tests/pattern/core src/tests/pattern/mesh src/tests/pattern/pycairo
  src/tests/pattern/raster --target native -v`: 42
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
  owner-count recovery, and the four-seed 72-step-per-seed callback
  state-machine fuzz.
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
- `moon -C cairoon test surface_pycairo_parity_test.mbt --target native -v`: 9
  pycairo `test_surface.py`-derived fixtures passed, covering surface
  context-manager cleanup, target equality/hash through `Context::get_target`,
  content/format getters, device-scale valid/extreme/invalid-matrix cases,
  device-offset normal/extreme round trips, fallback-resolution round trips,
  dirty/page operations, `create_for_rectangle`
  success/invalid-size/extreme numeric cases, `create_similar`
  success/invalid-size cases, and PDF-backed `create_similar_image`, including
  returned image usability after the creating PDF surface scope exits.
- `moon -C cairoon test surface_mime_test.mbt --target native -v`: 6
  black-box tests passed after adding image/PDF/PS/SVG
  `supports_mime_type` matrix coverage, invalid MIME type string coverage, and
  pycairo-derived same-payload multi-key storage with per-key clearing.
- `moon -C cairoon test surface_subsurface_test.mbt --target native -v`: 3
  black-box tests passed after adding invalid-size coverage for
  `Surface::create_for_rectangle`.
- `moon -C cairoon test font_face_test.mbt scaled_font_test.mbt --target native
  -v`: 15 black-box tests passed after adding embedded-NUL validation for toy
  font family, context font-family selection, and ScaledFont text extents.
