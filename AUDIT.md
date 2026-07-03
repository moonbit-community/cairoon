# cairoon Migration Audit

## Current Slice

Implemented in this workspace:

- MoonBit native package initialization with `moon.mod` and `moon.pkg`.
- System Cairo 1.18.4 linkage through `pkg-config`-derived flags.
- C FFI glue split by Cairo object family, following pycairo's
  `private.h` plus per-family C file architecture. GC-managed external objects
  currently cover `Surface`, `MappedImageSurface`, `ImageData`, `Context`,
  `Path`, `Pattern`, `FontOptions`, `FontFace`, `ScaledFont`, `Region`, and
  `Device`.
- `Context` retains its target `Surface` with `moonbit_incref` and releases it
  in the finalizer.
- `Context::new_for_mapped_image` retains its target `MappedImageSurface` with
  the same context payload mechanism, so a mapped image wrapper cannot be
  finalized while a context created from it is still live.
- `Context::get_target` and `Context::get_group_target` return referenced
  `Surface` wrappers that also retain the context target wrapper. This keeps
  mapped-image targets valid when the context is finalized before the returned
  surface wrapper.
- `Surface::image_for_data` stores its backing `FixedArray[Byte]` as an owned
  Cairo surface user-data payload, so the buffer lives until the last
  `cairo_surface_t` reference is destroyed, including referenced wrappers
  returned through APIs such as `Pattern::get_surface`.
- `Surface::get_data` returns an `ImageData` external object over a Cairo image
  surface's mutable data pointer. The view retains the `Surface` wrapper with
  `moonbit_incref`, checks the Cairo surface status before access, bounds-checks
  indexes, copies out on demand, and calls `cairo_surface_mark_dirty` after
  byte writes.
- `MappedImageSurface::get_data` returns the same `ImageData` view type. Mapped
  views retain the `MappedImageSurface` wrapper, check the current mapped
  pointer before every access, and report `SurfaceFinished` after either
  `Surface::unmap_image` or `MappedImageSurface::unmap` instead of reading a
  stale image pointer.
- `Surface::map_to_image` returns a dedicated `MappedImageSurface` external
  object. Its payload stores the base surface pointer, mapped image surface
  pointer, and retained base MoonBit `Surface` wrapper; explicit unmap and the
  finalizer call `cairo_surface_unmap_image` exactly once.
- `Pattern::for_surface` retains its base `Surface` wrapper while the pattern
  wrapper exists, and `Pattern::get_surface` returns a referenced `Surface`
  wrapper that can outlive the pattern wrapper.
- Public `Status`, `CairoError`, version helpers, compile-time Cairo version
  constants, feature flags, MIME/tag constants, portable Cairo enum types,
  `Format::stride_for_width`, `FORMAT_INVALID` as an explicit integer
  sentinel, pure `Matrix` parity operations, pure rectangle,
  glyph, text-cluster, and extents values, image `Surface` including PNG
  filename load/save plus stream read/write, buffer-backed creation, and
  retained mutable `ImageData` views for image and mapped-image surfaces, core `Context`
  drawing state including dash and hairline
  mode, clip APIs including rectangle-list copying,
  hit testing, geometric extents, absolute/relative/arc path drawing,
  current-point queries, path copy/append plus typed path segment iteration and
  stringification, referenced borrowed returns for target/source, source-surface
  convenience, core painting/page methods, and matrix/coordinate-conversion methods,
  Context group target/push/pop APIs, Context tag begin/end APIs, Context toy
  text show/path/extents APIs, Context glyph array extents/path/show APIs,
  ScaledFont text-to-glyphs, Context show-text-glyphs APIs,
  RecordingSurface constructor/extents/ink-extents APIs, PDFSurface
  filename/no-output/stream constructor, version helpers, version restriction,
  page-size, metadata, custom metadata, page-label, thumbnail, single-flag
  outline compatibility, and typed outline flag-set APIs, PSSurface
  filename/no-output/stream constructor, level
  helpers, level restriction, EPS mode, page-size, and DSC comment/setup APIs,
  SVGSurface filename/no-output/stream constructor, version helper, version
  restriction, and document-unit APIs,
  Device/ScriptDevice status/type/equal/hash, finish/flush/acquire/release,
  scoped acquire helper, file/stream script devices, script mode/comment
  helpers, recording-surface replay, and ScriptSurface creation/proxy helpers,
  portable `Surface` base helpers for `create_similar`,
  `create_similar_image`, `create_for_rectangle` with retained parent-wrapper
  lifetime, content/type/get_device queries, dirty markers, device
  offset/scale, fallback resolution,
  show-text-glyphs support checks, and
  TeeSurface creation/add/remove/index helpers with retained primary and target
  wrapper lifetimes,
  mapped image surface readback/unmap helpers, plus Surface MIME data
  set/get/clear/support checks that copy data across the MoonBit/C boundary,
  initial solid/surface/linear/radial/mesh `Pattern` APIs with
  extend/filter/dither/matrix/gradient state, mesh patch lifecycle/query
  helpers, and complete portable `Region` APIs including multi-rectangle
  construction.
- `FontOptions` external object with copy/merge/equal/hash, variations,
  Cairo 1.18 color font options, classic antialias/subpixel/hint state, and
  Surface/Context font-options accessors.
- `FontFace` external object with finalizer ownership, pointer equality/hash,
  toy font construction and family/slant/weight accessors, plus `Context`
  font-face get/set/select wrappers.
- `ScaledFont` external object with finalizer ownership, pointer equality/hash,
  constructor from `FontFace`/`Matrix`/`FontOptions`, font face/options and
  matrix getters, text and glyph extents, text-to-glyphs, and `Context` font
  matrix/size/extents plus scaled-font get/set/show-text-glyphs wrappers.
- Initial parity tests for version helpers, compile-time Cairo constants, enum
  exposure, pure value types, matrix behavior, image surface properties,
  buffer-backed image surface sharing and
  Cairo-reference lifetime behavior, PNG filename round trips and invalid path
  validation, deterministic pixel rendering, direct C Cairo oracle image-paint
  comparison, mutable image-data read/write/copy, buffer-backed storage sharing,
  image-data surface-retention, mapped-image data upload/unmap invalidation, and
  invalid-surface/index error mapping, context CTM, coordinate conversion,
  drawing-state behavior, path current-point,
  relative/arc, copy/append, stringification, and iteration behavior,
  borrowed target/source/group-target lifetime behavior, group push/pop and
  pop-to-source rendering behavior, tag begin/end smoke behavior, tag and MIME
  string constants, integer constant parity including `FORMAT_INVALID`, tag
  input validation and nesting error coverage, Context toy text
  extents/current-point/path behavior, text input validation, Context glyph
  array extents/path/show
  behavior, empty glyph arrays, glyph context-error propagation, text-to-glyphs
  output copying, show-text-glyphs rendering, and text-glyph input validation,
  mapped image whole-surface and rectangle-extents writeback behavior,
  wrong-base and double-unmap errors, core painting/page behavior, hit testing
  and extents, MIME data storage/clear behavior including embedded NUL bytes
  and zero-length payloads, recording surface bounded/unbounded extents,
  replay-through-surface-pattern behavior, subtype-mismatch errors,
  PDF surface version helper behavior, no-output and filename construction,
  version restriction, page size, metadata, custom metadata, page label,
  thumbnail, single-flag and combined-flag outline behavior,
  stable structural output markers, PDF 1.4 link-tag annotation markers,
  finished-surface errors, invalid string validation, and subtype-mismatch
  errors,
  image surfaces returning no device, script device lifecycle and device
  reference equality, script mode/comment validation, recording replay,
  script-surface proxy rendering behavior, and `DeviceFinished` propagation,
  PS surface level helper behavior, no-output and filename construction, EPS
  mode, level restriction, size/DSC helpers, finished-surface errors, invalid
  DSC/path validation, stable page/drawing output markers, and subtype-mismatch
  errors,
  SVG surface version helper behavior, no-output and filename construction,
  document-unit behavior, finished-surface errors, invalid path validation, and
  stable geometry/color output markers, and subtype-mismatch errors,
  clip behavior including non-rectangular clip status propagation,
  pattern RGBA, gradient geometry/color-stop behavior, mesh patch construction,
  control/corner/path queries, invalid-index and lifecycle errors, non-mesh
  mismatch, painting smoke behavior, pattern state behavior, explicit pattern
  sources, surface-pattern borrowed surface returns, font-options behavior,
  font-face and scaled-font behavior with context error propagation, region
  behavior, TeeSurface mirrored drawing/index/error/lifetime behavior,
  exhaustive status/error classification, and retained-owner lifetime stress.
- `API_INVENTORY.md` now tracks the full pycairo API surface against cairoon
  status.
- `TESTING.md` defines the migration reliability gates and records why the
  pycairo test suite is useful but insufficient by itself.

## Gate Status

- Gate 1 API inventory: partial. A full inventory ledger exists in
  `API_INVENTORY.md`; multiple rows remain Partial or Decision.
- Gate 2 behavioral parity: partial. First MoonBit tests cover a small subset
  of pycairo's matrix, surface, context, pattern, raster-source callback,
  region, and error behavior.
- Gate 3 differential rendering: partial. Deterministic raw-pixel rendering
  tests exist for direct colors and explicit patterns, a direct C image oracle
  covers one ARGB32 paint case, and vector outputs have stable structural
  marker checks including PDF link-tag annotations. Full cross-run comparison
  against pycairo output is not yet automated.
- Gate 4 memory and lifetime: partial. Stub ownership follows the documented
  external-object pattern, and retained-owner stress now covers subsurfaces,
  data-backed surface patterns, data-backed raster-source acquire surfaces,
  mapped images, ImageData surface and
  mapped-image views, context target wrappers, and TeeSurface
  primary/target/index wrappers. The current font stack still exposes macOS
  Cairo/Quartz/CoreText LeakSanitizer reports through toy-font,
  scaled-font, toy-text rendering, glyph rendering/path, and
  show-text-glyphs paths. These must be resolved or intentionally suppressed
  before claiming this gate.
  Finalizer stress tests still need to be broadened across every external type.

## Last Verified

2026-07-02 and 2026-07-03:

- `moon -C cairoon check --target native`: passed.
- `moon -C cairoon test --target native -v`: 231 tests passed.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  most recently ran the 229-test native suite on 2026-07-03 after the
  raster-source get-acquire slice. The get-acquire slice raised native coverage
  to 231 tests. The rerun found no invalid access and no
  `cairoon_raster`, `raster_source`, or `cairoon_pattern` entries in the
  visible leak roots; it still failed during the known macOS LeakSanitizer
  reporting class documented in `TESTING.md`.
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
  helper stack, ImageData helper/finalizer stack, or mapped-image data helper
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

## Known Gaps

- Normalized PDF/SVG/PS output comparison is missing, and SVG/PS
  tag-materialization assertions are still absent. PDF/PS/SVG stream-writer
  constructors, script stream devices, and PNG stream read/write now have
  copied-byte callback tests and read/write error propagation coverage.
- `Surface::copy_data` still copies Cairo image data into MoonBit `Bytes`;
  `Surface::get_data` is the mutable image-surface view and intentionally
  retains the surface wrapper instead of exposing a raw pointer.
- The package currently records Homebrew Cairo 1.18.4 paths. A portable setup
  script or generated config should replace this before publishing.
- ASan was run manually for the current expanded slice; CI automation has not
  been wired into this repository yet. The current LSan failure on macOS
  toy-font, scaled-font, toy-text rendering, glyph rendering/path, and
  show-text-glyphs paths is an open reliability item.
