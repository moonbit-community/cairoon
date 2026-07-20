# Migration Audit History, Part 3

Historical snapshot of `AUDIT.md` lines 1070-1640 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.


- `./scripts/verify.sh`: passed. The local reliability gate ran
  `moon fmt --check`, `scripts/check-project-layout.py`,
  the then-current link-flag check, `scripts/check-ffi-ownership.py`,
  `scripts/check-api-inventory.py`, `scripts/check-reliability-ledger.py`,
  native `moon check`, targeted image,
  ScaledFont oracle,
  font-options/font-face/scaled-font, vector including PDF combined text
  document-feature plus PS DSC/SVG unit backend-feature oracle checks,
  surface base/ImageData tests,
  stream black-box/white-box tests, mapped-image, subsurface, recording,
  MIME, PDF/PS/SVG helper, TeeSurface, script-device, and object-trait tests,
  context lifetime/state/matrix/path/group/text/glyph/extents/clip/painting tests,
  Path tests,
  pattern/pycairo-parity/gradient/mesh tests, raster manual/owner/state
  white-box tests, and
  Region/lifetime-stress tests,
  the full native suite, `moon info --target native`, and targeted ASan
  image-oracle, font-options/font-face/scaled-font, vector-output, stream,
  surface base/ImageData, mapped-image, subsurface, recording, MIME,
  PDF/PS/SVG helpers, TeeSurface, script-device, object-trait,
  context-lifetime/state/matrix/path/group/text/glyph/extents/clip/painting, Path,
  pattern/pycairo-parity/gradient/mesh, raster manual/owner/state, and
  Region/lifetime-stress tests with
  leak detection disabled. The current run includes
  the pycairo context font-extents parity slice,
  the pycairo group-target stack-restoration slice,
  the pycairo rectangle path-extents slice,
  the pycairo source RGBA round-trip slice,
  the pycairo empty-path clip `in_clip` slice,
  the pycairo mesh curve-first patch slice,
  the pycairo polygon fill-extents slice,
  the mapped-image scoped-error upload slice,
  the TeeSurface positive out-of-range status slice,
  the PDF/PS stream target lifetime slice, the pycairo append-path string
  equivalence slice, the pycairo close-path stringification slice,
  the gradient color-stop ordering/snapshot slice,
  the stream-vs-file vector output equivalence slice,
  the tagged multi-page stream equivalence slice,
  the mixed/layered stream equivalence slice,
  the document-feature stream equivalence slice,
  the backend feature/tag stream combo slice,
  the wide multi-page stream equivalence slice,
  the vector stream invalid-status fallback slice,
  the PNG/script stream invalid-status fallback slice,
  the callback invocation reference-balance slice,
  the vector output white-box split slice,
  the vector output scene helper split slice,
  the vector output marker/oracle test split slice,
  the test-vector C glue split slice,
  the test-vector tag scene C glue split slice,
  the Font raw FFI family split slice,
  the Font C glue split slice,
  the Pattern C glue split slice,
  the raster-source callback C glue split slice,
  the Surface C glue split slice,
  the base Surface C glue split slice,
  the Surface wrapper split slice,
  the Surface raw FFI family split slice,
  the Context C glue split slice,
  the Context wrapper split slice,
  the Pattern wrapper split slice,
  the Pattern black-box test split slice,
  the raster-source black-box test split slice,
  the Pattern raw FFI family split slice,
  the raster-source stale-release replacement slice,
  the raster-source acquire-only owner fuzz slice,
  the raster-source failed-acquire owner-count fuzz slice,
  the raster-source manual callback fuzz slice,
  the wide multi-page vector/tag oracle slice,
  the packaging/pycairo-porting documentation slice, the mixed
  vector/tag/text marker slice, the direct C oracle slice, the PDF thumbnail
  direct C oracle slice, the PDF thumbnail stream equivalence slice, the PDF
  JPEG MIME stream equivalence slice, the PDF text document-feature stream
  equivalence slice, the PDF page-operation document-feature stream
  equivalence slice, the backend feature/tag stream combo slice, the PS/SVG
  backend-combo stream inertness slice, the non-text primitive vector stream
  equivalence slice,
  the standalone text vector stream equivalence slice,
  the single-page tag stream equivalence slice, and the prior C
  stub split that moved private test oracles out of `cairoon_misc.c` into
  common/file/vector/image helper files, plus the raw FFI splits that moved
  font and pattern extern declarations into `ffi_font_options.mbt`,
  `ffi_font_face.mbt`, `ffi_scaled_font.mbt`, `ffi_text_to_glyphs.mbt`,
  `ffi_pattern.mbt`, `ffi_pattern_mesh.mbt`, and
  `ffi_pattern_raster_source.mbt`.
- `moon -C cairoon check --target native`: passed.
- `moon -C cairoon test --target native`: 485 tests passed. The current run
  includes the expanded pattern-combo image oracle slice,
  the tag-heavy stream-to-direct-oracle differential slice,
  the backend stream-to-direct-oracle differential slice,
  the backend lifecycle-matrix differential slice,
  the backend tag-matrix differential slice,
  the resized backend page-sequence combo slice,
  the backend nested tag/page sequence slice,
  the backend surface-page feature/tag combo slice,
  the Context drawing-state all-enum round-trip slice,
  the pycairo raw C-int operator passthrough slice,
  the pycairo raw C-int context drawing-state enum passthrough slice,
  the pycairo raw C-int FontOptions enum passthrough slice,
  the pycairo raw C-int toy-font slant/weight parsing slice,
  the pycairo context font-extents parity slice,
  the pycairo group-target stack-restoration slice,
  the pycairo rectangle path-extents slice,
  the pycairo 42x42 clip-extents, zero-radius arc, polygon path-extents,
  line in-stroke, empty stroke-extents, default coordinate-conversion, empty
  font-family selection, and font-size matrix parity slice,
  the pycairo source RGBA round-trip slice,
  the pycairo empty-path clip `in_clip` slice,
  the pycairo mesh curve-first patch slice,
  the pycairo polygon fill-extents slice,
  the mapped-image scoped-error upload slice,
  the TeeSurface positive out-of-range status slice,
  the PDF/PS stream target lifetime slice, the pycairo append-path
  string equivalence slice, the pycairo close-path stringification slice, the
  gradient color-stop ordering/snapshot slice, the stream-vs-file vector output
  equivalence slice, the non-text primitive vector stream equivalence slice,
  the single-page tag stream equivalence slice, the tagged multi-page stream
  equivalence slice, the mixed/layered stream equivalence slice, the wide
  multi-page stream equivalence slice, the document-feature stream equivalence
  slice, the backend feature/tag stream combo slice, the vector
  stream invalid-status fallback slice, the PNG/script stream invalid-status
  fallback slice, the callback invocation reference-balance slice,
  the backend stream callback multi-seed fuzz slice,
  the finalizer graph multi-seed fuzz slice,
  the matrix property-test slice, the lifetime stress test
  split slice, the vector output white-box split slice, the vector output
  scene helper split slice, the test-vector C glue split slice, the
  test-vector tag scene C glue split slice, the
  vector output marker/oracle test split slice, the
  Font raw FFI family split slice, the base Surface C
  glue split slice, the Surface wrapper split slice, the Surface raw FFI
  family split slice, the Context wrapper
  split slice, the Pattern wrapper split slice,
  the Pattern black-box test split slice, the raster-source black-box test
  split slice, the raster-source callback C glue split slice,
  the pycairo raw C-int pattern extend passthrough slice,
  the pycairo raw C-int pattern filter/dither passthrough slice,
  the Pattern raw enum documentation slice,
  the pycairo raw C-int context drawing-state enum passthrough slice,
  the pycairo raw C-int FontOptions enum passthrough slice,
  the pycairo raw C-int toy-font slant/weight parsing slice,
  the Pattern raw FFI family split slice, the raster-source stale-release
  replacement slice, the raster-source acquire-only owner fuzz slice,
  the raster-source failed-acquire owner-count fuzz slice, the raster-source
  callback state-machine fuzz slice, the raster-source manual callback fuzz
  slice, the mixed vector/tag/text marker slice,
  the direct C oracle slice, the PS/SVG tag metadata absence slice, the PDF
  tagged multi-page text marker slice, the PS/SVG tagged multi-page text
  inertness slice, the PDF rectangle tag marker slice,
  the PDF text tag marker slice,
  the PDF direct document-feature marker slice,
  the backend document-feature stream marker slice,
  the cross-backend tagged multi-page text direct C oracle slice, the
  PS/SVG tag and text-tag direct C oracle slice, the PDF text-tag direct C
  oracle slice, the raster-source deterministic callback fuzz slice, the
  raster-source compatible target/extents acquire slice, the
  PS/SVG Link tag direct C oracle slice, the context
  `get_group_target` post-scope lifetime slice, the PDF combined text
  document-feature oracle slice, the tagged `show_text_glyphs` vector-output
  slice, the tagged `show_text_glyphs` stream/inert-marker slice, the grouped
  glyph/tag vector-output slice, the copy_page retained vector-output slice, the
  Surface page primitive vector-output slice, the Surface show-page cleared
  primitive slice, the glyph vector backend oracle slice, the PDF JPEG MIME
  direct C oracle slice, the PDF thumbnail direct C oracle slice, the PDF
  thumbnail stream equivalence slice, the PDF JPEG MIME stream equivalence
  slice, the PDF text document-feature stream equivalence slice, the PDF
  page-operation document-feature stream equivalence slice, the non-text
  primitive vector stream equivalence slice, the backend feature/tag stream
  combo slice, the PS/SVG backend-combo stream inertness slice, the standalone
  text vector stream
  equivalence slice, the single-page tag stream
  equivalence slice, and
  the earlier context `get_source`
  surface-pattern lifetime coverage for the path where both the original source
  wrapper and context scope have exited, plus the layered multi-page vector/tag
  oracle slice, the wide multi-page vector/tag oracle slice, and the raw FFI split slices that keep public API and test count
  unchanged while reducing `ffi.mbt`.
- `moon -C cairoon test src/tests/path/core --target native -v`: 7 black-box Path
  tests passed, covering empty paths, pycairo-compatible stringification
  including close-path continuation formatting, copied-path lifetime after the
  source context exits, typed segment iteration, flattened copies, and path
  equality/hash behavior.
- `moon -C cairoon test src/tests/path/pycairo --target native -v`: 4
  pycairo `test_path.py`-derived fixtures passed, covering empty path string
  behavior, `copy_path().to_string()` formatting, self comparison/hash
  operators, and iterator `PathDataType`/coordinate tuples.
- `moon -C cairoon test src/tests/context/path --target native -v`: 11
  black-box Context path tests passed, covering current-point behavior,
  relative path operations and all three no-current-point errors,
  `new_sub_path` geometry retention, pycairo rectangle path-extents behavior,
  close-path current-point reset, arc current-point creation,
  path copy/append independence, pycairo-style append string
  equivalence after clearing the source context, flattened append behavior, and
  path error propagation.
- `moon -C cairoon test src/tests/context/pycairo --target native -v`: 39
  shared black-box Context pycairo parity tests passed, covering the 42x42 default
  clip-extents fixture, zero-radius `arc`/`arc_negative` non-empty paths,
  polygon `path_extents`, polygon `fill_extents`, empty `in_fill`, line
  `in_stroke`, rectangle `path_extents`, relative path current-point updates,
  empty `stroke_extents`, default user/device coordinate conversions,
  matrix setter/translate/scale/transform/rotate fixtures, dash offset
  normalization, current-point state, drawing-state default getters and enum
  setter round trips, raw operator C-int limit passthrough, save/restore
  drawing-state restoration, scalar line-width/miter-limit/tolerance setters,
  source RGBA round trips, explicit source-pattern round trips,
  copied `append_path` strings, empty clip/reset `in_clip` behavior, group
  stack push/pop variants, mask/mask-surface/alpha-paint pixel fixtures,
  font-face default/reset/custom round trips, `set_font_matrix` identity,
  font-options round trips, scaled-font round trips, empty
  `select_font_face("")`, `set_font_size(42)` font-matrix fixtures,
  text/font-extents/show-text/text-path fixtures, glyph-extents/show-glyphs/
  glyph-path fixtures, pycairo's `test_simple` method-smoke flow, and the PDF
  `show_text_glyphs` tuple fixture.
- `moon -C cairoon test src/tests/context/group --target native -v`: 5
  black-box Context group tests passed, covering `push_group`, `pop_group`,
  `pop_group_to_source`, raw-content `push_group_with_content`, group-target
  stack restoration to the original target, returned group patterns, and
  unmatched pop error mapping.
- `moon -C cairoon test src/tests/context/text --target native -v`,
  `src/tests/context/glyph`, and `src/tests/context/text_to_glyphs`: 16
  black-box Context text/glyph/text-to-glyph tests passed, covering
  context/scaled-font font/text/glyph extents parity, `show_text` current-point
  advance, text/glyph path creation, empty glyph arrays, text-to-glyph
  conversion, embedded-NUL validation, and context error propagation.
- `moon -C cairoon test src/tests/lifetime/context --target native -v`: 9
  black-box context lifetime tests passed, including `get_target`,
  `get_group_target`, `get_source`, and PDF/PS stream target wrappers that
  remain usable after their creating helper scopes exit.
- `moon -C cairoon test src/tests/context/state --target native -v`,
  `src/tests/context/matrix`, and `src/tests/context/extents`: 19 black-box
  context state/matrix/extents tests passed, including save/restore, sticky
  error status, dash validation, raw C-int operator and drawing-state enum
  passthrough parity, CTM conversion, invalid-matrix propagation, pycairo
  polygon fill-extents coverage, stroke extents, clip-independent geometry
  queries, hit-testing, non-identity transform composition, CTM save/restore,
  and singular set/scale/transform rejection.
- `moon -C cairoon test src/tests/surface/{base,mime,pycairo,subsurface}
  --target native -v`: 26 black-box surface tests passed, covering base
  surface state, retained subsurface parents, MIME storage/support, and pycairo
  surface parity fixtures.
- `moon -C cairoon test src/tests/image/{properties,data,mapped,png,buffer}
  --target native -v`: 29 black-box image-family tests passed, covering image
  properties, retained ImageData views, mapped images, PNG paths,
  buffer-backed image surfaces, and pycairo image-surface data fixtures.
- `moon -C cairoon test src/tests/backend/pdf src/tests/backend/ps
  src/tests/backend/svg src/tests/backend/recording src/tests/backend/tee
  --target native -v`: 30 black-box backend surface tests passed, covering
  Recording replay/extents, PDF/PS/SVG backend helpers and subtype/finished
  errors, filename constructors, raw backend enums, and Tee fanout/lifetime
  behavior.
- `moon -C cairoon test device_test.mbt backend_surfaces.mbt.md
  lifetime_stress_test.mbt lifetime_value_stress_test.mbt
  lifetime_image_data_stress_test.mbt lifetime_finalizer_fuzz_test.mbt
  lifetime_stream_stress_test.mbt --target native -v`: 26 black-box and
  executable backend/lifetime tests
  passed, covering script file/stream devices, script-surface target proxying,
  script writer `WriteError` and invalid-status fallback mapping, scoped
  script-device finish, retained script surface/device wrappers, executable
  backend docs, retained owner graph stress, external value-wrapper stress,
  image-data view stress, finalizer graph multi-seed fuzz, backend stream
  callback allocation stress, and
  backend stream callback multi-seed fuzz.
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
  text, and wide three-page tag/vector scenes.
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
  src/tests/surface/{base,mime,pycairo,subsurface} --target native -v`: 26
  ASan-compiled black-box surface tests passed with leak detection disabled.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  src/tests/image/{properties,data,mapped,png,buffer} --target native -v`: 29
  ASan-compiled black-box image-family tests passed with leak detection
  disabled.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  src/tests/backend/pdf src/tests/backend/ps src/tests/backend/svg
  src/tests/backend/recording src/tests/backend/tee --target native -v`: 30
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
  ARGB32 fixture across thirty-five scenes with `glyph_path`, `show_glyphs`,
  `show_text_glyphs`, source-surface offsets, mask-surface offsets, and
  raster-source pattern repeat rendering, dashed round-cap strokes, and
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
  clip/save/restore/OperatorAtop output.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  image_oracle_wbtest.mbt --target native -v`: 2 ASan-compiled white-box image
  oracle tests passed with leak detection disabled, directly exercising the
  source/mask offset, raster-source repeat, dashed-stroke, clipped-output,
  operator-output, surface-pattern-combo, transformed-gradient-pattern,
  radial-pattern-combo, surface-pattern pad/none/repeat-bilinear,
  linear-pattern pad/none, radial-pattern repeat/pad, curve-mesh,
  mesh-pattern, pattern-stack, group-compositing, mask-pattern, and
  fill-rule C oracle helper paths.
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
  device parity fixtures, script file/stream devices, script surfaces,
  device/surface retained-owner behavior, raw content construction, and script
  stream write-error mapping.
- `moon -C cairoon test src/tests/pattern/core --target native -v`: 12
  black-box Pattern core tests passed, covering solid/surface/common-state
  patterns, pointer identity/hash, raw enum passthrough, surface-pattern
  lifetime, and pattern type-mismatch error mapping.
- `moon -C cairoon test src/tests/pattern/mesh --target native -v`: 6
  black-box mesh Pattern tests passed, covering mesh patch lifecycle/query APIs,
  patch and point index validation, lifecycle error propagation, and non-mesh
  subtype rejection.
- `moon -C cairoon test src/tests/pattern/pycairo --target native -v`: 10
  black-box Pattern pycairo parity tests passed, covering pycairo
  solid/surface/gradient/mesh fixtures and mesh error-state mapping.
- `moon -C cairoon test src/tests/pattern/gradient --target native -v`: 5
  black-box gradient tests passed from a nested external package, covering
  linear/radial gradient geometry, color-stop count/tuple retrieval,
  duplicate-offset insertion order, copied color-stop snapshot stability after
  later pattern mutation, pattern-type mismatch mapping, and invalid-index
  mapping.
