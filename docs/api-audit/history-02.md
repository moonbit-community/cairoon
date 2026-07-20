# API Audit Delta History, Part 2

Historical snapshot of `API_INVENTORY.md` lines 583-803 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

- 2026-07-15: The pinned Rectangle parity ledger maps all 4 upstream
  `test_rectangle.py` cases to 3 family-local runtime anchors and 7 required
  generated signatures. The audit exposed missing pycairo tuple-style index
  syntax; `Rectangle::at` now provides checked `rectangle[index]` access and
  reuses the existing `InvalidIndex` error mapping.
- 2026-07-15: The pinned Path parity ledger maps all 4 upstream
  `test_path.py` cases to 4 family-local runtime anchors, 9 required generated
  signatures, and 1 deliberately absent constructor signature. It locks
  abstract construction, pycairo-compatible formatting, pointer-identity
  equality/order/hash, and typed iteration through the public package.
- 2026-07-15: The pinned Device parity ledger maps all 11 upstream
  `test_device.py` cases to 9 family-local runtime anchors, 15 required
  generated signatures, and 1 deliberately absent constructor signature. It
  records path/stream constructor separation, scoped finish behavior,
  identity-based equality/hash, and checked recording-surface subtype errors.
- 2026-07-15: The pinned Region parity ledger maps all 12 upstream
  `test_region.py` cases to 10 family-local runtime anchors, 19 required
  generated signatures, and 4 deliberately absent signatures. The audit moved
  the RectangleInt boundary fixture into the Region family and removed its
  generic `Hash` trait to match pycairo's unhashable protocol contract.
- 2026-07-15: The pinned Matrix parity ledger maps all 11 upstream
  `test_matrix.py` cases to 6 family-local runtime anchors, 11 required
  generated signatures, and 2 deliberately absent signatures. Matrix now
  exposes pycairo-compatible `*` multiplication and checked `matrix[index]`
  access while preserving cairoon's documented immutable-value transforms.
- 2026-07-15: The pinned Font parity ledger now maps all 35 upstream
  `test_font.py` cases to 14 family-local MoonBit runtime anchors, 21 required
  generated signatures, and 3 deliberately absent signatures. The audit also
  removed the generic `Hash` trait from mutable `FontOptions` while preserving
  its explicit Cairo-compatible `hash()` method.
- 2026-07-14: `RasterSourcePattern` callback reliability is now closed with a
  deterministic six-state transition matrix covering all 36 directed
  clear/release-only/acquire-only/acquire-release/dynamic/failure replacements,
  callback introspection, pixel/error results, stale-callback exclusion, and
  retained-surface owner balance under native and ASan runs.
- 2026-07-08: The external `src/tests/region/pycairo` package now carries the
  composite pycairo `test_api.py::test_region` fixture for multi-rectangle
  normalization, translate/copy behavior, and exact intersect/subtract/union/xor
  region splits through the published package path.
- 2026-07-08: The external `src/tests/api/enums` package now carries a pycairo
  `test_api.py::test_constants` raw-value fixture for antialias/operator
  constants, region overlap constructors, `FORMAT_RGB30`, `FORMAT_INVALID`,
  `MIME_TYPE_JPEG`, and SVG version raw strings.
- 2026-07-08: PDF/PS/SVG backend filename constructors now read back their
  path outputs and check backend file headers/markers, proving that the
  filename path writes real vector files rather than only reaching `finish()`.
- 2026-07-08: The external `src/tests/surface/mime` package now carries the
  pycairo `test_api.py::test_surface_mime_data_for_pdf` fixture, proving JPEG
  MIME payload embedding through the published `Surface::set_mime_data` and
  PDF file-output path.
- 2026-07-08: The external `src/tests/api/pycairo` package now carries the
  pycairo `test_api.py::test_surface_file_obj_error` fixture, proving failing
  PDF/PS stream writers map to checked `CairoIOError(WriteError, _)` through
  the published package path.
- 2026-07-08: PDF/PS/SVG backend differential coverage now includes scene 61,
  a link-audit file/stream/direct-C oracle covering PDF metadata/custom
  metadata, page labels, nested outlines, URI links, named-destination links,
  list-style structure tags, PS DSC markers, SVG pixel units, and PS/SVG
  negative PDF tag-metadata checks.
- 2026-07-08: PDF/PS/SVG backend differential coverage now includes scene 60,
  a cross-reference file/stream/direct-C oracle covering PDF metadata/custom
  metadata overwrite-removal, page labels, nested outlines, named-destination
  links, URI links, Index/Reference/Figure/Caption structure tags, and mixed
  `Surface::show_page`/`Surface::copy_page` transitions.
- 2026-07-08: The external `src/tests/backend/ps` package now carries a
  pycairo `test_surface.py::test_ps_surface_misc` DSC setup-order fixture,
  proving `ps_dsc_begin_page_setup` followed by `ps_dsc_begin_setup` through the
  published package path.
- 2026-07-08: The external `src/tests/api/pycairo` package now carries the
  pycairo `test_api.py::test_surface` constructor smoke fixture, proving image
  dimensions/format, PDF/PS/SVG stream constructors, and bounded/unbounded
  recording constructors through the published package path.
- 2026-07-08: The external `src/tests/api/pycairo` package now carries the
  pycairo `test_api.py::test_recording_surface_get_extents` fixture, proving
  unbounded, bounded, and post-finish recording extents through the published
  package path.
- 2026-07-08: pycairo `test_device.py::test_script_device_to_path` parity now
  verifies `Device::script(path)` writes script content to the requested
  pathname and cleans the temporary output around the fixture.
- 2026-07-08: The layout gate now enforces native-only target entries for every
  production `src/**/ffi*.mbt` file, including internal helper packages, so raw
  FFI declarations cannot silently become backend-generic during package
  extraction.
- 2026-07-08: PDF custom metadata parity now asserts that pycairo's reserved
  custom metadata names map to Cairo `InvalidString`, preserve
  `Status::message`, and use the checked `CairoInvalidArgument` payload.
- 2026-07-08: ARGB32 image rendering oracle coverage now includes a
  forty-fourth ordinary and buffer-backed direct-C scene in the
  pattern-operator oracle file, combining a transformed repeated surface
  pattern, a reflected transformed linear gradient through `OperatorHslHue`,
  group compositing, and a transformed radial mask.
- 2026-07-08: ARGB32 image rendering oracle coverage now includes a
  forty-fifth ordinary and buffer-backed direct-C scene in the pattern-operator
  oracle file, combining a transformed padded surface pattern, a repeated
  transformed linear gradient through `OperatorHslSaturation` inside a
  color-alpha group, and a transformed radial mask.
- 2026-07-08: ARGB32 image rendering oracle coverage now includes a
  forty-sixth ordinary and buffer-backed direct-C scene in the pattern-operator
  oracle file, combining a transformed reflected surface pattern, a repeated
  transformed radial gradient through `OperatorHslColor` inside a color-alpha
  group, and a transformed linear mask.
- 2026-07-08: ARGB32 image rendering oracle coverage now includes a
  forty-seventh ordinary and buffer-backed direct-C scene in the
  pattern-operator oracle file, combining a transformed repeated surface
  pattern, a reflected transformed linear gradient through
  `OperatorHslLuminosity` inside a color-alpha group, and a transformed radial
  mask.
- 2026-07-08: PDF/PS/SVG backend differential coverage now includes scene 59,
  a research-note file/stream/direct-C oracle covering PDF metadata/custom
  metadata overwrite-removal, page labels, nested outlines, URI and
  named-destination links, table/list/note/reference/figure/caption structure
  tags, and mixed `Context::copy_page`/`Surface::copy_page`/show-page
  transitions.
- 2026-07-08: PDF/PS/SVG backend differential coverage now includes scene 58,
  an appendix-rubric file/stream/direct-C oracle covering PDF metadata/custom
  metadata overwrite-removal, page labels, nested outlines, URI and
  named-destination links, Index/Code/Formula/Figure/Caption/BibEntry
  structure tags, and mixed `Context::copy_page`/`Surface::copy_page`/show-page
  transitions.
- 2026-07-08: Context pycairo parity now includes pixel-level coverage for
  `Context::set_source_surface` default and explicit offsets plus
  `Context::mask_surface` explicit offsets.
- 2026-07-08: PDF/PS/SVG backend differential coverage now includes scene 57,
  a review-dossier file/stream/direct-C oracle covering PDF metadata/custom
  metadata overwrite-removal, page labels, nested outlines, URI and
  named-destination links, TOC/list/table/note structure tags, and
  copy/show-page transitions.
- 2026-07-08: PDF/PS/SVG backend differential coverage now includes scene 56,
  an article-thread file/stream/direct-C oracle covering PDF metadata/custom
  metadata overwrite-removal, page labels, nested outlines, URI and
  named-destination tags, article/block-quote/note/figure/caption/reference
  structure tags, and copy/show page transitions.
- 2026-07-08: pycairo `test_image_surface_release_on_finish` parity now
  releases the retained MoonBit buffer for `Surface::image_for_data` during
  `Surface::finish`; a black-box test probes the internal Cairo user-data slot,
  then checks `copy_data` still maps to `SurfaceFinished`.
- 2026-07-07: pycairo `test_api.py::test_version` parity now includes the
  `CAIRO_VERSION_STRING == major.minor.micro` component consistency check and
  the Cairo encoded integer formula for `CAIRO_VERSION`.
- 2026-07-07: ARGB32 image rendering oracle coverage now includes a
  forty-third ordinary and buffer-backed direct-C scene in a separate
  pattern-operator oracle file, combining a transformed reflected surface
  pattern with a transformed radial gradient through `OperatorColorDodge`.
- 2026-07-07: PDF/PS/SVG backend differential coverage now includes scene 54,
  a bookmark-lattice file/stream/direct-C oracle covering metadata/custom
  metadata overwrite-removal, page labels, outline parent-child/sibling
  structure, URI and named-destination tags, and copy/show page transitions.
- 2026-07-07: ARGB32 image rendering oracle coverage now includes a
  forty-second ordinary and buffer-backed direct-C scene combining a transformed
  repeated surface-pattern stroke, linear paint, radial mask, group
  compositing, and `OperatorDifference`.
- 2026-07-07: ARGB32 image rendering oracle coverage now includes a
  forty-first ordinary and buffer-backed direct-C scene combining a mesh
  pattern, transformed surface pattern, repeated linear gradient, radial mask,
  group compositing, and `OperatorSoftLight`.
- 2026-07-07: PDF stream tag/metadata reliability now includes a public
  black-box marker fixture covering PDF stream output with metadata, custom
  metadata, page labels, parent/child outlines, URI links, named destinations,
  and document-structure tags through the published `CAIMEOX/cairoon` package.
- 2026-07-07: pycairo `test_surface.py` parity now includes a compact
  `ImageSurface.create_for_data` array fixture: a prefilled ARGB32
  `FixedArray[Byte]` can be wrapped with the default stride, queried for
  width/height/stride, and copied back byte-for-byte from the surface.
- 2026-07-07: pycairo `test_surface.py` parity now includes
  `test_image_surface_get_data_empty`: an ordinary 0x0 image surface exposes
  an empty `ImageData` view and empty copied data.
- 2026-07-07: pycairo `test_surface.py` parity now includes a
  `Surface::script_for_target` target-paint fixture: drawing through a
  script surface writes script output and produces the same image bytes as
  drawing directly to the target image surface.
- 2026-07-07: pycairo `test_api.py` parity now includes the
  `test_recording_surface_get_extents` post-finish fixture. Recording-surface
  bounded extents stay readable after `Surface::finish`, while non-recording
  subtype checks still map to `SurfaceTypeMismatch`.
- 2026-07-07: pycairo `test_api.py` parity now includes the
  `test_image_surface_get_data` mutable data-view fixture: an `ImageData` view
  shares bytes with later `get_data()` calls and observes subsequent
  `Context::paint` plus `Surface::flush` updates.
- 2026-07-07: pycairo `test_api.py` parity now includes
  `Surface::has_show_text_glyphs` before and after `finish()` plus the
  `Context::paint`/`OperatorSource` smoke fixture, covering the finished-surface
  `SurfaceFinished` mapping and deterministic ARGB32 white output.
- 2026-07-07: pycairo `test_api.py` parity now includes the
  `surface_destroy_before_context` and
  `surface_destroy_before_surface_pattern` lifetime fixtures, covering PDF/PS
  stream targets retained by `Context` and PDF stream surfaces retained through
  `Pattern::for_surface`.
- 2026-07-07: pycairo `test_api.py` parity now includes a Unicode
  `Context::show_text` smoke fixture and a Unicode PNG filename round-trip
  fixture through `Surface::write_to_png` and `Surface::image_from_png`.
- 2026-07-07: Backend vector oracle coverage adds scene 53, a cross-backend
  semantic-index fixture with PDF metadata, custom metadata, page labels,
  nested outlines, destination and URI links, TOC/TOCI/Reference,
  Art/BlockQuote/NonStruct/Note, and Figure/Caption structure tags, retained
  `Surface::copy_page`, stream-to-direct-C oracle equality, stable marker
  checks, and PS/SVG negative PDF-metadata assertions.
- 2026-07-07: Backend vector oracle coverage adds scene 52, a cross-backend
  annotation/list/table sequence with PDF metadata, custom metadata, page
  labels, outlines, URI and destination links, list/table structure tags,
  retained `Surface::copy_page`, stream-to-direct-C oracle equality, stable
  marker checks, and PS/SVG negative PDF-metadata assertions.
- 2026-07-07: PNG path/stream parity now mirrors pycairo's filename versus
  file-object fixture: write the same ARGB32 image through `Surface::write_to_png`
  and `Surface::write_to_png_stream`, compare the exact PNG bytes, then read both
  forms back and compare copied pixel data.
- 2026-07-07: PNG stream parity now includes a public black-box data round
  trip: write an ARGB32 image through `Surface::write_to_png_stream`, read it
  back through `Surface::image_from_png_stream`, and compare copied pixel data
  with the original source image.
- 2026-07-07: PDF surface lifecycle parity now includes post-finish
  `SurfaceFinished` checks for page labels, metadata, custom metadata, and
  outline insertion, matching the corresponding pycairo post-context-manager
  error fixtures.
- 2026-07-07: PS surface lifecycle parity now includes post-finish
  `SurfaceFinished` checks for the EPS getter, page size, DSC setup, DSC page
  setup, and DSC comments, matching the same lifecycle policy used by PDF/SVG
  backend helpers.
- 2026-07-07: Vector stream callback parity now covers the pycairo
  closed-before-finish fixture by creating PDF/PS/SVG stream surfaces, closing
  the writer state after construction, and requiring finish-time
  `CairoIOError(WriteError, _)` mapping.
