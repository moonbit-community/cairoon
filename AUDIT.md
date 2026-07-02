# cairoon Migration Audit

## Current Slice

Implemented in this workspace:

- MoonBit native package initialization with `moon.mod` and `moon.pkg`.
- System Cairo 1.18.4 linkage through `pkg-config`-derived flags.
- C FFI glue split by Cairo object family, following pycairo's
  `private.h` plus per-family C file architecture. GC-managed external objects
  currently cover `Surface`, `MappedImageSurface`, `Context`, `Path`,
  `Pattern`, `FontOptions`, `FontFace`, `ScaledFont`, and `Region`.
- `Context` retains its target `Surface` with `moonbit_incref` and releases it
  in the finalizer.
- `Context::new_for_mapped_image` retains its target `MappedImageSurface` with
  the same context payload mechanism, so a mapped image wrapper cannot be
  finalized while a context created from it is still live.
- `Surface::image_for_data` stores its backing `FixedArray[Byte]` as an owned
  Cairo surface user-data payload, so the buffer lives until the last
  `cairo_surface_t` reference is destroyed, including referenced wrappers
  returned through APIs such as `Pattern::get_surface`.
- `Surface::map_to_image` returns a dedicated `MappedImageSurface` external
  object. Its payload stores the base surface pointer, mapped image surface
  pointer, and retained base MoonBit `Surface` wrapper; explicit unmap and the
  finalizer call `cairo_surface_unmap_image` exactly once.
- `Pattern::for_surface` retains its base `Surface` wrapper while the pattern
  wrapper exists, and `Pattern::get_surface` returns a referenced `Surface`
  wrapper that can outlive the pattern wrapper.
- Public `Status`, `CairoError`, version helpers, portable Cairo enum types,
  `Format::stride_for_width`, pure `Matrix` parity operations, pure rectangle,
  glyph, text-cluster, and extents values, image `Surface` including PNG
  filename load/save and buffer-backed creation, core `Context` drawing state
  including dash, clip APIs including rectangle-list copying,
  hit testing, geometric extents, absolute/relative/arc path drawing,
  current-point queries, path copy/append plus typed path segment iteration and
  stringification, referenced borrowed returns for target/source, core
  painting/page methods, and matrix/coordinate-conversion methods,
  Context group target/push/pop APIs, Context tag begin/end APIs, Context toy
  text show/path/extents APIs, Context glyph array extents/path/show APIs,
  ScaledFont text-to-glyphs, Context show-text-glyphs APIs,
  RecordingSurface constructor/extents/ink-extents APIs, SVGSurface
  filename/no-output constructor, version helper, version restriction, and
  document-unit APIs, Cairo tag string constants,
  portable `Surface` base helpers for `create_similar`,
  `create_similar_image`, content/type queries, dirty markers, device
  offset/scale, fallback resolution, show-text-glyphs support checks, and
  mapped image surface readback/unmap helpers, plus Surface MIME data
  set/get/clear/support checks that copy data across the MoonBit/C boundary,
  initial solid/surface/linear/radial `Pattern` APIs with
  extend/filter/dither/matrix/gradient state, and complete portable `Region`
  APIs including multi-rectangle construction.
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
- Initial parity tests for version, enum exposure, pure value types, matrix
  behavior, image surface properties, buffer-backed image surface sharing and
  Cairo-reference lifetime behavior, PNG filename round trips and invalid path
  validation, deterministic pixel rendering, context CTM, coordinate
  conversion, drawing-state behavior, path current-point,
  relative/arc, copy/append, stringification, and iteration behavior,
  borrowed target/source/group-target lifetime behavior, group push/pop and
  pop-to-source rendering behavior, tag begin/end smoke behavior, tag string
  constants, tag input validation, Context toy text extents/current-point/path
  behavior, text input validation, Context glyph array extents/path/show
  behavior, empty glyph arrays, glyph context-error propagation, text-to-glyphs
  output copying, show-text-glyphs rendering, and text-glyph input validation,
  mapped image whole-surface and rectangle-extents writeback behavior,
  wrong-base and double-unmap errors, core painting/page behavior, hit testing
  and extents, MIME data storage/clear behavior including embedded NUL bytes
  and zero-length payloads, recording surface bounded/unbounded extents,
  replay-through-surface-pattern behavior, subtype-mismatch errors,
  SVG surface version helper behavior, no-output and filename construction,
  document-unit behavior, finished-surface errors, invalid path validation, and
  subtype-mismatch errors,
  clip behavior including non-rectangular clip status propagation,
  pattern RGBA, gradient
  geometry/color-stop behavior, pattern state behavior, explicit pattern
  sources, surface-pattern borrowed surface returns, font-options behavior,
  font-face and scaled-font behavior with context error propagation, region
  behavior, and error-status mapping.
- `API_INVENTORY.md` now tracks the full pycairo API surface against cairoon
  status.
- `TESTING.md` defines the migration reliability gates and records why the
  pycairo test suite is useful but insufficient by itself.

## Gate Status

- Gate 1 API inventory: partial. A full inventory ledger exists in
  `API_INVENTORY.md`; most rows remain Todo or Decision.
- Gate 2 behavioral parity: partial. First MoonBit tests cover a small subset
  of pycairo's matrix, surface, context, pattern, region, and error behavior.
- Gate 3 differential rendering: partial. Deterministic raw-pixel rendering
  tests exist for direct colors and explicit patterns. Cross-run comparison
  against pycairo output is not yet automated.
- Gate 4 memory and lifetime: partial. Stub ownership follows the documented
  external-object pattern, but the current font stack exposes macOS
  Cairo/Quartz/CoreText LeakSanitizer reports through toy-font, scaled-font,
  toy-text rendering, glyph rendering/path, and show-text-glyphs paths. These
  must be resolved or intentionally suppressed before claiming this gate.
  Finalizer stress tests still need to be broadened.

## Last Verified

2026-07-02:

- `moon -C cairoon test --target native -v`: 161 tests passed.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  ran the 161-test native suite after the SVGSurface slice
  and failed during LeakSanitizer reporting. The reported allocations are rooted in
  `cairo_toy_font_face_create`, `cairo_select_font_face`, macOS
  FontRegistry/CoreGraphics frames, and scaled-font Quartz/CoreText paths such
  as `cairo_scaled_font_create`, `CGFontCopyURL`, and
  `CTFontCreateWithGraphicsFont`, plus toy-text rendering caches reached
  through `cairo_show_text`, and glyph rendering/path caches reached through
  `cairo_show_glyphs`, `cairo_glyph_path`, and `cairo_show_text_glyphs`,
  `CTFontDrawGlyphs`, CoreGraphics, and ColorSync;
  no AddressSanitizer invalid-access report appeared before LSan failed and no
  text-to-glyphs native result finalizer, glyph/cluster marshaling helper,
  RecordingSurface helper, SVGSurface helper, Context text/tag/group, or
  MIME-data stub ownership stack appeared in the visible leak roots.
  Summary: `91621 byte(s) leaked in 503 allocation(s)`. The helper still emits
  a `moon.mod.json` lookup warning because this package uses `moon.mod`, but it
  correctly patched and restored the DSL `moon.pkg` and MoonBit runtime object
  for this package.

## Known Gaps

- No mesh/raster-source patterns, PDF/PS, stream/callback APIs, normalized SVG
  output comparison, or direct
  mutable image data view binding yet.
- `Surface::copy_data` copies the Cairo image data into MoonBit `Bytes`; it
  intentionally does not expose a mutable view yet.
- The package currently records Homebrew Cairo 1.18.4 paths. A portable setup
  script or generated config should replace this before publishing.
- ASan was run manually for the current expanded slice; CI automation has not
  been wired into this repository yet. The current LSan failure on macOS
  toy-font, scaled-font, toy-text rendering, glyph rendering/path, and
  show-text-glyphs paths is an open reliability item.
