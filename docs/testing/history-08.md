# Testing Evidence History, Part 8

Historical snapshot of `TESTING.md` lines 3798-4365 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

  A later backend navigation-map oracle slice added Scene 63, covering a
  two-page PDF/PS/SVG document with metadata, custom metadata removal, page
  labels, nested outlines, URI and named-destination tags, `TOC`/`TOCI`,
  `Reference`, `Div`, `Code`, `Formula`, `Figure`, and `Caption` structure
  tags, backend resizing, stable marker checks, file-vs-stream normalized
  equality, direct C oracle equality, and PS/SVG negative PDF-metadata checks.
  This raises `src/tests/oracle/vector_backend` to 211 tests and the observed
  full native suite to 726 tests without changing public API.
  A later backend accessibility-index oracle slice added Scene 64, covering a
  three-page PDF/PS/SVG document with metadata, custom metadata removal, page
  labels, nested outlines, URI and named-destination tags, `H1`,
  `L`/`LI`/`Lbl`/`LBody`, `Index`, `Reference`, `Note`, `Figure`, and
  `Caption` structure tags, backend resizing, stable marker checks,
  file-vs-stream normalized equality, direct C oracle equality, stream-to-C
  oracle equality, and PS/SVG negative PDF-metadata checks. This raises
  `src/tests/oracle/vector_backend` to 215 tests and the observed full native
  suite to 732 tests without changing public API.
  A later backend section-catalog oracle slice added Scene 65, covering a
  three-page PDF/PS/SVG document with metadata, custom metadata removal, page
  labels, nested outlines, URI and named-destination tags, `TOC`/`TOCI`,
  `Reference`, `H2`, `Code`, `Formula`, `Note`, `Figure`, `Caption`, and
  `BibEntry` structure tags, backend resizing, stable marker checks,
  file-vs-stream normalized equality, direct C oracle equality, stream-to-C
  oracle equality, and PS/SVG negative PDF-metadata checks. This raises
  `src/tests/oracle/vector_backend` to 219 tests and the observed full native
  suite to 736 tests without changing public API.
  A later pycairo module-constants slice added one external black-box fixture
  mapping `test_api.py::test_constants` to public cairoon raw-value observation:
  antialias/operator constants are checked through context raw getters, region
  overlaps through public constructors, `FORMAT_RGB30` through `image_raw(5)`,
  plus `FORMAT_INVALID`, `MIME_TYPE_JPEG`, and SVG 1.1/1.2 raw version strings.
  This raises `src/tests/api/enums` to 6 tests and the observed full native
  suite to 727 tests without changing public API.
  A later pycairo composite Region slice extended
  `region_pycairo_parity_test.mbt` with the upstream
  `test_api.py::test_region` multi-rectangle fixture, covering Cairo region
  normalization, translate/copy behavior, and exact intersect/subtract/union/xor
  split semantics. This raises `src/tests/region/pycairo` to 6 tests and the
  observed full native suite to 728 tests without changing public API.
  A later raster-source callback transition-closure slice added
  `pattern_raster_transition_matrix_test.mbt`, exhaustively executing all 36
  directed transitions among clear, release-only, acquire-only,
  acquire-with-release, dynamic acquire-with-release, and failed-acquire
  states. Every edge exercises the replaced state before replacement and the
  replacement state afterward, checks callback introspection and stale callback
  tokens, validates successful pixels or checked `NoMemory`, and verifies the
  C-side retained-surface owner count returns to zero. The package passes all
  7 tests in both native and targeted ASan runs, raising the observed full
  native suite to 737 tests; this closes the `RasterSourcePattern` API row while
  release-platform coverage remains a global `Tests`/portability gate.
  A later pycairo Pattern test-parity slice generalized the Context-only gate
  into `scripts/check-pycairo-test-parity.py`, moved family ledgers under
  `scripts/parity/`, and pinned all 31 upstream `test_pattern.py` cases to 18
  existing MoonBit runtime anchors, 26 required generated signatures, and 2
  deliberately absent abstract-constructor signatures. Source mode verifies
  the upstream SHA-256 and AST test sets; standalone mode verifies the pinned
  ledger snapshot. No duplicate MoonBit behavior tests were needed, so the
  observed full native suite remains 737 tests. The same full local gate found
  and fixed the current MoonBit `ambiguous_braces` error in the object-trait
  map fixture, then passed 737/737 native tests and all configured ASan runs.
  This closes the `Pattern basics` row and reduces the reliability ledger from
  10 to 9 `Partial` rows without changing public API.
  A later pycairo Surface test-parity slice added `scripts/parity/surface.json`,
  pinning all 68 upstream `test_surface.py` cases to 55 existing MoonBit
  runtime anchors, 50 required generated signatures, and 4 deliberately absent
  mapped-image signatures. The ledger records path/stream API splits,
  `MappedImageSurface` lifecycle restrictions, and the checked post-finish data
  policy explicitly. Together with the existing direct-C backend oracles,
  executable docs, portable method inventory, and targeted ASan packages, this
  closes both PDF/PS/SVG inventory tables and reduces the reliability ledger
  from 9 to 3 `Partial` rows without changing public API or the 737-test suite.
  A later pycairo Font test-parity slice added `scripts/parity/font.json`,
  pinning all 35 upstream `test_font.py` cases to 14 existing MoonBit runtime
  anchors, 21 required generated signatures, and 3 deliberately absent
  signatures. The ledger exposed that mutable pycairo `FontOptions` supports
  an explicit `hash()` method but rejects the generic hash protocol; cairoon
  now mirrors that contract by retaining `FontOptions::hash` and removing its
  generic MoonBit `Hash` trait. This closes the `Text and fonts` row and reduces
  the reliability ledger from 3 to 2 `Partial` rows without changing the
  737-test suite.
  A later pycairo Matrix test-parity slice added `scripts/parity/matrix.json`,
  pinning all 11 upstream `test_matrix.py` cases to 6 MoonBit runtime anchors,
  11 required generated signatures, and 2 deliberately absent signatures. The
  ledger exposed two valid pycairo operations missing from cairoon: matrix
  multiplication with `*` and checked component access with indexing syntax.
  Both are now public and executable-doc tested; invalid indexes still raise
  `CairoError::InvalidIndex`. The ledger also records the intentional MoonBit
  adaptation that Matrix fields are immutable and transforms return new values
  instead of mutating their receiver. This raises the observed full native
  suite from 737 to 739 tests, passes every configured ASan run, and leaves the
  reliability ledger at 2 explicit `Partial` rows.
  A later pycairo Region test-parity slice added `scripts/parity/region.json`,
  pinning all 12 upstream `test_region.py` cases to 10 family-local MoonBit
  runtime anchors, 19 required generated signatures, and 4 deliberately absent
  signatures. Its static protocol evidence exposed that `RectangleInt` still
  implemented generic `Hash` even though pycairo explicitly rejects hashing;
  cairoon now retains value equality while omitting `Hash` and `Compare` for
  both `Region` and `RectangleInt`. The 32-bit boundary/equality fixture moved
  from the generic value package into the Region family, so the full native
  suite remains 739 tests while Region grows from 6 to 7 fixtures and the value
  package shrinks from 7 to 6. The ledger also records cairoon's receiver-return
  boolean mutators as an explicit extension over pycairo's `None`. Source and
  pinned-snapshot parity modes pass with 225 tests across 6 families, and the
  full local gate passes 739/739 native tests plus every configured ASan
  package; the reliability ledger remains at 2 explicit `Partial` rows.
  A later pycairo Device test-parity slice added `scripts/parity/device.json`,
  pinning all 11 upstream `test_device.py` cases to 9 family-local MoonBit
  runtime anchors, 15 required generated signatures, and 1 deliberately absent
  abstract-constructor signature. The ledger records path and stream callbacks
  as separate typed constructors, `with_finished` as the context-manager
  adaptation, pointer identity for equality/hash, and checked
  `SurfaceTypeMismatch` for non-recording replay surfaces. Source-backed and
  pinned-snapshot parity modes now pass with 236 tests across 7 families; the
  Device package passes 18/18 under native and the configured clang/ASan run.
  The full local gate passes 739/739 native tests plus every configured ASan
  package, with no public API or native test-count change; the reliability
  ledger remains at 2 explicit `Partial` rows.
  A later pycairo Path test-parity slice added `scripts/parity/path.json`,
  pinning all 4 upstream `test_path.py` cases to 4 family-local MoonBit runtime
  anchors, 9 required generated signatures, and 1 deliberately absent abstract
  constructor signature. The ledger locks exact path stringification,
  pointer-identity equality/order/hash, and typed path iteration. Source-backed
  and pinned-snapshot parity modes now pass with 240 tests across 8 families;
  the Path core and parity packages pass 7/7 and 4/4 under both native and the
  configured clang/ASan run. The full local gate passes 739/739 native tests
  plus every configured ASan package, with no public API or native test-count
  change; the reliability ledger remains at 2 explicit `Partial` rows.
  A later pycairo Rectangle test-parity slice added
  `scripts/parity/rectangle.json`, pinning all 4 upstream `test_rectangle.py`
  cases to 3 family-local MoonBit runtime anchors and 7 required generated
  signatures. The ledger exposed missing tuple-style index syntax;
  `Rectangle::at` now provides checked `rectangle[index]` access and preserves
  `CairoInvalidArgument(InvalidIndex, _)` for out-of-range indexes. The public
  Context reference executes the new syntax. Source-backed and pinned-snapshot
  parity modes now pass with 244 tests across 9 families; targeted native,
  executable-doc, and configured clang/ASan tests pass. The full local gate
  passes 739/739 native tests plus every configured ASan package, with no
  native test-count change; the reliability ledger remains at 2 explicit
  `Partial` rows.
  A later pure-value parity slice added `scripts/parity/glyph.json`,
  `textcluster.json`, and `textextents.json`, pinning all 8 upstream cases to 5
  family-local MoonBit runtime anchors, 16 required generated signatures, and
  3 deliberately absent deprecated glyph-count signatures. Checked
  `TextCluster::at` and `TextExtents::at` operators preserve pycairo field
  order and `InvalidIndex` errors. Glyph deliberately uses its heterogeneous
  `(UInt64, Double, Double)` components rather than a precision-losing
  homogeneous index return. The TextExtents boundary fixture now reproduces
  pycairo's maximum and smallest-normal Double inputs. Source-backed parity
  passes with 252 tests across 12 families. The full local gate passes 739/739
  native tests plus every configured ASan package, with no native test-count
  change; the reliability ledger remains at 2 explicit `Partial` rows.
  A later Enum/Error parity slice added `scripts/parity/enums.json` and
  `error.json`, pinning all 11 upstream cases to 6 family-local MoonBit runtime
  anchors, 15 required generated signatures, and 4 deliberately absent legacy
  enum aliases. The checker now supports empty TypeError sets and recognizes
  tuple-form `pytest.raises((TypeError, ...))` assertions. The ledgers record
  closed enums, explicit raw-method boundaries, immutable typed suberrors, and
  Python-only pickle/exception protocol decisions. Source-backed parity passes
  with 263 tests across 14 families. The full local gate passes 739/739 native
  tests plus every configured ASan package, with no native test-count change;
  the reliability ledger remains at 2 explicit `Partial` rows.
  A later API/FilePaths parity slice added `scripts/parity/api.json` and
  `fspaths.json`, pinning all 17 upstream cases to 18 MoonBit runtime anchors,
  36 required generated signatures, 4 deliberately absent signatures, and 1
  exact inventory decision. The checker now accepts a runtime-less mapping
  only when an exact `API_INVENTORY.md` decision and non-empty MoonBit
  adaptation are both present. Source-backed parity passes with 280 tests
  across 16 families. The full local gate passes 739/739 native tests plus
  every configured ASan package, with no native test-count change; the
  reliability ledger remains at 2 explicit `Partial` rows.
  A later final-source parity slice added `scripts/parity/cmodule.json`,
  `typing.json`, `surface_numpy.json`, and `surface_pygame.json`, pinning the
  remaining 8 upstream tests to 10 runtime anchors, 12 required signatures, 1
  deliberately absent CAPI signature, 3 family-local decisions, and 1 static
  verify-gate anchor. The checker now rejects duplicate ledger source files and
  any unclaimed upstream `tests/test_*.py` file. Source-backed parity therefore
  covers all 288 tests across all 20 files exactly once; the native test count
  remains 739 and the reliability ledger remains at 2 explicit `Partial` rows.
  A later Cairo 1.18 tag-attribute closure slice added Scene 66 and five
  vector-backend tests. The MoonBit and direct-C scenes cover URI links with
  multiple explicit rectangles, named and page-position links, external-file
  page-position and destination links, explicit internal and extent-derived
  destinations, `TAG_CONTENT` `tag_name`/`id`, and `TAG_CONTENT_REF` `ref`.
  Invalid attributes, unknown structure tags, and forbidden nesting map to
  `TagError`; PDF/PS/SVG file, stream, and direct-C output are normalized and
  compared with stable positive or negative markers. The static scene checker
  requires all 10 attribute dimensions and all five runtime evidence tests.
  This closes the `Tags` row. The full local gate passes 745/745 native tests
  plus every configured clang/ASan package and reduces the reliability ledger
  to one explicit `Partial` row.

A later foundational-documentation slice adds focused executable references
for enums, status/version/errors, and pure value types. The external
`src/docs` package now passes 63/63 tests and the full native suite passes
761/761. `scripts/check-project-layout.py` requires all 11 reference files,
at least one executable `mbt check` block in each, and exact index entries in
both READMEs. Eight focused layout tests raise the Python checker suite to 63
tests and lock one passing case plus seven missing, untitled, malformed,
narrative-only, or incorrectly indexed failure paths.

A 2026-07-15 release-reliability pass replaced the old leak-disabled ASan
policy with a Linux package-isolated ASan/LSan runner. Its intentional-leak
preflight proves LSan is active, and a temporary `MOON_TOOLCHAIN_ROOT` lets
ASan own allocation without modifying the installed MoonBit runtime. The first
unsuppressed pass found and fixed one
real cairoon leak: stream write callbacks gave a freshly allocated MoonBit
`Bytes` value an extra C-side reference even though `FuncRef` arguments are
borrowed. Focused stream tests then passed 15/15. At that
release-reliability slice, the full native suite was 749/749 after separating
PDF, PS, and SVG grouped-glyph oracle cases.

The final exact-matrix replay also caught a clock-bound PDF oracle flake:
file and stream surfaces created on opposite sides of a wall-clock second
received different default Cairo creation dates. Cairo 1.17.6+ equivalence
fixtures now set fixed creation and modification dates. Cairo 1.15.10 does
not reliably serialize those experimental metadata setters, so the PDF
normalizer ignores only Cairo's automatic `/CreationDate (D:...)` line while
retaining strict comparison for all other lines. A synthetic byte-pair
assertion covers that rule. Both exact lanes then passed the full 761/761
suite and every package under ASan/LSan.

The exact Linux release evidence after the FontFace package extraction is:

- Cairo 1.15.10, archive SHA-256
  `62ca226134cf2f1fd114bea06f8b374eb37f35d8e22487eaa54d5e9428958392`:
  all static gates and 767/767 native tests pass; all discovered MoonBit
  packages pass ASan/LSan independently. The source-checkout and extracted
  publication-zip consumers each pass 1/1. The pure-C SVG probe reports
  exactly two 464-byte `_cairo_recording_surface_snapshot` allocations. Only
  the 226-test vector-oracle package uses the verified suppression, accounting
  for 16 allocations and 7424 bytes; every other package runs unsuppressed.
- Cairo 1.18.4, archive SHA-256
  `445ed8208a6e4823de1226a74ca319d3600e83f6369f99b14265006599c32ccb`:
  767/767 native tests pass and all discovered MoonBit packages pass ASan/LSan
  independently. The source-checkout and extracted publication-zip consumers
  each pass 1/1. The same pure-C probe reports exactly two 584-byte upstream
  allocations. The vector-oracle package accounts for 16 suppressed
  allocations and 9344 bytes; every other package runs unsuppressed.
- The script gate has 63 Python unit tests in total, including 16 dedicated
  sanitizer-policy tests plus failure-path coverage for publication CRC,
  member paths, integration exclusion, and every artifact-consumer command.
  An unknown probe exit code, allocation count, indirect leak, or stack
  signature is a hard failure rather than an expanded suppression.
  On stripped Ubuntu Cairo libraries, the probe selects a `cairo_restore`
  fallback and the runner additionally requires exactly 16 suppressions and
  the probe-predicted byte count.
  A separately named PDF probe frame distinguishes stripped interchange-init
  and paginated-finish stacks. Only the production PDF-stream constructor and
  Surface-finish wrappers may then suppress them, with the same exact
  allocation/byte accounting as the symbolized profile.

After the downstream fixture was added on 2026-07-15, the full host
`./scripts/verify.sh` gate passed again: 761/761 repository MoonBit tests, the
isolated consumer test passed 1/1 against both source and extracted publication
zip, with duplicate host ASan intentionally disabled for this run. Both exact
Linux lanes above reran that gate and every discovered package under
ASan/LSan.

The subsequent Region object-handle package extraction moved the raw GC handle
and all Region externs into `src/internal/region` while preserving the public
facade interface. Two package-local raw-handle tests raise the current suite to
763/763. The host gate, both exact Linux Cairo lanes, every package-isolated
ASan/LSan run, both downstream consumer paths, and the integrity-checked
540-member publication archive all pass after that extraction.

The subsequent FontOptions object-handle package extraction moved the sole raw
GC handle and all 28 FontOptions-specific externs into
`src/internal/font_options`. Context, Surface, and ScaledFont cross-family
paths now exchange `RawFontOptions` directly beneath the unchanged public
facade. Two package-local raw-handle tests raise the current suite to 765/765.
The host gate and both exact Linux Cairo lanes pass every package under
ASan/LSan, both downstream consumer paths pass 1/1, and the integrity-checked
publication archive contains 544 members.

The subsequent FontFace object-handle package extraction moved the sole raw GC
handle and all eight declared FontFace-specific externs into
`src/internal/font_face`. Context and ScaledFont cross-family paths now
exchange `RawFontFace` beneath the unchanged public facade. Two package-local
raw-handle tests raise the current suite to 767/767. The host gate and both
exact Linux Cairo lanes pass every package under ASan/LSan, both downstream
consumer paths pass 1/1, and the integrity-checked publication archive contains
548 members.

The subsequent Path object-handle package extraction moved the sole raw GC
handle and all seven Path-specific externs into `src/internal/path`. Context
copy/append paths and mesh Pattern get-path now exchange `RawPath` beneath the
unchanged public facade. The child has no production constructor, so it does
not introduce a test-only C ABI merely to create a package-local fixture.
Instead, the existing Context/Path/mesh/lifetime suites plus one new test that
uses a mesh-produced Path after its source Pattern scope ends cover both real
producers, append consumption, status errors, segment parsing, identity, and
finalization. The current suite is 768/768; the public generated interface is
unchanged, all five targeted host ASan packages pass, both downstream consumer
paths pass 1/1, and the integrity-checked publication archive contains 551
members. Both exact Linux Cairo lanes pass every discovered package under
ASan/LSan.

The subsequent Device object-handle package extraction moved the sole raw GC
handle and all 13 Device-only constructor, identity, lifecycle, type, and
script-state externs into `src/internal/device`. The five recording/script
Surface bridge externs remain in the facade package but now exchange
`RawDevice` beneath the unchanged public wrapper. The child owns stream chunk
copying before user retention, while native stream state still releases the
`#owned` writer closure. Two package-local raw identity/state/lifecycle tests
raise the current suite to 770/770. Targeted Device/ScriptSurface, stream,
value, and finalizer packages pass; the public generated interface hash is
unchanged, both downstream consumer paths pass 1/1, and the
integrity-checked publication archive contains 556 members. The complete host
gate passes, and the targeted ownership/lifetime packages also pass under host
ASan. Both exact Linux Cairo lanes pass every discovered package under
ASan/LSan; only the pure-C-probe-verified vector-oracle suppression is used,
covering exactly 16 allocations/7424 bytes on Cairo 1.15.10 and 16
allocations/9344 bytes on Cairo 1.18.4.

The subsequent ScaledFont object-handle package extraction moved the sole
`RawScaledFont` GC handle and all 18 ScaledFont and text-to-glyph raw externs
into `src/internal/scaled_font`, split across its core and temporary-result FFI
files. Its private `RawTextToGlyphs` result remains the sole owner of Cairo's
temporary glyph and cluster arrays; the public facade validates dimensions and
copies every glyph and cluster value before that result can be finalized.
Context get/set bridges now exchange `RawScaledFont` beneath the unchanged
public wrapper, with borrowed returns referenced by the native bridge. Two
package-local identity, owner, matrix, and text-to-glyph tests raise the suite
to 772/772. The root implementation count falls from 64 to 62 files and the
grandfathered public-root allowlist from 67 to 65, while the generated public
interface hash remains unchanged. The complete host gate and targeted host
ASan packages pass; both exact Linux Cairo lanes pass every discovered package
under ASan/LSan. Both downstream consumer paths pass 1/1, the
integrity-checked publication archive contains 561 members, and the only
suppression remains the pure-C-probe-verified vector-oracle case: exactly 16
allocations/7424 bytes on Cairo 1.15.10 and 16 allocations/9344 bytes on Cairo
1.18.4.

The subsequent Pattern object-handle package extraction moved the sole
`RawPattern` GC handle and 35 object-only externs into
`src/internal/pattern`, split into core/common/gradient and mesh FFI files.
The public facade retains only five SurfacePattern and typed-enum bridges plus
nine raster callback/content bridges; Context source, group, and mask bridges
now exchange `RawPattern` beneath the unchanged abstract `Pattern` wrapper.
The wrapper has no second finalizer. Owned constructors and `pop_group`,
referenced borrowed returns from `get_source` and `get_surface`, borrowed
set/mask arguments, retained SurfacePattern bases, raster callback closures,
and owned mesh `RawPath` results preserve their prior ownership contracts.
No C glue or native ABI changed.

Three package-local identity/state, gradient, and mesh tests raise the suite to
775/775. The root implementation count falls from 62 to 61 files and the
grandfathered public-root allowlist from 65 to 64. The generated public
interface remains byte-for-byte unchanged at SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.
The complete host gate and targeted Pattern, Context, lifetime, raster, and
oracle packages pass under host ASan. Both exact Linux Cairo lanes pass every
discovered package under ASan/LSan, both downstream consumer paths pass 1/1,
and the integrity-checked publication archive contains 568 members. The only
suppression remains the pure-C-probe-verified vector-oracle case: exactly 16
allocations/7424 bytes on Cairo 1.15.10 and 16 allocations/9344 bytes on Cairo
1.18.4.

The subsequent Context object-handle package extraction moved the sole
`RawContext` GC handle and 102 non-facade externs into
`src/internal/context`. Seven focused FFI files mirror the unchanged C split:
12 core, 11 clip/extents, 18 font/text, 11 matrix, 12 paint, 17 path, and 21
state declarations. The public root retains only 14 bridges whose signatures
require facade-owned Surface, Content, or enum types, split 5/5/2/2 across
core, state, font/text, and paint. Public `Context` is now a private
single-field wrapper with no second finalizer. Constructors still return one
owned raw handle and retain their target wrapper; target/group-target getters
return referenced Surface wrappers, `get_source` returns a referenced
`RawPattern`, `pop_group` returns an owned `RawPattern`, path copies return
owned `RawPath`, and font getters preserve their copy/reference contracts. No
C glue or native ABI changed.

Context is producer-only at the child-package layer because valid construction
requires facade-owned Surface wrappers, so no test-only raw constructor was
added. The existing public Context, font, Path, Pattern, image/Surface,
object-trait, lifetime, raster, and vector-oracle suites cover all real
producers and cross-family consumers. The suite remains 775/775. Direct public
implementation files fall from 61 to 58 and the exact public-root allowlist
from 64 to 61; 378 source files, 43 production FFI files, and 82 Cairo-linked
package configs pass their static gates. The public generated interface remains
byte-for-byte unchanged at SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.
The host gate, source and extracted 581-member publication consumers, and both
exact Linux Cairo lanes pass. Every discovered package passes ASan/LSan; the
only suppression remains the pure-C-probe-verified vector-oracle case, exactly
16 allocations/7424 bytes on Cairo 1.15.10 and 16 allocations/9344 bytes on
Cairo 1.18.4.

The subsequent Surface object-handle package extraction moved the sole
`RawSurface`, `RawMappedImageSurface`, and `RawImageData` GC handles plus all
79 object-only externs into `src/internal/surface`. Thirteen focused FFI files
mirror Cairo's base, state/page, image, mapped-image, image-data, PNG, MIME,
font-options, recording, PDF, PS, SVG, and Tee families. The public package
retains five bridges whose signatures require MoonBit stream callbacks. Typed
facade methods convert enums to raw `Int` and call the child package instead of
redeclaring a C symbol. Public `Surface`, `MappedImageSurface`, and `ImageData`
are private single-field wrappers with no second finalizer.

Context now owns 108 raw externs and retains 7 facade bridges; Pattern owns 38
raw externs and retains 10 facade callback/enum bridges; Device owns 16 raw
externs and retains 1 facade bridge. Their child packages exchange Surface
raw handles directly. Four Surface package tests plus four cross-package
Context/Pattern/Device tests raise the complete native suite from 775 to
783 tests. They cover raw identity/state, mapped-image and mutable-view owner
edges, MIME/font-options/recording/Tee composition, no-output PDF/PS/SVG state,
both Context constructors and target/source paths, SurfacePattern and raw
raster construction, and all script-device Surface paths.

The migration changes no C glue and preserves the exact 357-symbol production
C API set. All 13 duplicate typed/raw declarations were removed, and the FFI
audit rejects future duplicate symbols. The public generated interface remains
byte-for-byte unchanged at SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.
Direct public implementation files fall from 58 to 46 and the exact
public-root allowlist from 61 to 49; the source tree now has 44 production FFI
files and 83 Cairo-linked package configs. Full host and exact Cairo matrix
results are recorded in `AUDIT.md` after each release-candidate replay. The
current Cairo 1.15.10 and 1.18.4 lanes both pass 783/783 plus every
package-isolated ASan/LSan invocation; the only suppression is the standalone
C-probe-verified recording-snapshot leak, at 16 allocations/7424 bytes and 16
allocations/9344 bytes respectively.

## Typed Facade FFI Elimination

The next facade cleanup removed all 11 remaining non-callback extern
declarations from the public package root. Context and Pattern typed enum
methods now perform explicit enum-to-raw-`Int` conversion in MoonBit and call
their owner packages; Context font selection and `show_text_glyphs` follow the
same raw boundary. `Surface::get_device` now exchanges a raw Device handle
through `src/internal/device`. The final child-package counts are 109 Context,
38 Pattern, 17 Device, and 79 Surface externs. The only public-root externs are
the exact 12 callback ABI bridges in five files: seven raster-source callbacks,
two PNG stream callbacks, and one stream constructor each for PDF, PS, and
SVG.

The native audit now parses every `MOONBIT_FFI_EXPORT` definition, rejects
duplicate C exports, and requires one production MoonBit extern for every
local native export and vice versa. The resulting boundary has 348 local
native symbols plus the two deliberately direct libcairo symbols
`cairo_version` and `cairo_format_stride_for_width` across 40 production FFI
files. Test-only image user-data inspection moved out of production C and into
the oracle-native test package. A new Context raw-boundary test and a Device
cross-package Surface identity test raise the full native suite to 784/784.

The final local release replay covers 390 source files, 42 direct public
implementation files, a 45-entry exact public-root allowlist, and 83
Cairo-linked package configs. The checkout consumer and extracted-package
consumer each pass 1/1 against the integrity-checked 595-member publication
archive. The public generated interface remains byte-for-byte unchanged at
SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.
The host gate passes with duplicate ASan disabled, and both exact Linux Cairo
1.15.10 and 1.18.4 lanes pass every ordinary and package-isolated ASan/LSan
test. Their sole suppression remains the pure-C-probe-verified vector-oracle
recording snapshot: exactly 16 allocations/7424 bytes on Cairo 1.15.10 and 16
allocations/9344 bytes on Cairo 1.18.4.

## Public Documentation Baseline

The public-doc audit treats empty `///|` block markers as source separators,
not documentation. Its first implementation counted only declarations with an
explicit `pub` modifier. Generated MBTI review exposed 11 omitted object-handle
types: MoonBit types are abstract and externally nameable by default unless
declared `priv`. Publication-archive review then exposed the importable
constants and native support packages. The corrected checker covers 579 public
declarations across the 42 direct facade implementation files plus the
constants, Glyph, and native support owners. The docs package's `pub using`
aliases are audited at their declaration owners; internal and test-only
declarations are excluded.

The first documented slice covers 82 foundational error, status, enum, format,
and version declarations. The pure geometry/value slice adds all 56 Matrix,
Path, Rectangle, TextCluster, TextExtents, TextGlyphRun, FontExtents, and Glyph
declarations, including the previously omitted abstract `Path` type. The 42
support constants and native link anchor add another 43 documented
declarations. The Region slice adds all 22 owned-object, construction, query,
copy, translation, and boolean-operation declarations. The FontOptions slice
adds all 33 ownership, copy/merge, rendering-state, raw-enum compatibility,
variation, and color-palette declarations. The Context drawing-state slice adds
all 31 line, fill, operator, antialias, tolerance, miter, hairline, and dash
declarations. The Context core slice adds all 18 ownership, construction,
identity, save/restore, target/source, group, and tag declarations. The Context
path slice adds all 17 construction, current-point, copy, flatten, and append
declarations. The Context clipping/extents slice adds all 11 clip-state,
rectangle-export, geometry-bound, and hit-test declarations. The Context matrix
slice adds all 11 CTM composition, replacement, snapshot, and point/distance
conversion declarations. The Context source/painting/page slice adds all 14
source installation, masking, paint, fill, stroke, and page-emission
declarations. Its seven black-box tests include color clamping, source-pattern
user-space binding after CTM changes, pixel and offset behavior, path
preserve/consume behavior, and checked sticky-error propagation through every
method; lifetime tests and direct-C vector page oracles cover retained sources
and copy/show-page semantics. The Context font/text/glyph slice adds all 19
font-state, toy-text, explicit-glyph, cluster-aware text, extent, path, and
scaled-font declarations. Black-box and direct-C coverage proves owning
borrowed returns, isolated FontOptions copies, font/scaled-font round trips,
UTF-8 and embedded-NUL handling, path/current-point behavior, empty and
populated glyph arrays, multilingual shaping, vector text metadata, and exact
`CairoError(InvalidClusters, _)` classification. All 121 Context declarations
are now documented. The Device/script slice adds all 20 ownership, identity,
status/type, finish/flush, acquire/release, scoped cleanup, script mode/comment,
recording replay, and script-surface declarations. Its lifecycle audit fixed
native finish/release paths that could skip cleanup after sticky errors and
made scoped error cleanup preserve the closure error; an executable static
guard and a 19-test focused package, including ASan, pin those contracts. The
FontFace slice adds all 11 ownership, identity, toy construction, status,
family-copy, and typed/raw slant/weight declarations. Its focused allocation,
cross-scope, raw-error, and pycairo-derived packages pass 10/10 and 12/12. The
image slice adds all 31 ImageData, ImageSurface, and MappedImageSurface
declarations. It specifies owner-retained mutable views, zero-copy array
storage and release-on-finish, row padding, flush/dirty behavior, mapping
restrictions, exact-once unmap, and closure-error precedence. The lifecycle
audit replaced status-gated unmap with an always-cleaning native path and added
static guards plus two black-box regressions; all five image packages pass
33/33, including 9/9 for the mapped package under focused ASan. The Pattern
slice adds all 53 ownership, identity, solid/surface state, typed/raw
extend/filter/dither, matrix, gradient, mesh, and raster-source declarations.
The lifecycle audit found a release-side use-after-free when a callback cleared
its own retained state and an acquire-side risk of dropping the paired internal
release. Native state replacement is now deferred until all acquisitions using
the old pair finish. Three regressions cover release clear, acquire clear with
zero retained owners, and sticky `InvalidMatrix`. The Surface slice adds all 35
base ownership, identity, construction, state, finish/flush/dirty, page,
font-option, MIME, and PNG declarations. Its lifecycle audit found that sticky
status could skip native finish and retained image-data release, and that
checked cleanup could replace the closure error in `with_finished`. Native
finish now always performs backend and retained-data cleanup before returning
the original sticky status; the scoped helper performs best-effort raw cleanup
before re-raising the closure error. Static order guards and two black-box
regressions cover both failures. The ScaledFont slice adds all 15 ownership,
identity, matrix, metric, text, glyph, cluster, and checked-error contracts. Its
audit corrected glyph-only conversion to omit native cluster outputs, preserved
input-object status through raw construction, made native result release
deterministic and idempotent, and replaced a self-referential oracle with
independent direct-C copies. Focused matrix, UTF-8 byte-width, NUL, user-font
callback, raw-status, release, and 1000-iteration lifetime regressions cover
those contracts. The remaining 57 declarations are named exactly in
`scripts/public-docs-debt.txt`; that ledger may shrink but may not grow.

`scripts/check-public-docs.py` fails for a new undocumented declaration, a
missing debt entry, a stale entry after documentation is added, duplicate or
unsorted entries, and malformed ledger lines. Thirteen focused unit tests cover
those parser and ledger invariants, including default-abstract versus `priv`
types and the exact published-support scope. Six additional tests prove that
the Surface cleanup guard accepts the required native/scoped order and rejects
early returns, pre-release control transfer, conditional/skipped/reordered
native cleanup, misplaced status capture, incorrect native status precedence,
conditional or checked error cleanup, reversed scoped cleanup order, and
unchecked success cleanup, raising the script suite to 82/82.
The Surface lifecycle and documentation replay on exact Linux Cairo 1.15.10
and 1.18.4 covers 394 source files and passes all 792 native tests, both 1/1
downstream consumer paths, publication-archive integrity for 600 members, and
every package under ASan/LSan. The focused `image/buffer` and `stream/surface`
packages pass 8/8 and 16/16 in both ordinary lanes and under package-isolated
ASan/LSan. The sole suppression remains the pure-C-probe-confirmed recording
snapshot: 16 allocations/7424 bytes on Cairo 1.15.10 and 16 allocations/9344
bytes on Cairo 1.18.4. `src/pkg.generated.mbti` remains byte-for-byte unchanged
at SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.

The subsequent ScaledFont lifecycle and documentation replay adds substantive
contracts for all 15 declarations and raises documentation coverage to 522 of
579 with 57 exact debt entries. It corrects glyph-only conversion to pass null
cluster outputs, preserves non-null input error objects through raw
construction, and immediately releases copied native glyph/cluster arrays on
success and checked-error paths with an idempotent finalizer fallback. The
direct-C oracle now owns independent copy/free paths, and a test-only user-font
callback observes both clustered and null-cluster calls at the actual C ABI.
