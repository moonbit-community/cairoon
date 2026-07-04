# cairoon Migration Audit

## Current Slice

Implemented in this workspace:

- MoonBit native package initialization with `moon.mod` and `moon.pkg`.
- System Cairo 1.18.4 linkage through `pkg-config`-derived flags, with
  `scripts/configure-link-flags.sh` to refresh `moon.pkg` and
  `scripts/configure-link-flags.sh --check` in the local reliability gate.
- C FFI glue split by Cairo object family, following pycairo's
  `private.h` plus per-family C file architecture. GC-managed external objects
  currently cover `Surface`, `MappedImageSurface`, `ImageData`, `Context`,
  `Path`, `Pattern`, `FontOptions`, `FontFace`, `ScaledFont`, `Region`, and
  `Device`. Private test-only oracle glue is also split by responsibility:
  common drawing helpers, file/normalized-output comparison, vector-output
  oracles, and ARGB32 image oracles.
- MoonBit raw FFI declarations are beginning to follow the same family split:
  `ffi.mbt` keeps object type declarations and small module-level exports, while
  `ffi_font.mbt` owns raw `FontOptions`, `FontFace`, `ScaledFont`, and
  text-to-glyphs extern declarations, `ffi_pattern.mbt` owns raw `Pattern`,
  mesh-pattern, and raster-source-pattern extern declarations, and
  `ffi_device.mbt` owns raw `Device`, script-device, script-surface, and
  surface-get-device extern declarations.
  `ffi_path.mbt`, `ffi_pdf_surface.mbt`, `ffi_ps_surface.mbt`, and
  `ffi_region.mbt` own raw `Path`, PDF surface, PostScript surface, and
  `Region` extern declarations.
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
  for nineteen ARGB32 scenes covering paint, stroke, fill/stroke rectangles,
  Bezier paths, transforms, RGBA compositing, linear/radial gradients,
  toy-font `text_path`, toy-font `show_text`, `glyph_path`, `show_glyphs`,
  `show_text_glyphs`, source-surface offset sampling, and mask-surface offset
  compositing, raster-source pattern repeat rendering, dashed round-cap
  strokes, clipped paint/fill output, and `OperatorClear` compositing output,
  direct C Cairo oracle comparisons for fifteen deterministic PDF/PS/SVG vector
  scenes covering paint, stroke, fill/stroke rectangles, Bezier paths,
  transforms, linear/radial gradients, toy-font text paths, and toy-font
  `show_text`, two-page paint, clip, dashed stroke, repeated surface pattern,
  mask surface, and mesh pattern scenes, mutable image-data read/write/copy, buffer-backed storage sharing,
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
  matrices, and PDF JPEG MIME passthrough, recording surface
  bounded/unbounded extents,
  replay-through-surface-pattern behavior, subtype-mismatch errors,
  PDF surface version helper behavior, no-output and filename construction,
  version restriction, page size, metadata, custom metadata, page label,
  thumbnail, single-flag and combined-flag outline behavior,
  stable structural output markers, PDF metadata/custom-metadata/page-label/outline
  output markers, PDF multi-page output markers, PDF 1.4 fifteen-scene
  cross-backend direct C vector-oracle comparison plus three PDF tag oracle
  scenes, three PDF text-tag oracle scenes, one cross-backend tagged
  multi-page text oracle scene, and two PDF document-feature oracle scenes,
  including one text/tag-aware combined scene, PDF JPEG MIME data
  embedding, PDF 1.4 URI link-tag annotation markers,
  PDF named-destination tag markers, PDF document-structure tag markers,
  finished-surface errors, invalid string validation, and subtype-mismatch
  errors across bound page-size/version/metadata/custom-metadata/page-label/
  thumbnail/outline helpers,
  image surfaces returning no device, script device lifecycle and device
  reference equality, script mode/comment validation, recording replay,
  script-surface proxy rendering behavior, and `DeviceFinished` propagation,
  PS surface level helper behavior, no-output and filename construction, EPS
  mode, level restriction, size/DSC helpers, finished-surface errors, invalid
  DSC/path validation, stable page/drawing output markers, fifteen-scene direct C
  vector-oracle comparison with `CreationDate` normalization, normalized direct
  C oracle comparison for the combined language-level/DSC setup/page-setup/
  two-page feature scene and Link tag inertness on PS output, and subtype-mismatch
  errors across bound EPS/level/page-size/DSC helpers,
  SVG surface version helper behavior, no-output and filename construction,
  document-unit behavior, finished-surface errors including document-unit
  getters, invalid path validation, and
  stable geometry/color output markers, normalized fifteen-scene direct C vector-oracle comparison,
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
  covers nineteen deterministic ARGB32 scenes including stroke, rectangle,
  Bezier, transform, RGBA, linear/radial gradient, toy-font `text_path`,
  toy-font `show_text`, `glyph_path`, `show_glyphs`, `show_text_glyphs`,
  source-surface offset sampling, mask-surface offset compositing, and
  raster-source pattern repeat rendering, dashed round-cap stroke, and clipped
  paint/fill cases, and `OperatorClear` compositing output,
  ScaledFont font/text/glyph extents and empty, single/multi/spaced ASCII,
  precomposed/decomposed Latin, CJK, Arabic RTL, and emoji UTF-8
  text-to-glyph coordinate cases are compared against direct C Cairo primitive
  oracles, and vector outputs
  have stable structural marker checks plus direct C oracle comparisons for
  fifteen deterministic PDF/PS/SVG scenes covering paint, stroke, fill/stroke
  rectangles, Bezier paths, transforms, linear/radial gradients, toy-font text
  paths, toy-font `show_text`, two-page paint, clip, dashed stroke, repeated
  surface pattern, mask surface, and mesh pattern scenes. SVG comparison
  normalizes Cairo's dynamic `source-*` image ids. PDF metadata/custom
  metadata, page labels, outlines, multi-page output, URI link-tag annotations,
  named-destination tags, document-structure tags, and two two-page PDF
  document-feature combinations also have direct C oracle or marker checks; PDF
  JPEG MIME passthrough has output checks; image/PDF/PS/SVG MIME support
  matrices are covered; PS combined DSC/multi-page output, SVG combined
  version/unit/multi-page output, PS/SVG Link tag inertness, PS/SVG
  destination/document-structure rectangle and text tag output, and
  cross-backend tagged multi-page text output, plus a mixed vector/tag/text
  scene, have normalized direct C oracle checks matching Cairo 1.18.4 backend
  behavior. PDF tagged multi-page text and mixed vector/tag/text output also
  have explicit marker checks for page objects, link annotations, URI/
  destination entries, and StructTreeRoot elements. PS/SVG destination,
  document-structure, and mixed vector/tag/text tag scenes also have negative
  marker checks proving PDF-only tag metadata is not emitted.
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
  Finalizer stress still needs broader randomized callback-edge and
  failure-injection coverage under ASan.

## Last Verified

2026-07-02, 2026-07-03, and 2026-07-04:

- `./scripts/verify.sh`: passed. The local reliability gate ran
  `moon fmt --check`, `scripts/configure-link-flags.sh --check`, native
  `moon check`, targeted image, ScaledFont oracle,
  font-options/font-face/scaled-font, vector including PDF combined text
  document-feature plus PS DSC/SVG unit backend-feature oracle checks,
  surface base/ImageData tests,
  stream black-box/white-box tests, mapped-image, subsurface, recording,
  MIME, PDF/PS/SVG helper, TeeSurface, script-device, and object-trait tests,
  context lifetime/state/matrix/path/group/text/glyph/extents/clip/painting tests,
  Path tests,
  pattern/gradient/mesh tests, raster-owner white-box tests, and
  Region/lifetime-stress tests,
  the full native suite, `moon info --target native`, and targeted ASan
  image-oracle, font-options/font-face/scaled-font, vector-output, stream,
  surface base/ImageData, mapped-image, subsurface, recording, MIME,
  PDF/PS/SVG helpers, TeeSurface, script-device, object-trait,
  context-lifetime/state/matrix/path/group/text/glyph/extents/clip/painting, Path,
  pattern/gradient/mesh, and raster-owner/Region/lifetime-stress tests with
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
  the raster-source stale-release replacement slice,
  the raster-source acquire-only owner fuzz slice,
  the packaging/pycairo-porting documentation slice, the mixed
  vector/tag/text marker slice, the direct C oracle slice, and the prior C
  stub split that moved private test oracles out of `cairoon_misc.c` into
  common/file/vector/image helper files, plus the raw FFI splits that moved
  font and pattern extern declarations into `ffi_font.mbt` and
  `ffi_pattern.mbt`.
- `moon -C cairoon check --target native`: passed.
- `moon -C cairoon test --target native`: 373 tests passed. The current run
  includes the pycairo context font-extents parity slice,
  the pycairo group-target stack-restoration slice,
  the pycairo rectangle path-extents slice,
  the pycairo source RGBA round-trip slice,
  the pycairo empty-path clip `in_clip` slice,
  the pycairo mesh curve-first patch slice,
  the pycairo polygon fill-extents slice,
  the mapped-image scoped-error upload slice,
  the TeeSurface positive out-of-range status slice,
  the PDF/PS stream target lifetime slice, the pycairo append-path
  string equivalence slice, the pycairo close-path stringification slice, the
  gradient color-stop ordering/snapshot slice, the stream-vs-file vector output
  equivalence slice, the raster-source stale-release replacement slice, the
  raster-source
  acquire-only owner fuzz slice, the mixed
  vector/tag/text marker slice, the direct C oracle slice, the PS/SVG tag
  metadata absence slice, the PDF tagged multi-page text marker slice,
  the cross-backend tagged multi-page text direct C oracle slice, the
  PS/SVG tag and text-tag direct C oracle slice, the PDF text-tag direct C
  oracle slice, the raster-source deterministic callback fuzz slice, the
  raster-source compatible target/extents acquire slice, the
  PS/SVG Link tag direct C oracle slice, the context
  `get_group_target` post-scope lifetime slice, the PDF combined text
  document-feature oracle slice, and the earlier context `get_source`
  surface-pattern lifetime coverage for the path where both the original source
  wrapper and context scope have exited, plus the raw FFI split slices that
  keep public API and test count unchanged while reducing `ffi.mbt`.
- `moon -C cairoon test path_test.mbt --target native -v`: 7 black-box Path
  tests passed, covering empty paths, pycairo-compatible stringification
  including close-path continuation formatting, copied-path lifetime after the
  source context exits, typed segment iteration, flattened copies, and path
  equality/hash behavior.
- `moon -C cairoon test context_path_test.mbt --target native -v`: 11
  black-box Context path tests passed, covering current-point behavior,
  relative path operations, pycairo rectangle path-extents behavior,
  close-path current-point reset, arc current-point creation,
  path copy/append independence, pycairo-style append string
  equivalence after clearing the source context, flattened append behavior, and
  path error propagation.
- `moon -C cairoon test context_group_test.mbt --target native -v`: 4
  black-box Context group tests passed, covering `push_group`, `pop_group`,
  `pop_group_to_source`, `push_group_with_content`, group-target stack
  restoration to the original target, returned group patterns, and unmatched
  pop error mapping.
- `moon -C cairoon test context_text_test.mbt glyph_array_test.mbt --target
  native -v`: 11 black-box Context text/glyph tests passed, covering
  context/scaled-font font-extents and text-extents parity, `show_text`
  current-point advance, text/glyph path creation, empty glyph arrays,
  embedded-NUL validation, and context error propagation.
- `moon -C cairoon test context_lifetime_test.mbt --target native -v`: 9
  black-box context lifetime tests passed, including `get_target`,
  `get_group_target`, `get_source`, and PDF/PS stream target wrappers that
  remain usable after their creating helper scopes exit.
- `moon -C cairoon test context_state_test.mbt context_matrix_test.mbt
  context_extents_test.mbt --target native -v`: 15 black-box context
  state/matrix/extents tests passed, including save/restore, sticky error
  status, dash validation, CTM conversion, invalid-matrix propagation,
  pycairo polygon fill-extents coverage, stroke extents, and hit-testing.
- `moon -C cairoon test surface_mapped_test.mbt --target native -v`: 6
  black-box mapped-image tests passed, covering whole-surface and extent
  uploads, wrong-base and double-unmap failures, mapped-wrapper unmap,
  scoped unmap on success and Cairo errors, and upload-before-error propagation.
- `moon -C cairoon test surface_tee_test.mbt --target native -v`: 4
  black-box TeeSurface tests passed, covering mirrored drawing, retained
  primary/target wrappers, subtype errors, self add/remove errors,
  negative-index `InvalidIndex`, and positive out-of-range `NoMemory`
  status handling.
- `moon -C cairoon test surface_context_test.mbt image_data_test.mbt
  surface_subsurface_test.mbt surface_recording_test.mbt surface_mime_test.mbt
  surface_pdf_test.mbt surface_ps_test.mbt surface_svg_test.mbt
  device_test.mbt object_traits_test.mbt --target native -v`: 67 black-box
  surface/device/object-trait tests passed, covering base surface state,
  retained image-data views, retained subsurface parents, recording replay,
  MIME storage/support, PDF/PS/SVG helper errors, script devices, script
  stream callbacks, script surfaces, and external-object `Eq`/`Hash`
  behavior.
- `moon -C cairoon test device_test.mbt backend_surfaces.mbt.md
  lifetime_stress_test.mbt --target native -v`: 23 black-box and executable
  backend/lifetime tests passed, covering script file/stream devices,
  script-surface target proxying, script writer `WriteError` mapping, scoped
  script-device finish, retained script surface/device wrappers, executable
  backend docs, and backend stream callback allocation stress.
- `moon -C cairoon test vector_output_wbtest.mbt --target native -v`: 31
  white-box vector tests passed, including the mixed vector/tag/text marker
  checks, mixed vector/tag/text direct C oracle scene, PS/SVG destination and
  document-structure tag metadata absence checks, PDF tagged multi-page text
  structure markers, cross-backend tagged multi-page text, PS/SVG destination
  and document-structure rectangle and text tag scenes, PDF URI-link/
  named-destination/document-structure text tag scenes, and PS/SVG Link tag
  inertness matched against direct C Cairo output and the combined PDF
  metadata/custom-metadata/page-label/outline/URI/named-destination/
  document-structure test matched against a direct C Cairo output oracle that
  also draws tagged text.
- `moon -C cairoon test surface_stream_test.mbt --target native -v`: 8
  black-box stream callback tests passed, covering PDF/PS/SVG stream chunks,
  vector stream `WriteError`, PNG stream write/read, PNG write `WriteError`,
  and PNG short-read error mapping.
- `moon -C cairoon test surface_stream_wbtest.mbt --target native -v`: 1
  white-box stream equivalence test passed, comparing PDF/PS/SVG stream output
  with file output after normalized comparison for a deterministic two-page
  scene.
- `moon -C cairoon info --target native`: completed with no work to do; this
  stream equivalence slice changes no public API or generated interface
  metadata.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  vector_output_wbtest.mbt --target native -v`: 31 ASan-compiled
  white-box vector tests passed with leak detection disabled, directly
  exercising the mixed vector/tag/text marker and C oracle paths.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_test.mbt --target native -v`: 8 ASan-compiled black-box
  stream callback tests passed with leak detection disabled.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_stream_wbtest.mbt --target native -v`: 1 ASan-compiled white-box
  stream equivalence test passed with leak detection disabled.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_mapped_test.mbt --target native -v`: 6 ASan-compiled black-box
  mapped-image tests passed with leak detection disabled.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_tee_test.mbt --target native -v`: 4 ASan-compiled black-box
  TeeSurface tests passed with leak detection disabled.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  surface_context_test.mbt image_data_test.mbt surface_subsurface_test.mbt
  surface_recording_test.mbt surface_mime_test.mbt surface_pdf_test.mbt
  surface_ps_test.mbt surface_svg_test.mbt device_test.mbt
  object_traits_test.mbt --target native -v`: 67 ASan-compiled
  surface/device/object-trait tests passed with leak detection disabled.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  context_state_test.mbt context_matrix_test.mbt context_extents_test.mbt
  --target native -v`: 15 ASan-compiled black-box context state/matrix/extents
  tests passed with leak detection disabled.
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
  extents, glyph extents, and empty, single/multi/spaced ASCII,
  precomposed/decomposed Latin, CJK, Arabic RTL, and emoji UTF-8
  text-to-glyph coordinate cases against direct C Cairo results.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  scaled_font_oracle_wbtest.mbt --target native -v`: 2 ASan-compiled
  white-box ScaledFont oracle tests passed with leak detection disabled,
  covering the expanded UTF-8 text-extents and text-to-glyph input set.
- `moon -C cairoon test lifetime_stress_test.mbt --target native -v`: 6
  black-box lifetime tests passed after adding the backend stream callback
  1000-iteration allocation stress case.
- `moon -C cairoon test raster_lifetime_stress_test.mbt --target native -v`: 1
  black-box raster-source callback lifetime test passed after adding the
  1000-iteration set/get/manual acquire/release/replace/clear stress case.
- `moon -C cairoon test context_lifetime_test.mbt --target native -v`: 9
  black-box context lifetime tests passed, including `get_group_target`
  returning a surface that remains readable after the creating context helper
  scope exits, `get_source` returning a surface pattern that still exposes
  and paints from its source after the source wrapper and context scope exit,
  and PDF/PS stream target wrappers that remain usable after the creating
  surface helper scope exits.
- `moon -C cairoon test pattern_test.mbt --target native -v`: 20 black-box
  pattern tests passed after adding compatible target/extents raster-source
  acquire coverage, release-only raster callback state, finished-surface raster
  acquire failure-injection coverage, the C-side surface-finished sentinel, and
  post-failure acquire replacement recovery, plus deterministic 25-step
  callback replacement/failure fuzz with dynamic compatible source surfaces and
  final post-clear recovery.
- `moon -C cairoon test pattern_gradient_test.mbt --target native -v`: 5
  black-box gradient tests passed, covering linear/radial gradient geometry,
  color-stop count/tuple retrieval, duplicate-offset insertion order, copied
  color-stop snapshot stability after later pattern mutation, pattern-type
  mismatch mapping, and invalid-index mapping.
- `moon -C cairoon test pattern_raster_owner_wbtest.mbt --target native -v`: 3
  white-box raster-source owner-count tests passed, asserting acquire-only
  repeated same-surface paints, a 64-step acquire-only replacement fuzz, and
  release-only to acquire-only replacement all release cairoon's retained owner
  back to zero without calling stale release callbacks.
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
  pattern_test.mbt --target native -v`: 20 ASan-compiled black-box pattern
  tests passed with leak detection disabled, covering compatible target/extents
  raster-source acquire, release-only callback state, the raster acquire
  finished-surface rejection path, replacement recovery after that failure
  path, and deterministic callback replacement/failure fuzz with dynamic
  compatible source surfaces.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  pattern_raster_owner_wbtest.mbt --target native -v`: 3 ASan-compiled
  white-box raster-source owner-count tests passed with leak detection
  disabled, covering acquire-only repeated same-surface paints, the 64-step
  acquire-only replacement fuzz, and stale release-to-acquire-only
  replacement.
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
- `moon -C cairoon test enums_test.mbt --target native -v`: 4 black-box tests
  passed after adding `Rgb16_565`, `Rgb30`, `Rgb96F`, `Rgba128F`, and
  negative-width `Format::stride_for_width` coverage.
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
  The later pattern raw FFI split slice moved raw `Pattern`, mesh-pattern, and
  raster-source-pattern extern declarations from `ffi.mbt` into
  `ffi_pattern.mbt`, added that file to the native target list, and reduced
  `ffi.mbt` to 1866 lines. This did not change public API or test count.
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

## Known Gaps

- Broader normalized PDF/SVG/PS output comparison is still missing for
  tag/metadata/multi-page combinations beyond the current fifteen-scene
  cross-backend direct C fixtures, three PDF rectangle tag oracle scenes, three
  PDF text-tag oracle scenes, PS/SVG destination and document-structure
  rectangle and text tag oracle scenes, one cross-backend tagged multi-page
  text oracle scene, one cross-backend mixed vector/tag/text oracle scene, and
  two PDF document-feature oracle scenes. PDF/PS/SVG now
  have multi-page marker checks and three two-page direct C oracle scenes,
  PDF/PS/SVG have a single-page toy-font `show_text` oracle scene, and PDF has
  direct C coverage for URI links, named destinations, Document/Sect/H1/P
  structure tags in both rectangle and text cases, plus two two-page
  metadata/custom-metadata/page-label/outline/tag combinations, including one
  text/tag-aware scene, plus explicit PDF tagged multi-page text and mixed
  vector/tag/text structure/tag markers. PS/SVG Link tag inertness plus
  destination/document-structure rectangle/text and tagged multi-page text tags
  also have direct C oracle coverage, and PS/SVG destination/document-structure
  rectangle/text tags and mixed vector/tag/text tags now have negative
  PDF-metadata marker checks.
  Broader cross-backend tag/metadata combinations, broader multi-page
  combinations, and richer tag-output assertions are still absent beyond those
  PDF scenes, the tagged multi-page and mixed vector/tag/text PDF marker tests,
  PS/SVG tag-metadata absence checks, and PS/SVG Link/destination/
  document-structure rectangle/text plus tagged multi-page and mixed vector/
  tag/text direct-oracle coverage.
  PDF/PS/SVG stream-writer constructors now also have deterministic two-page
  stream-vs-file normalized equality coverage; script stream devices and PNG
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
