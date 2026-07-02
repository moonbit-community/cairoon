# cairoon Migration Audit

## Current Slice

Implemented in this workspace:

- MoonBit native package initialization with `moon.mod` and `moon.pkg`.
- System Cairo 1.18.4 linkage through `pkg-config`-derived flags.
- C FFI glue split by Cairo object family, following pycairo's
  `private.h` plus per-family C file architecture. GC-managed external objects
  currently cover `Surface`, `Context`, `Path`, `Pattern`, and `Region`.
- `Context` retains its target `Surface` with `moonbit_incref` and releases it
  in the finalizer.
- `Pattern::for_surface` retains its base `Surface` wrapper while the pattern
  wrapper exists, and `Pattern::get_surface` returns a referenced `Surface`
  wrapper that can outlive the pattern wrapper.
- Public `Status`, `CairoError`, version helpers, portable Cairo enum types,
  `Format::stride_for_width`, pure `Matrix` parity operations, pure rectangle,
  glyph, text-cluster, and extents values, image `Surface`, core `Context`
  drawing state including dash, clip APIs including rectangle-list copying,
  hit testing, geometric extents, absolute/relative/arc path drawing,
  current-point queries, path copy/append plus typed path segment iteration and
  stringification, referenced borrowed returns for target/source, core
  painting/page methods, and matrix/coordinate-conversion methods,
  initial solid/surface/linear/radial `Pattern` APIs with
  extend/filter/dither/matrix/gradient state, and initial `Region` APIs.
- `FontOptions` external object with copy/merge/equal/hash, variations,
  Cairo 1.18 color font options, classic antialias/subpixel/hint state, and
  Surface/Context font-options accessors.
- `FontFace` external object with finalizer ownership, pointer equality/hash,
  toy font construction and family/slant/weight accessors, plus `Context`
  font-face get/set/select wrappers.
- `ScaledFont` external object with finalizer ownership, pointer equality/hash,
  constructor from `FontFace`/`Matrix`/`FontOptions`, font face/options and
  matrix getters, text extents, and `Context` font matrix/size/extents plus
  scaled-font get/set wrappers.
- Initial parity tests for version, enum exposure, pure value types, matrix
  behavior, image surface properties, deterministic pixel rendering, context
  CTM, coordinate conversion, drawing-state behavior, path current-point,
  relative/arc, copy/append, stringification, and iteration behavior,
  borrowed target/source lifetime behavior,
  core painting/page behavior, hit testing and extents, clip behavior including
  non-rectangular clip status propagation, pattern RGBA, gradient
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
  Cairo/Quartz/CoreText LeakSanitizer reports through toy-font and scaled-font
  paths. These must be resolved or intentionally suppressed before claiming this
  gate. Finalizer stress tests still need to be broadened.

## Last Verified

2026-07-02:

- `moon -C cairoon test --target native -v`: 104 tests passed.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  ran the 104-test native suite after the Path data/iteration slice and failed
  during LeakSanitizer reporting. The reported allocations are rooted in
  `cairo_toy_font_face_create`, `cairo_select_font_face`, macOS
  FontRegistry/CoreGraphics frames, and scaled-font Quartz/CoreText paths such
  as `cairo_scaled_font_create`, `CGFontCopyURL`, and `CTFontCreateWithGraphicsFont`;
  no AddressSanitizer invalid-access report appeared before LSan failed. The
  helper still emits a `moon.mod.json` lookup warning because this package uses
  `moon.mod`, but it correctly patched and restored the DSL `moon.pkg` and
  MoonBit runtime object for this package.

## Known Gaps

- No mesh/raster-source patterns, ScaledFont glyph arrays/text-to-glyphs,
  PDF/SVG/PS, stream, callback, or `ImageSurface.create_for_data` binding yet.
  `Region` is partial and lacks the multi-rectangle constructor.
- `Surface::copy_data` copies the Cairo image data into MoonBit `Bytes`; it
  intentionally does not expose a mutable view yet.
- The package currently records Homebrew Cairo 1.18.4 paths. A portable setup
  script or generated config should replace this before publishing.
- ASan was run manually for the current expanded slice; CI automation has not
  been wired into this repository yet. The current LSan failure on macOS
  toy-font and scaled-font paths is an open reliability item.
