# Testing Evidence History, Part 2

Historical snapshot of `TESTING.md` lines 393-961 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.


The current cairoon slice is not a full migration. It has native package setup,
pycairo-style C glue split into a `src/native` native-stub package with private
shared declarations plus per-family stub files, a first pure support package
seam for `Glyph` under
`src/core/glyph` with package-local pure value and glyph-array marshaling tests,
and a pure constants support package under `src/core/constants` with facade
`pub const` re-exports and package-local constant tests,
with private test-only oracle glue moved to the
`src/tests/oracle/native` support package and split into constants,
ScaledFont, common drawing, file/normalized-output comparison, ARGB32 image,
raster-owner, vector-output entry points, vector-output scene drawing, and
PDF/PS/SVG vector feature renderers,
opaque external-object wrappers for `Surface`,
`MappedImageSurface`, `Context`, `Path`, `Pattern`, `FontOptions`, `FontFace`,
`ScaledFont`, `Region`, and `Device`, pure value types including `Glyph` with
`UInt64` index width, many portable enums,
including enum-only `SurfaceObserverMode` pycairo compatibility,
expanded Context path, painting/page, target/source borrowed returns,
source-surface convenience, Context pointer equality/hash, clip, matrix, drawing-state including pycairo hairline mode,
compile-time Cairo
constants, group APIs, tag APIs, toy
text APIs including Unicode `show_text` smoke parity, glyph array APIs,
text-to-glyphs/show-text-glyphs APIs,
including glyph-only text conversion for pycairo's `with_clusters=False` path,
documented product decisions for `CAPI`, legacy uppercase enum alias
constants, and non-implemented FreeType/user-font classes,
hit-testing/extents APIs, typed Path segment iteration and stringification,
PNG filename load/save including Unicode filename round trips plus stream
read/write, pycairo `surface_destroy_before_context` and
`surface_destroy_before_surface_pattern` lifetime parity for stream-backed
surfaces retained by contexts and surface patterns, direct C Cairo oracle
comparisons for forty-seven deterministic ARGB32 image scenes on ordinary and
buffer-backed image surfaces including toy-font `text_path`, toy-font
`show_text`, `glyph_path`, `show_glyphs`, `show_text_glyphs`,
source-surface offsets, mask-surface offsets, raster-source pattern repeat
rendering, dashed round-cap strokes, hairline strokes, clipped paint/fill output,
`OperatorClear` compositing output, group compositing output, mask pattern
compositing output, even-odd fill-rule output, and a surface-pattern
`Reflect`/`Nearest`/`DitherBest`/matrix combination plus transformed repeated
linear-gradient `Repeat`/`Nearest`/`DitherFast`/matrix output, transformed
radial-gradient `Reflect`/`Nearest`/`DitherGood`/matrix output,
surface-pattern `Pad`/`Bilinear`/`DitherDefault`/matrix and
`ExtendNone`/`Nearest`/`DitherNone`/matrix output, transformed linear-gradient
`Pad`/`Bilinear`/`DitherBest`/matrix output, transformed radial-gradient
`Repeat`/`Bilinear`/`DitherFast`/matrix output, surface-pattern
`Repeat`/`Bilinear`/`DitherGood`/matrix output, transformed linear-gradient
`ExtendNone`/`Good`/`DitherNone`/matrix output with duplicate-offset stops,
transformed radial-gradient `Pad`/`Good`/`DitherDefault`/matrix output,
curve/multi-patch mesh-pattern matrix output, and nested
surface/linear/radial/mask pattern-stack clip/save/restore/OperatorAtop output,
mesh/linear surface-mask group-compositing output, and
set_source_surface/repeated-surface-pattern/radial-mask group-compositing
output, surface-pattern device-offset mask with `OperatorScreen` group
compositing output, surface/radial-gradient `OperatorOverlay` group-mask
output, mesh/surface/linear pattern-stack `OperatorSoftLight` group-mask
output, surface-pattern stroke `OperatorDifference` group-mask output,
radial-gradient `OperatorColorDodge` over transformed reflected surface-pattern
output, transformed repeated surface-pattern plus reflected linear-gradient
`OperatorHslHue` group-mask output, transformed padded surface pattern plus
repeated linear-gradient `OperatorHslSaturation` group-mask output, and
transformed reflected surface pattern plus repeated radial gradient
`OperatorHslColor` group-mask output, and transformed repeated surface pattern
plus reflected linear gradient `OperatorHslLuminosity` group-mask output;
buffer-backed creation plus mutable `ImageData`
views for image and
mapped-image surfaces, pycairo-style scoped surface finish and mapped-image
unmap helpers with success/error cleanup coverage, portable
Surface base helpers such as similar-surface creation, rectangular child
surface creation with retained parent-wrapper lifetime, content/type queries,
pointer equality/hash for ordinary surfaces, dirty markers with
finished-status coverage, pycairo-derived surface context-manager/cmp-hash/
content-format/device-scale/create-for-rectangle/create-similar-image
fixtures, device offset/scale, fallback resolution,
show-text-glyphs support checks with finished-status coverage, invalid-size
error mapping for similar and rectangular child
surface construction, MIME constants, MIME data storage/query/clear support including
image/PDF/PS/SVG MIME support matrices, PDF JPEG MIME passthrough with direct C oracle coverage, PDF thumbnail direct C oracle coverage, pycairo-style PDF thumbnail resize/reset and post-finish error parity, and
RecordingSurface constructor/extents/ink-extents plus replay and explicit
post-finish extents-versus-ink behavior, mapped image
surface mapping/unmapping, PDFSurface filename/no-output/stream constructor,
version helpers, version restriction, size, metadata, custom metadata,
page-label, thumbnail reset, and single-flag and combined-flag outline helpers,
including subtype-mismatch checks for every bound PDF helper,
PSSurface
filename/no-output/stream constructor, level helpers, level restriction, EPS
mode, size and DSC helpers including subtype-mismatch checks for every bound PS
helper, SVGSurface filename/no-output/stream constructor,
version helpers, version
restriction, and document-unit helpers,
surface-pattern borrowed surface returns, Pattern pointer equality/hash
including independent solid-pattern identity,
pycairo solid-pattern default extend/filter/dither/matrix/clamped-RGBA,
setter round-trip, gradient point/color-stop/radial-circle, and mesh example
patch fixtures,
RasterSourcePattern
constructor/acquire/get-acquire/release callback glue with retained closure and acquired
surface owners, pycairo-derived callback-state/acquire-release paint fixtures,
finished-surface acquire failure injection, MeshPattern patch lifecycle/query
APIs, `FORMAT_INVALID` integer-sentinel coverage, FontOptions
state/accessor APIs, FontFace/ToyFontFace APIs, ScaledFont
basics including glyph extents, text-to-glyphs, and direct C Cairo oracle
comparison for font/text/glyph extents and empty, single/multi/spaced ASCII,
precomposed/decomposed Latin, CJK, Arabic RTL, and emoji UTF-8
text-to-glyph coordinate cases plus sheared font/CTM scale-matrix
composition, and
Device/ScriptDevice basics including status/type/equal/hash,
finish/flush/acquire/release, scoped acquire/finish, file/stream script devices,
pycairo-derived context-manager, cmp/hash, image-surface `get_device`,
script mode/comment, and recording replay fixtures, `Surface::get_device`,
`Surface::script`, and
`Surface::script_for_target`, TeeSurface mirrored drawing, owner retention,
independent target indexing, sticky removal errors, and finished status,
exhaustive `Status`/`CairoError` classification, retained-owner lifetime
stress tests, external value-wrapper allocation stress for `Path`, `Region`,
the font stack, solid/gradient/mesh `Pattern`, recording/similar/Tee
`Surface`, and script stream `Device`, `ImageData` view allocation stress for
ordinary, buffer-backed, and mapped image surfaces, backend stream callback
allocation stress for PDF/PS/SVG surfaces, PNG stream write/read, script
devices, and stream `WriteError` paths, raster-source callback allocation
stress for set/get/manual acquire/release/replace/clear paths plus a
white-box owner-count check for acquire-only repeated same-surface paints,
64-step acquire-only retained-owner replacement fuzz, compatible target/extents
acquire rendering with device-offset source surfaces, and deterministic
callback replacement/failure fuzz with dynamic compatible source surfaces,
plus a six-state exhaustive matrix covering all 36 directed callback-state
replacements with callback-shape, stale-token, pixel/error, and retained-owner
balance assertions,
Cairo float
image-format creation/readback coverage, `Format::stride_for_width` coverage
for legacy, 16-bit, 30-bit, float, and invalid-width cases, stable
structural vector-output markers plus direct C oracle comparisons
for seventeen deterministic PDF/PS/SVG vector scenes covering paint, stroke,
fill/stroke rectangles, Bezier paths, transforms, linear/radial gradients,
toy-font text paths, toy-font `show_text`, `glyph_path`, `show_glyphs`, two-page paint, clip, dashed
stroke, repeated surface pattern, mask surface, and mesh pattern scenes, with
SVG dynamic `source-*` image-id normalization, three PDF-only tag oracle scenes,
three PDF-only text-tag oracle scenes, PS/SVG Link tag inertness oracle
scenes, PS/SVG destination and document-structure rectangle/text tag oracle
scenes, one cross-backend tagged multi-page text oracle scene, one
cross-backend tagged `show_text_glyphs` oracle scene, one cross-backend grouped
glyph/tag multi-page oracle scene, one cross-backend copy_page retained
two-page oracle scene, one cross-backend mixed
vector/tag/text oracle scene, one cross-backend layered
three-page clip/dash/surface-pattern/mask/tag/text oracle scene, one
cross-backend wide three-page URI/destination/document-structure tag/vector
oracle scene, PDF tagged `show_text_glyphs` marker checks, PDF grouped
glyph/tag marker checks, PDF copy_page retained two-page marker checks, PDF
mixed vector/tag/text marker checks, PDF layered three-page marker checks, PDF
wide three-page marker checks, three
PDF-only document-feature/page-operation oracle scenes including one text/tag-aware combined scene, one
PS-only DSC/multi-page oracle scene, one SVG-only
version/unit/multi-page oracle scene, PDF metadata/custom-metadata/page-label/
outline output markers, PDF/PS/SVG
multi-page output markers, PDF tagged multi-page text structure markers, PDF
tagged `show_text_glyphs` Link/structure markers, PDF JPEG MIME payload embedding and PDF thumbnail output with direct C oracle comparison,
image/PDF/PS/SVG MIME support matrix checks,
PDF URI link-tag annotation markers, PDF named-destination tag markers, PDF
document-structure tag markers, PS/SVG Link tag inert-output checks, PS/SVG
destination/document-structure rectangle/text tag output checks, PS/SVG
destination/document-structure, tagged `show_text_glyphs`, grouped glyph/tag,
mixed vector/tag/text, layered three-page, and wide three-page
negative checks for PDF-only tag metadata, and cross-backend tagged multi-page
text, tagged `show_text_glyphs`, grouped glyph/tag, mixed vector/tag/text,
layered three-page, and wide three-page checks with direct C Cairo oracle
comparison, mutable image/mapped-image data view tests, and initial tests. Pattern has executable
reference examples for solid/shared state, surface patterns, gradients, mesh
patches, raster-source callbacks, and checked subtype/index/lifecycle errors.
Backend surface black-box tests also cover extended PDF custom-metadata/
thumbnail/outline subtype mismatches, PS size/setup/page-setup subtype
mismatches, and SVG document-unit getters after `finish()`.
ImageData black-box tests cover ordinary, buffer-backed, and PNG-loaded
`get_data` after `finish()`, plus retained ordinary views observing
base-surface `SurfaceFinished` after the base surface is finished.
Path has executable reference examples and pycairo-derived fixtures for typed
segment iteration, pycairo-style string formatting, self comparison/hash,
flattened append behavior, copied-path ownership, and checked invalid-matrix
errors. Region now covers empty,
single-rectangle, and multi-rectangle construction plus predicates, pycairo
negative and positive rectangle-index fixtures, equality mapping through
MoonBit `Eq`, empty-region overlap and translate behavior, region boolean
operations, and rectangle boolean operations including XOR split semantics and
cairoon's checked-chaining boolean mutator extension; `region.mbt.md` adds
executable reference examples for the same family. Matrix has executable
reference examples for component access,
pure-value transforms, multiplication, inversion, and checked errors. Surface
has executable reference examples for image properties, buffer-backed data,
similar/subsurface constructors, mapped images, PNG/MIME helpers, and checked
surface errors. Backend surfaces/devices have executable reference examples for
PDF/PS/SVG stream output and writer errors, PDF metadata/outlines, PS DSC, SVG
document units, recording replay, Tee fanout, script devices/surfaces, and
checked backend-specific errors. Context has executable reference examples for
construction and drawing state, transformations, paths, fill/stroke output,
clipping, groups, text/glyph APIs, and checked context errors. Font has
executable reference examples for FontOptions state/copy/merge, color
palettes, toy font faces, Surface/Context font options, ScaledFont
matrices/metrics, text-to-glyphs, and checked font errors.

Verified on 2026-07-02, 2026-07-03, 2026-07-04, 2026-07-05, 2026-07-06, 2026-07-07, and 2026-07-08:

- `./scripts/verify.sh`: passed. The local reliability gate ran
  `moon fmt --check`, `scripts/configure-cairo-constants.sh --check`,
  `scripts/check-ffi-ownership.py`, `scripts/check-api-inventory.py`,
  `scripts/check-reliability-ledger.py`, native `moon check`, targeted image,
  ScaledFont oracle,
  font-options/font-face/scaled-font, vector including PDF combined text
  document-feature plus PS DSC/SVG unit backend-feature oracle checks,
  surface base/ImageData tests,
  stream black-box/white-box tests, mapped-image, subsurface, recording,
  MIME, PDF/PS/SVG helper, TeeSurface, script-device, and object-trait tests,
  context lifetime/state/matrix/path/group/text/glyph/extents/clip/painting tests,
  Path tests,
  pattern/gradient/mesh tests, raster manual/owner/state white-box tests, and
  Region/lifetime-stress tests,
  the full native suite, `moon info --target native`, and targeted ASan
  image-oracle, font-options/font-face/scaled-font, vector-output, stream,
  surface base/ImageData, mapped-image, subsurface, recording, MIME,
  PDF/PS/SVG helpers, TeeSurface, script-device, object-trait,
  context-lifetime/state/matrix/path/group/text/glyph/extents/clip/painting, Path,
  pattern/gradient/mesh, raster manual/owner/state, and Region/lifetime-stress tests with
  leak detection disabled. The current run includes
  the surface-mask screen group image-oracle slice,
  the FontOptions variation embedded-NUL slice,
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
  the wide multi-page stream marker/equivalence slice,
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
  the wide multi-page vector/tag oracle slice,
  the packaging/pycairo-porting documentation slice, the layered multi-page
  vector/tag oracle slice, the mixed vector/tag/text marker slice, the direct
  C oracle slice, the PDF thumbnail direct C oracle slice, the PDF thumbnail
  stream equivalence slice, the PDF JPEG MIME stream equivalence slice, and
  the PDF text document-feature stream equivalence slice, the PDF
  page-operation document-feature stream equivalence slice, the non-text
  primitive vector stream equivalence slice, the backend feature/tag stream
  combo slice, the PS/SVG backend-combo stream inertness slice, the standalone
  text vector stream equivalence slice, and the single-page tag stream
  marker/equivalence stabilization slice.
- `moon -C cairoon check --target native`: passed.
- `moon -C cairoon test --target native`: 569 tests passed. The current run
  includes the expanded pattern-combo image oracle slice,
  the surface-mask screen group image-oracle slice,
  the mesh-mask group-compositing image oracle slice,
  the tag-heavy stream-to-direct-oracle differential slice,
  the backend stream-to-direct-oracle differential slice,
  the backend lifecycle-matrix differential slice,
  the backend tag-matrix differential slice,
  the resized backend page-sequence combo slice,
  the backend deep tag tree file/stream direct-oracle differential slice,
  the backend metadata-outline file/stream direct-oracle differential slice,
  the backend page-ops file/stream direct-oracle differential slice,
  the backend tag-metadata file/stream direct-oracle differential slice,
  the backend nested tag/page sequence slice,
  the backend surface-page feature/tag combo slice,
  the Context drawing-state all-enum round-trip slice,
  the pycairo raw C-int operator passthrough slice,
  the pycairo raw C-int context drawing-state enum passthrough slice,
  the pycairo raw C-int FontOptions enum passthrough slice,
  the FontOptions variation embedded-NUL slice,
  the pycairo raw C-int toy-font slant/weight parsing slice,
  the pycairo raw C-int content constructor slice,
  the pycairo raw C-int format constructor/getter slice,
  the pycairo context font-extents parity slice,
  the pycairo group-target stack-restoration slice,
  the pycairo rectangle path-extents slice,
  the pycairo 42x42 clip-extents, zero-radius arc, polygon path-extents,
  line in-stroke, empty stroke-extents, default coordinate-conversion, empty
  font-family selection, and font-size matrix parity slice,
  the pycairo hairline getter/setter and direct C hairline stroke oracle slice,
  the pycairo source RGBA round-trip slice,
  the pycairo empty-path clip `in_clip` slice,
  the pycairo mesh curve-first patch slice,
  the pycairo pattern gradient and mesh example fixture slice,
  the pycairo polygon fill-extents slice,
  the mapped-image scoped-error upload slice,
  the TeeSurface positive out-of-range status slice,
  the PDF/PS stream target lifetime slice, the pycairo append-path
  string equivalence slice, the pycairo close-path stringification slice, the
  gradient color-stop ordering/snapshot slice, the stream-vs-file vector output
  equivalence slice, the non-text primitive vector stream equivalence slice,
  the single-page tag stream marker/equivalence stabilization slice, the tagged
  multi-page stream marker/equivalence stabilization slice, the mixed/layered
  stream marker/equivalence stabilization slice, the wide multi-page stream
  marker/equivalence slice, the document-feature stream equivalence slice, the
  backend feature/tag stream combo slice, the vector
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
  the Pattern black-box test split slice,
  the raster-source black-box test split slice,
  the pycairo raw C-int pattern extend passthrough slice,
  the pycairo raw C-int pattern filter/dither passthrough slice,
  the Pattern raw enum documentation slice,
  the pycairo raw C-int context drawing-state enum passthrough slice,
  the pycairo raw C-int FontOptions enum passthrough slice,
  the pycairo raw C-int toy-font slant/weight parsing slice,
  the Pattern raw FFI family split slice, the Font C glue split slice,
  the Pattern C glue split slice, the raster-source callback C glue split
  slice, the Surface C glue split slice,
  the Context C glue split slice,
  the raster-source stale-release replacement slice, the raster-source
  acquire-only owner fuzz slice, the raster-source
  failed-acquire owner-count fuzz slice, the raster-source callback
  state-machine fuzz slice, the raster-source manual callback fuzz slice, the
  mixed vector/tag/text marker slice, the direct
  C oracle slice, the PS/SVG tag metadata absence slice, the PDF tagged
  multi-page text marker slice, the PS/SVG tagged multi-page text inertness
  slice, the PDF rectangle tag marker slice,
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
  text vector stream equivalence slice, the single-page tag stream
  marker/equivalence stabilization slice, and
  the earlier context `get_source`
  surface-pattern lifetime coverage for the path where both the original source
  wrapper and context scope have exited, plus the Path/Region lifetime gate,
  Surface/Device targeted gate, raw FFI split slices through context painting,
  the layered multi-page vector/tag oracle slice, and the wide multi-page
  vector/tag oracle slice.
- `moon -C cairoon test src/tests/path/core --target native -v`: 7 black-box Path
  tests passed, covering empty paths, pycairo-compatible stringification
  including close-path continuation formatting, typed segment iteration, copied-path lifetime after the source context exits,
  flattened copies, and path equality/hash behavior.
- `moon -C cairoon test src/tests/path/pycairo --target native -v`: 4
  pycairo `test_path.py`-derived fixtures passed, covering empty path string
  behavior, `copy_path().to_string()` formatting, self comparison/hash
  operators, and iterator `PathDataType`/coordinate tuples.
- `moon -C cairoon test src/tests/api/version --target native --deny-warn -v`:
  1 black-box API package test passed, covering public version helpers.
- `moon -C cairoon test src/tests/api/enums --target native --deny-warn -v`: 5
  black-box API package tests passed, covering portable enums,
  `Format::stride_for_width`, extended Cairo float/packed formats, and
  `FORMAT_INVALID`, plus pycairo enum smoke fixtures for
  `Jbig2GlobalMissing`, `TextClusterBackward`, and
  `SurfaceObserverNormal`.
- `moon -C cairoon test src/tests/api/pycairo --target native --deny-warn -v`:
  8 black-box API package tests passed, covering pycairo `test_api.py` Unicode
  fixtures for `Context::show_text("ēxāmple.")`, PNG filename write/read round
  trips through `Surface::write_to_png` and `Surface::image_from_png`,
  `test_surface` constructor smoke for image, PDF, PS, SVG, and recording
  surfaces,
  `surface_destroy_before_context` and
  `surface_destroy_before_surface_pattern` lifetime fixtures for stream-backed
  surfaces retained by contexts and surface patterns,
  `Surface::has_show_text_glyphs` finished-surface error mapping, and the
  `Context::paint`/`OperatorSource` smoke fixture, plus
  `RecordingSurface::recording_get_extents` before and after finish.
- `moon -C cairoon test src/tests/status/core --target native --deny-warn -v`: 2
  black-box status package tests passed, covering `run_cairo` success,
  `check_status`, public `Status::message`, and exhaustive `CairoError`
  suberror classification for every Cairo status exposed by the facade.
- `moon -C cairoon test src/tests/value/core --target native --deny-warn -v`:
  9 black-box value package tests passed, covering Rectangle, RectangleInt,
  Glyph, TextCluster, TextExtents, FontExtents, component access,
  positive/negative invalid-index error mapping, and numeric limits.
- `moon -C cairoon test src/tests/value/pycairo --target native --deny-warn -v`:
  6 black-box value parity tests passed, covering pycairo-style value
  equality/hash/component fixtures, clip-rectangle returns, recording extents,
  and Context/ScaledFont extents-return paths.
- `moon -C cairoon test src/tests/region/core --target native --deny-warn -v`:
  10 black-box Region package tests passed, covering constructors, copies,
  containment/overlap queries, mutating boolean operations, chainable rectangle
  mutators, invalid-index mapping, and copied-region lifetime.
- `moon -C cairoon test src/tests/region/pycairo --target native --deny-warn -v`:
  7 black-box Region parity tests passed, covering pycairo-derived rectangle
  index, signed 32-bit limits, equality, containment, composite multi-rectangle
  normalization, exact intersect/subtract/union/xor splits, cairoon's mutator
  receiver extension, and translate fixtures.
- `moon -C cairoon test src/tests/context/path --target native -v`: 11
  black-box Context path tests passed, covering current-point behavior,
  relative path operations and all three no-current-point errors,
  `new_sub_path` geometry retention, pycairo rectangle path-extents behavior,
  close-path current-point reset, arc current-point creation,
  path copy/append independence, pycairo-style append string
  equivalence after clearing the source context, flattened append behavior, and
  path error propagation.
- `moon -C cairoon test src/tests/context/pycairo --target native -v`: 39
  black-box shared Context parity tests passed across
  `context_pycairo_parity_test.mbt`,
  `context_state_paint_pycairo_parity_test.mbt`, and
  `context_font_text_pycairo_parity_test.mbt`, covering the 42x42 default
  clip-extents fixture, zero-radius `arc`/`arc_negative` non-empty paths,
  context comparison/hash behavior from pycairo's `test_cmp_hash`,
  polygon `path_extents`, polygon `fill_extents`, empty `in_fill`, line
  `in_stroke`, rectangle `path_extents`, absolute move/line/curve
  current-point fixtures, relative path current-point updates, empty
  `stroke_extents`, default user/device coordinate conversions,
  matrix setter/translate/scale/transform/rotate fixtures, dash offset
  normalization, current-point state, drawing-state default getters and enum
  setter round trips, hairline getter/setter, raw operator C-int limit
  passthrough, save/restore
  drawing-state restoration, scalar line-width/miter-limit/tolerance setters,
  source RGBA round trips, explicit source-pattern round trips,
  copied `append_path` strings, empty clip/reset `in_clip` behavior, group
  stack push/pop variants, mask/mask-surface/alpha-paint pixel fixtures,
  font-face default/reset/custom round trips, `set_font_matrix` identity,
  font-options round trips, scaled-font round trips, empty
  `select_font_face("")`, `set_font_size(42)` font-matrix fixtures,
  text/font-extents/show-text/text-path fixtures, glyph-extents/show-glyphs/
  glyph-path fixtures, the PDF `show_text_glyphs` tuple fixture, and
  pycairo's `test_simple` method-smoke flow across `clip_preserve`,
  `copy_page`, `copy_path_flat`, `fill`, `fill_preserve`, `font_extents`,
  `identity_matrix`, `new_sub_path`, `show_page`, `stroke_preserve`, dash
  count, font matrix, group target, scalar getters, and final status.
- `moon -C cairoon test src/tests/context/clip --target native -v`: 7
  black-box Context clipping tests passed from a nested external package,
  covering clip extents, `in_clip`, reset and save/restore behavior,
  path-clearing versus preserve behavior, empty and rectangular clip-list
  copying, non-rectangular clip status mapping, and existing-context-error
  propagation.
- `moon -C cairoon test src/tests/context/paint --target native -v`: 7
  black-box Context painting tests passed from a nested external package,
  covering alpha paint, source RGB/RGBA round trips, mask and mask-surface
  behavior, source-surface sampling, preserve variants, page operations, and
  existing-context-error propagation.
- `moon -C cairoon test src/tests/context/state --target native -v`: 10
  black-box Context drawing-state tests passed from a nested external package,
  covering default state, typed and raw drawing-state enum round trips,
  save/restore state restoration, dash clearing and invalid-dash errors,
  invalid restore mapping, and existing-context-error propagation.
- `moon -C cairoon test src/tests/context/group --target native -v`: 5
  black-box Context group tests passed from a nested external package, covering
  `push_group`, `pop_group`, `pop_group_to_source`, raw-content
  `push_group_with_content`, group-target stack restoration to the original
  target, returned group patterns, and unmatched pop error mapping.
- `moon -C cairoon test src/tests/context/matrix --target native -v`: 4
  black-box Context matrix tests passed from a nested external package,
  covering get/set/identity, translate/scale/rotate/transform, user/device
  coordinate conversions, non-identity transform composition, CTM
  save/restore, and singular set/scale/transform error propagation.
- `moon -C cairoon test src/tests/context/extents --target native -v`: 5
  black-box Context extents and hit-testing tests passed from a nested external
  package, covering fill/path/stroke extents, polygon fill-extents,
  clip-independent geometry queries, path preservation, hit tests, and
  existing-context-error propagation.
- `moon -C cairoon test src/tests/context/tag --target native -v`: 5
  black-box Context tag tests passed from a nested external package, covering
  matching begin/end, tag constants, embedded-NUL validation, nesting errors,
  and existing-context-error propagation.
- `moon -C cairoon test src/tests/context/text --target native -v`: 6
  black-box Context text tests passed from a nested external package, covering
  context/scaled-font font-extents and text-extents parity, `show_text`
  current-point advance, text path creation, embedded-NUL validation, and
  context error propagation.
- `moon -C cairoon test src/tests/context/glyph --target native -v`: 5
  black-box Context glyph tests passed from a nested external package, covering
  context/scaled-font glyph-extents parity, `show_glyphs`, `glyph_path`, empty
  glyph arrays, and context error propagation.
- `moon -C cairoon test src/tests/context/text_to_glyphs --target native -v`:
  5 black-box ScaledFont/Context text-to-glyph tests passed from a nested
  external package, covering empty/single/spaced text, renderable
  `show_text_glyphs` output, embedded-NUL validation, and context error
  propagation.
- `moon -C cairoon test src/tests/lifetime/context --target native -v`: 9
  black-box context lifetime tests passed, including `get_target`,
  `get_group_target`, `get_source`, and PDF/PS stream target wrappers that
  remain usable after their creating helper scopes exit.
- `moon -C cairoon test src/tests/surface/{base,mime,pycairo,subsurface}
  --target native -v`: 26 black-box Surface package tests passed, including
  base image/similar/state/status wrappers, pycairo surface parity,
  subsurfaces, MIME, and backend MIME-support matrix checks.
- `moon -C cairoon test src/tests/image/{properties,data,mapped,png,buffer}
  --target native -v`: 30 black-box image-family tests passed, including
  ImageSurface properties, raw image formats, buffer-backed image surfaces,
  mutable ImageData views, pycairo `test_image_surface_get_data` mutable-view
  sharing and post-paint flush update behavior, pycairo empty 0x0 image-surface
  `get_data` behavior, PNG path round trips, mapped images, pycairo-style
  mapped-image scope reuse failures, float image formats, and invalid
  image-family errors.
- `moon -C cairoon test src/tests/backend/pdf --target native -v`: 8
  black-box PDF surface tests passed from a nested external package, covering
  version helpers, raw C-int enums, no-output/page/document APIs, thumbnails,
  metadata/outline/path validation, filename construction with PDF header
  readback, subtype errors, and finished-surface errors.
- `moon -C cairoon test src/tests/backend/ps --target native -v`: 8
  black-box PS surface tests passed from a nested external package, covering
  level helpers, raw C-int enums, no-output/EPS/page/DSC APIs, pycairo DSC
  setup-order parity, DSC/path validation, filename construction with PS
  marker readback, subtype errors, and setup/page-size errors.
- `moon -C cairoon test src/tests/backend/svg --target native -v`: 6
  black-box SVG surface tests passed from a nested external package, covering
  version helpers, raw C-int enums, no-output/unit/version APIs, filename
  construction with SVG marker readback, subtype errors, and finished-surface
  document-unit errors.
- `moon -C cairoon test src/tests/backend/recording --target native -v`: 5
  black-box Recording surface tests passed from a nested external package,
  covering bounded/unbounded extents, post-finish extents, raw content ints,
  replay through patterns, and subtype errors.
- `moon -C cairoon test src/tests/backend/tee --target native -v`: 4
  black-box Tee surface tests passed from a nested external package, covering
  fanout painting, retained targets, out-of-range index status, subtype errors,
  and index errors.
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
  callback allocation stress, and backend stream callback multi-seed fuzz.
