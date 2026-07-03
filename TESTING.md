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

## Current Status

The current cairoon slice is not a full migration. It has native package setup,
pycairo-style C glue split into private shared declarations plus per-family
stub files, opaque external-object wrappers for `Surface`,
`MappedImageSurface`, `Context`, `Path`, `Pattern`, `FontOptions`, `FontFace`,
`ScaledFont`, `Region`, and `Device`, pure value types, many portable enums,
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
comparisons for fifteen deterministic ARGB32 image scenes on ordinary and
buffer-backed image surfaces including toy-font `text_path`, toy-font
`show_text`, `glyph_path`, `show_glyphs`, `show_text_glyphs`,
source-surface offsets, and mask-surface offsets, and
buffer-backed creation plus mutable `ImageData`
views for image and
mapped-image surfaces, portable
Surface base helpers such as similar-surface creation, rectangular child
surface creation with retained parent-wrapper lifetime, content/type queries,
pointer equality/hash for ordinary surfaces, dirty markers, device offset/scale, fallback resolution, show-text-glyphs
support checks, invalid-size error mapping for similar and rectangular child
surface construction, MIME constants, MIME data storage/query/clear support including
PDF JPEG MIME passthrough, and
RecordingSurface constructor/extents/ink-extents plus replay, mapped image
surface mapping/unmapping, PDFSurface filename/no-output/stream constructor,
version helpers, version restriction, size, metadata, custom metadata,
page-label, thumbnail, and single-flag and combined-flag outline helpers,
PSSurface
filename/no-output/stream constructor, level helpers, level restriction, EPS
mode, size and DSC helpers, SVGSurface filename/no-output/stream constructor,
version helpers, version
restriction, and document-unit helpers,
surface-pattern borrowed surface returns, Pattern pointer equality/hash,
RasterSourcePattern
constructor/acquire/get-acquire/release callback glue with retained closure and acquired
surface owners, MeshPattern patch lifecycle/query
APIs, `FORMAT_INVALID` integer-sentinel coverage, FontOptions
state/accessor APIs, FontFace/ToyFontFace APIs, ScaledFont
basics including glyph extents, text-to-glyphs, and direct C Cairo oracle
comparison for font/text/glyph extents and empty/ASCII/UTF-8 text-to-glyph
coordinate cases plus sheared font/CTM scale-matrix composition, and
Device/ScriptDevice basics including status/type/equal/hash,
finish/flush/acquire/release, scoped acquire, file/stream script devices,
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
stress for set/get/manual acquire/release/replace/clear paths, stable
structural vector-output markers plus direct C oracle comparisons
for ten deterministic PDF/PS/SVG vector scenes covering paint, stroke,
fill/stroke rectangles, Bezier paths, transforms, linear/radial gradients,
toy-font text paths, toy-font `show_text`, and a two-page paint scene, PDF metadata/custom-metadata/page-label/outline output
markers, PDF/PS/SVG multi-page output markers, PDF JPEG MIME payload embedding,
PDF URI link-tag annotation markers, PDF named-destination tag markers, PDF
document-structure tag markers, PS/SVG Link tag inert-output checks, mutable
image/mapped-image data view tests, and initial tests. Pattern has executable
reference examples for solid/shared state, surface patterns, gradients, mesh
patches, raster-source callbacks, and checked subtype/index/lifecycle errors.
Path has executable reference examples for typed segment iteration,
pycairo-style string formatting, flattened append behavior, copied-path
ownership, and checked invalid-matrix errors. Region now covers empty,
single-rectangle, and multi-rectangle construction plus predicates, region
boolean operations, and rectangle boolean operations including XOR split
semantics; `region.mbt.md` adds executable reference examples for the same
family. Matrix has executable reference examples for component access,
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

- `moon -C cairoon check --target native`: passed.
- `moon -C cairoon test image_oracle_wbtest.mbt --target native -v`: 2
  white-box image rendering oracle tests passed. Ordinary image surfaces and
  buffer-backed `Surface::image_for_data` surfaces both match the direct C
  ARGB32 fixture across fifteen scenes with `glyph_path`, `show_glyphs`,
  `show_text_glyphs`, source-surface offsets, and mask-surface offsets.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  image_oracle_wbtest.mbt --target native -v`: 2 ASan-compiled white-box image
  oracle tests passed with leak detection disabled, directly exercising the
  source/mask offset C oracle helper paths.
- `moon -C cairoon test scaled_font_oracle_wbtest.mbt --target native -v`: 2
  white-box ScaledFont oracle tests passed, comparing font extents, text
  extents, glyph extents, and empty/ASCII/UTF-8 text-to-glyph coordinate cases
  against direct C Cairo results.
- `moon -C cairoon test lifetime_stress_test.mbt --target native -v`: 6
  black-box lifetime tests passed after adding the backend stream callback
  1000-iteration allocation stress case.
- `moon -C cairoon test raster_lifetime_stress_test.mbt --target native -v`: 1
  black-box raster-source callback lifetime test passed after adding the
  1000-iteration set/get/manual acquire/release/replace/clear stress case.
- `moon -C cairoon test vector_output_wbtest.mbt --target native -v`: 15
  white-box tests passed after adding PDF named-destination and
  document-structure tag output marker checks alongside metadata, URI
  link-tag, MIME-output, page structure, and direct C vector oracle checks.
- `moon -C cairoon test surface_context_test.mbt context_lifetime_test.mbt
  pattern_test.mbt --target native -v`: 32 tests passed after adding
  `Surface`/`Context`/`Pattern` pointer equality/hash.
- `moon -C cairoon test surface_context_test.mbt --target native -v`: 12
  black-box tests passed after adding invalid-size coverage for
  `Surface::create_similar` and `Surface::create_similar_image`.
- `moon -C cairoon test surface_subsurface_test.mbt --target native -v`: 3
  black-box tests passed after adding invalid-size coverage for
  `Surface::create_for_rectangle`.
- `moon -C cairoon test scaled_font_test.mbt --target native -v`: 6
  black-box tests passed after adding sheared font/CTM scale-matrix
  composition coverage.
- `moon -C cairoon test region_test.mbt --target native -v`: 8 black-box
  tests passed after adding `Region::xor_rectangle` split-semantics coverage.
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
- `moon -C cairoon test --target native`: 302 tests passed.
- `moon -C cairoon info --target native`: passed; the latest
  source/mask offset image-oracle helper slice did not change the public
  interface.
- Test-only buffer-backed image oracle coverage plus Pure MoonBit Region
  rectangle-XOR and executable Matrix/Surface/Context/Font/Path/Pattern/Region
  documentation coverage were added without rerunning ASan because no C glue or
  finalizer ownership code changed in those slices.
- Test-only source/mask offset image-oracle helper coverage was added without
  changing the public API or native test count; sanitizer validation is
  recorded below.
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
  The later image oracle slices added private C helpers for fifteen deterministic
  ARGB32 scenes covering paint, stroke, fill/stroke rectangles, Bezier paths,
  transforms, RGBA compositing, linear/radial gradients, toy-font `text_path`,
  toy-font `show_text`, `glyph_path`, `show_glyphs`, `show_text_glyphs`,
  source-surface offset sampling, and mask-surface offset compositing, without
  changing the current test count because they broaden one existing white-box
  oracle test. ASan/LSan records for the image-oracle C helpers are recorded in
  the current verified block above; the full runner still fails during the
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
  ordinary and buffer-backed image surfaces.
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

The missing reliability pieces are substantial: broader automated differential tests,
the open macOS toy-font/scaled-font/toy-text/glyph/show-text-glyphs rendering
LSan failure, broader callback failure-injection/fuzz finalizer stress tests,
CI wiring, vector-output normalization for broader
multi-page/tag/metadata combinations beyond the current two-page direct C
oracle scene and the current single-page toy-font `show_text` oracle scene,
broader tag-output assertions beyond the current PDF URI link,
named-destination, document-structure, and PS/SVG Link coverage, and the
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
