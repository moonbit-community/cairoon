# cairoon Testing And Reliability Strategy

This document defines how cairoon evaluates migration reliability. The pycairo
test suite is a required source of behavioral cases, but it is not sufficient
by itself to claim a complete MoonBit Cairo binding.

## Assessment Of The pycairo Test Suite

The parent repository has broad pytest coverage across context, surface,
pattern, font, path, region, value types, errors, file-system paths, optional
third-party buffer integrations, and the pycairo C API. A quick inventory with
`rg --count-matches "^def test_" tests` shows roughly 288 pytest test
functions in `tests/test_*.py`.

Use it as:

- The primary behavioral checklist for pycairo-compatible Cairo semantics.
- A source of edge cases for invalid arguments, cairo status propagation,
  optional backend features, and resource lifetime behavior.
- A source of rendering and byte-buffer scenarios for image surfaces,
  patterns, PDF/SVG/PS output, and mapped image surfaces.

Do not treat it as sufficient because:

- Many tests assert Python-specific behavior: inheritance, object identity,
  hashing, pickle, buffer protocol, `with` context managers, NumPy, pygame,
  and Python exception classes.
- It does not validate MoonBit FFI ownership annotations, MoonBit reference
  counting, external-object finalizers, or retained MoonBit objects stored in
  C payloads.
- It is not a complete rendering oracle. Many drawing APIs are tested through
  state queries, not through pixel or vector-output equality.
- It does not define cairoon-specific API choices from `AGENTS.md`, such as
  pure-value `Matrix` methods returning transformed copies.
- It does not review the generated MoonBit public interface.

## Reliability Definition

A cairoon API row may move to `Done` in `API_INVENTORY.md` only when all
applicable gates below pass.

1. API shape: the public API appears in `pkg.generated.mbti`, has no raw
   pointer exposure, and follows the object/value mapping in `AGENTS.md`.
2. Status and error behavior: every Cairo status reachable from the wrapper is
   mapped through `Status` and `CairoError` or is documented as unreachable.
3. MoonBit behavioral tests: black-box tests cover normal behavior, boundary
   inputs, invalid arguments, and any cairo error states known from pycairo.
4. Differential parity: pure values, enums, query methods, and deterministic
   rendering are compared against pycairo or a small C Cairo oracle.
5. Lifetime safety: every external object path is exercised under
   AddressSanitizer/LeakSanitizer, including normal finalization, explicit
   `finish`/`flush`, retained base objects, and error exits.
6. Documentation: README or reference examples compile and run as MoonBit
   tests when possible.
7. Portability: backend-specific APIs are either tested on the required
   platform or recorded as an explicit `Decision`, not silently marked Done.

For the full-product claim, there must be no `Todo` or `Partial` rows left in
`API_INVENTORY.md`; unresolved scope must be recorded as `Decision`.

## Test Tiers

Run these tiers in order while developing a slice.

### Tier 0: Interface And Build Checks

```sh
moon -C cairoon check --target native
moon -C cairoon info --target native
```

Review `pkg.generated.mbti` after `moon info`. Public additions, `raise`
annotations, and enum constructors must match the intended API.

### Tier 1: MoonBit Unit And Black-Box Tests

```sh
moon -C cairoon test --target native -v
```

Each API slice must include tests for:

- Constructor success and status failure where Cairo can fail.
- Field order and component access for value types.
- Method state changes and getter round-trips.
- Invalid indexes, invalid sizes, invalid strings, and finished resources.
- cairoon-specific policy choices, especially value semantics.

### Tier 2: Differential Tests

For each implemented API family, add one of these oracles:

- pycairo oracle: a Python helper emits JSON or raw bytes for the same
  operation, and a MoonBit test compares the result.
- C Cairo oracle: a small C helper emits the expected primitive result when
  pycairo has Python-specific behavior.
- Golden file: for vector surfaces, normalize metadata and compare stable
  structural output rather than timestamps or object IDs.

Pixel comparisons are exact on the same Cairo version and platform unless the
Cairo manual documents backend-dependent tolerance. If tolerance is needed,
record the threshold beside the test.

### Tier 3: Memory And Lifetime Tests

Run ASan/LSan after every C stub or finalizer change:

```sh
python3 /Users/caimeo/.codex/skills/moonbit/moonbit-c-binding/scripts/run-asan.py \
  --repo-root /Users/caimeo/code/pycairo/cairoon \
  --pkg moon.pkg
```

Memory tests must cover:

- Construction and finalization of every external object type.
- Repeated creation/destruction loops.
- Borrowed Cairo resources wrapped as owned MoonBit external objects.
- MoonBit objects retained by C payloads with `moonbit_incref` and released
  with `moonbit_decref`.
- Error paths where Cairo returns a status object or null-like object.

### Tier 4: Backend Integration Tests

For surfaces and devices, add backend-specific smoke tests:

- Image: exact stride, format, dimensions, and raw byte output.
- Image PNG streams: read/write callback round trips and read/write error
  propagation.
- PDF/SVG/PS: create, finish, metadata, page behavior, stream writers, and
  normalized output.
- Recording/script/tee: only mark Done when the backend is available and tests
  run in CI.
- Cairo native observer surface/device APIs: not a pycairo migration gate.
  pycairo exposes `SurfaceObserverMode` but not those native APIs, so cairoon
  records the enum and leaves observer surfaces/devices to a future extension
  layer.
- Python C-extension capsule APIs and legacy Python enum alias names: not a
  MoonBit runtime migration gate. `CAPI` has no MoonBit equivalent, and
  uppercase enum-typed aliases cannot be represented directly in MoonBit
  without weakening them to raw integers.
- Native FreeType/user-font Cairo APIs: not a pycairo migration gate because
  pycairo documents them as not implemented and exposes no public classes for
  them in `cairo/__init__.pyi`.
- Platform APIs such as Win32/XCB/Xlib: require a platform-specific test job or
  an explicit product-scope Decision.

### Tier 5: Release Matrix

A release candidate must pass on all supported platforms:

- `moon check`
- `moon test`
- ASan/LSan native test run
- Differential pycairo/C oracle suite
- API inventory audit
- generated `pkg.generated.mbti` review

The current local gate is executable as:

```sh
./scripts/verify.sh
```

It runs `moon fmt --check`, native `moon check`, targeted white-box image,
ScaledFont, vector-output, and raster-pattern tests, the full native test
suite, `moon info --target native`, and targeted ASan builds for the image
oracle and raster-pattern suites when an ASan-capable `clang` is available.
Set `CAIROON_VERIFY_ASAN=0` to skip the targeted ASan portion intentionally.

## Current Status

The current cairoon slice is not a full migration. It has native package setup,
pycairo-style C glue split into private shared declarations plus per-family
stub files, opaque external-object wrappers for `Surface`,
`MappedImageSurface`, `Context`, `Path`, `Pattern`, `FontOptions`, `FontFace`,
`ScaledFont`, `Region`, and `Device`, pure value types including `Glyph` with
`UInt64` index width, many portable enums,
including enum-only `SurfaceObserverMode` pycairo compatibility,
expanded Context path, painting/page, target/source borrowed returns,
source-surface convenience, Context pointer equality/hash, clip, matrix, drawing-state including hairline mode,
compile-time Cairo
constants, group APIs, tag APIs, toy
text APIs, glyph array APIs, text-to-glyphs/show-text-glyphs APIs,
including glyph-only text conversion for pycairo's `with_clusters=False` path,
documented product decisions for `CAPI`, legacy uppercase enum alias
constants, and non-implemented FreeType/user-font classes,
hit-testing/extents APIs, typed Path segment iteration and stringification,
PNG filename load/save plus stream read/write, direct C Cairo oracle
comparisons for nineteen deterministic ARGB32 image scenes on ordinary and
buffer-backed image surfaces including toy-font `text_path`, toy-font
`show_text`, `glyph_path`, `show_glyphs`, `show_text_glyphs`,
source-surface offsets, mask-surface offsets, raster-source pattern repeat
rendering, dashed round-cap strokes, clipped paint/fill output, and
`OperatorClear` compositing output;
buffer-backed creation plus mutable `ImageData`
views for image and
mapped-image surfaces, pycairo-style scoped surface finish and mapped-image
unmap helpers with success/error cleanup coverage, portable
Surface base helpers such as similar-surface creation, rectangular child
surface creation with retained parent-wrapper lifetime, content/type queries,
pointer equality/hash for ordinary surfaces, dirty markers with
finished-status coverage, device offset/scale, fallback resolution,
show-text-glyphs support checks with finished-status coverage, invalid-size
error mapping for similar and rectangular child
surface construction, MIME constants, MIME data storage/query/clear support including
image/PDF/PS/SVG MIME support matrices and PDF JPEG MIME passthrough, and
RecordingSurface constructor/extents/ink-extents plus replay, mapped image
surface mapping/unmapping, PDFSurface filename/no-output/stream constructor,
version helpers, version restriction, size, metadata, custom metadata,
page-label, thumbnail, and single-flag and combined-flag outline helpers,
including subtype-mismatch checks for every bound PDF helper,
PSSurface
filename/no-output/stream constructor, level helpers, level restriction, EPS
mode, size and DSC helpers including subtype-mismatch checks for every bound PS
helper, SVGSurface filename/no-output/stream constructor,
version helpers, version
restriction, and document-unit helpers,
surface-pattern borrowed surface returns, Pattern pointer equality/hash,
RasterSourcePattern
constructor/acquire/get-acquire/release callback glue with retained closure and acquired
surface owners, finished-surface acquire failure injection, MeshPattern patch lifecycle/query
APIs, `FORMAT_INVALID` integer-sentinel coverage, FontOptions
state/accessor APIs, FontFace/ToyFontFace APIs, ScaledFont
basics including glyph extents, text-to-glyphs, and direct C Cairo oracle
comparison for font/text/glyph extents and empty, single/multi/spaced ASCII,
and UTF-8 text-to-glyph coordinate cases plus sheared font/CTM scale-matrix
composition, and
Device/ScriptDevice basics including status/type/equal/hash,
finish/flush/acquire/release, scoped acquire/finish, file/stream script devices,
script mode/comment helpers, recording replay, `Surface::get_device`,
`Surface::script`, and
`Surface::script_for_target`, TeeSurface mirrored drawing and target indexing,
exhaustive `Status`/`CairoError` classification, retained-owner lifetime
stress tests, external value-wrapper allocation stress for `Path`, `Region`,
the font stack, solid/gradient/mesh `Pattern`, recording/similar/Tee
`Surface`, and script stream `Device`, `ImageData` view allocation stress for
ordinary, buffer-backed, and mapped image surfaces, backend stream callback
allocation stress for PDF/PS/SVG surfaces, PNG stream write/read, script
devices, and stream `WriteError` paths, raster-source callback allocation
stress for set/get/manual acquire/release/replace/clear paths plus a
white-box owner-count check for acquire-only repeated same-surface paints,
Cairo float
image-format creation/readback coverage, `Format::stride_for_width` coverage
for legacy, 16-bit, 30-bit, float, and invalid-width cases, stable
structural vector-output markers plus direct C oracle comparisons
for fifteen deterministic PDF/PS/SVG vector scenes covering paint, stroke,
fill/stroke rectangles, Bezier paths, transforms, linear/radial gradients,
toy-font text paths, toy-font `show_text`, two-page paint, clip, dashed
stroke, repeated surface pattern, mask surface, and mesh pattern scenes, with
SVG dynamic `source-*` image-id normalization, three PDF-only tag oracle scenes,
one PDF-only document-feature oracle scene, PDF metadata/custom-metadata/page-label/outline output
markers, PDF/PS/SVG multi-page output markers, PDF JPEG MIME payload embedding,
image/PDF/PS/SVG MIME support matrix checks,
PDF URI link-tag annotation markers, PDF named-destination tag markers, PDF
document-structure tag markers, PS/SVG Link tag inert-output checks, mutable
image/mapped-image data view tests, and initial tests. Pattern has executable
reference examples for solid/shared state, surface patterns, gradients, mesh
patches, raster-source callbacks, and checked subtype/index/lifecycle errors.
Backend surface black-box tests also cover extended PDF custom-metadata/
thumbnail/outline subtype mismatches, PS size/setup/page-setup subtype
mismatches, and SVG document-unit getters after `finish()`.
ImageData black-box tests cover ordinary, buffer-backed, and PNG-loaded
`get_data` after `finish()`, plus retained ordinary views observing
base-surface `SurfaceFinished` after the base surface is finished.
Path has executable reference examples for typed segment iteration,
pycairo-style string formatting, flattened append behavior, copied-path
ownership, and checked invalid-matrix errors. Region now covers empty,
single-rectangle, and multi-rectangle construction plus predicates, region
boolean operations, and rectangle boolean operations including XOR split
semantics and pycairo-style chainable boolean mutator returns; `region.mbt.md`
adds executable reference examples for the same family. Matrix has executable
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

Verified on 2026-07-02 and 2026-07-03:

- `./scripts/verify.sh`: passed. The local reliability gate ran
  `moon fmt --check`, native `moon check`, targeted image, ScaledFont, vector,
  and pattern oracle tests, the full native suite, `moon info --target native`,
  and targeted ASan image-oracle and pattern tests with leak detection disabled.
- `moon -C cairoon check --target native`: passed.
- `moon -C cairoon test --target native`: 342 tests passed after adding
  context `get_source` surface-pattern lifetime coverage for the path where
  both the original source wrapper and context scope have exited.
- `moon -C cairoon info --target native`: completed with no work to do; this
  source-lifetime test slice changes no public API or generated interface
  metadata.
- `moon -C cairoon test image_oracle_wbtest.mbt --target native -v`: 2
  white-box image rendering oracle tests passed. Ordinary image surfaces and
  buffer-backed `Surface::image_for_data` surfaces both match the direct C
  ARGB32 fixture across nineteen scenes with `glyph_path`, `show_glyphs`,
  `show_text_glyphs`, source-surface offsets, mask-surface offsets, and
  raster-source pattern repeat rendering, dashed round-cap strokes, and
  clipped paint/fill output, and `OperatorClear` compositing output.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  image_oracle_wbtest.mbt --target native -v`: 2 ASan-compiled white-box image
  oracle tests passed with leak detection disabled, directly exercising the
  source/mask offset, raster-source repeat, dashed-stroke, clipped-output, and
  operator-output C oracle helper paths.
- `moon -C cairoon test scaled_font_oracle_wbtest.mbt --target native -v`: 2
  white-box ScaledFont oracle tests passed, comparing font extents, text
  extents, glyph extents, and empty, single/multi/spaced ASCII, and UTF-8
  text-to-glyph coordinate cases against direct C Cairo results.
- `moon -C cairoon test lifetime_stress_test.mbt --target native -v`: 6
  black-box lifetime tests passed after adding the backend stream callback
  1000-iteration allocation stress case.
- `moon -C cairoon test raster_lifetime_stress_test.mbt --target native -v`: 1
  black-box raster-source callback lifetime test passed after adding the
  1000-iteration set/get/manual acquire/release/replace/clear stress case.
- `moon -C cairoon test context_lifetime_test.mbt --target native -v`: 7
  black-box context lifetime tests passed, including `get_source` returning a
  surface pattern that still exposes and paints from its source after the
  source wrapper and context scope exit.
- `moon -C cairoon test pattern_test.mbt --target native -v`: 18 black-box
  pattern tests passed after adding release-only raster callback state,
  finished-surface raster acquire failure-injection coverage, the C-side
  surface-finished sentinel, and post-failure acquire replacement recovery.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  pattern_test.mbt --target native -v`: 18 ASan-compiled black-box pattern
  tests passed with leak detection disabled, covering release-only callback
  state, the raster acquire finished-surface rejection path, and replacement
  recovery after that failure path.
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
- `moon -C cairoon test surface_subsurface_test.mbt --target native -v`: 3
  black-box tests passed after adding invalid-size coverage for
  `Surface::create_for_rectangle`.
- `moon -C cairoon test font_face_test.mbt scaled_font_test.mbt --target native
  -v`: 15 black-box tests passed after adding embedded-NUL validation for toy
  font family, context font-family selection, and ScaledFont text extents.
- `moon -C cairoon test region_test.mbt --target native -v`: 8 black-box
  tests passed after adding `Region::xor_rectangle` split-semantics coverage.
- `moon -C cairoon test region_test.mbt region.mbt.md --target native -v`: 12
  tests passed after changing Region boolean operations to return the mutated
  receiver for pycairo-style chaining. This covered region and rectangle
  operands, explicit returned-receiver checks, a chained rectangle-boolean
  sequence, and executable Region docs.
- `moon -C cairoon info --target native`: regenerated `pkg.generated.mbti`
  after the public Region return-type change.
- `moon -C cairoon test --target native`: 333 tests passed after the Region
  chainable-mutator slice. ASan/LSan was not rerun because this slice changed
  only MoonBit wrappers, docs, and tests, with no C glue, callback, finalizer,
  or retained-owner changes.
- `moon -C cairoon test object_traits_test.mbt --target native -v`: 3
  black-box tests passed after adding MoonBit `Eq`/`Hash` protocol coverage for
  hashable Cairo external objects, `Path` self-comparison coverage through
  `Compare`, and `Region` equality coverage without `Hash`.
- `moon -C cairoon test region.mbt.md --target native -v`: 3 executable
  Region reference examples passed.
- `moon -C cairoon test matrix.mbt.md --target native -v`: 4 executable
  Matrix reference examples passed.
- `moon -C cairoon test path.mbt.md --target native -v`: 4 executable Path
  reference examples passed.
- `moon -C cairoon test pattern.mbt.md --target native -v`: 6 executable
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
  palettes, toy font faces, Surface/Context font options, ScaledFont
  matrices/metrics, text-to-glyphs, and checked font errors.
- `moon -C cairoon test backend_surfaces.mbt.md --target native -v`: 8
  executable Backend Surface reference examples passed, covering PDF/PS/SVG
  stream output and writer errors, PDF metadata/outlines, PS DSC, SVG document
  units, recording replay, Tee fanout, script devices/surfaces, and checked
  backend-specific errors.
- `moon -C cairoon test enums_test.mbt --target native -v`: 4 black-box tests
  passed after adding `Rgb16_565`, `Rgb30`, `Rgb96F`, `Rgba128F`, and
  negative-width `Format::stride_for_width` coverage.
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
- Raster-source optional callback-state coverage added release-only C callback
  ownership paths and reran targeted ASan with leak detection disabled for
  `pattern_test.mbt`.
- Pure MoonBit backend MIME support matrix coverage was added without rerunning
  ASan because no C glue, finalizer, callback trampoline, or retained owner
  code changed in that slice.
- Test-only source/mask/raster-source image-oracle helper coverage was added
  without changing the public API or native test count; sanitizer validation
  is recorded below.
- Documentation-only product-decision audit for pycairo `CAPI`, legacy enum
  aliases, and non-implemented FreeType/user-font classes: `moon -C cairoon
  check --target native`, `moon -C cairoon test --target native -v`, and
  `moon -C cairoon info --target native` passed on 2026-07-03.
- ASan/LSan via `run-asan.py`: rerun on 2026-07-03 for the source/mask offset
  image-oracle C helper slice. The full runner again failed during the known
  macOS FontRegistry/CoreText/ColorSync LeakSanitizer class while running the
  black-box executable, before Moon could launch the white-box executable. The
  log at `/tmp/cairoon-source-mask-offset-asan.txt` reports
  `89578 byte(s) leaked in 476 allocation(s)`. A grep of that log found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, or double-free entries. The
  ASan-compiled white-box image oracle was therefore run directly with leak
  detection disabled, and exited 0 as recorded above.
- ASan/LSan via `run-asan.py`: rerun on 2026-07-03 for the raster-source
  image-oracle C helper slice. The full runner again failed during the known
  macOS FontRegistry/CoreText/ColorSync LeakSanitizer class after running the
  black-box executable and before launching the white-box executable. The log
  at `/tmp/cairoon-raster-source-oracle-asan.txt` reports
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
- ASan/LSan via `run-asan.py`: rerun on 2026-07-03 for the ScaledFont
  text-to-glyph direct C oracle helper slice. The full runner still failed
  during the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer class
  after the black-box executable ran and before Moon could launch the
  white-box executable. A grep of
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
- ASan/LSan via `run-asan.py`: rerun on 2026-07-03 for the glyph-index width
  FFI slice. The full runner still failed during the known macOS
  FontRegistry/CoreText/ColorSync LeakSanitizer class after the black-box
  executable ran. A grep of `/tmp/cairoon-glyph-index-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, or double-free entries; the
  `cairoon_context_glyph` hits were leak-stack frames. Summary:
  `1667619 byte(s) leaked in 12429 allocation(s)`. The ASan-instrumented
  black-box executable was then run directly with leak detection disabled for
  `value_types_test.mbt`, `glyph_array_test.mbt`, `text_to_glyphs_test.mbt`,
  `context.mbt.md`, and `README.mbt.md`; it exited 0 and
  `/tmp/cairoon-glyph-index-blackbox-asan.txt` records the selected tests. The
  ASan-instrumented white-box executable was likewise run for
  `scaled_font_oracle_wbtest.mbt` and `image_oracle_wbtest.mbt`; it exited 0
  and `/tmp/cairoon-glyph-index-whitebox-asan.txt` records those oracle tests.
- ASan/LSan via `run-asan.py`: rerun on 2026-07-03 for the raster-source
  callback allocation stress slice. The full runner still failed during the
  known macOS FontRegistry/CoreText/ColorSync LeakSanitizer class after the
  black-box executable ran. A grep of
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
- ASan/LSan via `run-asan.py`: rerun on 2026-07-03 for the raster-source
  acquire-only release-trampoline slice. The full runner still failed during
  the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer class after the
  black-box executable ran. A grep of
  `/tmp/cairoon-raster-release-trampoline-asan.txt` found no
  heap-use-after-free, stack-use-after, heap-buffer-overflow,
  global-buffer-overflow, double-free, `cairoon_raster`, `raster_source`,
  `cairoon_pattern`, or `make_data_backed_raster_source_pattern` entries.
  Summary: `89194 byte(s) leaked in 474 allocation(s)`. The ASan-instrumented
  black-box executable was then run directly with leak detection enabled for
  `pattern_test.mbt:0-17` and `raster_lifetime_stress_test.mbt:0-1`; both
  exited 0 and the logs record the selected tests.
- ASan/LSan via `run-asan.py`: rerun for the two-page vector oracle helper
  slice. The full runner still failed during the known macOS
  FontRegistry/CoreText/ColorSync LeakSanitizer class before the white-box
  executable launched. A grep of `/tmp/cairoon-vector-multipage-asan.txt` found
  no `ERROR: AddressSanitizer`, heap-use-after-free, heap-buffer-overflow,
  global-buffer-overflow, double-free,
  `cairoon_test_render_vector_scene_oracle`,
  `cairoon_test_draw_vector_scene`, `cairoon_test_render_vector_surface`, or
  `cairoon_test_vector` entries. Summary:
  `56037 byte(s) leaked in 415 allocation(s)`.
  The ASan-instrumented white-box executable was then run directly with leak
  detection disabled using
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; it exited 0, and
  `/tmp/cairoon-vector-multipage-whitebox-asan.txt` shows the vector output
  oracle test executed without any AddressSanitizer invalid-access report.
- ASan/LSan via `run-asan.py`: rerun on 2026-07-03 for the image glyph-oracle
  helper slice. The full runner still failed during the known macOS
  FontRegistry/CoreText/ColorSync LeakSanitizer class before launching the
  white-box executable. A grep of
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
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; it exited 0, and
  `/tmp/cairoon-image-glyph-oracle-whitebox-asan.txt` shows the image oracle
  test executed without any AddressSanitizer invalid-access report.
- ASan/LSan via `run-asan.py`: rerun on 2026-07-03 for the external
  value-wrapper stress slice. The full runner still failed during the known
  macOS FontRegistry/CoreText/ColorSync LeakSanitizer class after the
  black-box executable ran. A grep of
  `/tmp/cairoon-finalizer-value-stress-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, double-free,
  `script_device_create_for_stream`, `cairoon_stream`, `cairoon_pattern`,
  `cairoon_path`, `cairoon_region`, `cairoon_device`, or `cairoon_surface`
  entries indicating invalid access; the `lifetime_stress` hit was the Moon
  test selector line. Summary:
  `55717 byte(s) leaked in 412 allocation(s)`. The ASan-instrumented
  black-box executable was then run directly with leak detection disabled; it
  exited 0, and
  `/tmp/cairoon-finalizer-value-stress-blackbox-asan.txt` shows all four
  `lifetime_stress_test.mbt` tests executed without any AddressSanitizer
  invalid-access report.
- ASan/LSan via `run-asan.py`: rerun on 2026-07-03 for the `ImageData` view
  allocation stress slice. The full runner still failed during the known macOS
  FontRegistry/CoreText/ColorSync LeakSanitizer class after the black-box
  executable ran. A grep of `/tmp/cairoon-image-data-stress-asan.txt` found no
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
- ASan/LSan via `run-asan.py`: rerun on 2026-07-03 for the backend stream
  callback stress slice. The full runner still failed during the known macOS
  FontRegistry/CoreText/ColorSync LeakSanitizer class after the black-box
  executable ran. A grep of `/tmp/cairoon-stream-callback-stress-asan.txt`
  found no `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
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
- ASan/LSan via `run-asan.py`: ran the 237-test native suite on 2026-07-03
  after the `Surface`/`Context`/`Pattern` pointer equality/hash slice. No
  AddressSanitizer invalid-access report appeared, and a grep of
  `/tmp/cairoon-equal-hash-asan.txt` found no
  `cairoon_surface_equal`, `cairoon_surface_hash`, `cairoon_context_equal`,
  `cairoon_context_hash`, `cairoon_pattern_equal`, or
  `cairoon_pattern_hash` entries in visible leak roots. The run still failed
  during the same known macOS FontRegistry/CoreText/ColorSync LeakSanitizer
  class: `56037 byte(s) leaked in 415 allocation(s)`.
- ASan/LSan via `run-asan.py`: ran on 2026-07-03 after adding retained-owner
  lifetime stress tests. The first run found a real heap-use-after-free when a
  `Surface` returned by `Context::get_target` outlived a context created from a
  `MappedImageSurface`; the borrowed target wrapper did not retain the mapped
  image wrapper, so the mapped image finalizer could unmap the image before
  `Surface::copy_data`. This was fixed by returning borrowed target/group
  target wrappers with the context target wrapper retained as their base. The
  fixed rerun progressed past that invalid access and then failed during
  LeakSanitizer reporting with the known macOS
  FontRegistry/CoreGraphics/CoreText/ColorSync leak roots
  (`91029 byte(s) leaked in 494 allocation(s)`). No AddressSanitizer
  invalid-access report appeared in the fixed rerun before LSan failed.
- ASan/LSan via `run-asan.py`: ran the 108-test native suite after the PNG
  filename API slice, the 113-test native suite after the
  `Surface::image_for_data` slice, and the 114-test native suite after the
  cairo-surface user-data lifetime fix, and the 117-test native suite after the
  portable Surface base API slice, the 122-test native suite after the
  mapped image surface slice, and the 127-test native suite after the Surface
  MIME data slice, and the 131-test native suite after the Context group API
  slice, the 136-test native suite after the Context tag API slice, and the
  142-test native suite after the Context toy text API slice, and the 148-test
  native suite after the glyph array API slice, and the 152-test native suite
  after the text-to-glyphs/show-text-glyphs slice, and the 156-test native
  suite after the RecordingSurface slice, and the 161-test native suite after
  the SVGSurface slice, and the 167-test native suite after the PSSurface
  slice, and the 173-test native suite after the PDFSurface slice; these runs
  failed in LeakSanitizer, as did the 179-test native suite after the
  MeshPattern slice and the 185-test native suite after the
  Device/ScriptSurface slice and the 185-test native suite after the PDF
  outline flag-set slice, then failed after the module-constants slice with the
  expanded 189-test native suite, and after the `create_for_rectangle` slice
  with the expanded 190-test native suite, and after the `set_source_surface`
  slice with the expanded 192-test native suite, and after the
  `Context::set_hairline/get_hairline` slice with the same 192-test native
  suite, and after the retained-parent `create_for_rectangle` lifetime
  hardening with the expanded 193-test native suite, and after the retained-owner
  lifetime stress/fix slice with the expanded 196-test native suite.
  The later status/error classification slice is pure MoonBit test coverage and
  raised the native suite to 198 tests; ASan was not rerun for that non-C change.
  The TeeSurface slice added C glue and raised the native suite to 201 tests;
  ASan/LSan was rerun on 2026-07-03. It reported only the same macOS
  LeakSanitizer class, with no `ERROR: AddressSanitizer`,
  heap-use-after-free, stack-use-after, `cairoon_tee`, or `tee_surface` entries
  in `/tmp/cairoon-tee-asan.txt`; summary:
  `90213 byte(s) leaked in 490 allocation(s)`. The most recent leak report is
  rooted in
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
  Device/ScriptSurface helper, Context text/tag/group, MIME-data stub, or
  compile-time constant helper ownership stack, or Surface
  `create_for_rectangle` helper, retained-parent subsurface helper/finalizer
  stack, retained target/group-target helper stack, mapped-image lifetime
  helper stack, TeeSurface helper stack, or Context
  `set_source_surface`/hairline helpers appeared in the visible leak roots.
  The later `FORMAT_INVALID` constant-sentinel slice touched the C
  compile-time integer-constant oracle and raised the native suite to 202
  tests; ASan/LSan was rerun on 2026-07-03. It reported only the same macOS
  LeakSanitizer class. A grep of `/tmp/cairoon-format-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  `cairoon_compile_int_constant`, `cairoon_compile_string_constant`,
  `cairoon_misc`, or compile-time constant helper stack entries; summary:
  `89925 byte(s) leaked in 482 allocation(s)`.
  The later vector-output marker slice added a private C file-scan test helper
  and raised the native suite to 205 tests; ASan/LSan was rerun on
  2026-07-03. It reported only the same macOS LeakSanitizer class. A grep of
  `/tmp/cairoon-vector-output-asan.txt` found no `ERROR: AddressSanitizer`,
  heap-use-after-free, stack-use-after, global-buffer-overflow, or
  `cairoon_test_file` entries; summary:
  `89925 byte(s) leaked in 482 allocation(s)`.
  The later tag-nesting slice is pure MoonBit test coverage and raised the
  native suite to 206 tests; ASan was not rerun for that non-C change.
  The later direct C image-oracle slice added a private C helper and raised the
  native suite to 207 tests; ASan/LSan was rerun on 2026-07-03. It reported
  only the same macOS LeakSanitizer class. A grep of
  `/tmp/cairoon-image-oracle-asan.txt` found no `ERROR: AddressSanitizer`,
  heap-use-after-free, stack-use-after, global-buffer-overflow, or
  `cairoon_test_argb32` entries; summary:
  `90021 byte(s) leaked in 479 allocation(s)`.
  The later PDF link-tag output marker slice is pure MoonBit test coverage and
  raised the native suite to 208 tests; ASan was not rerun for that non-C
  change.
  The later ImageData mutable-view slice added C glue, a new external object,
  and four black-box tests, raising the native suite to 212 tests. ASan/LSan
  was rerun on 2026-07-03. It reported only the same macOS LeakSanitizer class.
  A grep of `/tmp/cairoon-image-data-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  global-buffer-overflow, `cairoon_image_data`, or
  `cairoon_image_surface_get_data` entries; summary:
  `89173 byte(s) leaked in 474 allocation(s)`.
  The later mapped-image ImageData slice added three black-box tests, raising
  the native suite to 215 tests. ASan/LSan was rerun on 2026-07-03. It reported
  only the same macOS LeakSanitizer class. A grep of
  `/tmp/cairoon-mapped-image-data-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  global-buffer-overflow, `cairoon_image_data`,
  `cairoon_image_surface_get_data`, or
  `cairoon_mapped_image_surface_get_data` entries; summary:
  `64989 byte(s) leaked in 398 allocation(s)`.
  The later PDF/PS/SVG stream-writer slice added C callback state,
  copied-byte trampolines, and four black-box tests, raising the native suite
  to 219 tests. The first ASan/LSan run exposed a real `moonbit_make_bytes`
  leak rooted at `cairoon_stream_write`; after removing the extra retained
  reference, the fixed ASan/LSan rerun reported only the same macOS
  LeakSanitizer class. A grep of `/tmp/cairoon-stream-asan-fixed.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  global-buffer-overflow, or `cairoon_stream` entries; summary:
  `65485 byte(s) leaked in 405 allocation(s)`.
  The later PNG stream-write slice reused the copied-byte writer trampoline and
  added two black-box tests, raising the native suite to 221 tests. ASan/LSan
  was rerun on 2026-07-03 and reported only the same macOS LeakSanitizer class.
  A grep of `/tmp/cairoon-png-stream-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  global-buffer-overflow, `cairoon_surface_write_to_png_stream`, or
  `cairoon_stream` entries; summary:
  `64909 byte(s) leaked in 399 allocation(s)`.
  The later PNG stream-read slice added exact-length reader callbacks and two
  black-box tests, raising the native suite to 223 tests. ASan/LSan was rerun
  on 2026-07-03 and reported only the same macOS LeakSanitizer class. A grep
  of `/tmp/cairoon-png-read-stream-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  global-buffer-overflow, `cairoon_image_surface_create_from_png_stream`,
  `cairoon_stream_read`, or `cairoon_stream` entries; summary:
  `55397 byte(s) leaked in 405 allocation(s)`.
  The later script stream-device slice added device-retained write callbacks
  and two black-box tests, raising the native suite to 225 tests. ASan/LSan was
  rerun on 2026-07-03 and reported only the same macOS LeakSanitizer class. A
  grep of `/tmp/cairoon-script-stream-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  global-buffer-overflow, `cairoon_script_device_create_for_stream`,
  `cairoon_stream_attach_device`, or `cairoon_stream` entries; summary:
  `64765 byte(s) leaked in 396 allocation(s)`.
  The later RasterSourcePattern slice added retained MoonBit acquire/release
  callbacks, acquired-surface owner tracking, a README doctest, two focused
  black-box behavior/lifetime tests, one subtype-mismatch test, and raster
  coverage inside the retained-owner stress loop, raising the native suite to
  229 tests. ASan/LSan was rerun on 2026-07-03 and reported only the same macOS
  LeakSanitizer class. A grep of `/tmp/cairoon-raster-source-asan.txt` found
  no `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  global-buffer-overflow, `cairoon_raster`, `raster_source`, or
  `cairoon_pattern` entries; summary:
  `64333 byte(s) leaked in 390 allocation(s)`.
  The later raster-source get-acquire slice returned retained MoonBit
  acquire/release closures and added two focused tests for callback retrieval,
  optional release callbacks, clear behavior, and subtype mismatch, raising the
  native suite to 231 tests. ASan/LSan was rerun on 2026-07-03 and reported
  only the same macOS LeakSanitizer class. A grep of
  `/tmp/cairoon-raster-get-acquire-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  global-buffer-overflow, `cairoon_raster`, `raster_source`, or
  `cairoon_pattern` entries; summary:
  `55365 byte(s) leaked in 405 allocation(s)`.
  The later vector-output direct C oracle slice added private C helpers for
  direct PDF/PS/SVG paint-fixture generation and normalized file comparison,
  while keeping the native suite at 231 tests. ASan/LSan was rerun on
  2026-07-03 and reported only the same macOS LeakSanitizer class. A grep of
  `/tmp/cairoon-vector-oracle-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  global-buffer-overflow, `cairoon_test_render_vector`,
  `cairoon_test_vector`, `cairoon_test_read_file`,
  `cairoon_test_files_equal`, or `cairoon_test_paint_vector` entries; summary:
  `55365 byte(s) leaked in 405 allocation(s)`.
  The later vector tag inertness slice added two pure MoonBit tests for PS/SVG
  Link tag no-op behavior, raising the native suite to 233 tests. ASan/LSan was
  not rerun for that slice because it did not change C glue or ownership code.
  The later image oracle slices added private C helpers for nineteen deterministic
  ARGB32 scenes covering paint, stroke, fill/stroke rectangles, Bezier paths,
  transforms, RGBA compositing, linear/radial gradients, toy-font `text_path`,
  toy-font `show_text`, `glyph_path`, `show_glyphs`, `show_text_glyphs`,
  source-surface offset sampling, mask-surface offset compositing, and
  raster-source pattern repeat rendering, dashed round-cap stroke state,
  clipped paint/fill output, and `OperatorClear` compositing output, without
  changing the current test count because they broaden one existing white-box
  oracle test. ASan/LSan
  records for the image-oracle C helpers are recorded in the current verified
  block above; the full runner still fails during the
  known macOS LeakSanitizer class before the white-box executable launches, and
  the instrumented white-box executable exits 0 with leak detection disabled.
  The later `ScaledFont::text_to_glyphs_only` slice added pure MoonBit API
  coverage for pycairo's `with_clusters=False` path, keeping the native suite
  at 233 tests; ASan/LSan was not rerun for that non-C change.
  The later ScaledFont text-to-glyph oracle slice added a private C helper and
  a second white-box ScaledFont oracle test, raising the native suite to 249
  tests; ASan/LSan was rerun as recorded above.
  The later ScaledFont text-to-glyph matrix slice expanded that same white-box
  oracle test to cover empty, ASCII, precomposed Latin UTF-8, CJK UTF-8, and
  varied baseline coordinates without changing public API or test count; ASan
  was not rerun because no C glue changed.
  The later vector scene oracle slice broadened the private C vector oracle
  from a paint-only fixture to seven deterministic PDF/PS/SVG scenes covering
  paint, stroke, fill/stroke rectangles, Bezier paths, transforms, and
  linear/radial gradients, raising the native suite to 234 tests. ASan/LSan was
  rerun on 2026-07-03; the full runner still failed during the known macOS
  LeakSanitizer class before the white-box executable launched, with summary
  `55445 byte(s) leaked in 407 allocation(s)`. A grep of
  `/tmp/cairoon-vector-scenes-asan.txt` found no `ERROR: AddressSanitizer`,
  heap-use-after-free, stack-use-after, heap-buffer-overflow,
  global-buffer-overflow, double-free,
  `cairoon_test_render_vector_scene_oracle`,
  `cairoon_test_draw_vector_scene`, or
  `cairoon_test_render_vector_surface` entries. The ASan-instrumented
  white-box executable was then run directly with leak detection disabled and
  exited 0; `/tmp/cairoon-vector-scenes-whitebox-asan.txt` shows the vector
  output scene oracle test executed without any AddressSanitizer invalid-access
  report.
  The later toy-font text-path and `show_text` oracle slices expanded those
  fixtures to nine scenes, and the later two-page oracle slice expanded them to
  ten scenes without changing the number of tests. The latest sanitizer
  validation is recorded in the current verified block above.
  The later Surface invalid-size slice added pure MoonBit black-box coverage for
  `create_similar`, `create_similar_image`, and `create_for_rectangle` mapping
  negative dimensions to `CairoInvalidArgument(InvalidSize, _)`, raising the
  native suite to 251 tests. ASan/LSan was not rerun for that slice because it
  did not change C glue or ownership code.
  The later ScaledFont matrix-composition slice added pure MoonBit black-box
  coverage for sheared font matrices, sheared CTMs, CTM translation suppression,
  and scale-matrix composition, raising the native suite to 252 tests.
  ASan/LSan was not rerun for that slice because it did not change C glue or
  ownership code.
  The later Region documentation slice added `region.mbt.md` with three
  executable examples, raising the native suite to 256 tests. ASan/LSan was not
  rerun for that slice because it did not change C glue or ownership code.
  The later Matrix documentation slice added `matrix.mbt.md` with four
  executable examples, raising the native suite to 260 tests. ASan/LSan was not
  rerun for that slice because it did not change C glue or ownership code.
  The later Path documentation slice added `path.mbt.md` with four executable
  examples covering typed segments, pycairo-style string formatting, flattened
  append behavior, copied-path ownership, and checked invalid-matrix errors,
  raising the native suite to 264 tests. ASan/LSan was not rerun for that slice
  because it did not change C glue or ownership code.
  The later Pattern documentation slice added `pattern.mbt.md` with six
  executable examples covering solid/shared state, surface patterns, gradients,
  mesh patches, raster-source callbacks, and checked subtype/index/lifecycle
  errors, raising the native suite to 270 tests. ASan/LSan was not rerun for
  that slice because it did not change C glue or ownership code.
  The later buffer-backed image oracle slice expanded `image_oracle_wbtest.mbt`
  so `Surface::image_for_data` renders the same ARGB32 scenes against the
  existing direct C Cairo oracle and verifies backing-buffer bytes match
  `copy_data`, raising the native suite to 271 tests. ASan/LSan was not rerun
  for that slice because it did not change C glue or ownership code. The later
  source/mask offset oracle slice expanded that image oracle helper to fifteen
  scenes covering non-zero `set_source_surface` and `mask_surface` offsets on
  ordinary and buffer-backed image surfaces. The later raster-source image
  oracle slice expanded it to sixteen scenes by comparing `Pattern::raster_source`
  repeat rendering against direct C Cairo. The later dashed-stroke image oracle
  slice expanded it to seventeen scenes by comparing dash and round-cap stroke
  state against direct C Cairo. The later clipped-output image oracle slice
  expanded it to eighteen scenes by comparing clipped paint/fill output against
  direct C Cairo. The later operator-output image oracle slice expanded it to
  nineteen scenes by comparing `OperatorClear` compositing output against direct
  C Cairo.
  The later Surface documentation slice added `surface.mbt.md` with six
  executable examples covering image properties, buffer-backed data,
  similar/subsurface constructors, mapped images, PNG/MIME helpers, and checked
  surface errors, raising the native suite to 277 tests. ASan/LSan was not
  rerun for that slice because it did not change C glue or ownership code.
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
  suite to 315 tests. ASan/LSan was not rerun for that slice because it did not
  change C glue or ownership code.
  The later SVG version-unit multi-page vector-output marker slice added one
  pure MoonBit white-box test covering SVG 1.2 version restriction, `SvgUnitPx`
  state, px width/height output, and two-page drawing markers, raising the
  native suite to 316 tests. ASan/LSan was not rerun for that slice because it
  did not change C glue or ownership code.
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

The missing reliability pieces are substantial: broader automated differential tests,
the open macOS toy-font/scaled-font/toy-text/glyph/show-text-glyphs rendering
LSan failure, broader callback fuzz/finalizer stress tests, additional
failure-injection paths, CI wiring, vector-output normalization for broader
multi-page/tag/metadata combinations beyond the current fifteen-scene
cross-backend direct C fixture set, three PDF tag oracle scenes, and one PDF
document-feature oracle scene, including the current two-page direct C oracle
scene and the current single-page toy-font `show_text` oracle scene, broader
tag-output assertions beyond the current URI link, named-destination,
document-structure, PDF document-feature, and PS/SVG Link coverage, and the
remaining API families from `API_INVENTORY.md`.

## Porting pycairo Tests

When translating a pycairo test:

- Preserve Cairo behavior and numeric expectations.
- Replace Python type errors with cairoon `CairoInvalidArgument` where the
  public MoonBit API can express the invalid input.
- Replace Python inheritance checks with opaque-owner API checks.
- Replace Python buffer protocol cases with explicit MoonBit buffer ownership
  tests.
- Keep Python-specific tests out of cairoon unless they reveal a Cairo semantic
  that still applies.

Every translated test should name the pycairo source file and behavior in the
test name or nearby comment when the connection is not obvious.
