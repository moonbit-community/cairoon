# Testing Evidence History, Part 7

Historical snapshot of `TESTING.md` lines 3230-3797 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

  A later Toy font raw slant/weight parity slice added `FontFace::toy_raw`,
  `FontFace::get_slant_raw`, `FontFace::get_weight_raw`, and
  `Context::select_font_face_raw`, covering pycairo `font.c`/`context.c` C-int
  parsing for toy font slant/weight. Known raw values round trip through raw
  getters and invalid raw values map to Cairo's `InvalidSlant`/`InvalidWeight`
  status. It raises `font_face_test.mbt` to 10 tests and the expected full
  native suite to 474 tests.
  A later Content raw constructor parity slice added
  `Surface::create_similar_raw`, `Surface::get_content_raw`,
  `Context::push_group_with_content_raw`, `Surface::recording_raw`,
  `Surface::script_raw`, and `Pattern::raster_source_raw`, covering pycairo
  `surface.c`, `context.c`, and `pattern.c` C-int parsing for
  `cairo_content_t`. Known raw values round trip through raw content getters,
  and unknown raw content maps to `CairoInvalidArgument(InvalidContent, _)`
  before entering Cairo's assertion-prone content paths. It raises
  `surface_context_test.mbt` to 20 tests, `context_group_test.mbt` to 5 tests,
  `surface_recording_test.mbt` to 4 tests, `device_test.mbt` to 10 tests,
  `pattern_raster_source_test.mbt` to 7 tests, and the current full native
  suite to 482 tests.
  A later Format raw constructor/getter parity slice added
  `Surface::image_raw`, `Surface::image_for_data_raw`,
  `Surface::create_similar_image_raw`, `Surface::get_format_raw`,
  `MappedImageSurface::get_format_raw`, and
  `Format::stride_for_width_raw`, covering pycairo `surface.c` C-int parsing
  for `cairo_format_t` constructors and stride helpers. Known raw values round
  trip through raw format getters, typed getters decode only known Cairo
  formats, and invalid raw formats map to
  `CairoInvalidArgument(InvalidFormat, _)` for constructor paths. It raises
  `surface_context_test.mbt` to 21 tests and the current full native suite to
  483 tests.
  A later backend stream-to-direct-oracle differential slice added
  `surface_stream_oracle_test.mbt`, comparing PDF/PS/SVG stream callback
  output for scenes 35 through 40 directly against normalized direct C Cairo
  oracle files. This covers the backend stream-combo, surface-page combo,
  nested-tag, resized page-sequence, tag-matrix, and lifecycle-matrix fixtures
  through the callback path, adds the file to the targeted normal/ASan verify
  gate, and raises the current full native suite to 484 tests.
  A later tag-heavy stream-to-direct-oracle differential slice extended
  `surface_stream_oracle_test.mbt` with matched 10x10 stream surfaces for
  scenes 15 through 17 and 22 through 30, comparing PDF/PS/SVG stream callback
  output directly with normalized direct C Cairo oracle files for URI-link,
  destination-link, document-structure, text-tag, tagged multi-page,
  mixed-tag/text, layered, wide, `show_text_glyphs`, and grouped glyph/tag
  vector scenes. It raises `surface_stream_oracle_test.mbt` to 2 tests and
  the current full native suite to 485 tests.
  A later tagged font-matrix text differential slice added scene 43 in the
  focused `cairoon_test_vector_text_state_scenes.c` oracle file, covering
  `Context::set_font_matrix`, transformed `show_text`, transformed
  `text_path`, URI and destination tags, and Document/Sect structure tags
  across PDF/PS/SVG. The slice adds direct-C file output equality,
  file-vs-stream normalized equality, stream-vs-direct-C oracle equality, PDF
  marker assertions, and PS/SVG negative PDF-metadata checks, raising the
  vector-backend package to 118 tests.
  A later backend text-state differential slice added scene 44 in the focused
  `cairoon_test_backend_text_state.c` oracle file, covering PDF metadata,
  custom-metadata deletion, page labels, outlines, retained copy/show
  multi-page output, PS DSC setup, SVG document units, and transformed toy-font
  `show_text`/`text_path` under URI, destination, and Document/Sect/H1/P tags.
  The slice adds file-vs-stream equality, file-vs-direct-C equality,
  stream-vs-direct-C equality through the backend oracle dispatcher, stable
  PDF/PS/SVG marker checks, and PS/SVG file/stream negative PDF-metadata
  checks, raising the vector-backend package to 122 tests.
  A later deep tag stream-to-direct-C oracle slice extended
  `surface_stream_oracle_test.mbt` so backend scene 45 is rendered through
  PDF/PS/SVG stream callbacks and compared against normalized direct C Cairo
  oracle files. This strengthens the deep tag tree fixture from PDF stream
  marker coverage plus PS/SVG stream-vs-file equality to full cross-backend
  stream-to-direct-C differential coverage without changing the public API or
  total test count.
  A later metadata-outline stream-to-direct-C oracle slice added scene 46 in
  the focused `cairoon_test_backend_metadata_outline.c` oracle file, covering
  PDF metadata/custom-metadata overwrite/removal, page labels, outline
  root/child/sibling/grandchild flags, URI and named-destination links,
  Document/Sect/H1 structure tags, retained `Surface::copy_page`, PDF/PS page
  resizing, PS Level 3 DSC, and SVG point units. The slice adds
  file-vs-stream equality, file-vs-direct-C equality, stream-vs-direct-C
  equality through the backend oracle dispatcher, stable PDF/PS/SVG marker
  checks, and PS/SVG file/stream negative PDF-metadata checks.
  A later page-ops stream-to-direct-C oracle slice added scene 47 in the
  focused `cairoon_test_backend_page_ops.c` oracle file, covering mixed
  `Surface::show_page`, `Surface::copy_page`, `Context::copy_page`, and
  `Context::show_page` behavior across four PDF/PS/SVG pages with metadata
  and custom-metadata removal, page labels, outline flags, URI links, named
  destinations, document-structure tags, PDF/PS page resizing, PS DSC markers,
  and SVG point units. The slice adds file-vs-stream equality,
  file-vs-direct-C equality, stream-vs-direct-C equality through the backend
  oracle dispatcher, stable PDF/PS/SVG marker checks, and PS/SVG file/stream
  negative PDF-metadata checks.
  A later FontOptions variation string-boundary slice added one black-box test
  proving `FontOptions::set_variations(Some(...))` rejects embedded NUL
  strings with `CairoInvalidArgument(InvalidString, _)` before FFI and leaves
  the previous valid variation value intact. This raises
  `font_options_test.mbt` to 9 tests and the expected full native suite to 558
  tests without changing public API.
  A later pycairo FontOptions variations parity slice extended
  `font_pycairo_parity_test.mbt` with the parent
  `test_font_options_variations` behavior: default `None`, string set/get, and
  clearing back to `None`. This raises the font pycairo parity file to 9 tests
  and the current full native suite to 664 tests without changing public API.
  A later pycairo ScaledFont getter parity slice extended
  `font_pycairo_parity_test.mbt` with the parent scaled-font extents,
  font-face/font-options, CTM, font-matrix, and scale-matrix getter behavior.
  This raises the font pycairo parity file to 10 tests and the current full
  native suite to 665 tests without changing public API.
  A later pycairo FontOptions enum setter parity slice extended
  `font_pycairo_parity_test.mbt` with the parent antialias, hint-metrics,
  hint-style, and subpixel-order setter/getter behavior. This raises the font
  pycairo parity file to 11 tests and the current full native suite to 666
  tests without changing public API.
  A later pycairo ScaledFont extents parity slice extended
  `font_pycairo_parity_test.mbt` with the parent text-extents and glyph-extents
  behavior, including positive text/glyph inputs and zeroed empty input
  extents. This raises the font pycairo parity file to 12 tests and the current
  full native suite to 667 tests without changing public API.
  A later Font family package split moved the external black-box tests into
  `src/tests/font/{face,options,scaled,pycairo}` so each font family links and
  runs as its own external package. The four focused font package gates cover
  39 tests, and the full native suite remains 677 tests without changing public
  API.
  A later tag-metadata stream-to-direct-C oracle slice added scene 48 in the
  focused `cairoon_test_backend_tag_metadata.c` oracle file, covering PDF
  metadata/custom-metadata overwrite/removal, page labels, outline parent/child
  links, URI links, named destinations, `Document`/`Sect`/`P`/`Figure`/`Span`
  structure tags, retained `Surface::copy_page`, `Surface::show_page`,
  `Context::show_page`, PDF/PS page resizing, PS Level 3 DSC markers, and SVG
  point units. The slice adds file-vs-stream equality, file-vs-direct-C
  equality, stream-vs-direct-C equality through the backend oracle dispatcher,
  stable PDF/PS/SVG marker checks, and PS/SVG file/stream negative
  PDF-metadata checks, raising the vector-backend package to 140 tests and the
  expected full native suite to 562 tests without changing public API.
  A later stream-tag stabilization slice replaced the tag-heavy PDF
  stream-vs-file equality assertions in `surface_stream_tag_test.mbt` with
  stable stream marker checks for the single-page rectangle/text tag scenes,
  mixed tag/vector/text, tagged `show_text_glyphs`, tagged font-matrix text,
  grouped glyph tags, layered multi-page tags, and tagged multi-page text.
  PS/SVG still use normalized file-vs-stream equality for the same scenes.
  This avoids Cairo PDF stream/file object-layout nondeterminism while
  preserving semantic tag coverage, raising the vector-backend package to 147
  tests and the expected full native suite to 569 tests without changing
  public API.
  A later structure-sequence stream-to-direct-C oracle slice added scene 49 in
  the focused `cairoon_test_backend_structure_sequence.c` oracle file,
  covering retained `Surface::copy_page`, retained `Context::copy_page`,
  cleared `Surface::show_page`, final `Context::show_page`, PDF
  metadata/custom-metadata overwrite/removal, page labels, nested outline
  links, URI links, named destinations, list/table/figure/paragraph structure
  tags, PDF/PS page resizing, PS Level 3 DSC markers, and SVG point units. The
  slice adds file-vs-stream equality, file-vs-direct-C equality, stable
  PDF/PS/SVG marker checks, and PS/SVG file/stream negative PDF-metadata
  checks, raising the vector-backend package to 151 tests and the expected full
  native suite to 573 tests without changing public API.
  A later surface-pattern pycairo parity slice added one black-box fixture for
  `Pattern::for_surface`, proving pycairo-compatible default
  `ExtendNone`/`Good`/`DitherDefault`/identity-matrix state and referenced
  `get_surface()` dimensions. This raises `pattern_pycairo_parity_test.mbt` to
  5 tests and the expected full native suite to 574 tests without changing
  public API.
  A later context absolute-path parity slice added one black-box fixture for
  `Context::move_to`, `Context::line_to`, and `Context::curve_to` current-point
  behavior, narrowing the remaining method-by-method context parity gap. This
  raises `context_pycairo_parity_test.mbt` to 34 tests and the expected full
  native suite to 575 tests without changing public API.
  A later outline-sequence stream-to-direct-C oracle slice added scene 50 in
  the focused `cairoon_test_backend_outline_sequence.c` oracle file, covering a
  three-page PDF/PS/SVG sequence with `Context::copy_page`,
  `Surface::copy_page`, and `Surface::show_page`, PDF
  metadata/custom-metadata overwrite/removal, page labels,
  root/child/sibling/grandchild outline flags, URI and named-destination tags,
  Document/Sect/Figure structure tags, PDF/PS page resizing, PS Level 3 DSC
  markers, and SVG point units. The slice adds file-vs-stream equality,
  file-vs-direct-C equality, stream-vs-direct-C equality through the backend
  oracle dispatcher, stable PDF/PS/SVG markers, and PS/SVG file/stream negative
  PDF-metadata checks, raising the vector-backend package to 155 tests and the
  expected full native suite to 579 tests without changing public API.
  A later page/glyph stream-to-direct-C oracle slice extended
  `surface_stream_oracle_test.mbt` with scenes 31 through 33, comparing
  PDF/PS/SVG stream callback output directly against normalized direct C Cairo
  oracle files for retained `Context::copy_page`, `glyph_path`, and
  `show_glyphs` vector scenes. This raises the vector-backend package to 156
  tests without changing public API.
  A later primitive/text stream-to-direct-C oracle slice extended
  `surface_stream_oracle_test.mbt` with scenes 0 through 14, comparing
  PDF/PS/SVG stream callback output directly against normalized direct C Cairo
  oracle files for paint/stroke/path/transform/gradient/text/page/clip/dash,
  surface-pattern, mask-surface, and mesh-pattern vector scenes. This raises
  the vector-backend package to 157 tests and the expected full native suite to
  587 tests without changing public API.
  A later single-backend feature stream-to-direct-C oracle slice extended
  `surface_stream_oracle_test.mbt` with scenes 18 through 21 and 34 plus PDF
  JPEG MIME and thumbnail stream output, comparing PDF/PS/SVG stream callback
  bytes directly against normalized direct C Cairo oracle files for PDF
  metadata/custom-metadata/page-label/outline/tag document features, PDF
  text-aware and page-operation document features, PS DSC/page setup, SVG
  version/document units, JPEG MIME passthrough, and PDF thumbnail output. This
  raises the vector-backend package to 159 tests and the expected full native
  suite to 589 tests without changing public API.
  A later PDF thumbnail pycairo parity slice added one pure MoonBit black-box
  test for `PDFSurface.set_thumbnail_size`, covering the upstream
  `10x10 -> 0x0 -> 1x1` resize/reset sequence before finish and checked
  `SurfaceFinished` mapping for a post-finish thumbnail update. This raises
  `surface_pdf_test.mbt` to 8 tests and the expected full native suite to 590
  tests without changing public API.
  A later context/pattern comparison parity slice added two pycairo
  `test_cmp_hash` fixtures: `Context` self-equality plus same-target
  different-context inequality, and repeated `Context.get_source()` pattern
  equality/hash behavior. This raises `context_pycairo_parity_test.mbt` to 35
  tests, `pattern_pycairo_parity_test.mbt` to 6 tests, and the expected full
  native suite to 581 tests without changing public API.
  A later Pattern mesh-detail parity slice added pycairo's
  `test_mesh_pattern_example1` and `test_mesh_pattern_rest` fixtures to
  `pattern_pycairo_parity_test.mbt`, covering Coons-patch construction, path
  extraction, corner-color queries, control-point queries, and invalid
  patch/corner/control-point index errors. This raises
  `pattern_pycairo_parity_test.mbt` to 8 tests and the expected full native
  suite to 583 tests without changing public API.
  A later Pattern independent-identity parity slice added pycairo's
  `test_pattern` identity/hash behavior for standalone solid patterns to
  `pattern_pycairo_parity_test.mbt`, proving that the same wrapper compares
  equal and hashes consistently while an independently allocated solid pattern
  with identical RGBA components compares unequal by Cairo pointer identity.
  This raises `pattern_pycairo_parity_test.mbt` to 9 tests and the expected
  full native suite to 591 tests without changing public API.
  A later Context/Pattern pycairo parity slice added pycairo's `test_tags`
  begin/end smoke fixture to `context_pycairo_parity_test.mbt` and pycairo's
  `test_mesh_pattern_error_states` lifecycle checks to
  `pattern_pycairo_parity_test.mbt`. The current context package and pattern
  family gates have 105 and 46 tests respectively without changing public API.
  A later Pattern family package split moved the remaining root pattern tests
  into `src/tests/pattern/{core,mesh,pycairo}`, leaving `src/tests/pattern` as
  a pure directory container. The focused counts are 12, 6, and 10 tests for
  those packages, preserving the same 28 root fixtures with no public API
  changes.
  A later Font pycairo parity fixture slice added
  `font_pycairo_parity_test.mbt` with eight pycairo `test_font.py`-derived
  black-box fixtures covering surface font-options default getters,
  FontOptions copy/equality/merge, color mode, color palette, custom palette
  colors and missing-index errors, FontFace and ScaledFont identity/hash
  behavior, toy-font family/slant/weight getters including Cairo's empty-family
  `Helvetica` normalization, ScaledFont matrix/font-options getters, and
  empty/single/spaced ASCII `text_to_glyphs` result shape. At that point, the
  font package gate had 35 tests without changing public API.
  A later pure value pycairo parity slice added `Hash` derivations for
  `Rectangle`, `RectangleInt`, `Glyph`, `TextCluster`, `TextExtents`, and
  `FontExtents`, plus `value_pycairo_parity_test.mbt` with six pycairo
  namedtuple-style fixtures covering fields, component order, equality/hash,
  numeric limits, `Context::copy_clip_rectangle_list`,
  `RecordingSurface::recording_get_extents`, and Context/ScaledFont
  text/font/glyph extents return paths. This raises the expected full native
  suite to 602 tests.
  A later Matrix pycairo parity slice added `matrix_pycairo_parity_test.mbt`
  with four pycairo `test_matrix.py`-derived fixtures covering equality,
  `init_rotate(0)`, component access including positive and negative invalid
  indexes, `Matrix(1, 1).invert()`, `multiply`, `translate`, scale-away then
  scale-back-to-identity, rotate/scale/translate composition smoke, and
  identity point/distance transforms. This raises the expected full native
  suite to 606 tests without changing public API.
  A later Region pycairo parity slice added `region_pycairo_parity_test.mbt`
  with five pycairo `test_region.py`-derived fixtures covering invalid
  negative/positive rectangle indexes, returned rectangle equality, Region
  equality/inequality through MoonBit `Eq`, empty-region overlap, point
  containment, mutating boolean operations returning the receiver, and
  translate behavior for empty and non-empty regions. This raises the expected
  full native suite to 611 tests without changing public API.
  A later RectangleInt pycairo limits slice extended
  `value_pycairo_parity_test.mbt` with pycairo
  `test_region.py::test_rectangles_limits`-derived 32-bit boundary coverage for
  `RectangleInt` fields/components and MoonBit `Eq` identity. This
  raises the expected full native suite to 705 tests without changing public
  API.
  A later pure value invalid-index slice extended `value_types_test.mbt` with
  positive and negative component-index error coverage for `Rectangle`,
  `RectangleInt`, `TextCluster`, `TextExtents`, and `FontExtents`. This raises
  the expected full native suite to 706 tests without changing public API.
  A later Pattern pycairo raw-extend slice extended
  `pattern_pycairo_parity_test.mbt` with pycairo's `test_set_extend` raw C-int
  passthrough fixture for `42`, preserving the raw value through
  `get_extend_raw` while the typed getter rejects the unknown value with
  `CairoInvalidArgument(InvalidStatus, _)`. This raises the pattern pycairo
  package to 11 tests and the expected full native suite to 707 tests without
  changing public API.
  A later API enum pycairo smoke slice extended `enums_test.mbt` with
  pycairo-derived status, text-cluster flag, surface-observer mode,
  `Extend`, and `Filter` constructor coverage. This raises the API enum
  package to 5 tests and the expected full native suite to 708 tests without
  changing public API.
  A later mapped-image pycairo context-manager slice extended
  `surface_mapped_test.mbt` with reuse-after-scope `SurfaceFinished` coverage
  for repeated base unmap, mapped-image data access, and repeated
  `with_unmapped`. This raises the mapped-image package to 7 tests and the
  expected full native suite to 709 tests without changing public API.
  A later link-audit stream-to-direct-C oracle slice added scene 61 as a
  focused PDF/PS/SVG backend fixture with title/author/keywords metadata,
  custom metadata, page labels, nested outlines, URI and named-destination
  links, `Document`/`Sect`/`P`/`L`/`LI`/`LBody` structure tags, PS DSC markers,
  SVG pixel units, stream-to-direct-C normalized equality, file-vs-stream
  equality, stable marker checks, and PS/SVG negative PDF-metadata checks. This
  raises the vector-backend package by four tests and the expected full native
  suite to 713 tests without changing public API.
  A later Path pycairo parity slice added `path_pycairo_parity_test.mbt` with
  four pycairo `test_path.py`-derived fixtures covering empty path
  string/length behavior, `copy_path().to_string()` formatting including
  close-path continuation, self comparison/hash operators, and iterator
  `PathDataType`/coordinate tuples. This raises the expected full native suite
  to 615 tests without changing public API.
  A later Device pycairo parity slice added `device_pycairo_parity_test.mbt`
  with five pycairo `test_device.py`-derived fixtures covering script-device
  context-manager cleanup, Device equality/hash through `Surface::get_device`,
  image-surface `get_device is None`, script mode/comment output, and
  recording-surface replay plus post-finish `DeviceFinished`. This raises the
  expected full native suite to 620 tests without changing public API.
  A later Device parity extension raised that file to eight fixtures by
  covering pycairo's script feature constant, script-device type query,
  file-path constructor with script-content readback, basic acquire/release, and
  script-surface create-for-target target-paint parity. This raises the
  expected full native suite to 657 tests without changing public API.
  A later Pattern raster-source pycairo parity slice added
  `pattern_raster_pycairo_parity_test.mbt` with two pycairo
  `test_raster_source`-derived fixtures covering callback optional/clear
  states, compatible-image acquire with device offset, acquire/release event
  order, and red pixel output after `Context::paint`. This raises the expected
  full native suite to 622 tests without changing public API.
  A later Surface pycairo parity slice added `surface_pycairo_parity_test.mbt`
  with six pycairo `test_surface.py`-derived fixtures covering surface
  context-manager cleanup, target equality/hash through `Context::get_target`,
  content/format getters, device-scale valid/extreme/invalid-matrix cases,
  `create_for_rectangle` success/invalid-size/extreme numeric cases, and
  PDF-backed `create_similar_image`, including returned image usability after
  the creating PDF surface scope exits. A later Surface parity extension raised
  that file to nine fixtures by covering `create_similar`, device-offset
  normal/extreme round trips, fallback-resolution round trips, and dirty/page
  operations. This raises the expected full native suite to 631 tests without
  changing public API.
  A later pattern-tag stream-to-direct-C oracle slice added scene 51 in the
  focused `cairoon_test_backend_pattern_tag.c` oracle file, covering a
  transformed surface pattern, radial mask, PDF metadata/custom-metadata
  removal, page labels, outline flags, URI and named-destination links,
  `Document`/`Sect`/`P`/`Figure`/`Div`/`Span` structure tags, retained
  `Surface::copy_page`, `Surface::show_page`, PDF/PS page resizing, PS Level 3
  DSC markers, SVG point units, `Context::set_font_matrix`, and
  `ScaledFont::text_to_glyphs`. The slice adds file-vs-stream equality,
  file-vs-direct-C equality, stream-vs-direct-C equality through the backend
  oracle dispatcher, stable PDF/PS/SVG markers, and PS/SVG file/stream
  negative PDF-metadata checks. This raises the expected full native suite to
  635 tests without changing public API.
  A later vector backend scene wiring audit slice added
  `scripts/check-vector-backend-scenes.py` to keep backend scene enum entries,
  direct C dispatch, MoonBit stream-oracle match arms, aggregate stream-oracle
  scene lists, native stub registration, and Backend Differential Slices rows
  in sync. This keeps the expected full native suite at 635 tests while making
  missing backend oracle evidence a local verify-gate failure.
  A later source-size budget slice split the oversized ARGB32 image oracle
  scene dispatcher into focused basic, pattern, and pattern-stack scene files
  and added `scripts/check-source-size-budget.py` to the local verify gate.
  This keeps the expected full native suite at 635 tests while making future
  source/test/script/native-glue files above 850 lines fail local verification
  until they are split deliberately. The later C architecture gate tightened
  `.c` and `.h` files to 600 lines, followed by Python-test and MoonBit gates.
  The current universal gate closes the final 850-line allowance: every checked
  source kind now rejects line 601 in four focused boundary tests.
  A later PNG path/stream pycairo parity slice added a black-box fixture that
  writes one ARGB32 image through both `Surface::write_to_png` and
  `Surface::write_to_png_stream`, compares exact PNG bytes, and compares the
  copied image data after reading both outputs back. The observed full native
  suite is now 637 tests without changing public API.
  A later Context pycairo parity organization slice moved the font/text/glyph
  and simple-smoke pycairo fixtures from `context_pycairo_parity_test.mbt` into
  `context_font_text_pycairo_parity_test.mbt`. The shared Context pycairo
  parity package still carries the same 35 external pycairo parity fixtures,
  the observed full native suite remains 637 tests, and the largest Context
  pycairo parity file drops from 675 to 471 lines without changing public API.
  A later Context pycairo state/paint organization slice moved drawing-state,
  dash/scalar/source, copied-path, clip, group, and mask/alpha-paint pycairo
  fixtures into `context_state_paint_pycairo_parity_test.mbt`. The same 35
  external pycairo parity fixtures remain covered, the observed full native
  suite remains 637 tests, and `context_pycairo_parity_test.mbt` drops from 471
  to 272 lines without changing public API.
  A later vector-output oracle organization slice split direct-C vector oracle
  tests from `vector_output_oracle_test.mbt` into focused basic,
  tag/text-tag, page/glyph/multipage, and PDF document-feature files. The same
  oracle, marker, and inert-tag assertions remain covered, the observed full
  native suite remains 637 tests, and `vector_output_oracle_test.mbt` drops
  from 441 to 25 lines without changing public API.
  A later Surface/context test organization slice moved buffer-backed
  image-surface tests into `image_surface_data_test.mbt`, PNG path round-trip
  coverage into `surface_png_test.mbt`, and the context invalid-restore state
  error test into `context_state_test.mbt`. The observed full native suite
  remains 637 tests, `surface_context_test.mbt` drops from 525 to 348 lines, and
  no public API changes.
  A later Context state package split moved `context_state_test.mbt` into the
  nested external package `src/tests/context/state`. The observed focused
  counts are 96 tests in `src/tests/context` and 10 tests in
  `src/tests/context/state`, with no public API changes.
  A later Context family package split moved `context_path_test.mbt`,
  `context_clip_test.mbt`, and `context_painting_test.mbt` into nested
  external packages under `src/tests/context/{path,clip,paint}`. The observed
  focused counts are 71 tests in `src/tests/context`, 11 in
  `src/tests/context/path`, 7 in `src/tests/context/clip`, and 7 in
  `src/tests/context/paint`, with no public API changes.
  A later Context support package split moved group, matrix, extents, tag,
  text, glyph, and text-to-glyphs tests into nested external packages under
  `src/tests/context/`. The observed focused count for the shared parity root
  is now 36 tests, with all moved behavior still covered through separately
  linked public-package seams and no public API changes.
  A later Context pycairo package split moved the remaining shared parity root
  into `src/tests/context/pycairo`, leaving `src/tests/context` as a pure
  directory container. The observed focused count for the pycairo package is
  still 36 tests, with no public API changes.
  A later Surface image-property organization slice moved image-surface
  property, raw-format/raw-content, finished/subtype error, and Cairo
  float-format black-box tests into `surface_image_properties_test.mbt`. The
  same external behavior remains covered, `surface_context_test.mbt` drops
  from 348 to 246 lines, and no public API changes.
  A later vector-backend output test organization slice split the mixed
  PDF/PS/SVG marker checks from `vector_output_test.mbt` into
  `vector_output_pdf_test.mbt`, `vector_output_ps_test.mbt`, and
  `vector_output_svg_test.mbt`. The observed full native suite remains 637
  tests, the largest vector-output marker file drops from 490 to 383 lines, and
  no public API changes.
  A later lifetime stream stress organization slice split
  `lifetime_stream_stress_test.mbt` into focused helper, allocation-stress, and
  multi-seed fuzz files. The same 18 lifetime black-box tests remain covered,
  `lifetime_stream_stress_test.mbt` is replaced by 222/125/88-line files, and
  no public API changes.
  A later surface-stream organization slice split `surface_stream_test.mbt`
  into shared helper, vector-stream, PNG-stream, and retained-chunk files. The
  same 13 public stream black-box tests remain covered, the largest stream
  callback test file drops from 383 to 163 lines, and no public API changes.
  A later Stream surface package split moved those root stream callback tests
  into `src/tests/stream/surface`, leaving `src/tests/stream` as a pure
  directory container. The focused package has 14 tests, and
  `src/tests/stream/device` keeps 18 script device/surface tests with no public
  API changes.
  A later annotation-sequence stream-to-direct-C oracle slice added scene 52 as
  a focused PDF/PS/SVG backend fixture with annotation/list/table structure
  tags, metadata, page labels, outlines, URI/destination links, retained
  `Surface::copy_page`, stable marker checks, stream-to-direct-C normalized
  equality, and PS/SVG negative PDF-metadata checks. This raises the
  vector-backend package by four tests and the expected full native suite to
  641 tests without changing public API.
  A later semantic-index stream-to-direct-C oracle slice added scene 53 as a
  focused PDF/PS/SVG backend fixture with TOC/TOCI/Reference,
  Art/BlockQuote/NonStruct/Note, Figure/Caption structure tags, metadata, page
  labels, outlines, destination/URI links, retained `Surface::copy_page`,
  stable marker checks, stream-to-direct-C normalized equality, and PS/SVG
  negative PDF-metadata checks. This raises the vector-backend package by four
  tests and the expected full native suite to 645 tests without changing public
  API.
  A later bookmark-lattice stream-to-direct-C oracle slice added scene 54 as a
  focused PDF/PS/SVG backend fixture with list and figure structure tags,
  metadata/custom-metadata overwrite and removal, page labels, parent-child and
  root-sibling outlines, destination/URI links, `Surface::copy_page`,
  `Surface::show_page`, `Context::show_page`, stable marker checks,
  stream-to-direct-C normalized equality, and PS/SVG negative PDF-metadata
  checks. This adds four vector-backend tests without changing public API.
  A later article-thread stream-to-direct-C oracle slice added scene 56 as a
  focused PDF/PS/SVG backend fixture with article, block quote, note, figure,
  caption, and reference structure tags, metadata/custom-metadata overwrite and
  removal, page labels, nested outlines, URI/destination links,
  `Surface::copy_page`, `Context::show_page`, `Surface::show_page`, stable
  marker checks, stream-to-direct-C normalized equality, and PS/SVG negative
  PDF-metadata checks. This adds four vector-backend tests without changing
  public API.
  A later review-dossier stream-to-direct-C oracle slice added scene 57 as a
  focused PDF/PS/SVG backend fixture with TOC, reference, list, table,
  non-struct, and note structure tags, metadata/custom-metadata overwrite and
  removal, page labels, nested outlines, URI/destination links,
  `Surface::copy_page`, `Context::copy_page`, `Surface::show_page`, stable
  marker checks, stream-to-direct-C normalized equality, and PS/SVG negative
  PDF-metadata checks. This adds four vector-backend tests without changing
  public API.
  A later appendix-rubric stream-to-direct-C oracle slice added scene 58 as a
  focused PDF/PS/SVG backend fixture with Index, reference, code, formula,
  figure, caption, block-quote, and bibliography-entry structure tags,
  metadata/custom-metadata overwrite and removal, page labels, nested outlines,
  URI/destination links, `Context::copy_page`, `Surface::copy_page`,
  `Surface::show_page`, stable marker checks, stream-to-direct-C normalized
  equality, and PS/SVG negative PDF-metadata checks. This adds four
  vector-backend tests without changing public API.
  A later research-note stream-to-direct-C oracle slice added scene 59 as a
  focused PDF/PS/SVG backend fixture with table, list, note, reference, figure,
  and caption structure tags, metadata/custom-metadata overwrite and removal,
  page labels, nested outlines, URI/destination links, `Context::copy_page`,
  `Surface::copy_page`, `Surface::show_page`, stable marker checks,
  stream-to-direct-C normalized equality, and PS/SVG negative PDF-metadata
  checks. This adds four vector-backend tests without changing public API.
  A later ScriptSurface create-for-target parity slice added one public
  black-box fixture proving that drawing through `Surface::script_for_target`
  emits script output and produces the same target image bytes as drawing
  directly to an image surface. This adds one pycairo-derived fixture without
  changing public API.
  A later Context pycairo surface-source offset parity slice added two
  black-box fixtures for `Context::set_source_surface` default/explicit
  offsets and `Context::mask_surface` explicit offsets, checked with exact
  ARGB32 pixels. This raises the context pycairo package to 38 tests without
  changing public API.
  A later image-surface empty-data parity slice added one public black-box
  fixture proving that an ordinary 0x0 `Surface::image` exposes an empty
  `ImageData` view and empty copied image bytes, matching pycairo's
  `test_image_surface_get_data_empty` behavior without changing public API.
  A later create-for-data array parity slice added one public black-box
  fixture proving that a prefilled ARGB32 `FixedArray[Byte]` can back
  `Surface::image_for_data` with its default stride and be copied back
  byte-for-byte, matching the core storage-sharing behavior of pycairo's
  array-backed `ImageSurface.create_for_data` fixture without changing public
  API.
  A later PDF stream tag marker slice added one public black-box fixture for
  stream output with PDF metadata, custom metadata, page labels, parent/child
  outlines, URI links, named destinations, and document-structure tags. This
  keeps the recent CI failure mode covered by the normal external stream test
  package without requiring fragile PDF byte equality and without changing
  public API.
  A later API `test_surface` constructor-smoke slice added one external
  black-box fixture proving image format/dimensions, PDF/PS/SVG stream
  constructors, and bounded/unbounded recording constructors through the
  published package path. This raises `src/tests/api/pycairo` to 8 tests
  without changing public API.
  A later pycairo PS misc slice added one external black-box fixture proving
  pycairo's `PSSurface` DSC page-setup-before-setup ordering through
  `src/tests/backend/ps`, raising that backend package to 8 tests and bringing
  the observed full native suite to 698 tests without changing public API.
  A later pycairo MIME reference-semantics slice added one external black-box
  fixture proving that the same MIME payload can be stored under multiple keys
  and each key can be cleared independently. This raises
  `src/tests/surface/mime` to 6 tests and the observed full native suite to 699
  tests without changing public API.
  A later pycairo create-for-data release-on-finish slice changed the C glue to
  detach the backing-buffer user-data slot immediately after
  `Surface::finish`, added a black-box retained-slot probe plus a
  `SurfaceFinished` copy-data check under `src/tests/image/buffer`, and raised
  that package to 7 tests and the observed full native suite to 700 tests
  without changing public API.
  A later pycairo transformed-coordinate slice added one external black-box
  fixture proving that `Context::user_to_device`,
  `Context::user_to_device_distance`, `Context::device_to_user`, and
  `Context::device_to_user_distance` match pycairo/Cairo behavior after a
  translate-plus-scale CTM. This raises `src/tests/context/pycairo` to 14
  tests and the observed full native suite to 714 tests without changing public
  API.
  A later pycairo pattern-surface/filter slice added two external black-box
  fixtures proving `Pattern::for_surface` constructor/use through
  `Context::set_source` and `Pattern::set_filter`/`get_filter` round trips,
  matching pycairo's `test_surface_pattern` and `test_pattern_filter`
  behavior. This raises `src/tests/pattern/pycairo` to 13 tests and the
  observed full native suite to 716 tests without changing public API.
  A later pycairo file-object error slice added one external black-box fixture
  mapping pycairo's `test_api.py::test_surface_file_obj_error` to cairoon's
  explicit PDF/PS stream-writer API: a failing writer now proves checked
  `CairoIOError(WriteError, _)` propagation through `src/tests/api/pycairo`.
  This raises that package to 9 tests and the observed full native suite to 717
  tests without changing public API.
  A later pycairo PDF MIME payload slice added one external black-box fixture
  mapping pycairo's `test_api.py::test_surface_mime_data_for_pdf` to cairoon's
  public `Surface::set_mime_data` plus PDF file-output path. The test uses the
  same 281-byte JPEG payload as the existing direct-C oracle and verifies that
  Cairo embeds it in the generated PDF. This raises `src/tests/surface/mime` to
  7 tests and the observed full native suite to 718 tests without changing
  public API. Targeted local checks for this slice:
  `moon test src/tests/surface/mime --target native --deny-warn -v` and
  `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/opt/homebrew/opt/llvm/bin/llvm-ar ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon test src/tests/oracle/pattern_raster --target native --deny-warn -v`.
  A later backend attachment-index oracle slice added Scene 62, covering a
  two-page PDF/PS/SVG document with metadata, custom metadata removal, page
  labels, nested outlines, URI and named-destination tags, structure tags,
  backend resizing, stable marker checks, file-vs-stream normalized equality,
  direct C oracle equality, and PS/SVG negative PDF-metadata checks. This
  raises `src/tests/oracle/vector_backend` to 207 tests and the observed full
  native suite to 722 tests without changing public API. Local checks for this
  slice: `moon test src/tests/oracle/vector_backend --target native --deny-warn -v`
  and `./scripts/verify.sh`, including the local ASan pass.
