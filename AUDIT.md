# cairoon Migration Audit

## Current Slice

Implemented in this workspace:

- MoonBit native package initialization with `moon.mod` and `src/moon.pkg`.
- System Cairo 1.18.4 linkage through `pkg-config`-derived flags, with
  `scripts/configure-link-flags.sh` to refresh `src/moon.pkg`,
  `src/native/moon.pkg`, and external test package configs, plus
  `scripts/configure-link-flags.sh --check` in the local reliability gate.
- Static raw FFI ownership linting through
  `scripts/check-ffi-ownership.py`, wired into `scripts/verify.sh`, so every
  non-primitive production `src/**/ffi*.mbt` parameter must be annotated with
  `#borrow` or `#owned`; test oracle `*_ffi_test.mbt` files are deliberately
  outside this production-boundary lint.
- Static top-level and portable method pycairo API inventory linting through
  `scripts/check-api-inventory.py`, wired into `scripts/verify.sh`, so every
  public class/function in parent `cairo/__init__.pyi` must have an
  implementation or explicit product-decision anchor in `API_INVENTORY.md`, and
  every portable pycairo class method in the first-product scope must have a
  public MoonBit API anchor in `src/pkg.generated.mbti`.
- Static reliability-ledger linting through
  `scripts/check-reliability-ledger.py`, wired into `scripts/verify.sh`, so
  migration status rows use accepted statuses, `Partial` rows state remaining
  gaps explicitly, the TESTING scorecard keeps its required dimensions, and CI
  continues to run native/ASan verify gates.
- Initial external black-box API package extraction under
  `src/tests/api/{version,enums,pycairo}`. Root-level `tests/` packages are
  intentionally forbidden while `moon.mod source = "src"` keeps the public
  import path as `CAIMEOX/cairoon`. External test packages that import cairoon
  carry Cairo `cc-link-flags`, and `scripts/configure-link-flags.sh --check`
  verifies those flags alongside the public and native package configs.
- The external API black-box packages cover version helpers, portable enum
  constructors, `Format::stride_for_width`, `FORMAT_INVALID`, and pycairo
  `test_api.py` smoke/lifetime fixtures.
- Status/error black-box tests now live in `src/tests/status`, importing only
  the public `CAIMEOX/cairoon` API. This validates `check_status`,
  `run_cairo`, public `Status::message`, and all `CairoError` suberror classes
  through the published package seam.
- Pure public value black-box tests now live in
  `src/tests/value/{core,pycairo}`, importing only the public
  `CAIMEOX/cairoon` API. This validates rectangles, glyphs, text clusters, and
  font/text extents, including component access, invalid-index error mapping,
  hash/equality fixtures, numeric limits, and return paths from Context,
  ScaledFont, recording surfaces, and clip extents through separately linked
  published-package seams.
- Matrix black-box tests now live in `src/tests/matrix`, importing only the
  public `CAIMEOX/cairoon` API. This validates external-package access to public
  types, methods, checked errors, and `CairoInvalidArgument` pattern matching;
  `scripts/verify.sh` discovers all `src/tests/**/moon.pkg` packages for normal
  and ASan targeted runs.
- Region black-box tests now live in `src/tests/region/{core,pycairo}`,
  importing only the public `CAIMEOX/cairoon` API. This validates Region
  lifetime/copy behavior, rectangle construction, containment, overlap enums,
  mutating boolean operations, chained pycairo-style mutators, and invalid-index
  error mapping through separately linked published-package seams.
- Surface black-box tests now live in
  `src/tests/surface/{base,mime,pycairo,subsurface}`, importing only the
  public `CAIMEOX/cairoon` API. This validates base surface state,
  similar/subsurface behavior, MIME storage/support, and pycairo base-surface
  parity through separately linked published-package seams.
- Image-family black-box tests now live in
  `src/tests/image/{properties,data,mapped,png,buffer}`, importing only the
  public `CAIMEOX/cairoon` API. This validates ImageSurface, ImageData,
  MappedImageSurface, PNG path, buffer-backed, float-format, and raw
  image-format behavior through separately linked published-package seams.
- Backend surface black-box tests now live in
  `src/tests/backend/{pdf,ps,recording,svg,tee}`, importing only the public
  `CAIMEOX/cairoon` API. This validates Recording, PDF, PS, SVG, and Tee
  constructors, raw backend enums, subtype and finished-surface errors,
  filename constructors, recording replay, and Tee fanout/lifetime behavior
  through separately linked published-package seams.
- Context black-box tests now live in
  `src/tests/context/{pycairo,clip,extents,glyph,group,matrix,paint,path,state,tag,text,text_to_glyphs}`,
  importing only the public `CAIMEOX/cairoon` API. This validates drawing
  state, transforms, paths, pycairo parity fixtures, groups, text/glyph APIs,
  extents, clipping, painting, tags, and ScaledFont text-to-glyph conversion
  through separately linked published-package seams.
- Pattern black-box tests now live in
  `src/tests/pattern/{core,mesh,pycairo,gradient,raster}`, importing only the
  public `CAIMEOX/cairoon` API. This validates solid/surface/common-state
  patterns, pycairo parity fixtures, gradient queries, mesh patch lifecycle,
  raster-source callbacks, and raster-source callback fuzz/state behavior
  through separately linked published-package seams.
- Font black-box tests now live in `src/tests/font/{face,options,scaled,pycairo}`,
  importing only the public `CAIMEOX/cairoon` API. This validates toy font
  faces, font options, pycairo font parity fixtures, context font-option/font-face
  round trips, ScaledFont construction, matrix queries, text extents,
  invalid-string handling, and context error propagation through separately
  linked published-package seams; ScaledFont C-oracle tests remain white-box.
- Stream/device black-box tests now live in
  `src/tests/stream/{surface,device}`, importing only the public
  `CAIMEOX/cairoon` API. This validates PDF/PS/SVG/PNG stream writers/readers,
  callback chunk retention, script devices, script surfaces, device lifetime
  helpers, raw script content mapping, and stream error mapping through
  separately linked published-package seams; backend stream oracle tests remain
  white-box.
- Path black-box tests now live in `src/tests/path`, importing only the public
  `CAIMEOX/cairoon` API. This validates Path formatting, iteration, flattening,
  scope survival, and path comparison behavior through the published package
  seam.
- Object trait black-box tests now live in `src/tests/object`, importing only
  the public `CAIMEOX/cairoon` API. This validates Eq/Hash semantics across
  external object wrappers through the published package seam.
- Lifetime/stress black-box tests now live in
  `src/tests/lifetime/{context,owner,finalizer,stream,image_data,value,raster}`,
  importing only the public `CAIMEOX/cairoon` API. This validates retained
  owner graphs, mapped image lifetimes, image data views, value wrapper stress,
  raster-source callback retention, stream callback stress/fuzz, finalizer fuzz
  paths, and context borrowed-return lifetimes through separately linked
  published-package seams.
- Public C stubs now live in the `src/native` native-stub package, and
  `src/native/moon.pkg` references each compiled C file by bare filename. The
  public `src/moon.pkg` imports `CAIMEOX/cairoon/native` for linking and owns no
  `native-stub` entries. The layout gate checks that every `src/native/*.c`
  file is explicitly owned by `src/native/moon.pkg`.
- The compile-time constants oracle now lives in
  `src/tests/oracle/constants`, importing the public `CAIMEOX/cairoon` package
  and declaring its test-only C oracle externs locally. This proves direct-C
  oracle tests can move out of the public package root while still linking
  against public-package native stubs.
- The ScaledFont direct-C oracle now lives in `src/tests/oracle/scaled_font`,
  importing the public `CAIMEOX/cairoon` package and declaring its test-only
  extents/text-to-glyphs oracle externs plus native result decoder locally.
  This keeps ScaledFont oracle assertions outside the public package root
  without exposing private `TextToGlyphsNative` helpers.
- The ARGB32 image rendering oracle now lives in `src/tests/oracle/image`,
  importing the public `CAIMEOX/cairoon` package and declaring its scene oracle
  extern locally. This proves pixel-differential rendering tests can leave the
  public package root while still exercising ordinary and buffer-backed image
  surfaces through the published API.
- Raster-source pattern owner/state/manual lifecycle oracles now live in
  `src/tests/oracle/pattern_raster`, importing the public `CAIMEOX/cairoon`
  package and declaring the owner-count extern inside a `*_test.mbt` helper.
  This keeps the public package root free of raster-source test-only owner
  accounting while preserving ASan-covered callback lifecycle fuzzing.
- Vector-output and backend stream oracles now live in
  `src/tests/oracle/vector_backend`, importing the public `CAIMEOX/cairoon`
  package and declaring file/vector/direct-C oracle externs inside a
  `*_test.mbt` helper. This removes the last root `*_wbtest.mbt` files while
  preserving 113 PDF/PS/SVG vector, stream-equivalence, tag, metadata, page,
  and backend lifecycle oracle tests through the published API seam.
- Test-only C oracle helpers now live in `src/tests/oracle/native` as a
  separate native-stub package imported by the oracle test packages. This keeps
  constants, ScaledFont, image, raster-owner, and PDF/PS/SVG vector oracle C
  symbols out of public `src/moon.pkg` while preserving a shared C oracle
  implementation for all external oracle tests.
- `Glyph` is the first pure support package seam. The implementation lives in
  `src/core/glyph`, while the public package re-exports it with a type alias.
  Package-local tests cover the pure value invariants and field-array marshaling
  preparation, while API, Context, and ScaledFont oracle tests prove
  `@cairoon.Glyph::new`, field access, `Glyph::components`, glyph-array FFI, and
  text-to-glyphs output still work through the public facade.
- `src/internal/version` is the first internal implementation package seam. It
  owns the raw Cairo version externs and UTF-8 decoding, while the public
  `src/version.mbt` facade preserves `@cairoon.cairo_version()` and
  `@cairoon.cairo_version_string()`. The package has a local native test and is
  discovered by `scripts/verify.sh` with Cairo link flags maintained by
  `scripts/configure-link-flags.sh`.
- `src/internal/format` is the first enum-adjacent internal implementation
  package seam. It owns the raw `cairo_format_stride_for_width` extern, while
  public `src/format.mbt` keeps the `Format` enum constructors and typed/raw
  stride methods. Package-local, API, and surface tests prove the facade
  preserves typed enum construction, raw C-int passthrough, and float-format
  stride behavior.
- `src/internal/status` is the second enum-adjacent internal implementation
  package seam. It owns the raw `cairo_status_to_string` helper and UTF-8
  decoding, while public `src/status.mbt` keeps the `Status` enum constructors,
  `Status::message`, and `CairoError` integration. Package-local and API tests
  prove public status messages and exhaustive status/error classification still
  work through the facade.
- `src/internal/pdf` is the first backend-helper internal implementation
  package seam. It owns raw PDF version count/version/string externs and UTF-8
  decoding, while public `src/pdf_surface.mbt` keeps `PDFVersion` constructors,
  typed/raw version string methods, and all `Surface::pdf*` object wrappers.
  Package-local and surface black-box tests prove PDF version helpers still
  work through the facade.
- `src/internal/ps` is the second backend-helper internal implementation
  package seam. It owns raw PostScript level count/level/string externs and
  UTF-8 decoding, while public `src/ps_surface.mbt` keeps `PSLevel`
  constructors, typed/raw level string methods, and all `Surface::ps*` object
  wrappers. Package-local and surface black-box tests prove PS level helpers
  still work through the facade.
- `src/internal/svg` is the third backend-helper internal implementation
  package seam. It owns raw SVG version count/version/string externs and UTF-8
  decoding, while public `src/svg_surface.mbt` keeps `SVGVersion` constructors,
  typed/raw version string methods, and all `Surface::svg*` object wrappers.
  Package-local and surface black-box tests prove SVG version helpers still
  work through the facade.
- C FFI glue split by Cairo object family, following pycairo's
  `private.h` plus per-family C file architecture. GC-managed external objects
  currently cover `Surface`, `MappedImageSurface`, `ImageData`, `Context`,
  `Path`, `Pattern`, `FontOptions`, `FontFace`, `ScaledFont`, `Region`, and
  `Device`. Context C glue follows the same family split:
  `cairoon_context.c` keeps core construction/status/tag/target/source and
  group glue, while `cairoon_context_font_text.c`,
  `cairoon_context_matrix.c`, `cairoon_context_state.c`,
  `cairoon_context_path.c`, `cairoon_context_clip_extents.c`, and
  `cairoon_context_paint.c` own the corresponding font/text, transform,
  drawing-state, path, clip/extents/hit-test, and source/paint/page stubs.
  Surface C glue is also split by responsibility: `cairoon_surface.c` keeps
  base surface creation/status/equality/hash/type and finish glue, while
  `cairoon_surface_png.c`, `cairoon_surface_mime.c`,
  `cairoon_surface_state.c`, and `cairoon_surface_font_options.c` own PNG
  writers, MIME helpers, state/page helpers, and surface font-options. The
  `cairoon_image_surface.c`, `cairoon_mapped_image_surface.c`, and
  `cairoon_recording_surface.c` files own image, mapped-image, and recording
  stubs; PDF, PS, SVG, and Tee surfaces continue to live in their dedicated
  files.
  Pattern C glue is split into base/surface/solid/gradient state in
  `cairoon_pattern.c`, mesh-pattern operations in `cairoon_mesh_pattern.c`,
  public raster-source exports in `cairoon_raster_source_pattern.c`, and
  raster-source callback/owner lifecycle glue in
  `cairoon_raster_source_callbacks.c`.
  Font C glue is split into `cairoon_font_options.c`,
  `cairoon_font_face.c`, `cairoon_scaled_font.c`, and
  `cairoon_scaled_font_oracle.c`.
- MoonBit raw FFI declarations are beginning to follow the same family split:
  `ffi.mbt` keeps object type declarations and private native helper types, while
  `ffi_context_clip_extents.mbt` owns raw `Context` clip/extents/hit-testing
  extern declarations, `ffi_context_core.mbt` owns raw `Context` construction,
  status, identity, save/restore, tag, target/source, and group extern
  declarations,
  `ffi_context_font_text.mbt` owns raw `Context` font/text/scaled-font extern
  declarations, `ffi_context_matrix.mbt` owns raw `Context`
  matrix/coordinate-conversion extern declarations, `ffi_context_path.mbt`
  owns raw `Context` path construction/copy extern declarations,
  `ffi_context_paint.mbt` owns raw `Context` source/painting/page extern
  declarations,
  `ffi_context_state.mbt` owns raw `Context` drawing-state/line-style/dash
  extern declarations,
  `ffi_font_options.mbt` owns raw `FontOptions` extern declarations,
  `ffi_font_face.mbt` owns raw toy-font-face and `FontFace` extern
  declarations, `ffi_scaled_font.mbt` owns raw `ScaledFont` extern
  declarations, and `ffi_text_to_glyphs.mbt` owns raw text-to-glyphs result
  extern declarations. `ffi_pattern.mbt` owns raw
  base/surface/solid/gradient `Pattern` extern declarations,
  `ffi_pattern_mesh.mbt` owns raw mesh-pattern extern declarations, and
  `ffi_pattern_raster_source.mbt` owns raw raster-source-pattern extern
  declarations backed by the public raster-source exports.
  `ffi_device.mbt` owns raw `Device`, script-device, script-surface, and
  surface-get-device extern declarations.
  `ffi_image_data.mbt` owns raw `ImageData` extern declarations;
  `ffi_image_surface.mbt`, `ffi_mapped_image_surface.mbt`,
  `ffi_recording_surface.mbt`, `ffi_surface.mbt`,
  `ffi_surface_font_options.mbt`, `ffi_surface_mime.mbt`,
  `ffi_surface_png.mbt`, and `ffi_surface_state.mbt` own raw image, mapped
  image, recording, base, font-options, MIME, PNG, and state/page surface
  extern declarations; and `ffi_path.mbt`, `ffi_pdf_surface.mbt`,
  `ffi_ps_surface.mbt`, `ffi_svg_surface.mbt`, `ffi_tee_surface.mbt`, and
  `ffi_region.mbt` own raw `Path`, PDF surface, PostScript surface, SVG
  surface, Tee surface, and `Region` extern declarations. Raw PDF version
  helper externs have moved out of `ffi_pdf_surface.mbt` into
  `src/internal/pdf`; raw PostScript level helper externs have moved out of
  `ffi_ps_surface.mbt` into `src/internal/ps`; raw SVG version helper externs
  have moved out of `ffi_svg_surface.mbt` into `src/internal/svg`.
- MoonBit `Context` public wrappers now follow the same family split as their
  raw FFI files: `context.mbt` keeps core construction/status/tag/group
  wrappers, while `context_font_text.mbt`, `context_matrix.mbt`,
  `context_state.mbt`, `context_path.mbt`, `context_clip_extents.mbt`, and
  `context_paint.mbt` own the corresponding font/text, transform, drawing
  state, path, clip/extents/hit-test, and source/paint/page wrappers.
- MoonBit `Surface` public wrappers follow the Surface C glue split:
  `surface.mbt` keeps string helpers, similar/subsurface constructors,
  identity/status/type/device, and finish/with-finished wrappers, while
  `image_surface.mbt`, `surface_png.mbt`, `surface_mime.mbt`,
  `surface_state.mbt`, `surface_font_options.mbt`, `recording_surface.mbt`,
  and `tee_surface.mbt` own the corresponding image, PNG, MIME, state/page,
  font-options, recording-surface, and TeeSurface wrappers.
- MoonBit `Pattern` public wrappers are split by family: `pattern.mbt` keeps
  solid/surface/common-state wrappers, `pattern_gradient.mbt` owns gradient
  constructors and color-stop/geometry queries, `pattern_mesh.mbt` owns
  mesh-patch methods, and `pattern_raster_source.mbt` owns raster-source
  callback accessors.
- MoonBit `Eq`/`Hash` traits are implemented for hashable Cairo external
  objects that already expose cairoon equality/hash helpers: `Surface`,
  `Context`, `Pattern`, `Device`, `FontOptions`, `FontFace`, `ScaledFont`, and
  `Path`; `Path` also implements `Compare`, and `Region` implements `Eq`
  without `Hash`, matching pycairo's unhashable region behavior.
- `Context` retains its target `Surface` with `moonbit_incref` and releases it
  in the finalizer.
- `Context::new_for_mapped_image` retains its target `MappedImageSurface` with
  the same context payload mechanism, so a mapped image wrapper cannot be
  finalized while a context created from it is still live.
- `Context::get_target` returns a referenced `Surface` wrapper that also
  retains the context target wrapper. `Context::get_group_target` returns a
  referenced `Surface` wrapper that retains the `Context` wrapper, keeping the
  active group target valid when the creating context scope exits before the
  returned surface wrapper.
- `Surface::image_for_data` stores its backing `FixedArray[Byte]` as an owned
  Cairo surface user-data payload, so the buffer lives until the last
  `cairo_surface_t` reference is destroyed, including referenced wrappers
  returned through APIs such as `Pattern::get_surface`.
- `Surface::get_data` returns an `ImageData` external object over a Cairo image
  surface's mutable data pointer. The view retains the `Surface` wrapper with
  `moonbit_incref`, checks the retained cairoon surface status before access so
  existing views report `SurfaceFinished` after the base surface is finished,
  bounds-checks indexes, copies out on demand, and calls
  `cairo_surface_mark_dirty` after byte writes.
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
  including `SurfaceObserverMode` as an enum-only pycairo API surface entry
  rather than Cairo's native observer surface/device extension APIs,
  `Format::stride_for_width` including legacy, 16-bit, 30-bit, float, and
  invalid-width cases, `FORMAT_INVALID` as an explicit integer sentinel, pure
  `Matrix` parity operations, pure rectangle,
  glyph with `UInt64` index, text-cluster, and extents values, image `Surface`
  including PNG
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
  documented product-scope decisions for pycairo's `CAPI`, legacy uppercase
  enum alias constants, and non-implemented FreeType/user-font classes,
  RecordingSurface constructor/extents/ink-extents APIs, PDFSurface
  filename/no-output/stream constructor, version helpers, version restriction,
  page-size, metadata, custom metadata, page-label, thumbnail, single-flag
  outline compatibility, and typed outline flag-set APIs, PSSurface
  filename/no-output/stream constructor, level
  helpers, level restriction, EPS mode, page-size, and DSC comment/setup APIs,
  SVGSurface filename/no-output/stream constructor, version helper, version
  restriction, and document-unit APIs,
  Device/ScriptDevice status/type/equal/hash, finish/flush/acquire/release,
  scoped acquire/finish helpers, file/stream script devices, script mode/comment
  helpers, recording-surface replay, and ScriptSurface creation/proxy helpers,
  portable `Surface` base helpers for `create_similar`,
  `create_similar_image`, `create_for_rectangle` with retained parent-wrapper
  lifetime, content/type/get_device queries, pointer equality/hash for
  ordinary surfaces, dirty markers with finished-status coverage, device
  offset/scale, fallback resolution,
  show-text-glyphs support checks with finished-status coverage, and
  TeeSurface creation/add/remove/index helpers with retained primary and target
  wrapper lifetimes,
  mapped image surface readback/unmap helpers, plus Surface MIME data
  set/get/clear/support checks that copy data across the MoonBit/C boundary
  and lock image/PDF/PS/SVG backend support matrices,
  initial solid/surface/linear/radial/mesh `Pattern` APIs with
  pointer equality/hash, extend/filter/dither/matrix/gradient state, mesh patch lifecycle/query
  helpers, and complete portable `Region` APIs including multi-rectangle
  construction and pycairo-style chainable boolean mutator returns.
- `FontOptions` external object with copy/merge/equal/hash, variations,
  Cairo 1.18 color font options, classic antialias/subpixel/hint state, and
  Surface/Context font-options accessors.
- `FontFace` external object with finalizer ownership, pointer equality/hash,
  toy font construction and family/slant/weight accessors, plus `Context`
  font-face get/set/select wrappers and embedded-NUL family validation.
- `ScaledFont` external object with finalizer ownership, pointer equality/hash,
  constructor from `FontFace`/`Matrix`/`FontOptions`, font face/options and
  matrix getters including sheared font/CTM scale-matrix composition, text and
  glyph extents, full and glyph-only text-to-glyphs,
  direct C Cairo oracle comparison for font/text/glyph extents and
  empty, single/multi/spaced ASCII, precomposed/decomposed Latin, CJK,
  Arabic RTL, and emoji UTF-8 text-to-glyph coordinate cases,
  embedded-NUL text-extents validation,
  and `Context`
  font matrix/size/extents plus scaled-font
  get/set/show-text-glyphs wrappers.
- Initial parity tests for version helpers, compile-time Cairo constants, enum
  exposure, pure value types, matrix behavior, image surface properties,
  buffer-backed image surface sharing and
  Cairo-reference lifetime behavior, PNG filename round trips and invalid path
  validation, Surface similar/subsurface invalid-size error mapping,
  deterministic pixel rendering, direct C Cairo oracle comparisons
  for twenty ARGB32 scenes covering paint, stroke, fill/stroke rectangles,
  Bezier paths, transforms, RGBA compositing, linear/radial gradients,
  toy-font `text_path`, toy-font `show_text`, `glyph_path`, `show_glyphs`,
  `show_text_glyphs`, source-surface offset sampling, and mask-surface offset
  compositing, raster-source pattern repeat rendering, dashed round-cap
  strokes, clipped paint/fill output, `OperatorClear` compositing output, and a
  surface-pattern `Reflect`/`Nearest`/`DitherBest`/matrix combination,
  direct C Cairo oracle comparisons for seventeen deterministic PDF/PS/SVG
  vector scenes covering paint, stroke, fill/stroke rectangles, Bezier paths,
  transforms, linear/radial gradients, toy-font text paths, toy-font
  `show_text`, `glyph_path`, `show_glyphs`, two-page paint, clip, dashed
  stroke, repeated surface pattern, mask surface, mesh pattern scenes, a layered three-page clip/dash/surface-pattern/mask/tag/text scene,
  and a wide three-page URI/destination/document-structure tag/vector scene,
  mutable image-data read/write/copy, buffer-backed storage sharing,
  image-data surface-retention, mapped-image data upload/unmap invalidation, and
  invalid-surface/index error mapping, context CTM, coordinate conversion,
  drawing-state behavior, path current-point,
  relative/arc, copy/append, stringification, and iteration behavior,
  borrowed target/source/group-target post-scope lifetime behavior, group push/pop and
  pop-to-source rendering behavior, tag begin/end smoke behavior, tag and MIME
  string constants, integer constant parity including `FORMAT_INVALID`, tag
  input validation and nesting error coverage, Context toy text
  extents/current-point/path behavior, text input validation, Context glyph
  array extents/path/show behavior with 64-bit glyph indices, empty glyph
  arrays, glyph context-error propagation, text-to-glyphs
  output copying including glyph-only conversion, ScaledFont sheared matrix
  composition, font/text/glyph extents, and text-to-glyph string-matrix direct C
  oracle comparison,
  show-text-glyphs rendering, and
  text-glyph input validation,
  mapped image whole-surface and rectangle-extents writeback behavior,
  wrong-base and double-unmap errors, image/buffer-backed/PNG-loaded
  `get_data` after `finish()` behavior, retained `ImageData` view
  base-finish invalidation, core painting/page behavior, hit testing
  and extents, MIME data storage/clear behavior including embedded NUL bytes,
  zero-length payloads, invalid MIME type strings, image/PDF/PS/SVG support
  matrices, PDF JPEG MIME passthrough with direct C oracle coverage, PDF
  thumbnail direct C oracle coverage, recording surface
  bounded/unbounded extents,
  replay-through-surface-pattern behavior, subtype-mismatch errors,
  PDF surface version helper behavior, no-output and filename construction,
  version restriction, page size, metadata, custom metadata, page label,
  thumbnail, single-flag and combined-flag outline behavior,
  stable structural output markers, PDF metadata/custom-metadata/page-label/outline
  output markers, PDF multi-page output markers, PDF 1.4 seventeen-scene
  cross-backend direct C vector-oracle comparison including `glyph_path` and
  `show_glyphs` plus three PDF tag oracle scenes, three PDF text-tag oracle scenes, one cross-backend tagged
  multi-page text oracle scene, one cross-backend tagged `show_text_glyphs`
  oracle scene, one cross-backend grouped glyph/tag multi-page oracle scene,
  one cross-backend copy_page retained two-page oracle scene,
  one cross-backend mixed vector/tag/text oracle
  scene, one cross-backend layered three-page clip/dash/surface-pattern/mask/tag/text
  oracle scene, one cross-backend wide three-page URI/destination/
  document-structure tag/vector oracle scene, and three PDF document-feature/page-operation
  oracle scenes, including one text/tag-aware combined scene, PDF JPEG MIME data embedding
  and PDF thumbnail output with direct C oracle comparison, PDF 1.4 URI link-tag annotation markers,
  PDF named-destination tag markers, PDF document-structure tag markers,
  finished-surface errors, invalid string validation, and subtype-mismatch
  errors across bound page-size/version/metadata/custom-metadata/page-label/
  thumbnail/outline helpers,
  image surfaces returning no device, script device lifecycle and device
  reference equality, script mode/comment validation, recording replay,
  script-surface proxy rendering behavior, and `DeviceFinished` propagation,
  PS surface level helper behavior, no-output and filename construction, EPS
  mode, level restriction, size/DSC helpers, finished-surface errors, invalid
  DSC/path validation, stable page/drawing output markers, seventeen-scene direct C
  vector-oracle comparison with `glyph_path`, `show_glyphs`, and
  `CreationDate` normalization, normalized direct
  C oracle comparison for the combined language-level/DSC setup/page-setup/
  two-page feature scene and Link tag inertness on PS output, and subtype-mismatch
  errors across bound EPS/level/page-size/DSC helpers,
  SVG surface version helper behavior, no-output and filename construction,
  document-unit behavior, finished-surface errors including document-unit
  getters, invalid path validation, and
  stable geometry/color output markers, normalized seventeen-scene direct C
  vector-oracle comparison including `glyph_path` and `show_glyphs`,
  normalized direct C oracle comparison for the combined version-restricted/
  document-unit/two-page feature scene and Link tag inertness on SVG output, and
  subtype-mismatch errors,
  clip behavior including non-rectangular clip status propagation,
  pattern RGBA, gradient geometry/color-stop behavior, mesh patch construction,
  control/corner/path queries, invalid-index and lifecycle errors, non-mesh
  mismatch, painting smoke behavior, pattern state behavior, explicit pattern
  sources, surface-pattern borrowed surface returns, font-options behavior,
  font-face and scaled-font behavior with context error propagation, region
  behavior including rectangle XOR split semantics, TeeSurface mirrored
  drawing/index/error/lifetime behavior, Cairo float image-format creation and
  buffer-backed readback behavior,
  exhaustive status/error classification, retained-owner lifetime stress, and
  external value-wrapper allocation stress for `Path`, `Region`, the font
  stack, solid/gradient/mesh `Pattern`, recording/similar/Tee `Surface`, and
  script stream `Device`, plus `ImageData` view allocation stress for ordinary,
  buffer-backed, and mapped image surfaces, plus backend stream callback
  allocation stress for PDF/PS/SVG surfaces, PNG stream write/read, script
  devices, and stream `WriteError` paths, plus raster-source callback
  allocation stress for set/get/manual acquire/release/replace/clear paths,
  acquire-only retained-owner release-trampoline cleanup, 64-step acquire-only
  retained-owner replacement fuzz, and finished-surface acquire failure
  injection.
- `API_INVENTORY.md` now tracks the full pycairo API surface against cairoon
  status.
- `matrix.mbt.md`, `surface.mbt.md`, `backend_surfaces.mbt.md`,
  `context.mbt.md`, `font.mbt.md`, `path.mbt.md`, `pattern.mbt.md`, and
  `region.mbt.md` document Matrix, Surface, backend surface/device, Context,
  FontOptions, FontFace, ScaledFont, Path, Pattern, and Region behavior with
  executable examples.
- `TESTING.md` defines the migration reliability gates and records why the
  pycairo test suite is useful but insufficient by itself.

## Gate Status

- Gate 1 API inventory: partial. A full inventory ledger exists in
  `API_INVENTORY.md`; multiple rows remain Partial or Decision. The
  `CAPI`, legacy uppercase enum alias constants, `SurfaceObserverMode`,
  `FreeTypeFontFace`, and `UserFontFace` rows are resolved product decisions.
  Cairo's native observer surface/device APIs and native FreeType/user-font
  extension APIs are intentionally outside the current pycairo-migration
  product.
- Gate 2 behavioral parity: partial. First MoonBit tests cover a small subset
  of pycairo's matrix, surface, context, pattern, raster-source callback,
  region, and error behavior.
- Gate 3 differential rendering: partial. Deterministic raw-pixel rendering
  tests exist for direct colors and explicit patterns, a direct C image oracle
  covers thirty-five deterministic ARGB32 scenes including stroke, rectangle,
  Bezier, transform, RGBA, linear/radial gradient, toy-font `text_path`,
  toy-font `show_text`, `glyph_path`, `show_glyphs`, `show_text_glyphs`,
  source-surface offset sampling, mask-surface offset compositing, and
  raster-source pattern repeat rendering, dashed round-cap stroke, clipped
  paint/fill cases, `OperatorClear` compositing output, group compositing
  output, mask pattern compositing output, even-odd fill-rule output, and a
  surface-pattern
  `Reflect`/`Nearest`/`DitherBest`/matrix combination plus transformed
  repeated linear-gradient `Repeat`/`Nearest`/`DitherFast`/matrix output,
  transformed radial-gradient `Reflect`/`Nearest`/`DitherGood`/matrix output,
  surface-pattern `Pad`/`Bilinear`/`DitherDefault`/matrix and
  `ExtendNone`/`Nearest`/`DitherNone`/matrix output, transformed
  linear-gradient `Pad`/`Bilinear`/`DitherBest`/matrix output, transformed
  radial-gradient `Repeat`/`Bilinear`/`DitherFast`/matrix output,
  surface-pattern `Repeat`/`Bilinear`/`DitherGood`/matrix output, transformed
  linear-gradient `ExtendNone`/`Good`/`DitherNone`/matrix output with
  duplicate-offset stops, transformed radial-gradient
  `Pad`/`Good`/`DitherDefault`/matrix output, curve/multi-patch mesh-pattern
  matrix output, and nested surface/linear/radial/mask pattern-stack
  clip/save/restore/OperatorAtop output,
  ScaledFont font/text/glyph extents and empty, single/multi/spaced ASCII,
  precomposed/decomposed Latin, CJK, Arabic RTL, and emoji UTF-8
  text-to-glyph coordinate cases are compared against direct C Cairo primitive
  oracles, and vector outputs
  have stable structural marker checks plus direct C oracle comparisons for
  seventeen deterministic PDF/PS/SVG scenes covering paint, stroke, fill/stroke
  rectangles, Bezier paths, transforms, linear/radial gradients, toy-font text
  paths, toy-font `show_text`, `glyph_path`, `show_glyphs`, two-page paint, clip, dashed stroke, repeated
  surface pattern, mask surface, and mesh pattern scenes. SVG comparison
  normalizes Cairo's dynamic `source-*` image ids. PDF metadata/custom
  metadata, page labels, outlines, multi-page output, URI link-tag annotations,
  named-destination tags, document-structure tags, and three two-page PDF
  document-feature/page-operation combinations also have direct C oracle or marker checks; PDF
  JPEG MIME passthrough has output checks; image/PDF/PS/SVG MIME support
  matrices are covered; PS combined DSC/multi-page output, SVG combined
  version/unit/multi-page output, PS/SVG Link tag inertness, PS/SVG
  destination/document-structure rectangle and text tag output, and
  cross-backend tagged multi-page text output, tagged `show_text_glyphs`
  output, a mixed vector/tag/text
  scene, and a layered three-page clip/dash/surface-pattern/mask/tag/text
  scene, and a wide three-page URI/destination/document-structure tag/vector
  scene have normalized direct C oracle checks matching Cairo 1.18.4 backend
  behavior. PDF tagged multi-page text, tagged `show_text_glyphs`, mixed
  vector/tag/text output, and layered three-page output plus the wide
  three-page tag/vector output also have explicit marker checks for page objects, link annotations, URI/
  destination entries, and StructTreeRoot elements. PS/SVG destination,
  document-structure, tagged `show_text_glyphs`, mixed vector/tag/text,
  layered three-page, and wide three-page tag
  scenes also have negative marker checks proving PDF-only tag metadata is not emitted.
  Full cross-run comparison against pycairo output is not yet automated.
- Gate 4 memory and lifetime: partial. Stub ownership follows the documented
  external-object pattern, and retained-owner stress now covers subsurfaces,
  data-backed surface patterns, data-backed raster-source acquire surfaces,
  mapped images, ImageData surface and
  mapped-image views, context target wrappers, and TeeSurface
  primary/target/index wrappers. External value-wrapper stress now covers
  `Path`, `Region`, `FontOptions`, `FontFace`, `ScaledFont`, solid/gradient/mesh
  `Pattern`, recording/similar/Tee `Surface`, and script stream `Device` in a
  1000-iteration loop. `ImageData` allocation stress now covers ordinary,
  buffer-backed, and mapped image data views in a 1000-iteration loop. Backend
  stream callback stress now covers PDF/PS/SVG stream surfaces, PNG stream
  write/read, script stream devices, and stream `WriteError` paths in a
  1000-iteration loop. Raster-source callback stress now covers callback
  set/get/manual acquire/release/replace/clear paths in a 1000-iteration loop,
  and deterministic callback fuzz covers repeated acquire/release replacement,
  temporary release-only state, callback clearing, finished-surface failures,
  dynamic compatible source-surface returns, and final post-clear recovery. The
  C glue installs cairoon's release trampoline for acquire-only states
  so retained acquired-surface owners are released even when the user supplies
  no release closure. Black-box raster-source tests also cover the pycairo
  acquire pattern that creates a compatible image from target/extents and
  applies the extents device offset.
  The current font stack still exposes macOS
  Cairo/Quartz/CoreText LeakSanitizer reports through toy-font,
  scaled-font, toy-text rendering, glyph rendering/path, and
  show-text-glyphs paths. These must be resolved or intentionally suppressed
  before claiming this gate.
  Finalizer graph fuzz now covers multi-seed surface/context/pattern/font/path/
  region/mapped-image/raster-source/script-device owner graphs, error exits,
  callback clearing, and allocation pressure under ASan. Broader platform
  coverage and stronger randomized finalizer/callback-edge coverage still
  remain before claiming the full memory gate.

## Last Verified

Prior full verifies passed on 2026-07-02, 2026-07-03, 2026-07-04,
2026-07-05, and earlier 2026-07-06 slices. The most recent 2026-07-06 run:

- `./scripts/verify.sh`: passed. The local reliability gate ran
  `moon fmt --check`, `scripts/check-project-layout.py`,
  `scripts/configure-link-flags.sh --check`, `scripts/check-ffi-ownership.py`,
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
- `moon -C cairoon test path_test.mbt --target native -v`: 7 black-box Path
  tests passed, covering empty paths, pycairo-compatible stringification
  including close-path continuation formatting, copied-path lifetime after the
  source context exits, typed segment iteration, flattened copies, and path
  equality/hash behavior.
- `moon -C cairoon test src/tests/context/path --target native -v`: 11
  black-box Context path tests passed, covering current-point behavior,
  relative path operations, pycairo rectangle path-extents behavior,
  close-path current-point reset, arc current-point creation,
  path copy/append independence, pycairo-style append string
  equivalence after clearing the source context, flattened append behavior, and
  path error propagation.
- `moon -C cairoon test src/tests/context/pycairo --target native -v`: 36
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
  polygon fill-extents coverage, stroke extents, and hit-testing.
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
  recovery, and a 72-step callback state-machine fuzz covering clear,
  release-only, acquire-only, acquire+release, failed acquire, dynamic
  compatible-source, callback-introspection, and owner-count balance
  transitions.
- `moon -C cairoon test surface_context_test.mbt surface_mapped_test.mbt
  surface.mbt.md --target native -v`: 32 scoped Surface/mapped-image tests and
  executable docs passed after adding pycairo-style success/error cleanup
  helpers.
- `moon -C cairoon test device_test.mbt backend_surfaces.mbt.md --target
  native -v`: 17 scoped Device/script backend tests and executable docs passed
  after adding pycairo-style device finish cleanup.
- `moon -C cairoon test --target native`: 340 tests passed after adding
  `Device::with_finished`, `Surface::with_finished`,
  `MappedImageSurface::with_unmapped`, and their executable docs examples.
- `moon -C cairoon info --target native`: passed, and `pkg.generated.mbti`
  records the new public scoped lifecycle helpers.
- ASan/LSan was not rerun for the scoped Surface lifecycle slice because it
  changed only MoonBit wrappers, tests, docs, and generated interface metadata,
  with no C glue, finalizer, callback trampoline, or retained-owner code
  change.
- ASan/LSan was not rerun for the scoped Device lifecycle slice because it
  changed only MoonBit wrappers, tests, docs, and generated interface metadata,
  with no C glue, finalizer, callback trampoline, or retained-owner code
  change.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  src/tests/pattern/core src/tests/pattern/mesh src/tests/pattern/pycairo
  src/tests/pattern/raster --target native -v`: 41
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
  owner-count recovery, and the 72-step callback state-machine fuzz.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the raster-source owner-count test-probe slice. The full runner
  still failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class. A grep of
  `/tmp/cairoon-raster-owner-count-asan.txt` found no heap-use-after-free,
  stack-use-after, heap-buffer-overflow, global-buffer-overflow, double-free,
  `cairoon_raster`, `raster_source`, `cairoon_pattern`,
  `raster_surface_owner`, or `pattern_raster_owner` entries; summary:
  `54975 byte(s) leaked in 398 allocation(s)`. The ASan-instrumented
  white-box executable was then run directly with
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0` for
  `pattern_raster_owner_wbtest.mbt:0-1` and exited 0; the output is recorded
  in `/tmp/cairoon-raster-owner-count-whitebox-asan.txt`.
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
- `moon -C cairoon test src/tests/api/enums --target native --deny-warn -v`: 4
  black-box tests passed after adding `Rgb16_565`, `Rgb30`, `Rgb96F`,
  `Rgba128F`, and negative-width `Format::stride_for_width` coverage.
- `moon -C cairoon test surface_subsurface_test.mbt --target native -v`: 3
  black-box tests passed after adding invalid-size coverage for
  `Surface::create_for_rectangle`.
- `moon -C cairoon test font_face_test.mbt scaled_font_test.mbt --target native
  -v`: 15 black-box tests passed after adding embedded-NUL validation for toy
  font family, context font-family selection, and ScaledFont text extents.
- `moon -C cairoon test font_face_test.mbt --target native -v`: 10
  black-box tests passed after adding pycairo-compatible raw C-int toy
  slant/weight parsing for `FontFace::toy_raw` and
  `Context::select_font_face_raw`, including `InvalidSlant`/`InvalidWeight`
  error mapping for invalid raw values.
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
- `moon -C cairoon test matrix_test.mbt matrix_property_test.mbt matrix.mbt.md
  --target native -v`: 13 Matrix tests passed, covering field/component
  semantics, deterministic property checks for multiplication associativity,
  inverse identity, composed point/distance transforms, distance-vs-point-delta
  behavior, and executable Matrix reference examples.
- `moon -C cairoon test path.mbt.md --target native -v`: 4 executable Path
  reference examples passed.
- `moon -C cairoon test pattern.mbt.md --target native -v`: 7 executable
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
  palettes, toy font faces with raw slant/weight parsing, Surface/Context font
  options, ScaledFont matrices/metrics, text-to-glyphs, and checked font
  errors.
- `moon -C cairoon test backend_surfaces.mbt.md --target native -v`: 8
  executable Backend Surface reference examples passed, covering PDF/PS/SVG
  stream output and writer errors, PDF metadata/outlines, PS DSC, SVG document
  units, recording replay, Tee fanout, script devices/surfaces, and checked
  backend-specific errors.
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
- Test-only source/mask/raster-source image-oracle helper coverage was added
  without changing the public API or native test count; sanitizer validation
  is recorded below.
- Executable backend surface/device reference documentation was added without
  rerunning ASan because no C glue, finalizer, callback trampoline, or retained
  owner code changed in that slice.
- Pure MoonBit PDF tag-output marker coverage for named destinations and
  document structure was added without rerunning ASan because no C glue,
  finalizer, callback trampoline, or retained owner code changed in that slice.
- Pure MoonBit Cairo float image-format coverage was added without rerunning
  ASan because no C glue, finalizer, callback trampoline, or retained owner
  code changed in that slice.
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
- Documentation-only product-decision audit for pycairo `CAPI`, legacy enum
  aliases, and non-implemented FreeType/user-font classes: `moon -C cairoon
  check --target native`, `moon -C cairoon test --target native -v`, and
  `moon -C cairoon info --target native` passed on 2026-07-03.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the source/mask offset image-oracle C helper slice. The full runner
  again failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class while running the black-box executable, before Moon could
  launch the white-box executable. The log at
  `/tmp/cairoon-source-mask-offset-asan.txt` reports
  `89578 byte(s) leaked in 476 allocation(s)`. A grep of that log found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, or double-free entries. The
  ASan-compiled white-box image oracle was therefore run directly with leak
  detection disabled, and exited 0 as recorded above.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the raster-source image-oracle C helper slice. The full runner
  again failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class after running the black-box executable and before
  launching the white-box executable. The log at
  `/tmp/cairoon-raster-source-oracle-asan.txt` reports
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
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the ScaledFont text-to-glyph direct C oracle helper slice. The full
  runner still failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class after the black-box executable ran and before Moon could
  launch the white-box executable. A grep of
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
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the glyph-index width FFI slice. The full runner still failed
  during the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer class
  after the black-box executable ran. A grep of
  `/tmp/cairoon-glyph-index-asan.txt` found no `ERROR: AddressSanitizer`,
  heap-use-after-free, stack-use-after, heap-buffer-overflow,
  global-buffer-overflow, or double-free entries; the `cairoon_context_glyph`
  hits were leak-stack frames. Summary:
  `1667619 byte(s) leaked in 12429 allocation(s)`. The ASan-instrumented
  black-box executable was then run directly with leak detection disabled for
  `value_types_test.mbt`, `glyph_array_test.mbt`, `text_to_glyphs_test.mbt`,
  `context.mbt.md`, and `README.mbt.md`; it exited 0 and
  `/tmp/cairoon-glyph-index-blackbox-asan.txt` records the selected tests. The
  ASan-instrumented white-box executable was likewise run for
  `scaled_font_oracle_wbtest.mbt` and `image_oracle_wbtest.mbt`; it exited 0
  and `/tmp/cairoon-glyph-index-whitebox-asan.txt` records those oracle tests.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the raster-source callback allocation stress slice. The full
  runner still failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class after the black-box executable ran. A grep of
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
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the backend stream callback stress slice. The full runner still
  failed during the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer
  class after the black-box executable ran. A grep of
  `/tmp/cairoon-stream-callback-stress-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
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
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the `ImageData` view allocation stress slice. The full runner still
  failed during the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer
  class after the black-box executable ran. A grep of
  `/tmp/cairoon-image-data-stress-asan.txt` found no
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
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the external value-wrapper stress slice. The full runner still
  failed during the known macOS FontRegistry/CoreText/ColorSync
  LeakSanitizer class after the black-box executable ran. A grep of
  `/tmp/cairoon-finalizer-value-stress-asan.txt` found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, double-free,
  `script_device_create_for_stream`, `cairoon_stream`, `cairoon_pattern`,
  `cairoon_path`, `cairoon_region`, `cairoon_device`, or `cairoon_surface`
  entries indicating invalid access; the `lifetime_stress` hit was the Moon
  test selector line. Summary:
  `55717 byte(s) leaked in 412 allocation(s)`. The ASan-instrumented
  black-box executable was then run directly with leak detection disabled using
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; it exited 0, and
  `/tmp/cairoon-finalizer-value-stress-blackbox-asan.txt` shows all four
  `lifetime_stress_test.mbt` tests executed without any AddressSanitizer
  invalid-access report.
- `run-asan.py --repo-root /Users/caimeo/code/pycairo/cairoon --pkg moon.pkg`:
  rerun for the image glyph-oracle helper slice. The full runner still failed
  during the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer class
  before launching the white-box executable. A grep of
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
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; it exited 0 and
  `/tmp/cairoon-image-glyph-oracle-whitebox-asan.txt` shows the image oracle
  test executed without any AddressSanitizer invalid-access report.
  The previous ASan record covers the image text-oracle helper slice, where
  the full runner still failed during the same known macOS LeakSanitizer class
  with the same summary while direct whitebox ASan exited 0.
  The earlier ASan record covers the two-page vector oracle helper slice. The
  full runner still
  failed during the known macOS FontRegistry/CoreText/ColorSync LeakSanitizer
  class before the white-box executable launched. A grep of
  `/tmp/cairoon-vector-multipage-asan.txt` found no `ERROR: AddressSanitizer`,
  heap-use-after-free, heap-buffer-overflow, global-buffer-overflow,
  double-free, `cairoon_test_render_vector_scene_oracle`,
  `cairoon_test_draw_vector_scene`, `cairoon_test_render_vector_surface`, or
  `cairoon_test_vector` entries. Summary:
  `56037 byte(s) leaked in 415 allocation(s)`.
  The ASan-instrumented white-box executable was then run directly with leak
  detection disabled using
  `ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0`; it exited 0 and
  `/tmp/cairoon-vector-multipage-whitebox-asan.txt` shows the vector output
  oracle test executed without any AddressSanitizer invalid-access report.
  The previous equality/hash rerun found no invalid access and no
  `cairoon_surface_equal`, `cairoon_surface_hash`, `cairoon_context_equal`,
  `cairoon_context_hash`, `cairoon_pattern_equal`, or `cairoon_pattern_hash`
  entries in the visible leak roots; it still failed during the same known
  macOS LeakSanitizer reporting class. Summary:
  `56037 byte(s) leaked in 415 allocation(s)`.
  The previous vector scene oracle rerun found no invalid access and no
  `cairoon_test_render_vector_scene_oracle`,
  `cairoon_test_draw_vector_scene`, or
  `cairoon_test_render_vector_surface` entries in the visible leak roots; it still
  failed during the known macOS LeakSanitizer reporting class documented in
  `TESTING.md`. Summary:
  `55445 byte(s) leaked in 407 allocation(s)`.
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
  helper stack, vector-output direct C oracle helper stack,
  ImageData helper/finalizer stack, or mapped-image data helper
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
  The later PS/SVG Link tag inertness slice added two pure MoonBit vector-output
  tests, raising the native suite to 233 tests; ASan/LSan was not rerun for that
  non-C change.
  The later image oracle slice added C helper scenes and was checked with the
  ASan runner at `/tmp/cairoon-image-oracle-asan.txt`: the full `moon test`
  ASan/LSan run still failed during the known macOS LeakSanitizer class before
  Moon could launch the white-box executable, with the same
  `55365 byte(s) leaked in 405 allocation(s)` summary and no
  AddressSanitizer invalid-access report. The ASan-instrumented white-box
  executable was then run directly with leak detection disabled and exited 0;
  `/tmp/cairoon-image-oracle-whitebox-asan.txt` shows the image oracle test
  executed, and greps found no `ERROR: AddressSanitizer`, heap-use-after-free,
  stack-use-after, global-buffer-overflow, heap-buffer-overflow, or double-free
  report.
  The later `ScaledFont::text_to_glyphs_only` slice is pure MoonBit API
  coverage for pycairo's `with_clusters=False` path; the native suite stayed at
  233 tests and ASan/LSan was not rerun for that non-C change.
  The later ScaledFont text-to-glyph oracle slice added a private C helper and
  a second white-box ScaledFont oracle test, raising the native suite to 249
  tests; ASan/LSan validation is recorded in `Last Verified` above.
  The later ScaledFont text-to-glyph matrix slice expanded that same white-box
  oracle test to cover empty, ASCII, precomposed Latin UTF-8, CJK UTF-8, and
  varied baseline coordinates without changing public API or test count; ASan
  was not rerun because no C glue changed.
  The later vector scene oracle slice broadened the private C vector oracle
  from a paint-only fixture to seven deterministic PDF/PS/SVG scenes covering
  paint, stroke, fill/stroke rectangles, Bezier paths, transforms, and
  linear/radial gradients, raising the native suite to 234 tests. The full
  ASan/LSan runner wrote `/tmp/cairoon-vector-scenes-asan.txt` and failed only
  in the known macOS LeakSanitizer class summarized above; greps found no
  `ERROR: AddressSanitizer`, heap-use-after-free, stack-use-after,
  heap-buffer-overflow, global-buffer-overflow, double-free, or new vector scene
  helper entries. The ASan-instrumented white-box executable was then run
  directly with leak detection disabled; it exited 0, and
  `/tmp/cairoon-vector-scenes-whitebox-asan.txt` shows the vector output scene
  oracle test executed without any AddressSanitizer invalid-access report.
  The later toy-font text-path and `show_text` oracle slices expanded those
  fixtures to nine scenes, and the later two-page oracle slice expanded them to
  ten scenes without changing the number of tests. The latest sanitizer
  validation is recorded in `Last Verified` above.
  The later Surface invalid-size slice added pure MoonBit black-box coverage for
  `create_similar`, `create_similar_image`, and `create_for_rectangle` mapping
  negative dimensions to `CairoInvalidArgument(InvalidSize, _)`, raising the
  native suite to 251 tests; ASan was not rerun because no C glue changed.
  The later ScaledFont matrix-composition slice added pure MoonBit black-box
  coverage for sheared font matrices, sheared CTMs, CTM translation suppression,
  and scale-matrix composition, raising the native suite to 252 tests; ASan was
  not rerun because no C glue changed.
  The later Region documentation slice added `region.mbt.md` with three
  executable examples, raising the native suite to 256 tests; ASan was not
  rerun because no C glue changed.
  The later Matrix documentation slice added `matrix.mbt.md` with four
  executable examples, raising the native suite to 260 tests; ASan was not
  rerun because no C glue changed.
  The later Matrix property-test slice added `matrix_property_test.mbt` with
  four deterministic property checks for multiplication associativity, inverse
  identity, composed point/distance transforms, and distance-vs-point-delta
  behavior, raising the native suite to 392 tests. The file is included in the
  targeted normal and ASan verification gate because it exercises value-level
  transform semantics used throughout drawing code.
  The later Path documentation slice added `path.mbt.md` with four executable
  examples covering typed segments, pycairo-style string formatting, flattened
  append behavior, copied-path ownership, and checked invalid-matrix errors,
  raising the native suite to 264 tests; ASan was not rerun because no C glue
  changed.
  The later Pattern documentation slice added `pattern.mbt.md` with six
  executable examples covering solid/shared state, surface patterns, gradients,
  mesh patches, raster-source callbacks, and checked subtype/index/lifecycle
  errors, raising the native suite to 270 tests; ASan was not rerun because no
  C glue changed.
  The later buffer-backed image oracle slice expanded `image_oracle_wbtest.mbt`
  so `Surface::image_for_data` renders the same ARGB32 scenes against the
  existing direct C Cairo oracle and verifies backing-buffer bytes match
  `copy_data`, raising the native suite to 271 tests; ASan was not rerun
  because no C glue changed. The later source/mask offset oracle slice expanded
  that image oracle helper to fifteen scenes covering non-zero
  `set_source_surface` and `mask_surface` offsets on ordinary and
  buffer-backed image surfaces. The later raster-source image oracle slice
  expanded it to sixteen scenes by comparing `Pattern::raster_source` repeat
  rendering against direct C Cairo. The later dashed-stroke image oracle slice
  expanded it to seventeen scenes by comparing dash and round-cap stroke state
  against direct C Cairo. The later clipped-output image oracle slice expanded
  it to eighteen scenes by comparing clipped paint/fill output against direct C
  Cairo. The later operator-output image oracle slice expanded it to nineteen
  scenes by comparing `OperatorClear` compositing output against direct C Cairo.
  The later surface-pattern-combo image oracle slice expanded it to twenty
  scenes by comparing surface-pattern `Reflect`/`Nearest`/`DitherBest`/matrix
  combination output against direct C Cairo.
  The later Surface documentation slice added `surface.mbt.md` with six
  executable examples covering image properties, buffer-backed data,
  similar/subsurface constructors, mapped images, PNG/MIME helpers, and checked
  surface errors, raising the native suite to 277 tests; ASan was not rerun
  because no C glue changed.
  The later Context documentation slice added `context.mbt.md` with eight
  executable examples covering construction/state, transforms, paths,
  fill/stroke output, clipping, groups, text/glyphs, and checked context
  errors, raising the native suite to 285 tests; ASan was not rerun because no
  C glue changed.
  The later Font documentation slice added `font.mbt.md` with seven executable
  examples covering FontOptions state/copy/merge, color palettes, toy font
  faces, Surface/Context font options, ScaledFont matrices/metrics,
  text-to-glyphs, and checked font errors, raising the native suite to 292
  tests; ASan was not rerun because no C glue changed.
  The later Backend Surface documentation slice added `backend_surfaces.mbt.md`
  with eight executable examples covering PDF/PS/SVG stream output and writer
  errors, PDF metadata/outlines, PS DSC, SVG document units, recording replay,
  Tee fanout, script devices/surfaces, and checked backend-specific errors,
  raising the native suite to 300 tests; ASan was not rerun because no C glue
  changed.
  The later PDF tag-output marker slice added two pure MoonBit white-box tests
  covering named destinations and document structure tags, raising the native
  suite to 302 tests; ASan was not rerun because no C glue changed.
  The later Cairo float image-format slice added two pure MoonBit black-box
  tests covering `Rgb96F` and `Rgba128F` construction/readback for ordinary and
  buffer-backed image surfaces, raising the native suite to 304 tests; ASan was
  not rerun because no C glue changed.
  The later format-stride slice added one pure MoonBit black-box test covering
  `Rgb16_565`, `Rgb30`, `Rgb96F`, `Rgba128F`, and negative-width
  `Format::stride_for_width`, raising the native suite to 305 tests; ASan was
  not rerun because no C glue changed.
  The later raster-source finished-surface slice added one black-box
  failure-injection test and C-side surface-finished tracking for callbacks,
  raising the native suite to 306 tests; targeted ASan with leak detection
  disabled passed for `pattern_test.mbt`.
  The later ordinary image-surface finished-status slice added one pure
  MoonBit black-box test covering idempotent `finish()` and `SurfaceFinished`
  mapping for `flush`, `copy_page`, and `show_page`, raising the native suite
  to 307 tests; ASan was not rerun because no C glue changed.
  The later raster-source optional-callback slice added release-only callback
  state APIs and one black-box test, raising the native suite to 308 tests;
  targeted ASan with leak detection disabled passed for `pattern_test.mbt`.
  The later backend MIME support matrix slice added one pure MoonBit black-box
  test, raising the native suite to 309 tests; ASan was not rerun because no C
  glue changed.
  The later spaced-ASCII text-to-glyph slice added one pure MoonBit black-box
  test and expanded the existing ScaledFont direct C oracle case set, raising
  the native suite to 310 tests; ASan was not rerun because no C glue changed.
  The later glyph-index width slice promoted `Glyph.index` and glyph marshal
  arrays to `UInt64`, added one pure value-type max-index test, and raised the
  native suite to 311 tests; targeted ASan validation is recorded above.
  The later pure value-type numeric-limit slice added one black-box test for
  pycairo `Rectangle`, `TextExtents`, and `TextCluster` boundary values,
  raising the native suite to 312 tests; ASan was not rerun because no C glue
  changed.
  The later surface numeric-limit slice added one black-box test for pycairo
  `Surface::set_device_offset`, `Surface::set_device_scale`, and
  `Surface::create_for_rectangle` extreme numeric cases, raising the native
  suite to 313 tests; ASan was not rerun because no C glue changed.
  The later PDF combined vector-output marker slice added one pure MoonBit
  white-box test covering metadata, custom metadata, page labels, outlines, URI
  links, named destinations, and document-structure tags across a two-page PDF,
  raising the native suite to 314 tests; ASan was not rerun because no C glue
  changed.
  The later PS DSC multi-page vector-output marker slice added one pure MoonBit
  white-box test covering language-level restriction, setup DSC comments,
  page-setup DSC comments, and two-page drawing markers, raising the native
  suite to 315 tests; the later backend-feature oracle slice upgraded this test
  with a direct C Cairo output oracle.
  The later SVG version-unit multi-page vector-output marker slice added one
  pure MoonBit white-box test covering SVG 1.2 version restriction, `SvgUnitPx`
  state, px width/height output, and two-page drawing markers, raising the
  native suite to 316 tests; the later backend-feature oracle slice upgraded
  this test with a direct C Cairo output oracle.
  The later PDF thumbnail vector-output marker slice added one pure MoonBit
  white-box test covering `Surface::pdf_set_thumbnail_size` output through
  `/Thumb` image markers and thumbnail dimensions, raising the native suite to
  317 tests; ASan was not rerun because no C glue changed.
  The later UTF-8 string-boundary slice added two pure MoonBit black-box tests
  covering embedded-NUL rejection for `FontFace::toy`,
  `Context::select_font_face`, and `ScaledFont::text_extents`, raising the
  native suite to 319 tests; ASan was not rerun because no C glue changed.
  The later Surface finished-status slice added one pure MoonBit black-box test
  covering `Surface::has_show_text_glyphs`, dirty markers, device offset/scale
  wrappers, and fallback-resolution wrappers after `finish()`, raising the
  native suite to 320 tests; ASan was not rerun because no C glue changed.
  The later backend surface error-path slice added three pure MoonBit
  black-box tests covering extended PDF custom-metadata/thumbnail/outline
  subtype mismatches, PS size/setup/page-setup subtype mismatches, and SVG
  document-unit getters after `finish()`, raising the native suite to 323
  tests; ASan was not rerun because no C glue changed.
  The later ImageData owner-status slice fixed ordinary `ImageData` views to
  check their retained base `Surface` wrapper before byte access and added two
  black-box tests for ordinary, buffer-backed, and PNG-loaded `get_data` after
  `finish()` plus retained-view base-finish invalidation, raising the native
  suite to 325 tests; ASan validation is recorded above.
  The later raster-source acquire-only release-trampoline slice changed C glue
  to install `cairoon_raster_source_release` whenever an acquire callback is
  installed, so acquired surface owners retained by C are released even without
  a user release closure. This changed no public API and kept the native suite
  at 325 tests; ASan/LSan validation is recorded above.
  The later external-object trait slice added pure MoonBit `Eq`/`Hash`
  implementations for hashable Cairo external objects, `Compare` for `Path`,
  `Eq` for unhashable `Region`, and three black-box tests, raising the native
  suite to 328 tests; ASan was not rerun because no C glue, finalizer, callback
  trampoline, or retained owner code changed.
  The later complex vector oracle slice added five private direct C vector
  scenes covering clip, dash, repeated surface patterns, mask surfaces, and
  mesh patterns across PDF/PS/SVG, plus SVG dynamic `source-*` id
  normalization. This changed only test-helper C glue and one white-box test,
  raising the native suite to 329 tests; ASan/LSan validation is recorded
  above.
  The later PDF tag oracle slice added three private PDF-only direct C vector
  scenes covering URI links, named destinations, and Document/Sect/H1/P
  structure tags. This changed only test-helper C glue and one white-box test,
  raising the native suite to 330 tests; ASan/LSan validation is recorded
  above.
  The later image-surface checked-getter slice changed public
  width/height/stride/format getters to `raise CairoError`, added status
  plumbing for copied-data readback, and covered `SurfaceFinished` plus
  non-image `SurfaceTypeMismatch`, raising the native suite to 331 tests;
  ASan/LSan validation is recorded above.
  The later PDF document-feature oracle slice added one private PDF-only
  direct C vector scene covering metadata, custom metadata, page labels,
  outlines, URI links, named destinations, and Document/Sect/P structure tags
  across two pages. This changed only test-helper C glue and one white-box
  test, raising the native suite to 332 tests; ASan/LSan validation is
  recorded above.
  The later PDF combined text document-feature oracle slice upgraded the
  combined metadata/custom-metadata/page-label/outline/URI/named-destination/
  document-structure marker test with a second private PDF-only direct C
  vector scene that includes text under Link, Dest, and Document/Sect/P tags.
  This changed only test-helper C glue and one existing white-box test.
  The later Region chainable-mutator slice changed public Region boolean
  methods to return the mutated receiver, matching pycairo's
  `intersect`/`subtract`/`union`/`xor` return semantics for both region and
  rectangle operands, and added one black-box test. This raised the native
  suite to 333 tests; ASan/LSan was not rerun because no C glue, finalizer,
  callback, or retained-owner code changed.
  The later raster-source owner-count slice added a private C test probe and
  one white-box test asserting that acquire-only repeated same-surface paints
  release cairoon's retained owner back to zero after each paint. This raised
  the native suite to 334 tests; ASan/LSan validation is recorded above.
  The later Surface scoped-lifecycle slice added public
  `Surface::with_finished` and `MappedImageSurface::with_unmapped`, matching
  pycairo surface and mapped-image context-manager cleanup with success and
  Cairo-error coverage, plus two executable Surface docs examples and refreshed
  generated interface metadata. This raised the native suite to 338 tests;
  ASan/LSan was not rerun because no C glue, finalizer, callback trampoline,
  or retained-owner code changed.
  The later Device scoped-lifecycle slice added public
  `Device::with_finished`, matching pycairo device context-manager cleanup with
  success and Cairo-error coverage, plus one executable Backend Surface docs
  example and refreshed generated interface metadata. This raised the native
  suite to 340 tests; ASan/LSan was not rerun because no C glue, finalizer,
  callback trampoline, or retained-owner code changed.
  The later dashed-stroke image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from sixteen to seventeen scenes,
  adding dash and round-cap stroke-state coverage without changing the public
  API or adding a new test case. The targeted `image_oracle_wbtest.mbt` run
  passed 2 tests, the targeted ASan build passed 2 tests with leak detection
  disabled, and the full native suite remained at 340 tests.
  The later clipped-output image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from seventeen to eighteen scenes,
  adding clipped paint/fill output coverage without changing the public API or
  adding a new test case. The targeted `image_oracle_wbtest.mbt` run passed 2
  tests, the targeted ASan build passed 2 tests with leak detection disabled,
  and the full native suite remained at 340 tests.
  The later operator-output image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from eighteen to nineteen scenes,
  adding `OperatorClear` compositing output coverage without changing the
  public API or adding a new test case. The targeted `image_oracle_wbtest.mbt`
  run passed 2 tests, the targeted ASan build passed 2 tests with leak
  detection disabled, and the full native suite remained at 340 tests.
  The later surface-pattern-combo image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from nineteen to twenty scenes,
  adding `Reflect`/`Nearest`/`DitherBest`/matrix surface-pattern coverage
  without changing the public API or adding a new test case. The targeted
  `image_oracle_wbtest.mbt` run passed 2 tests, and the targeted ASan build
  passed 2 tests with leak detection disabled.
  The later transformed-gradient-pattern image oracle slice expanded the
  ordinary and buffer-backed direct C ARGB32 image oracle from twenty to
  twenty-one scenes, adding transformed repeated linear-gradient
  `Repeat`/`Nearest`/`DitherFast`/matrix coverage without changing the public
  API or adding a new test case. The targeted `image_oracle_wbtest.mbt` run
  passed 2 tests, and the targeted ASan build passed 2 tests with leak detection
  disabled. The full native suite remained at 457 tests.
  The later mesh-pattern image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from twenty-one to twenty-two
  scenes, adding mesh-pattern fill output coverage by reusing the existing
  direct C vector-oracle mesh helper. The targeted `image_oracle_wbtest.mbt`
  run passed 2 tests, the targeted ASan build passed 2 tests with leak
  detection disabled, and the full native suite remained at 457 tests.
  The later group-compositing image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from twenty-two to twenty-three
  scenes, adding `push_group_with_content`/`pop_group_to_source`/
  `paint_with_alpha` output coverage without changing the public API or adding
  a new test case. The targeted `image_oracle_wbtest.mbt` run passed 2 tests,
  the targeted ASan build passed 2 tests with leak detection disabled, and the
  full native suite remained at 457 tests.
  The later mask-pattern image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from twenty-three to twenty-four
  scenes, adding `Context::mask(Pattern)` alpha-mask compositing output
  coverage without changing the public API or adding a new test case. The
  targeted `image_oracle_wbtest.mbt` run passed 2 tests, the targeted ASan
  build passed 2 tests with leak detection disabled, and the full native suite
  remained at 457 tests.
  The later even-odd fill-rule image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from twenty-four to twenty-five
  scenes, adding `Context::set_fill_rule(FillEvenOdd)`/`fill` output coverage
  without changing the public API or adding a new test case. The targeted
  `image_oracle_wbtest.mbt` run passed 2 tests, the targeted ASan build passed
  2 tests with leak detection disabled, and the full native suite remained at
  457 tests.
  The later radial-pattern-combo image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from twenty-five to twenty-six
  scenes, adding transformed radial-gradient `Reflect`/`Nearest`/`DitherGood`
  matrix output coverage without changing the public API or adding a new test
  case. The targeted `image_oracle_wbtest.mbt` run passed 2 tests, the targeted
  ASan build passed 2 tests with leak detection disabled, and the full native
  suite remained at 457 tests.
  The later expanded-pattern-combo image oracle slice expanded the ordinary
  and buffer-backed direct C ARGB32 image oracle from twenty-six to thirty
  scenes, adding surface-pattern `Pad`/`Bilinear`/`DitherDefault`/matrix,
  surface-pattern `ExtendNone`/`Nearest`/`DitherNone`/matrix, transformed
  linear-gradient `Pad`/`Bilinear`/`DitherBest`/matrix, and transformed
  radial-gradient `Repeat`/`Bilinear`/`DitherFast`/matrix output coverage
  without changing the public API or adding a new test case. The targeted
  `image_oracle_wbtest.mbt` run passed 2 tests, and the current full native
  suite remains at 485 tests.
  The later pattern-combo continuation slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from thirty to thirty-four scenes,
  adding surface-pattern `Repeat`/`Bilinear`/`DitherGood`/matrix, transformed
  linear-gradient `ExtendNone`/`Good`/`DitherNone`/matrix with duplicate-offset
  stops, transformed radial-gradient `Pad`/`Good`/`DitherDefault`/matrix, and
  curve/multi-patch mesh-pattern matrix output coverage without changing the
  public API or adding a new test case. The targeted `image_oracle_wbtest.mbt`
  run passed 2 tests, and the current full native suite remains at 485 tests.
  The later pattern-stack image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from thirty-four to thirty-five
  scenes, adding nested surface/linear/radial/mask pattern-stack
  clip/save/restore/OperatorAtop output coverage without changing the public
  API. The targeted `src/tests/oracle/image` run passed 2 tests.
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
  The later context group-target lifetime slice changed `get_group_target`
  returned surfaces to retain the `Context` wrapper, added one black-box test
  proving the returned group target remains readable after its creating context
  helper scope exits, and closed the `Construction and target lifetime` sub-row
  as Done. This raised the native suite to 343 tests. `./scripts/verify.sh`
  passed, including the full 343-test native suite.
  The later ScriptDevice product-scope slice marked `ScriptDevice` /
  `ScriptSurface` Done by recording that Python file-like object adapters are
  represented by explicit MoonBit stream callbacks rather than Python objects;
  the existing 23-test device/backend/lifetime target passed.
  The later PS/SVG Link tag oracle slice upgraded backend inertness checks with
  a direct C Cairo oracle comparison for the shared Link tag scene on PS and
  SVG outputs. This raised `vector_output_wbtest.mbt` to 23 tests and the full
  native suite to 344 tests.
  The later ScaledFont UTF-8 oracle slice expanded the existing direct C Cairo
  ScaledFont oracle inputs to cover decomposed Latin text extents plus
  decomposed Latin, Arabic RTL, and emoji/non-BMP `text_to_glyphs` cases. This
  did not add public API or a new test case; the targeted 2-test
  `scaled_font_oracle_wbtest.mbt` run passed, including an ASan-compiled rerun
  with leak detection disabled.
  The later raster-source compatible-extents slice ported pycairo's acquire
  pattern that creates a compatible image from callback target/extents, applies
  the extents device offset, paints into it, and balances release callbacks.
  This raised `pattern_test.mbt` to 19 tests and the full native suite to 345
  tests.
  The later PDF text-tag oracle slice added three direct C Cairo oracle scenes
  for URI-link, named-destination, and document-structure tags drawn with
  `show_text`. This raised `vector_output_wbtest.mbt` to 24 tests and the full
  native suite to 346 tests.
  The later backend tag/text-tag oracle slice expanded that check to normalized
  direct C Cairo comparisons for PS and SVG destination and shared
  Document/Sect/H1/P rectangle and text tag scenes. This raised
  `vector_output_wbtest.mbt` to 25 tests and the full native suite to 347
  tests.
  The later tagged multi-page text oracle slice added one cross-backend direct C
  Cairo comparison covering URI links on page one and named-destination plus
  Document/Sect/P text tags on page two. This raised
  `vector_output_wbtest.mbt` to 26 tests and the full native suite to 348
  tests.
  The later raster-source deterministic callback fuzz slice added a 25-step
  replacement/failure/recovery test covering temporary release-only state,
  callback clearing, finished-surface failure injection, dynamic compatible
  source-surface returns from acquire callbacks, manual callback retrieval, and
  final post-clear recovery. This raised `pattern_test.mbt` to 20 tests and the
  full native suite to 349 tests.
  The later PDF tagged multi-page text marker slice added a structural marker
  check for the existing two-page Link/Dest/Document/Sect/P text scene,
  asserting page count, page objects, annotations, URI/destination entries, and
  StructTreeRoot elements in the emitted PDF. This raised
  `vector_output_wbtest.mbt` to 27 tests and the full native suite to 350
  tests.
  The later PS/SVG tagged multi-page text inertness slice added negative marker
  checks for the same two-page Link/Dest/Document/Sect/P text scene on
  PostScript and SVG, proving those backends do not emit PDF-only annotations,
  destinations, URI strings, or structure-tree metadata for the scene.
  The later PDF rectangle tag marker slice added stable marker assertions for
  the direct-C URI-link, named-destination, and Document/Sect/H1/P rectangle
  tag scenes, covering annotations, destination names, and structure-tree
  output from the compact geometry fixtures.
  The later PDF text tag marker slice tightened the direct-C text-tag fixtures
  to compact in-page text geometry, added stable marker assertions for
  URI-link, named-destination, and Document/Sect/H1/P text tag output, and
  extended PS/SVG negative marker checks to the URI-link text tag scene.
  The later PDF direct document-feature marker slice added stable marker
  assertions for the direct-C document-feature scene, covering metadata, custom
  metadata, page labels, outlines, URI/destination links, and Document/Sect/P
  structure output.
  The later PS/SVG tag metadata absence slice added negative marker checks for
  destination and document-structure rectangle/text tag scenes, proving those
  backends do not emit PDF-only annotations, destinations, structure-tree
  markers, or link metadata for those tags. This raised
  `vector_output_wbtest.mbt` to 28 tests and the full native suite to 351
  tests.
  The later mixed vector/tag/text oracle slice added a single-page
  cross-backend scene combining clip, dash, regular drawing, toy-font text, URI
  links, named destinations, and Document/Sect/P structure tags. This raised
  `vector_output_wbtest.mbt` to 29 tests and the full native suite to 352
  tests.
  The later mixed vector/tag/text marker slice added PDF combined tag marker
  assertions and PS/SVG negative PDF-metadata marker assertions for that mixed
  scene. This raised `vector_output_wbtest.mbt` to 31 tests and the full
  native suite to 354 tests.
  The later raster-source acquire-only owner fuzz slice added a 64-step
  replacement fuzz for retained-owner balancing and added that white-box file
  to the normal and ASan verification gates. This raised the full native suite
  to 355 tests.
  The later stream vector output equivalence slice added a white-box
  PDF/PS/SVG stream-vs-file normalized equality test for a deterministic
  two-page scene and added stream black-box/white-box files to the normal and
  ASan verification gates. This raised the full native suite to 356 tests.
  The later raster-source stale-release replacement slice added one white-box
  owner-count test proving release-only to acquire-only callback replacement
  drops the stale release closure while cairoon's internal release trampoline
  still balances retained owners. This raised
  `pattern_raster_owner_wbtest.mbt` to 3 tests and the full native suite to
  357 tests.
  The later gradient color-stop ordering/snapshot slice added one black-box
  test proving duplicate-offset color stops preserve cairo insertion order and
  `get_color_stops_rgba` returns a copied MoonBit snapshot that does not grow
  after later pattern mutation. This raised `pattern_gradient_test.mbt` to 5
  tests and the full native suite to 358 tests.
  The later pycairo close-path stringification slice added one black-box Path
  test proving `Path::to_string` matches pycairo's `close path` line plus the
  continuation `move_to` segment emitted by cairo after closing a subpath. This
  raised `path_test.mbt` to 6 tests and the full native suite to 359 tests.
  The later pycairo append-path string equivalence slice added one black-box
  Context path test proving `append_path` preserves the copied path's
  pycairo-style string after the source context has been cleared. This raised
  `context_path_test.mbt` to 10 tests and the full native suite to 360 tests.
  The later PDF/PS stream target lifetime slice added one black-box Context
  lifetime test proving `Context::new` keeps vector stream targets alive after
  the original surface wrapper leaves scope, and added `context_lifetime_test.mbt`
  to the normal and ASan verification gates. This raised
  `context_lifetime_test.mbt` to 9 tests and the full native suite to 361 tests.
  The later TeeSurface positive out-of-range status slice added one black-box
  test proving a valid tee surface preserves Cairo's positive out-of-range
  `NoMemory` status as `CairoMemoryError(NoMemory, _)`, matching pycairo's
  `MemoryError` path, and added `surface_tee_test.mbt` to the normal and ASan
  verification gates. This raised `surface_tee_test.mbt` to 4 tests and the
  full native suite to 362 tests.
  The later mapped-image scoped-error upload slice added one black-box test
  proving `MappedImageSurface::with_unmapped` uploads painted data before
  propagating a Cairo error, and added `surface_mapped_test.mbt` to the normal
  and ASan verification gates. This raised `surface_mapped_test.mbt` to 6 tests
  and the full native suite to 363 tests.
  The later pycairo polygon fill-extents slice added one black-box Context
  extents test proving Cairo's line-to-created polygon fill bounds match
  pycairo's `(0, 0, 1, 1)` expectation, and added context state/matrix/extents
  tests to the normal and ASan verification gates. This raised
  `context_extents_test.mbt` to 5 tests and the full native suite to 364 tests.
  The later pycairo mesh curve-first patch slice added one black-box
  MeshPattern test proving a patch can start with `curve_to` before any
  explicit `move_to`, added the missing `set_corner_color_rgb` construction
  error check, and added gradient/mesh pattern tests to the normal and ASan
  verification gates. This raised `pattern_mesh_test.mbt` to 6 tests and the
  full native suite to 365 tests.
  The later pycairo empty-path clip slice added one black-box Context clip
  test proving `clip()` with no current path makes `in_clip` false until
  `reset_clip()` restores the surface clip, and added `context_clip_test.mbt`
  to the normal and ASan verification gates. This raised
  `context_clip_test.mbt` to 6 tests and the full native suite to 366 tests.
  The later pycairo source RGBA round-trip slice added one black-box Context
  painting test proving `set_source_rgb/rgba` installs a solid pattern whose
  RGBA values are visible through `get_source().get_rgba()`, and added
  `context_painting_test.mbt` to the normal and ASan verification gates. This
  raised `context_painting_test.mbt` to 7 tests and the full native suite to
  367 tests.
  The later pycairo rectangle path-extents slice added one black-box Context
  path test proving `rectangle(1, 2, 4, 5)` yields path extents
  `(1, 2, 5, 7)`, and added `context_path_test.mbt` to the normal and ASan
  verification gates. This raised `context_path_test.mbt` to 11 tests and the
  full native suite to 368 tests.
  The later pycairo group-target stack-restoration slice added one black-box
  Context group test proving `get_group_target()` switches away from the
  original target inside `push_group()` and restores to the original target
  after both `pop_group()` and `pop_group_to_source()`, and added
  `context_group_test.mbt` to the normal and ASan verification gates. This
  raised `context_group_test.mbt` to 4 tests and the full native suite to 369
  tests.
  The later pycairo context font-extents parity slice added one black-box
  Context text test proving `Context::font_extents()` matches the current
  `ScaledFont::extents()`, and added `context_text_test.mbt` and
  `glyph_array_test.mbt` to the normal and ASan verification gates. This raised
  `context_text_test.mbt` to 6 tests and the full native suite to 370 tests.
  The later ScaledFont returned-object lifetime slice added one black-box test
  proving `ScaledFont::get_font_face()` and `get_font_options()` remain usable
  after the source scaled-font scope exits, and added `font_options_test.mbt`,
  `font_face_test.mbt`, `scaled_font_test.mbt`, and `lifetime_stress_test.mbt`
  to the normal and ASan verification gates. This raised
  `scaled_font_test.mbt` to 8 tests and the full native suite to 371 tests.
  The later Path/Region lifetime gate slice added black-box tests proving a
  copied `Path` remains usable after its source `Context` scope exits and a
  copied `Region` remains usable after its source `Region` scope exits, then
  added `path_test.mbt` and `region_test.mbt` to the normal and ASan
  verification gates. This raised `path_test.mbt` to 7 tests,
  `region_test.mbt` to 10 tests, and the full native suite to 373 tests.
  The later Surface/Device targeted gate slice refactored `scripts/verify.sh`
  to drive the normal and ASan target lists from one shared array, then added
  `surface_context_test.mbt`, `image_data_test.mbt`,
  `surface_subsurface_test.mbt`, `surface_recording_test.mbt`,
  `surface_mime_test.mbt`, `surface_pdf_test.mbt`, `surface_ps_test.mbt`,
  `surface_svg_test.mbt`, `device_test.mbt`, and `object_traits_test.mbt` to
  both gates. This did not add public API or new tests; it makes the existing
  67 surface/device/object-trait tests part of the routine ASan reliability
  sweep.
  The later raw FFI split slice moved the `FontOptions`, `FontFace`,
  `ScaledFont`, and text-to-glyphs extern declarations from the 2580-line
  `ffi.mbt` into `ffi_font.mbt`, added that file to the native target list, and
  reduced `ffi.mbt` to 2226 lines. This did not change public API or test
  count.
  The later Font raw FFI family split slice moved FontOptions, FontFace,
  ScaledFont, and text-to-glyphs result extern declarations from the 353-line
  `ffi_font.mbt` into `ffi_font_options.mbt`, `ffi_font_face.mbt`,
  `ffi_scaled_font.mbt`, and `ffi_text_to_glyphs.mbt`, added all four files to
  the native target list, and removed the now-empty aggregate `ffi_font.mbt`.
  This did not change public API or test count.
  The later pattern raw FFI split slice moved raw `Pattern`, mesh-pattern, and
  raster-source-pattern extern declarations from `ffi.mbt` into
  `ffi_pattern.mbt`, added that file to the native target list, and reduced
  `ffi.mbt` to 1866 lines. This did not change public API or test count.
  The later Pattern raw FFI family split slice moved mesh-pattern and
  raster-source-pattern extern declarations from the 359-line
  `ffi_pattern.mbt` into `ffi_pattern_mesh.mbt` and
  `ffi_pattern_raster_source.mbt`, added both files to the native target list,
  and left `ffi_pattern.mbt` as the 184-line base/surface/solid/gradient extern
  file. This did not change public API or test count.
  The later Path/Region raw FFI split slice moved raw `Path` and `Region`
  extern declarations from `ffi.mbt` into `ffi_path.mbt` and
  `ffi_region.mbt`, added both files to the native target list, and reduced
  `ffi.mbt` to 1683 lines. This did not change public API or test count.
  The later Device raw FFI split slice moved raw `Device`, script-device,
  script-surface, and surface-get-device extern declarations from `ffi.mbt`
  into `ffi_device.mbt`, added that file to the native target list, and
  reduced `ffi.mbt` to 1578 lines. This did not change public API or test
  count.
  The later PDF surface raw FFI split slice moved raw PDF surface extern
  declarations from `ffi.mbt` into `ffi_pdf_surface.mbt`, added that file to
  the native target list, and reduced `ffi.mbt` to 1481 lines. This did not
  change public API or test count.
  The later PostScript surface raw FFI split slice moved raw PostScript surface
  extern declarations from `ffi.mbt` into `ffi_ps_surface.mbt`, added that file
  to the native target list, and reduced `ffi.mbt` to 1404 lines. This did not
  change public API or test count.
  The later SVG surface raw FFI split slice moved raw SVG surface extern
  declarations from `ffi.mbt` into `ffi_svg_surface.mbt`, added that file to the
  native target list, and reduced `ffi.mbt` to 1344 lines. This did not change
  public API or test count.
  The later Tee surface raw FFI split slice moved raw Tee surface extern
  declarations from `ffi.mbt` into `ffi_tee_surface.mbt`, added that file to the
  native target list, and reduced `ffi.mbt` to 1315 lines. This did not change
  public API or test count.
  The later ImageData raw FFI split slice moved raw `ImageData` and image/mapped
  get-data extern declarations from `ffi.mbt` into `ffi_image_data.mbt`, added
  that file to the native target list, and reduced `ffi.mbt` to 1270 lines. This
  did not change public API or test count.
  The later surface raw FFI split slice moved raw image, recording, base
  surface, mapped-image-surface, PNG stream, MIME-data, and surface
  font-options extern declarations from `ffi.mbt` into `ffi_surface.mbt`, added
  that file to the native target list, and reduced `ffi.mbt` to 906 lines. This
  did not change public API or test count.
  The later Surface raw FFI family split slice moved image, mapped-image,
  recording, PNG, MIME, state/page, and surface font-options extern
  declarations from the 363-line `ffi_surface.mbt` into
  `ffi_image_surface.mbt`, `ffi_mapped_image_surface.mbt`,
  `ffi_recording_surface.mbt`, `ffi_surface_png.mbt`,
  `ffi_surface_mime.mbt`, `ffi_surface_state.mbt`, and
  `ffi_surface_font_options.mbt`, added all seven files to the native target
  list, and left `ffi_surface.mbt` as the 54-line base-surface extern file.
  This did not change public API or test count.
  The later Context core raw FFI split slice moved raw context construction,
  status, identity, save/restore, tag, target/source, and group extern
  declarations from `ffi.mbt` into `ffi_context_core.mbt`, added that file to
  the native target list, and reduced `ffi.mbt` to 820 lines. This did not
  change public API or test count.
  The later Context font/text raw FFI split slice moved raw context
  font-options, font-face, toy-font selection, font-matrix, text, glyph,
  show-text-glyphs, and scaled-font extern declarations from `ffi.mbt` into
  `ffi_context_font_text.mbt`, added that file to the native target list, and
  reduced `ffi.mbt` to 659 lines. This did not change public API or test count.
  The later Context matrix raw FFI split slice moved raw context transform,
  CTM, identity-matrix, and user/device coordinate-conversion extern
  declarations from `ffi.mbt` into `ffi_context_matrix.mbt`, added that file to
  the native target list, and reduced `ffi.mbt` to 559 lines. This did not
  change public API or test count.
  The later Context drawing-state raw FFI split slice moved raw context
  line-style, hairline, fill/operator/antialias/tolerance, miter, and dash
  extern declarations from `ffi.mbt` into `ffi_context_state.mbt`, added that
  file to the native target list, and reduced `ffi.mbt` to 444 lines. This did
  not change public API or test count.
  The later Context path raw FFI split slice moved raw context path
  construction, current-point, copy-path, and append-path extern declarations
  from `ffi.mbt` into `ffi_context_path.mbt`, added that file to the native
  target list, and reduced `ffi.mbt` to 311 lines. This did not change public
  API or test count.
  The later Context clip/extents raw FFI split slice moved raw context clip,
  clip-rectangle-list, fill/stroke/path extents, and hit-testing extern
  declarations from `ffi.mbt` into `ffi_context_clip_extents.mbt`, added that
  file to the native target list, and reduced `ffi.mbt` to 225 lines. This did
  not change public API or test count.
  The later Context paint raw FFI split slice moved raw context source,
  paint/mask/fill/stroke, and page-operation extern declarations from
  `ffi.mbt` into `ffi_context_paint.mbt`, added that file to the native target
  list, and reduced `ffi.mbt` to 142 lines. This did not change public API or
  test count.
  The later Context wrapper split slice moved public `Context` font/text,
  transform, drawing-state, path, clip/extents/hit-test, and source/paint/page
  wrappers from the 1000-line `context.mbt` into six family files matching the
  raw FFI split, leaving `context.mbt` as the 117-line core wrapper file. This
  did not change public API or test count.
  The later Context C glue split slice moved context font/text,
  matrix/coordinate-conversion, drawing-state/line-style/dash, path
  construction/copy, clip/extents/hit-test, and source/paint/page C stubs from
  the 1518-line `cairoon_context.c` into six family C files matching the raw
  FFI and wrapper splits, leaving `cairoon_context.c` as the 195-line core
  construction/status/tag/target/source/group glue file. This did not change
  public API or test count.
  The later Surface C glue split slice moved image surface constructors,
  PNG-read helpers, image queries/copy-data, mapped-image lifecycle/queries,
  and recording-surface constructors/extents from the 975-line
  `cairoon_surface.c` into `cairoon_image_surface.c`,
  `cairoon_mapped_image_surface.c`, and `cairoon_recording_surface.c`, leaving
  `cairoon_surface.c` as the 516-line base surface glue file. This did not
  change public API or test count.
  The later base Surface C glue split slice moved PNG writers, MIME helpers,
  state/page helpers, and surface font-options from the 516-line
  `cairoon_surface.c` into `cairoon_surface_png.c`,
  `cairoon_surface_mime.c`, `cairoon_surface_state.c`, and
  `cairoon_surface_font_options.c`, leaving `cairoon_surface.c` as the
  161-line base creation/status/equality/hash/type/finish glue file. This did
  not change public API or test count.
  The later Surface wrapper split slice moved image, PNG, MIME, recording,
  TeeSurface, state/page, and surface font-options public wrapper methods from
  the 496-line `surface.mbt` into `image_surface.mbt`, `surface_png.mbt`,
  `surface_mime.mbt`, `recording_surface.mbt`, `tee_surface.mbt`,
  `surface_state.mbt`, and `surface_font_options.mbt`, leaving `surface.mbt`
  as the 122-line core helper/constructor/status/device/finish wrapper file.
  This did not change public API or test count.
  The later Pattern C glue split slice moved mesh-pattern operations and
  raster-source callback/owner lifecycle glue from the 921-line
  `cairoon_pattern.c` into `cairoon_mesh_pattern.c` and
  `cairoon_raster_source_pattern.c`, leaving `cairoon_pattern.c` as the
  283-line base/surface/solid/gradient state glue file. This did not change
  public API or test count.
  The later raster-source callback C glue split slice moved retained callback
  state, acquired-surface owner tracking, Cairo acquire/release trampolines,
  and the owner-count test probe from the 417-line
  `cairoon_raster_source_pattern.c` into
  `cairoon_raster_source_callbacks.c`, leaving
  `cairoon_raster_source_pattern.c` as the 125-line public raster-source
  constructor/callback-accessor export file. This did not change public API or
  test count.
  The later Pattern wrapper split slice moved gradient, mesh, and raster-source
  public wrapper methods from the 514-line `pattern.mbt` into
  `pattern_gradient.mbt`, `pattern_mesh.mbt`, and
  `pattern_raster_source.mbt`, leaving `pattern.mbt` as the 136-line
  solid/surface/common-state wrapper file. This did not change public API or
  test count.
  The later Pattern black-box test split slice moved the raster-source
  callback/lifetime/error tests from the 682-line `pattern_test.mbt` into
  `pattern_raster_source_test.mbt`, leaving `pattern_test.mbt` focused on
  solid/surface/common-state behavior. This did not change public API or test
  count.
  The later raster-source black-box test split slice moved deterministic
  callback fuzz and callback getter/state tests from the 515-line
  `pattern_raster_source_test.mbt` into
  `pattern_raster_source_fuzz_test.mbt` and
  `pattern_raster_source_state_test.mbt`, leaving
  `pattern_raster_source_test.mbt` as the 246-line core raster-source
  render/error/lifetime test file. This did not change public API or test
  count.
  The later Font C glue split slice moved font-options, toy-font-face,
  scaled-font, and scaled-font oracle stubs from the 772-line
  `cairoon_font.c` into `cairoon_font_options.c`,
  `cairoon_font_face.c`, `cairoon_scaled_font.c`, and
  `cairoon_scaled_font_oracle.c`. This did not change public API or test
  count.
  The later test-vector C glue split slice moved shared vector scene ids and
  prototypes into `cairoon_test_vector_private.h`, common vector scene drawing
  into `cairoon_test_vector_scenes.c`, and backend-specific feature renderers
  into `cairoon_test_pdf_vector.c`, `cairoon_test_ps_vector.c`, and
  `cairoon_test_svg_vector.c`, leaving `cairoon_test_vector.c` as the 92-line
  exported oracle entry file. This did not change public API or test count.
  The later test-vector tag scene C glue split slice moved direct-C
  URI/destination/structure tag, text-tag, mixed tag/vector, layered multi-page,
  and wide multi-page tag scene fixtures from the 452-line
  `cairoon_test_vector_scenes.c` into
  `cairoon_test_vector_tag_scenes.c`, leaving
  `cairoon_test_vector_scenes.c` as the 135-line primitive scene dispatcher
  file. This did not change public API or test count.
  The later layered multi-page vector/tag oracle slice added scene 27, a
  three-page PDF/PS/SVG direct C oracle combining clip, dash, surface pattern,
  mask surface, URI link tags, Document/Sect/P structure tags, and toy-font
  text. It also added PDF combined marker assertions and PS/SVG negative
  PDF-metadata marker assertions for that scene. This raised
  `vector_output_wbtest.mbt` to 34 tests and the full native suite to 376
  tests.
  The later tagged multi-page stream equivalence slice added one
  `surface_stream_wbtest.mbt` case proving PDF/PS/SVG stream-writer output
  matches file output after normalization for a three-page URI-link and
  Document/Sect/P text-tag scene. This raised `surface_stream_wbtest.mbt` to 2
  tests and the full native suite to 377 tests.
  The later raster-source failed-acquire owner-count fuzz slice added one
  white-box test alternating finished-surface acquire failures with successful
  callback replacements while asserting cairoon's retained owner counts return
  to zero after each paint. This raised `pattern_raster_owner_wbtest.mbt` to 4
  tests and the full native suite to 378 tests.
  The later wide multi-page vector/tag oracle slice added scene 28, a
  three-page PDF/PS/SVG direct C oracle combining URI link tags, destination
  links, named destinations, Document/Sect/P structure tags, toy-font text, and
  surface-pattern vector drawing. It also added PDF combined marker assertions
  and PS/SVG negative PDF-metadata marker assertions for that scene. This raised
  `vector_output_wbtest.mbt` to 37 tests and the full native suite to 381 tests.
  The later wide multi-page stream equivalence slice added one
  `surface_stream_wbtest.mbt` case proving PDF/PS/SVG stream-writer output
  matches file output after normalization for the wide three-page URI/
  destination/Document/Sect/P tag/vector scene. This raised
  `surface_stream_wbtest.mbt` to 3 tests and the full native suite to 382 tests.
  The later vector stream invalid-status fallback slice expanded
  `surface_stream_test.mbt` to cover PDF/PS/SVG writer `WriteError` mapping and
  `LastStatus` callback-return normalization to `WriteError`. This raised
  `surface_stream_test.mbt` to 9 tests and the full native suite to 383 tests.
  The later PNG/script stream invalid-status fallback slice added one PNG
  writer `LastStatus` fallback test and one script stream writer `LastStatus`
  fallback test, proving the shared copied-byte writer trampoline normalizes
  invalid callback statuses to `WriteError` beyond vector surfaces. This raised
  `surface_stream_test.mbt` to 10 tests, `device_test.mbt` to 9 tests, and the
  full native suite to 385 tests.
  The later callback invocation reference-balance slice made `cairoon_stream`
  and raster-source callback glue incref C-held MoonBit arguments before
  invoking MoonBit callbacks, and made the PDF/PS/SVG, PNG, and script public
  stream writer wrappers copy C-provided chunks before invoking user writers.
  Stored stream chunks now remain valid after the callback returns. It added
  one black-box test that stores chunks across all stream writer families and
  checks them after allocation pressure. This raises `surface_stream_test.mbt`
  to 11 tests and the expected full native suite to 435 tests.
  The later mixed/layered stream equivalence slice added two
  `surface_stream_wbtest.mbt` cases proving PDF/PS/SVG stream-writer output
  matches file output after normalization for the single-page mixed
  URI/destination/Document/Sect/P vector/text scene and the layered three-page
  clip/dash/surface-pattern/mask/tag/text scene. This raised
  `surface_stream_wbtest.mbt` to 5 tests and the full native suite to 387
  tests.
  The later document-feature stream equivalence slice added one
  `surface_stream_wbtest.mbt` case proving PDF/PS/SVG stream-writer output
  matches file output after normalization for backend-specific document
  features: PDF metadata/custom metadata/page labels/outlines/tags, PS DSC
  comments, and SVG version/document-unit output. This raised
  `surface_stream_wbtest.mbt` to 6 tests and the full native suite to 388
  tests.
  The later vector output white-box split slice moved shared marker/oracle
  helpers into `vector_output_common_wbtest.mbt`, scene rendering helpers into
  `vector_output_scenes_wbtest.mbt`, and left the 37 executable tests in
  `vector_output_wbtest.mbt`. This reduced the main vector-output test file
  from 1292 lines to 623 lines without changing public API or test count.
  The later vector output marker/oracle test split slice moved the direct C
  oracle, cross-backend tag, and late combined marker tests from the 623-line
  `vector_output_wbtest.mbt` into `vector_output_oracle_wbtest.mbt`, leaving
  `vector_output_wbtest.mbt` focused on structural output markers. This did
  not change public API or test count.
  The later vector output scene helper split slice moved pattern, surface,
  mask, mesh, and tag-heavy scene helpers from the 525-line
  `vector_output_scenes_wbtest.mbt` into
  `vector_output_pattern_scenes_wbtest.mbt` and
  `vector_output_tag_scenes_wbtest.mbt`, leaving
  `vector_output_scenes_wbtest.mbt` as the 192-line scene dispatcher and
  document-feature renderer file. This did not change public API or test
  count.
  The later lifetime stress test split moved external value-wrapper stress,
  image-data view stress, and backend stream callback stress into
  `lifetime_value_stress_test.mbt`, `lifetime_image_data_stress_test.mbt`, and
  `lifetime_stream_stress_test.mbt`, leaving `lifetime_stress_test.mbt`
  focused on mapped-image lifetime and retained owner graph stress. This did
  not change public API or test count.
  The later backend stream callback multi-seed fuzz slice added a second
  `lifetime_stream_stress_test.mbt` test with four seeds and 96 deterministic
  transitions covering PDF/PS/SVG writers, PNG writer, script writer, PNG
  reader exact and short reads, `WriteError`, invalid-status fallback, and
  reader-error paths. This raises the expected full native suite to 449 tests
  and keeps the file in the targeted normal/ASan verify gate.
  The later finalizer graph multi-seed fuzz slice added
  `lifetime_finalizer_fuzz_test.mbt` with four seeds and 160 deterministic
  transitions covering surface/context/pattern/font/path/region/mapped-image/
  raster-source/script-device owner graphs, explicit and implicit mapped-image
  cleanup edges, expected Cairo errors, callback clearing, and allocation
  pressure. This raises the expected full native suite to 450 tests and adds
  the file to the targeted normal/ASan verify gate.
  The later raster-source callback state-machine fuzz slice added
  `pattern_raster_state_wbtest.mbt` with a 72-step deterministic transition
  test covering clear, release-only, acquire-only, acquire+release, failed
  acquire, dynamic compatible-source, callback-introspection, and owner-count
  balance paths. This raised the full native suite to 393 tests and added the
  file to the targeted normal and ASan verification gate.
  The later raster-source manual callback fuzz slice added
  `pattern_raster_manual_wbtest.mbt` with three deterministic seeds over 144
  total callback transitions. It covers `raster_get_callbacks()` manual
  acquire/release calls, release-only callbacks, acquire-only callbacks,
  acquire+release callbacks, failed finished-surface acquire returns, dynamic
  compatible-source acquire returns, pixel readback, and owner-count balance
  after every transition. This raises the expected full native suite to 424
  tests and adds the file to the targeted normal and ASan verification gate.
  The later tagged `show_text_glyphs` vector-output slice added a
  cross-backend scene rendered by MoonBit from `ScaledFont::text_to_glyphs`
  output and by direct C Cairo through `cairo_scaled_font_text_to_glyphs` and
  `cairo_show_text_glyphs`, plus a PDF Link/structure marker check. This raised
  the full native suite to 395 tests and expanded the vector white-box target to
  39 tests.
  The later tagged `show_text_glyphs` stream/inert-marker slice added PS/SVG
  negative marker checks for the same scene and a PDF/PS/SVG stream-vs-file
  normalized equality test for the text-glyph tag path. This raised the full
  native suite to 397 tests, the vector white-box target to 40 tests, and the
  surface stream white-box target to 7 tests.
  The later grouped glyph/tag vector-output slice added scene 30, combining
  group-pattern painting, a linear gradient, alpha compositing, multi-page
  URI/destination/Document/Sect/P tags, and two `show_text_glyphs` calls. It
  added direct C oracle coverage, PDF structure marker checks, PS/SVG inert-tag
  negative marker checks, and PDF/PS/SVG stream-vs-file normalized equality
  coverage. This raised the full native suite to 401 tests, the vector
  white-box target to 43 tests, and the surface stream white-box target to 8
  tests.
  The later copy_page retained vector-output slice added scene 31, using
  `copy_page` to emit a first vector page while retaining its drawing state for
  a second page with additional geometry. It added PDF/PS/SVG direct C oracle
  coverage, a PDF two-page marker check, and PDF/PS/SVG stream-vs-file
  normalized equality coverage. This raised the full native suite to 404 tests,
  the vector white-box target to 45 tests, and the surface stream white-box
  target to 9 tests.
  The later Surface page primitive slice added a dedicated C oracle that calls
  `cairo_surface_copy_page`/`cairo_surface_show_page` directly and compared it
  with MoonBit `Surface::copy_page`/`Surface::show_page` output for PDF/PS/SVG.
  It also added a PDF two-page marker check and PDF/PS/SVG stream-vs-file
  normalized equality coverage for the Surface primitive path. This raised the
  full native suite to 407 tests, the vector white-box target to 47 tests, and
  the surface stream white-box target to 10 tests.
  The later Surface show-page cleared slice added a dedicated C oracle that
  calls `cairo_surface_show_page` for both pages and compared it with MoonBit
  `Surface::show_page` output for PDF/PS/SVG. It also added a PDF two-page
  marker check and PDF/PS/SVG stream-vs-file normalized equality coverage for
  the cleared-page primitive path. This raised the full native suite to 410
  tests, the vector white-box target to 49 tests, and the surface stream
  white-box target to 11 tests.
  The later glyph vector backend oracle slice added scenes 32 and 33 covering
  `glyph_path` and `show_glyphs` on PDF/PS/SVG, with direct C oracle coverage
  and stream-vs-file normalized equality. This raised the full native suite to
  412 tests, the vector white-box target to 50 tests, and the surface stream
  white-box target to 12 tests.
  The later PDF JPEG MIME direct C oracle slice added a PDF-only oracle that
  paints an image surface with JPEG MIME data and compares the complete PDF
  output against the MoonBit wrapper path. This raised the full native suite to
  413 tests and the vector white-box target to 51 tests; the surface stream
  white-box target remained at 12 tests.
  The later PDF thumbnail direct C oracle slice upgraded
  `Surface::pdf_set_thumbnail_size` from marker-only coverage to a PDF-only
  direct C oracle comparison with fixed metadata dates. This raised the full
  native suite to 414 tests and the vector white-box target to 52 tests; the
  surface stream white-box target remained at 12 tests.
  The later PDF thumbnail stream-equivalence slice added a PDF-only
  file-vs-stream output equality check for `Surface::pdf_set_thumbnail_size`.
  This raised the full native suite to 415 tests and the surface stream
  white-box target to 13 tests; the vector white-box target remained at 52
  tests.
  The later PDF JPEG MIME stream-equivalence slice added a PDF-only
  file-vs-stream output equality check for JPEG MIME payload embedding. This
  raised the full native suite to 416 tests and the surface stream white-box
  target to 14 tests; the vector white-box target remained at 52 tests.
  The later PDF text document-feature stream-equivalence slice added a
  PDF-only file-vs-stream output equality check for the combined text,
  metadata, page-label, outline, URI-link, named-destination, and structure-tag
  scene. This raised the full native suite to 417 tests and the surface stream
  white-box target to 15 tests; the vector white-box target remained at 52
  tests.
  The later non-text primitive vector stream-equivalence slice added a
  cross-backend PDF/PS/SVG file-vs-stream output equality check for all
  non-text primitive vector scenes covering paint, stroke, fill, paths,
  transforms, gradients, multi-page, clip, dash, surface-pattern, mask-surface,
  and mesh-pattern rendering. This raised the full native suite to 418 tests
  and the then-combined surface stream white-box target to 16 tests; the vector
  white-box target remained at 52 tests.
  The later single-page tag stream-equivalence slice added a separate
  `surface_stream_tag_wbtest.mbt` case proving PDF/PS/SVG file-vs-stream
  normalized equality for URI-link, named-destination, and document-structure
  rectangle/text tag scenes. This raised the full native suite to 419 tests;
  the then-combined `surface_stream_wbtest.mbt` target remained at 16 tests and
  the vector white-box target remained at 52 tests.
  The later stream-equivalence organization slice split the 17 stream
  equivalence tests across `surface_stream_wbtest.mbt` (6 base/vector tests),
  `surface_stream_backend_wbtest.mbt` (4 backend feature tests), and
  `surface_stream_tag_wbtest.mbt` (7 tag-heavy tests), with shared helpers in
  `surface_stream_helpers_wbtest.mbt`. This preserved the full native suite at
  419 tests and changed no public API.
  The later PDF page-operation document-feature differential slice added
  scene 34: a PDF-only direct C oracle, stable marker test, and file-vs-stream
  normalized equality for a `Context::copy_page` retained-page document that
  combines metadata, custom metadata, page labels, outlines, URI links, named
  destinations, document-structure tags, and retained text drawing. This
  raises the expected full native suite to 422 tests, the vector white-box
  target to 54 tests, the backend stream target to 5 tests, and the combined
  split stream-equivalence targets to 18 tests.
  The later standalone text stream-equivalence slice added a PDF/PS/SVG
  file-vs-stream normalized equality check for the toy-font `text_path` and
  `show_text` vector scenes. This raises the expected full native suite to 423
  tests, the base stream white-box target to 7 tests, and the combined split
  stream-equivalence targets to 19 tests.
  The later backend feature/tag stream-combo slice added
  `surface_stream_combo_wbtest.mbt`, a cross-backend file-vs-stream normalized
  equality test for one three-page scene combining backend document features
  (PDF metadata/page labels/outlines, PS DSC, SVG version/unit), URI and named
  destination tags, document-structure tags, surface patterns, toy text, and
  `show_text_glyphs`. A follow-up upgraded that file with a scene 35 direct C
  Cairo oracle and stable PDF/PS/SVG marker checks for the same combo scene.
  A later negative-marker slice added PS/SVG checks proving that combo tags do
  not emit PDF annotation, destination, URI, or structure-tree metadata on
  those backends. A later tagged multi-page negative-marker slice added PS/SVG
  checks proving the two-page Link/Dest/Document/Sect/P text scene stays inert
  on those backends. A later PDF rectangle tag marker slice added marker
  checks for the direct-C rectangle URI-link, named-destination, and
  Document/Sect/H1/P scenes. A later PDF text tag marker slice tightened the
  direct-C text-tag fixtures, added marker checks for the URI-link,
  named-destination, and Document/Sect/H1/P text scenes, and extended PS/SVG
  negative metadata checks to the URI-link text scene. A later PDF direct
  document-feature marker slice added stable checks for the direct-C combined
  metadata/page-label/outline/URI/destination/structure scene. A later backend
  document-feature stream marker slice added stable checks for PDF/PS/SVG
  document-feature stream output, covering PDF metadata/custom metadata/page
  labels/outlines/tags, PS DSC/page markers, and SVG document-unit/page
  markers. A later backend-combo stream inertness slice added PS/SVG stream
  checks proving that the three-page backend feature/tag scene does not emit
  PDF annotation, destination, URI, or structure-tree metadata on those stream
  backends. A later deep-structure slice broadened the same scene with a third
  PDF outline and nested Document/Sect/H1/P/Span tags while preserving the
  direct C oracle, file-vs-stream equality, marker checks, and PS/SVG inertness
  checks. This raises the expected full native suite to 435 tests and leaves
  the combined split backend/stream output targets at 25 tests. A later
  Context drawing-state enum slice added a pycairo-derived black-box test that
  round-trips every typed Antialias, FillRule, LineCap, LineJoin, and Operator
  value through the public Context setters/getters. This raises the expected
  full native suite to 436 tests and raises `context_state_test.mbt` to 7 tests.
  A later backend surface-page feature/tag combo slice added scene 36 plus
  `surface_stream_page_combo_wbtest.mbt`, covering `Surface::copy_page` and
  `Surface::show_page` across PDF/PS/SVG file-vs-stream output, direct C Cairo
  oracle output, stable backend markers, and PS/SVG negative PDF-metadata
  checks. This raises the expected full native suite to 440 tests and raises
  the combined split backend/stream output targets to 29 tests.
  A later backend nested tag/page sequence slice added scene 37 plus
  `surface_stream_nested_tag_wbtest.mbt`, covering deeper document-structure
  nesting, URI/destination links, retained-page `Surface::copy_page`,
  `Surface::show_page`, nested PDF outlines, richer metadata/custom metadata,
  page labels, PS DSC, and SVG document units across PDF/PS/SVG
  file-vs-stream output, direct C Cairo oracle output, stable backend markers,
  and PS/SVG negative PDF-metadata checks. This raises the expected full native
  suite to 444 tests and raises the combined split backend/stream output targets
  to 33 tests.
  A later resized page-sequence combo slice added scene 38 plus
  `surface_stream_page_sequence_wbtest.mbt`, covering alternating
  `Surface::copy_page`/`Surface::show_page`, PDF/PS page-size changes,
  PDF metadata/custom-metadata overwrite/removal, page labels, outline
  parent/child mixtures, URI/destination links, document-structure tags, PS
  DSC, and SVG document units across PDF/PS/SVG file-vs-stream output, direct
  C Cairo oracle output, stable backend markers, and PS/SVG negative
  PDF-metadata checks. This raises the expected full native suite to 448 tests
  and raises the combined split backend/stream output targets to 37 tests.
  A later backend tag-matrix differential slice added scene 39 plus
  `surface_stream_tag_matrix_wbtest.mbt`, crossing the deep tag-nesting
  coverage from scene 37 with the resized page-sequence and metadata
  overwrite/removal coverage from scene 38. It covers four PDF/PS/SVG pages,
  retained and cleared page operations, nested document-structure tags,
  URI/destination links, `show_text_glyphs`, PDF metadata/custom metadata,
  page labels, outline parent/child mixtures, PDF/PS page-size changes, PS
  DSC, and SVG document units across file-vs-stream output, direct C Cairo
  oracle output, stable backend markers, and PS/SVG negative PDF-metadata
  checks. This raises the expected full native suite to 454 tests and raises
  the combined split backend/stream output targets to 41 tests.
  A later backend lifecycle-matrix differential slice added scene 40 plus
  `surface_stream_lifecycle_wbtest.mbt`, extending the cross-backend direct-C
  fixtures to a five-page sequence with consecutive retained `Surface::copy_page`
  output, later cleared/fresh pages, PDF/PS page-size changes, PDF metadata
  and custom-metadata overwrite/removal, page labels, outline parent/child/
  grandchild mixtures, URI/destination links, deeper list/table/document
  structure tags, `show_text_glyphs`, PS Level 2 DSC markers, and SVG
  millimeter document units across file-vs-stream output, direct C Cairo oracle
  output, stable backend markers, and PS/SVG negative PDF-metadata checks. This
  raises the expected full native suite to 461 tests and raises the combined
  split backend/stream output targets to 45 tests.
  A later Context pycairo parity slice added
  `context_pycairo_parity_test.mbt`, covering pycairo's 42x42 default
  clip-extents fixture and zero-radius `arc`/`arc_negative` non-empty path
  behavior. It is included in the targeted normal and ASan verification gates
  and raises the expected full native suite to 456 tests.
  A later Context raw-operator parity slice added
  `Context::set_operator_raw`/`Context::get_operator_raw`, covering pycairo's
  C-int operator passthrough for `-1`, `0`, `INT_MAX`, and `INT_MIN` without
  forcing unknown values through the typed `Operator` API. It raises the
  expected full native suite to 457 tests and raises `context_state_test.mbt`
  to 8 tests.
  A later Context pycairo parity broadening slice extended
  `context_pycairo_parity_test.mbt`, covering pycairo's polygon
  `path_extents`, line `in_stroke`, and empty `stroke_extents` fixtures. It is
  included in the targeted normal and ASan verification gates, raises that
  parity file to 5 tests, and raises the expected full native suite to 464
  tests.
  A later Context pycairo method-fixture slice extended
  `context_pycairo_parity_test.mbt`, covering pycairo's default user/device
  coordinate conversions, empty `select_font_face("")`, and
  `set_font_size(42)` font matrix. It is included in the targeted normal and
  ASan verification gates, raises that parity file to 8 tests, and raises the
  expected full native suite to 467 tests.
  A later Context pycairo state/source fixture slice extended
  `context_pycairo_parity_test.mbt`, covering pycairo's current-point,
  dash-offset normalization, scalar line-width/miter-limit/tolerance setter,
  and source RGBA round-trip fixtures. It is included in the targeted normal
  and ASan verification gates, raises that parity file to 12 tests, and raises
  the expected full native suite to 489 tests.
  A later Context pycairo geometry/source fixture slice extended
  `context_pycairo_parity_test.mbt`, covering pycairo's polygon
  `fill_extents`, empty `in_fill`, rectangle `path_extents`, relative path
  current-point updates, matrix setter/translate/scale/transform/rotate
  fixtures, and explicit source-pattern round trips. It is included in the
  targeted normal and ASan verification gates, raises that parity file to 16
  tests, and raises the expected full native suite to 493 tests.
  A later Context pycairo font-object fixture slice extended
  `context_pycairo_parity_test.mbt`, covering pycairo's font-face
  default/reset/custom round trips, `set_font_matrix(Matrix())`,
  font-options set/get, and scaled-font set/get fixtures. It is included in
  the targeted normal and ASan verification gates, raises that parity file to
  20 tests, and raises the expected full native suite to 497 tests.
  A later Context pycairo clip/group/paint fixture slice extended
  `context_pycairo_parity_test.mbt`, covering pycairo's copied `append_path`
  string fixture, empty clip/reset `in_clip` behavior, group
  push/pop/pop-to-source/content/unmatched-pop fixture, and mask,
  mask-surface, and alpha-paint fixtures. It is included in the targeted
  normal and ASan verification gates, raises that parity file to 24 tests, and
  raises the expected full native suite to 501 tests.
  A later Context pycairo drawing-state fixture slice extended
  `context_pycairo_parity_test.mbt`, covering pycairo's default
  antialias/fill-rule/line-cap/line-join/operator getters, typed enum setter
  round trips, raw operator C-int limit passthrough, and save/restore
  drawing-state restoration. It is included in the targeted normal and ASan
  verification gates, raises that parity file to 28 tests, and raises the
  expected full native suite to 505 tests.
  A later Context pycairo text/glyph fixture slice extended
  `context_pycairo_parity_test.mbt`, covering pycairo's font/text extents,
  `show_text` current-point advance, `text_path` fillable path,
  `glyph_extents`, `show_glyphs` no-path rendering, `glyph_path` fillable
  path, and PDF no-output `show_text_glyphs` tuple flow. It is included in the
  targeted normal and ASan verification gates, raises that parity file to 31
  tests, and raises the expected full native suite to 508 tests.
  A later package-layout management slice added `PROJECT_LAYOUT.md`,
  `scripts/check-project-layout.py`, and the root source allowlist. It records
  the then-current single-package root as migration debt, forbids new
  root-level source/test/C/doc source files, documents the
  `src/`/`src/tests/`/oracle migration order, and adds the layout check to the
  local reliability gate before native compilation. The follow-up source-root
  extraction moved the public package into `src/`, set `moon.mod`
  `source = "src"`, made executable black-box test packages live under
  `src/tests/`, emptied the root source allowlist, and updated scripts to
  locate `src/moon.pkg` and `src/pkg.generated.mbti`.
  A later Pattern pycairo default-state fixture slice added
  `pattern_pycairo_parity_test.mbt`, covering pycairo's solid-pattern default
  extend/filter/dither/matrix/clamped-RGBA getters and explicit matrix/extend/
  filter/dither/RGBA setter round trips. It is included in the targeted normal
  and ASan verification gates and raises the expected full native suite to 510
  tests.
  A later Pattern raw-extend parity slice added
  `Pattern::set_extend_raw`/`Pattern::get_extend_raw`, covering pycairo's
  C-int extend passthrough for `42` while keeping typed `Pattern::get_extend`
  checked with `CairoInvalidArgument(InvalidStatus, _)` for unknown raw values.
  It raises `pattern_test.mbt` to 11 tests and the expected full native suite
  to 468 tests.
  A later Pattern raw filter/dither parity slice added
  `Pattern::set_filter_raw`/`Pattern::get_filter_raw` and
  `Pattern::set_dither_raw`/`Pattern::get_dither_raw`, covering pycairo
  `pattern.c` C-int parsing for filter and dither while keeping typed getters
  checked with `CairoInvalidArgument(InvalidStatus, _)` for unknown raw values.
  It raises `pattern_test.mbt` to 12 tests and the expected full native suite
  to 469 tests.
  A later Pattern raw enum documentation slice extended `pattern.mbt.md` with
  an executable raw enum compatibility example covering
  `Pattern::set_extend_raw`, `Pattern::set_filter_raw`, and
  `Pattern::set_dither_raw`, documenting that unknown raw values remain visible
  through raw getters and are rejected by typed getters. It raises
  `pattern.mbt.md` to 7 executable examples and the expected full native suite
  to 470 tests.
  A later Context raw drawing-state enum parity slice added
  `Context::set_antialias_raw`/`Context::get_antialias_raw`,
  `Context::set_fill_rule_raw`/`Context::get_fill_rule_raw`,
  `Context::set_line_cap_raw`/`Context::get_line_cap_raw`, and
  `Context::set_line_join_raw`/`Context::get_line_join_raw`, covering pycairo
  `context.c` C-int parsing for antialias, fill-rule, line-cap, and line-join
  while keeping typed getters checked with
  `CairoInvalidArgument(InvalidStatus, _)` for unknown raw values. It raises
  `context_state_test.mbt` to 9 tests and the expected full native suite to
  471 tests.
  A later FontOptions raw enum parity slice added
  `FontOptions::set_antialias_raw`/`FontOptions::get_antialias_raw`,
  `FontOptions::set_subpixel_order_raw`/`FontOptions::get_subpixel_order_raw`,
  `FontOptions::set_hint_style_raw`/`FontOptions::get_hint_style_raw`,
  `FontOptions::set_hint_metrics_raw`/`FontOptions::get_hint_metrics_raw`,
  and `FontOptions::set_color_mode_raw`/`FontOptions::get_color_mode_raw`,
  covering pycairo `font.c` C-int parsing for font options while keeping typed
  getters checked with `CairoInvalidArgument(InvalidStatus, _)` for unknown raw
  values. It raises `font_options_test.mbt` to 8 tests and the expected full
  native suite to 472 tests.
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
  `surface_stream_oracle_wbtest.mbt`, comparing PDF/PS/SVG stream callback
  output for scenes 35 through 40 directly against normalized direct C Cairo
  oracle files. This covers the backend stream-combo, surface-page combo,
  nested-tag, resized page-sequence, tag-matrix, and lifecycle-matrix fixtures
  through the callback path, adds the file to the targeted normal/ASan verify
  gate, and raises the current full native suite to 484 tests.
  A later tag-heavy stream-to-direct-oracle differential slice extended
  `surface_stream_oracle_wbtest.mbt` with matched 10x10 stream surfaces for
  scenes 15 through 17 and 22 through 30, comparing PDF/PS/SVG stream callback
  output directly with normalized direct C Cairo oracle files for URI-link,
  destination-link, document-structure, text-tag, tagged multi-page,
  mixed-tag/text, layered, wide, `show_text_glyphs`, and grouped glyph/tag
  vector scenes. It raises `surface_stream_oracle_wbtest.mbt` to 2 tests and
  the current full native suite to 485 tests.
  A later API inventory reliability slice extended
  `scripts/check-api-inventory.py` beyond classes, functions, and methods so
  it also audits pycairo top-level constants from `cairo/__init__.pyi`.
  Public Cairo constants such as `CAIRO_VERSION*`, `HAS_*`, `MIME_TYPE_*`,
  `TAG_*`, `PDF_OUTLINE_ROOT`, `FORMAT_INVALID`, and
  `COLOR_PALETTE_DEFAULT` must now have both inventory anchors and public
  `pkg.generated.mbti` anchors, while `version`/`version_info`, `CAPI`,
  `CairoError = Error`, and legacy uppercase enum aliases must resolve to
  explicit product decisions or public error mappings. The gate now reports 67
  pycairo top-level entries, 224 top-level constants, and 255 portable class
  methods covered by the migration ledger.
  A later backend page-transition differential slice added scene 41 plus
  `surface_stream_page_transition_test.mbt`, covering a show_page-cleared first
  page, a copy_page-retained second page, and a retained-overlay final page
  across PDF/PS/SVG file-vs-stream output, direct C Cairo oracle output, stable
  backend markers, and PS/SVG negative PDF-metadata checks. The PDF path covers
  metadata, custom-metadata deletion, page labels, outline parent/child
  relationships, URI and destination links, and Document/Sect/P/Figure/Span
  structure tags while the PS/SVG paths prove those tags remain backend-inert.
  A later backend state-stack differential slice added scene 42 plus
  `surface_stream_state_stack_test.mbt`, covering clipped surface-pattern
  drawing, `push_group_with_content`/`pop_group_to_source` compositing,
  gradient mask painting, and context-level `copy_page` across PDF/PS/SVG
  file-vs-stream output, direct C Cairo oracle output, stable backend markers,
  and PS/SVG negative PDF-metadata checks. The PDF path covers metadata,
  custom-metadata deletion, page labels, outline parent/child relationships,
  URI and destination tags, and Document/Sect/Figure/P/Span structure tags.
  A later backend structure-sequence differential slice added scene 49 plus
  `surface_stream_structure_sequence_test.mbt`, covering retained
  `Surface::copy_page`, retained `Context::copy_page`, cleared
  `Surface::show_page`, and final `Context::show_page` output across
  PDF/PS/SVG file-vs-stream output, direct C Cairo oracle output, stable
  backend markers, and PS/SVG negative PDF-metadata checks. The PDF path covers
  metadata, custom-metadata deletion, page labels, nested outline links, URI
  and destination tags, and Document/Part/Sect/list/table/figure/paragraph
  structure tags while the PS/SVG paths prove those tags remain backend-inert.

## Known Gaps

- Current tests are strong enough for the `Done` inventory rows when
  `./scripts/verify.sh` passes on the target platform, but they are not enough
  for a full pycairo migration claim. Full-product reliability still requires
  every `Partial` row in `API_INVENTORY.md` to gain explicit evidence or become
  a documented `Decision`, plus passing CI coverage for the
  native/oracle/sanitizer gates on each supported release platform.
- Broader normalized PDF/SVG/PS output comparison is still missing for
  tag/metadata/multi-page combinations beyond the current seventeen-scene
  cross-backend direct C fixtures, three PDF rectangle tag oracle scenes, three
  PDF text-tag oracle scenes with stable PDF marker checks, PS/SVG destination
  and document-structure
  rectangle and text tag oracle scenes, one cross-backend tagged multi-page
  text oracle scene, one cross-backend mixed vector/tag/text oracle scene, one
  cross-backend layered three-page clip/dash/surface-pattern/mask/tag/text oracle
  scene, one cross-backend wide three-page URI/destination/document-structure
  tag/vector oracle scene, one cross-backend tagged `show_text_glyphs` oracle
  scene, one cross-backend grouped glyph/tag multi-page oracle scene, one
  cross-backend copy_page retained two-page oracle scene, one cross-backend
  backend-feature/tag stream-combo oracle scene with PS/SVG negative
  tag-metadata marker checks, one cross-backend backend nested tag/page
  sequence oracle scene with PS/SVG negative tag-metadata marker checks, one
  cross-backend resized page-sequence oracle scene with PS/SVG negative
  tag-metadata marker checks, one cross-backend backend tag-matrix oracle scene
  with PS/SVG negative tag-metadata marker checks, one cross-backend backend
  lifecycle matrix oracle scene with PS/SVG negative tag-metadata marker checks,
  one cross-backend backend page-transition oracle scene with PS/SVG negative
  tag-metadata marker checks,
  one cross-backend backend state-stack oracle scene with PS/SVG negative
  tag-metadata marker checks,
  one cross-backend backend structure-sequence oracle scene with PS/SVG
  negative tag-metadata marker checks,
  and three PDF
  document-feature/page-operation oracle scenes. PDF/PS/SVG now
  have multi-page marker checks and three two-page direct C oracle scenes,
  PDF/PS/SVG have a single-page toy-font `show_text` oracle scene, and PDF has
  direct C coverage for URI links, named destinations, Document/Sect/H1/P
  structure tags in both rectangle and text cases, PDF/PS/SVG stream-vs-file
  equality for the corresponding single-page rectangle/text tag scenes, plus
  three two-page metadata/custom-metadata/page-label/outline/tag combinations,
  including one text/tag-aware scene, plus cross-backend stream-vs-file
  backend-feature/tag/multi-page combo, resized page-sequence combo, and
  tag-matrix/lifecycle combo scenes,
  plus explicit PDF text-tag,
  PDF direct document-feature marker, tagged multi-page text, tagged
  `show_text_glyphs`, grouped glyph/tag
  multi-page, copy_page retained two-page, mixed vector/tag/text, layered
  three-page, and wide three-page structure/tag
  markers. PS/SVG Link tag inertness plus destination/document-structure
  rectangle/text and tagged multi-page text tags also have direct C oracle
  coverage, and PS/SVG URI-link text tags, destination/document-structure
  rectangle/text tags, mixed vector/tag/text tags, layered three-page tags, and
  wide three-page tags now have negative PDF-metadata marker checks, and the
  backend-combo stream output, backend page-transition output, backend
  state-stack output, and backend structure-sequence output have matching
  PS/SVG negative PDF-metadata marker checks.
  Broader cross-backend tag/metadata combinations, broader multi-page
  combinations, and richer tag-output assertions are still absent beyond those
  PDF scenes, the tagged multi-page, tagged `show_text_glyphs`, grouped
  glyph/tag multi-page, copy_page retained two-page, mixed
  vector/tag/text, layered three-page, and wide three-page PDF marker tests,
  PS/SVG tag-metadata absence checks including URI-link text tags,
  backend-combo stream output, resized page-sequence output, tag-matrix output,
  lifecycle-matrix output, page-transition output, state-stack output, and
  structure-sequence output, and PS/SVG
  Link/destination/document-structure rectangle/text plus tagged multi-page, tagged
  `show_text_glyphs`, grouped glyph/tag, mixed vector/tag/text, layered
  three-page, and wide three-page direct-oracle coverage.
  Broader platform coverage and finalizer fuzz remain absent beyond
  the current deterministic raster-source owner-count, state-machine, manual
  get-callback, callback allocation, retained-owner, stream retention, backend
  stream multi-seed callback fuzz, and finalizer graph fuzz tests.
  PDF/PS/SVG stream-writer constructors now also have non-text primitive vector
  scenes, standalone toy-font `text_path`/`show_text` vector scenes,
  deterministic two-page, tagged three-page, tagged `show_text_glyphs`,
  grouped glyph/tag multi-page,
  copy_page retained two-page, mixed vector/tag/text, layered three-page
  clip/dash/surface-pattern/mask/tag/text, wide three-page tag/vector, PDF text
  document-feature, backend-feature/tag/multi-page combo, backend tag-matrix
  combo, backend lifecycle-matrix combo, backend structure-sequence combo,
  PS/SVG stream negative tag-metadata checks for those combos, PDF JPEG
  MIME and PDF thumbnail output,
  and backend document-feature stream-vs-file normalized
  equality plus stream marker coverage, plus
  PDF/PS/SVG, PNG-writer, and script-writer `WriteError`
  and invalid-status fallback mapping; script stream devices and PNG
  stream read/write now have copied-byte callback tests and read/write error
  propagation coverage.
- `Surface::copy_data` still copies Cairo image data into MoonBit `Bytes`;
  `Surface::get_data` is the mutable image-surface view and intentionally
  retains the surface wrapper instead of exposing a raw pointer.
- The package records concrete native link flags in `moon.pkg`, as required by
  the current MoonBit package DSL. `scripts/configure-link-flags.sh` refreshes
  those flags from the target platform's `pkg-config`, and the local gate
  checks for drift; a future publishing workflow may still want package-manager
  specific guidance for non-`pkg-config` Cairo installations.
- ASan was run manually for the current expanded slice; CI automation has not
  been wired into this repository yet. The current LSan failure on macOS
  toy-font, scaled-font, toy-text rendering, glyph rendering/path, and
  show-text-glyphs paths is an open reliability item.
