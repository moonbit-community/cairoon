# Migration Audit History, Part 7

Historical snapshot of `AUDIT.md` lines 3222-3783 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

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
  A later Context pycairo surface-source offset fixture slice extended
  `context_state_paint_pycairo_parity_test.mbt`, covering
  `Context::set_source_surface` default and explicit offsets plus
  `Context::mask_surface` explicit offsets with pixel-level ARGB32 fixtures.
  It raises the context pycairo package to 38 black-box tests without changing
  public API.
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

## Surface Package Extraction

The ninth object-handle seam moves `RawSurface`, `RawMappedImageSurface`, and
`RawImageData` plus 79 raw externs into `src/internal/surface`, split across 13
Cairo-family FFI files. The public facade retains five stream-callback bridges;
typed enum methods convert to raw `Int` in MoonBit. Context, Pattern, and Device
now exchange raw Surface handles in their child packages, yielding exact
child/facade splits of 108/7, 38/10, and 16/1 externs respectively. The three
public Surface-family wrappers remain private single-field owners with no
independent finalizer.

Four Surface package tests and four cross-package Context/Pattern/Device tests
raise the full native suite to 783/783. The raw tests exercise every new
producer/consumer boundary and the existing external suites continue to cover
mapped/data owner invalidation, callback ABI, retained source/target lifetimes,
backend subtype errors, and allocation/finalizer stress. Static review proves
that the 357-symbol production C API set is identical to the parent commit and
no C source changed. All 13 duplicate typed/raw declarations were removed; the
FFI audit now rejects duplicate symbols as well as missing ownership
annotations. `src/pkg.generated.mbti` is byte-for-byte unchanged at SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.
The layout now contains 46 direct public implementation files, a 49-entry
exact public-root allowlist, 394 source files, 44 production FFI files, and 83
Cairo-linked package configs.

## Typed Facade FFI Elimination

The tenth package-boundary pass removed the last 11 public-root non-callback
extern declarations. Typed Context and Pattern enum APIs now convert their
closed MoonBit enums to raw Cairo `Int` values before crossing into the owner
package. Context font selection and text-cluster flags use the same rule, and
Surface-to-Device exchange now happens through `src/internal/device`. Context,
Pattern, Device, and Surface own 109, 38, 17, and 79 externs respectively. The
public root retains exactly 12 callback ABI declarations in five files: seven
raster-source callbacks, two PNG stream callbacks, and one PDF, PS, and SVG
stream constructor each.

The corresponding duplicate typed C setter/selector bridges and unused typed
getter helpers were deleted. The production boundary now contains exactly 348
`MOONBIT_FFI_EXPORT` definitions, each paired one-to-one with one production
MoonBit extern, plus the explicitly allowlisted direct libcairo symbols
`cairo_version` and `cairo_format_stride_for_width`. The ownership audit also
rejects duplicate exports and duplicate extern declarations. The image-surface
user-data probe is no longer a production export; its MoonBit-callable test
entry point lives in the oracle-native package.

The new raw Context and Device tests raise the native suite to 784/784. The
final layout has 42 direct public implementation files, a 45-entry exact
public-root allowlist, 390 source files, 40 production FFI files, and 83
Cairo-linked package configs. The public interface is byte-for-byte unchanged
at SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.
The local host release gate and both exact Linux Cairo lanes pass; each lane
runs all ordinary tests and every discovered package under ASan/LSan. The only
suppression is the standalone-C-probe-confirmed recording snapshot in the
vector oracle: exactly 16 allocations/7424 bytes on Cairo 1.15.10 and 16
allocations/9344 bytes on Cairo 1.18.4.

## Public Documentation Audit

The 2026-07-15 audit rechecked the pinned pycairo source against upstream HEAD
`80ea3348aff95e8441e6c3e2086371ea40528d81`; the revisions match. Empty `///|`
block markers are not documentation. The first checker version also omitted 11
object-handle declarations without an explicit `pub` modifier. Generated MBTI
and MoonBit's access-control contract prove those are default-abstract public
types; only `priv` types are package-private. Publication-archive inspection
then exposed two more downstream-importable support owners that the first gate
did not audit: generated constants and the native-stub anchor. The corrected
product inventory contains 579 declarations across 45 audited files. The docs
package's `pub using` aliases are counted at their declaration owners, while
internal and test-only declarations remain excluded.

Foundational errors, statuses, enums, formats, and versions account for 82
documented declarations. Matrix, Path, Rectangle, TextCluster, TextExtents,
TextGlyphRun, FontExtents, and Glyph documentation adds 56, including the
abstract `Path` type. The 42 support-package constants and one native anchor
are now documented as well. Region contributes all 22 owned-object,
construction, query, copy, translation, and boolean-operation declarations.
FontOptions contributes all 33 ownership, copy/merge, rendering-state,
raw-enum compatibility, variation, and color-palette declarations. Context
drawing state contributes all 31 line, fill, operator, antialias, tolerance,
miter, hairline, and dash declarations. Context core contributes all 18
ownership, construction, identity, save/restore, target/source, group, and tag
declarations. Context paths contribute all 17 construction, current-point,
copy, flatten, and append declarations. Context clipping/extents contribute all
11 clip-state, rectangle-export, geometry-bound, and hit-test declarations. The
Context matrix slice contributes all 11 CTM composition, replacement, snapshot,
and point/distance conversion declarations. The Context source/painting/page
slice contributes all 14 source installation, masking, paint, fill, stroke, and
page-emission declarations. Its seven-test black-box package now additionally
locks color-component clamping, source-pattern user-space binding across later
CTM changes, and checked sticky-error propagation through every public method;
existing pixel, offset, preserve/consume, lifetime, and direct-C multi-page
oracles cover the rest of the documented contract. The Context font/text/glyph
slice contributes all 19 font-state, toy-text, explicit-glyph, cluster-aware
text, extent, path, and scaled-font declarations. Existing black-box and
direct-C oracles cover owning borrowed returns, copied FontOptions state,
font/scaled-font round trips, UTF-8 and embedded-NUL handling, current-point and
path behavior, empty and populated glyph arrays, multilingual shaping, and
vector text metadata; the focused regression now also locks generic
`CairoError(InvalidClusters, _)` mapping. All 121 Context declarations are now
documented. The current exact baseline is therefore 357 documented
declarations and 222 grandfathered documentation-debt entries.

`scripts/check-public-docs.py` parses the audited declaration forms and checks
the sorted debt ledger in both directions: a new undocumented declaration,
an undocumented declaration missing from the ledger, or a now-documented
stale entry fails verification. Thirteen focused checker tests include the
default-abstract/private distinction and the exact published-support scope,
raising the script unit suite to 76/76.
The local release gate passes all 784 native tests, both checkout and
extracted-package consumers pass 1/1, and the integrity-checked
archive contains 598 members. The public generated interface remains
byte-for-byte unchanged at SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.
This documentation-only replay skipped duplicate host ASan; the unchanged
runtime remains covered by the immediately preceding exact Cairo 1.15.10 and
1.18.4 ordinary plus package-isolated ASan/LSan runs.

## Pattern Lifecycle And Documentation Audit

The 2026-07-16 Pattern audit covers all 53 public declarations across
`pattern.mbt`, `pattern_gradient.mbt`, `pattern_mesh.mbt`, and
`pattern_raster_source.mbt`. Their substantive `///` contracts now specify the
single native owner, pointer-identity equality/hash, independently referenced
Surface and Path returns, typed/raw enum behavior, user-to-pattern matrix
direction, gradient stop clamping/order, mesh patch state and index errors,
Cairo version boundaries, and raster callback closure/surface retention. The
public-documentation baseline is now 472 of 579 with 107 exact debt entries.

The native review found that a raster release closure could clear or replace
its own registration. `cairo_pattern_set_user_data` then destroyed the active
`CairoonRasterSourceState`, after which the release trampoline read
`state->release_arg`, producing an ASan-confirmed heap use-after-free. Applying
the same immediate mutation from acquire could also remove Cairo's internal
release trampoline before it balanced the returned Surface owner. Callback
state now tracks callback depth and outstanding successful acquisitions;
replacement or clear is queued and applied only after the old acquire/release
pair has finished. Call-scoped callback function and closure pointers are held
in locals with explicit MoonBit references, and owner cleanup completes before
the old state can be destroyed.

Three black-box regressions pin release-side clear, acquire-side clear with a
zero native owner count, and sticky `InvalidMatrix` after a singular pattern
matrix. Exact Linux Cairo 1.15.10 and 1.18.4 each pass the complete 790/790
native suite, both isolated downstream consumers, the 598-member publication
archive, and every package under ASan/LSan. Their sole suppression remains the
pure-C-probe-confirmed recording snapshot: 16 allocations/7424 bytes and 16
allocations/9344 bytes respectively. The 348 local native symbols plus two
direct libcairo symbols remain unchanged; no public API was added or removed.

## Surface Lifecycle And Documentation Audit

The 2026-07-16 Surface audit covers all 35 public declarations across
`surface.mbt`, `surface_state.mbt`, `surface_font_options.mbt`,
`surface_mime.mbt`, and `surface_png.mbt`. Their substantive `///` contracts
now specify native and parent ownership, pointer identity, caller-buffer
retention, typed/raw boundaries, coordinate units, status diagnostics,
terminal finish behavior, flush/dirty synchronization, page operations,
independent FontOptions snapshots, MIME data copies, and PNG path/stream error
mapping. The public-documentation baseline is now 507 of 579 with 72 exact debt
entries.

Comparison with Cairo 1.18.4's `cairo_surface_finish` implementation and
pycairo's Surface cleanup path exposed two errors in cairoon. First,
`cairoon_surface_finish` returned a sticky status before calling
`cairo_surface_finish`, so backend cleanup and release of a retained
`image_for_data` buffer could be skipped. Second, `Surface::with_finished`
called checked cleanup after a closure error, allowing cleanup's sticky status
to replace the original exception. Native finish now captures the original
status, always calls Cairo finish and retained-data release for a valid handle,
then reports the original status before any cleanup status. The scoped helper
uses raw best-effort cleanup on its error path and checked finish on success.

The ownership lint now fixes the complete native status/cleanup skeleton,
rejecting non-null early returns, pre-release control transfer, conditional or
reordered cleanup, misplaced status capture, and incorrect
original/marker/finish/data precedence. It also rejects conditional or checked
cleanup on the scoped error path, cleanup after re-raise, and unchecked or
conditional success cleanup.
Six focused checker tests exercise its passing and failing forms. A test-only
public-Cairo probe creates a defined sticky `InvalidMatrix` with an invalid
fallback resolution and proves that explicit finish still clears the retained
caller-buffer slot. A PDF stream regression
creates sticky `WriteError` and proves that `with_finished` preserves the
closure's later `InvalidString`. The focused packages pass 8/8 and 16/16 in
ordinary and package-isolated ASan/LSan runs on exact Cairo 1.15.10 and 1.18.4.
The complete native suite now contains 792 tests.

The complete local release matrix passes on exact Linux Cairo 1.15.10 and
1.18.4: 792/792 native tests, both checkout and extracted-publication consumers
at 1/1, integrity checks for all 600 archive members, and every package under
ASan/LSan. The only suppression is independently reproduced by the pure-C
recording-snapshot probe and remains isolated to the vector oracle package: 16
allocations/7424 bytes on Cairo 1.15.10 and 16 allocations/9344 bytes on Cairo
1.18.4. The 348 local native symbols plus two direct libcairo symbols remain
unchanged. After removing `moon info`'s blank-line-only generated-file churn,
`src/pkg.generated.mbti` remains byte-for-byte unchanged at SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.

## ScaledFont Lifecycle And Documentation Audit

The 2026-07-16 ScaledFont audit covers all 15 public declarations in
`scaled_font.mbt`. Their substantive `///` contracts now specify the owning
`cairo_scaled_font_t` reference, identity equality/hash, independently owned
FontFace and FontOptions returns, font/CTM/scale matrix coordinate rules,
degenerate versus non-finite matrix behavior, user-space metrics, UTF-8 byte
clusters, glyph index width, result ownership, embedded-NUL validation, and
checked error mapping. The public-documentation baseline is now 522 of 579
with 57 exact debt entries.

Comparison with pycairo's `PycairoScaledFont_TextToGlyphs` and Cairo 1.18.4
exposed three reliability gaps. First, glyph-only conversion requested and
discarded clusters instead of passing null cluster outputs, so it could perform
extra work and surface cluster-only allocation or backend failures. Second,
the raw constructor collapsed an erroneous but non-null FontFace or FontOptions
to `NullPointer` rather than preserving its Cairo status. Third, copied glyph
and cluster arrays remained allocated until GC finalized the temporary result.
The native bridge now accepts an explicit cluster mode, forwards non-null
inputs to Cairo even when they carry an error status, and provides an
idempotent release used on both successful and raised MoonBit decode paths;
the external-object finalizer remains a fallback.

The direct-C oracle no longer returns the production result wrapper or calls
production accessors. Each oracle accessor invokes Cairo independently, copies
the requested fields into a MoonBit array, and immediately frees the Cairo
arrays. A test-only user font records whether all three optional cluster output
arguments are null, proving the glyph-only ABI at runtime. Further regressions
cover raw `InvalidSlant` preservation, repeated release, zero font/CTM
matrices, non-finite determinants, embedded NUL in all three text methods,
2/3/4-byte UTF-8 clusters, and 1000 iterations of both conversion modes.

The complete local release matrix passes on exact Linux Cairo 1.15.10 and
1.18.4: 796/796 native tests, both checkout and extracted-publication consumers
at 1/1, integrity checks for all 600 archive members, and every package under
ASan/LSan. Focused ScaledFont packages pass 3/3, 9/9, and 4/4 in ordinary and
sanitized runs; the 1000-iteration lifetime package passes 1/1. The only
suppression remains the independently reproduced recording-snapshot leak in
the vector oracle package: 16 allocations/7424 bytes on Cairo 1.15.10 and 16
allocations/9344 bytes on Cairo 1.18.4. The production boundary now contains
349 local native symbols plus two direct libcairo symbols. The public
`src/pkg.generated.mbti` remains byte-for-byte unchanged at SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.

## RecordingSurface And TeeSurface Lifecycle And Documentation Audit

The 2026-07-16 audit covers all 8 public declarations in
`recording_surface.mbt` and `tee_surface.mbt`. Their substantive `///` contracts
now specify the sole native Surface owner, Cairo's recording-operation
snapshots, bounded pixel coordinates, typed/raw content values, replay and ink
extents, primary/replica MoonBit retention, independent indexed references,
duplicate/removal behavior, and checked finished/type/index errors. The public
documentation baseline is now 530 of 579 with 49 exact debt entries.

Comparison with Cairo 1.15.10 and 1.18.4 exposed one status-fidelity defect.
The Tee-specific receiver check inspected native status and type but ignored
cairoon's explicit finish marker. If `tee_index` was the first method called
after `finish`, Cairo attempted to create a `SurfaceFinished` error surface;
because that status has no dedicated static nil surface, the returned status
degraded to `NoMemory`. All Tee methods now use the shared Surface type
precondition, preserving `SurfaceFinished` before entering Cairo. Recording's
intentional exception remains explicit: configured extents mirror pycairo and
can be read after finish, while ink measurement follows cairoon's terminal
Surface policy.

Two new Tee tests prove that an independently referenced indexed target remains
usable after removal and after the target, tee, and backing arrays leave their
creator scope, and that index/add/remove all preserve `SurfaceFinished`.
Existing error coverage now also proves absent-target removal raises and stores
sticky `InvalidIndex`. Recording coverage pins the post-finish extents/ink
distinction. Focused Recording and Tee packages pass 5/5 and 6/6 in ordinary
and package-isolated ASan/LSan runs on both exact Cairo versions; the executable
documentation package passes 63/63.

The complete local release matrix passes on exact Linux Cairo 1.15.10 and
1.18.4: 798/798 native tests, both checkout and extracted-publication consumers
at 1/1, integrity checks for all 600 archive members, and every package under
ASan/LSan. The only suppression is independently reproduced by the pure-C
recording-snapshot probe and remains isolated to the vector oracle package: 16
allocations/7424 bytes on Cairo 1.15.10 and 16 allocations/9344 bytes on Cairo
1.18.4. The production boundary remains 349 local native symbols plus two
direct libcairo symbols. The public `src/pkg.generated.mbti` remains
byte-for-byte unchanged at SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.

The failing remote workflow run 28795446888 was inspected without rerunning or
pushing. Its only failed job was Ubuntu ASan, where the old PDF wide multi-page
tag stream test compared normalized file and stream bytes and returned false;
ordinary Ubuntu and macOS jobs passed. The unpushed local history already
contains commit `715aaa6`, which limits exact byte equivalence to PS/SVG and
checks stable PDF structure markers instead. The matching wide-scene filter
passes 4/4 under local ASan, including the formerly failing PDF stream case.

## Stream Constructor Failure Ownership Audit

The 2026-07-16 stream audit found a failure-order defect shared by PDF, PS, and
SVG stream surfaces plus ScriptDevice. Their `#owned` writer state was passed to
the new Cairo producer before it could be attached as user data. If attachment
failed, `cairoon_stream_attach` released the state immediately and the caller
then destroyed the producer. Backend destruction can still invoke its writer,
so this rare allocation-failure path could call through freed MoonBit state.

The attach helpers consume state only on successful user-data attachment. All
four constructors check native status before attachment. Null construction,
native-status, and attachment failures now all call a shared Surface or Device
cleanup helper. Each helper null-checks the producer, destroys it while the
callback state is still valid, releases the state exactly once, and leaves the
caller to return a null raw owner with the original status.

`scripts/check-stream-cleanup.py` independently parses these five native files
and statically pins successful ownership transfer, shared-helper structure, and
all three pre-transfer failure branches; it is separate from the already-large
FFI checker. Nine negative mutations reject missing or malformed attachment,
helper-side failure consumption, missing shared cleanup, missing status checks,
and reversed Surface/Device helper order; one passing baseline contributes ten
script tests.

`src/tests/oracle/stream_failure` adds two dynamic fault-injection tests. Its
test-only C bridge creates real PDF, PS, SVG, and ScriptDevice stream producers,
arms the MoonBit closure, and invokes the production cleanup helper as though
user-data attachment had failed. PDF/PS/SVG destruction must call the still-live
writer and emit nonzero bytes; ScriptDevice destruction has no portable output
multiplicity contract, so leak, use-after-free, and double-release detection is
delegated to ASan/LSan/UBSan. Both exact Cairo lanes pass this oracle 2/2 plus
17/17 stream-surface, 19/19 ScriptDevice, and 2/2 stream-lifetime tests in
ordinary and package-isolated sanitizer runs. No production FFI symbol or
public MoonBit signature changed.

## SVG Surface Contract And Documentation Audit

The 2026-07-16 SVG audit completed substantive docs for all 11 public
declarations. File and stream constructors specify point-sized pages, optional
output, retained writer ownership, copied callback chunks, and finish-time
error reporting. Version helpers specify copied arrays and strings plus exact
raw invalid-value behavior. Restriction and document-unit methods now record
the before-drawing timing rule, root-size-only unit effect, Cairo 1.15.10
development-floor/1.16 stable API boundary, historical default-unit variance,
and checked finished/subtype errors.

The focused package now checks both negative and positive invalid raw version
strings. It also proves the linked Cairo behavior intentionally exposed by raw
methods: unknown unit `99` preserves the previously selected pixel unit, and
unknown version restriction `99` is a no-op that leaves Surface status at
`Success`. This evidence does not generalize to other out-of-range integers,
which remain unsupported. Typed methods are exhaustive and are the portable
default.

`scripts/check-public-docs.py` reports 541 documented declarations and 38 exact
debt entries. Exact Linux Cairo 1.15.10 and 1.18.4 each pass the 6/6 SVG package,
63/63 executable docs, 798/798 complete native suite, 90/90 script checks, both
1/1 downstream consumer paths, all 602 publication members, and every package
under ASan/LSan. The sole suppression is the independently reproduced Cairo
recording-snapshot leak: 16 allocations/7424 bytes on 1.15.10 and 16
allocations/9344 bytes on 1.18.4. No public signature or production FFI symbol
changed.

## PostScript Surface Contract And Documentation Audit

The 2026-07-16 PostScript audit completed substantive docs for all 13 public
declarations. File/no-output/stream construction now records point units,
multi-page sizing, writer retention, copied chunks, and finish-time errors.
Level helpers specify copied returns and restriction-before-drawing. EPS and
page-size methods specify current-page timing and EPS's single-page rule. DSC
methods now define the one-way Header to Setup to PageSetup protocol, byte
limits, prohibited newlines and Cairo-owned structural comments, sticky
`InvalidDscComment`, NUL validation, and checked receiver errors.
