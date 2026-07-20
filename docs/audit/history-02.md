# Migration Audit History, Part 2

Historical snapshot of `AUDIT.md` lines 562-1069 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

- `src/internal/scaled_font` is the sixth facade-owned object seam. It owns the
  sole `RawScaledFont` external object, private `RawTextToGlyphs` result object,
  and all 18 constructor, identity, getter, matrix, extents, text conversion,
  and result-accessor externs using raw `Int` status and flag values. Internal
  Context font/text functions exchange `RawScaledFont`; checked facade methods
  alone wrap or unwrap it. Public
  `ScaledFont` still assembles typed matrices, extents, glyphs, clusters, and
  `TextGlyphRun` values and never exposes the raw result owner. Package-local
  raw identity/matrix/text-result tests plus external Font, Context, glyph,
  oracle, value-stress, and finalizer tests cover behavior and ownership.
- `src/internal/pattern` is the seventh facade-owned object seam. It owns the
  sole `RawPattern` external object and 35 object-only core, solid, gradient,
  common-state, and mesh externs using raw `Int` status and enum values. Public
  `ffi_pattern.mbt` retains two SurfacePattern and three typed-enum bridges;
  `ffi_pattern_raster_source.mbt` retains nine callback/content bridges, and
  Context source/group/mask bridges exchange `RawPattern`. Public `Pattern`
  remains an abstract single-field wrapper and owns typed conversion, value
  assembly, callback APIs, traits, and `CairoError` mapping. Three package-local
  raw identity/state/gradient/mesh tests plus external Pattern, Context,
  image/vector oracle, callback-owner/fuzz, value-stress, and finalizer tests
  cover behavior and ownership.
- `src/internal/context` is the eighth facade-owned object seam and is
  producer-only at the child layer. It owns the sole `RawContext` external
  object and 102 non-facade externs, split into seven C-matched families with
  counts 12/11/18/11/12/17/21. The public root retains exactly 14
  Surface/Content/typed-enum bridges, split 5/5/2/2 across core, state,
  font/text, and paint. Public `Context` remains an abstract single-field
  wrapper with no second finalizer and retains all typed status/enum/value
  conversion, string validation, traits, and `CairoError` mapping. Constructors
  return one owned raw handle and retain their target wrapper; borrowed target,
  group-target, source, and font returns preserve their Cairo reference/copy
  contracts; `pop_group` and path copies preserve owned-return contracts. No C
  glue or native ABI changed. Because valid construction requires facade-owned
  Surface wrappers, no test-only raw constructor was added. Public Context,
  cross-family, lifetime, oracle, and package-isolated ASan/LSan evidence covers
  every real producer and consumer.
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
- MoonBit raw FFI declarations follow the same family split. The sole
  `RawContext` owner and 102 non-facade Context externs live in
  `src/internal/context`, divided into 12 core, 11 clip/extents, 18 font/text,
  11 matrix, 12 paint, 17 path, and 21 state declarations. The public root
  retains exactly 14 bridges whose signatures require facade-owned types: five
  Surface/Content core bridges, five typed state setters, two typed font/text
  bridges, and two Surface paint bridges.
  `src/internal/scaled_font/{ffi,ffi_text_to_glyphs}.mbt` own
  `RawScaledFont`, private `RawTextToGlyphs`, and all 18 scaled-font/result
  extern declarations. `src/internal/pattern/{ffi,ffi_mesh}.mbt` own
  `RawPattern` and 35 object-only core/solid/gradient/mesh extern declarations;
  public `ffi_pattern.mbt` retains five SurfacePattern/typed-enum bridges, and
  `ffi_pattern_raster_source.mbt` retains nine callback/content bridge externs
  backed by the public raster-source exports.
  `src/internal/device/ffi.mbt` owns `RawDevice` and the 13 Device-only extern
  declarations; `ffi_device.mbt` retains only five recording/script Surface
  bridge declarations that exchange `RawDevice` with facade-owned `Surface`.
  `ffi_image_data.mbt` owns raw `ImageData` extern declarations;
  `ffi_image_surface.mbt`, `ffi_mapped_image_surface.mbt`,
  `ffi_recording_surface.mbt`, `ffi_surface.mbt`,
  `ffi_surface_font_options.mbt`, `ffi_surface_mime.mbt`,
  `ffi_surface_png.mbt`, and `ffi_surface_state.mbt` own raw image, mapped
  image, recording, base, font-options, MIME, PNG, and state/page surface
  extern declarations; and `ffi_pdf_surface.mbt`, `ffi_ps_surface.mbt`,
  `ffi_svg_surface.mbt`, and `ffi_tee_surface.mbt` own raw PDF surface,
  PostScript surface, SVG surface, and Tee surface extern declarations. Raw
  Context, Device, FontFace, FontOptions, Path, Pattern, Region, and ScaledFont
  extern declarations plus their sole GC handles now live in their respective
  `src/internal/<family>` packages. The
  private text-to-glyphs result owner also lives with ScaledFont. Raw PDF
  version helper externs have moved out of `ffi_pdf_surface.mbt` into
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
  construction and cairoon's checked-chaining boolean mutator extension.
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
  `API_INVENTORY.md`; one row remains `Partial`, while `Decision` rows record
  explicit product scope. The
  `CAPI`, legacy uppercase enum alias constants, `SurfaceObserverMode`,
  `FreeTypeFontFace`, and `UserFontFace` rows are resolved product decisions.
  Cairo's native observer surface/device APIs and native FreeType/user-font
  extension APIs are intentionally outside the current pycairo-migration
  product.
- Gate 2 behavioral parity: partial but strong. Twenty pinned family ledgers
  map all 288 upstream tests to 197 family-local MoonBit runtime anchors, 291
  required public signatures, 29 deliberately absent signatures, 4 explicit
  inventory decisions, and 1 mandatory static verify gate. Source-set checking
  proves every upstream `tests/test_*.py` file is claimed exactly once.
  Additional black-box tests cover raster-source callback behavior;
  release-platform evidence still keeps the product-level gate partial.
- Gate 3 differential rendering: strong for the portable migration scope.
  Deterministic raw-pixel rendering
  tests exist for direct colors and explicit patterns, a direct C image oracle
  covers forty-seven deterministic ARGB32 scenes including stroke, rectangle,
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
  Scene 66 closes Cairo 1.18's finite tag-attribute contract with URI,
  multi-rectangle, named-destination, page-position, external-file,
  internal/extent-derived destination, content, and content-reference cases;
  invalid attributes and nesting map to `TagError`. A pycairo byte-output
  cross-run is not automated, but direct-C Cairo is the normative portable
  rendering oracle and all upstream pycairo tests are pinned by the parity
  ledger.
- Gate 4 memory and lifetime: strong local evidence for the portable scope.
  Stub ownership follows the documented
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
  All three Linux Cairo lanes run every discovered package in a separate
  ASan/LSan/UBSan process. Intentional signed-overflow and leak probes prove the
  runtimes are active, and the only suppressions are constrained by standalone
  C reproductions and exact allocation counts. Earlier macOS
  Cairo/Quartz/CoreText LeakSanitizer reports remain historical evidence, not
  the current release blocker: Linux is the authoritative LSan/UBSan platform,
  while the shipped macOS lane runs the ordinary native gate.
  Finalizer graph fuzz now covers multi-seed surface/context/pattern/font/path/
  region/mapped-image/raster-source/script-device owner graphs, error exits,
  callback clearing, and allocation pressure under ASan. The remainder selects
  one of five operations and the independent quotient selects each operation's
  local scenario. Exact runtime counters pin operation counts
  `33/38/25/36/28`, surface colors `14/19`, mapped error/explicit/implicit
  unmap `18/7/13`, font sizes `3/5/8/5/4`, region widths `11/14`, raster
  success/failure `27/9`, and script-device success/`WriteError` `19/9`.
  The focused package passes host ASan/UBSan and both exact-Cairo Linux lanes
  under ASan/LSan/UBSan. Broader platform coverage and stronger randomized
  finalizer/callback-edge coverage remain useful release depth. The
  product-level Tests row remains `Partial` until the release commit has shipped
  Ubuntu/macOS evidence; this is not an open local lifetime defect.

## Last Verified

The most recent full local verification passed on 2026-07-19:

- `CAIROON_VERIFY_ASAN=0 ./scripts/verify.sh` passed 225/225 script tests,
  841/841 native tests, 63/63 executable documentation tests, formatting,
  project layout, source-size, Cairo build-protocol/generated-constant, FFI
  ownership, exact external-owner/finalizer/stress evidence, API inventory,
  pycairo parity, public documentation, reliability-ledger, vector-scene,
  native type including warning 73, and generated-interface gates. The
  isolated consumer passed 6/6 against both the checkout and the
  integrity-tested extracted 668-member publication zip. A targeted host
  ASan/UBSan run passed the finalizer-only `RawTextToGlyphs` package;
  authoritative whole-workspace ASan/LSan/UBSan coverage is supplied by the
  Linux lanes below.
- `./scripts/test-cairo-matrix.sh cairo-1.15.10` and
  `./scripts/test-cairo-matrix.sh cairo-1.18.4` passed the same 225 script,
  841 native, and 63 documentation tests, all three 6/6 consumer modes, all
  668 byte-identical publication members, and every discovered package under
  ASan/LSan/UBSan.
  Intentional signed-overflow and leak preflights passed in both lanes. The
  constrained vector suppression accounted for 16 allocations/7424 bytes on
  1.15.10 and 16/9344 on 1.18.4; the constrained PDF/JBIG2 suppressions
  accounted for 9 allocations/988 bytes and 14/2352 respectively. Every other
  package remained unsuppressed.
- `./scripts/test-cairo-matrix.sh ubuntu-24.04-system` passed with Ubuntu
  24.04's unmodified system Cairo 1.18.0: 225/225 script tests, 841/841 native
  tests, 63/63 executable docs, all three 6/6 consumer modes, all 668
  byte-identical publication members, and every discovered package under
  ASan/LSan/UBSan on both local arm64 and Rosetta-backed x86_64.
  The stripped recording path used exactly 16 suppressions/9344 bytes at
  `cairo_restore` on arm64 and 16/9216 bytes on x86_64, exactly matching the
  576-byte x86_64 layout. The stripped PDF path used exactly 10/2284 at
  `cairoon_pdf_surface_create_for_stream` plus 4/68 at
  `cairoon_surface_finish` on x86_64. The matrix now accepts explicit platform
  and Docker-context selection, applies the platform to build and run, isolates
  image tags by platform, and retries/resumes fixed downloads.
- The parity ledger covers all 288 tests in 20 pinned pycairo families, public
  documentation covers 579/579 declarations with zero debt, and the production
  boundary remains 349 local FFI symbols plus two direct libcairo symbols.
  No push or CI rerun was used to obtain this evidence, so the sole global
  `Partial` remains shipped release-commit evidence.

An earlier matrix replay exposed and closed one test-only PDF nondeterminism:
under ASan, sequential file and stream surfaces could cross a wall-clock
second and receive different Cairo-generated creation dates. Cairo 1.17.6+
equivalence fixtures now set fixed creation and modification dates. The
1.15.10 comparator ignores only the automatically generated
`/CreationDate (D:...)` line and continues to compare every other PDF byte;
a synthetic byte-pair assertion locks that normalization rule. Both exact
Linux lanes above passed again after this fix.

Prior full verifies passed on 2026-07-02, 2026-07-03, 2026-07-04,
2026-07-05, and earlier 2026-07-06 slices. The most recent 2026-07-06 run:
