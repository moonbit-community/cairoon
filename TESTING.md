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

1. API shape: the public API appears in `src/pkg.generated.mbti`, has no raw
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

## Current Sufficiency Verdict

The current test set is sufficient to protect the migrated slices that are
listed as `Done` in `API_INVENTORY.md`, provided `./scripts/verify.sh` passes
on the target platform. It is not sufficient to claim a complete pycairo
migration because several rows are intentionally still `Partial`, and because
some reliability evidence is local/manual rather than continuous CI evidence.

Evaluate each slice with this scorecard:

| Dimension | Required Evidence | Current State |
|---|---|---|
| API surface | Public entries appear in `src/pkg.generated.mbti`; Python-only pycairo APIs are recorded as `Decision`; `scripts/check-api-inventory.py` passes against parent `cairo/__init__.pyi` | Strong for current portable APIs; all pycairo public top-level entries, top-level constants, and 255 portable class methods are mapped to public MoonBit API anchors or explicit product decisions |
| Reliability ledger | `API_INVENTORY.md` statuses are `Done`, `Partial`, or `Decision`; every `Partial` row names its remaining gap; this scorecard and CI/verify gate are checked by `scripts/check-reliability-ledger.py` | Strong for current migrated slices; the lint runs in the local and CI verify gate, and any future full-product claim still requires zero `Todo`/`Partial` rows |
| FFI boundary safety | Production raw `src/**/ffi*.mbt` declarations mark every non-primitive C FFI parameter with `#borrow` or `#owned`, and `scripts/check-ffi-ownership.py` passes | Strong for current raw externs, including internal helper packages; the lint runs in the local and CI verify gate |
| Behavioral parity | pycairo-derived black-box cases or direct C Cairo primitive oracles cover normal and invalid inputs | Strong for image, context, path, font, pattern, region, surface/device, and backend helpers already listed in the inventory |
| Rendering parity | Deterministic image pixels or normalized PDF/PS/SVG bytes match direct C Cairo output | Strong for the enumerated image and vector fixtures, including backend page-transition, state-stack, deep-tag, metadata-outline, page-ops, tag-metadata, structure-sequence, outline-sequence, pattern-tag, semantic-index, and bookmark-lattice tag/metadata/page-operation output; still partial for broader tag/metadata/multi-page combinations |
| Lifetime safety | External-object ownership, borrowed returns, callback retention, and error exits run under ASan/LSan or stress tests | Strong for targeted local gates; macOS LSan remains intentionally disabled for known toy-font/glyph leak reports |
| Callback safety | C-held MoonBit callbacks and callback arguments are retained across the callback invocation and released deterministically | Strong for stream writers/readers and raster-source callbacks covered by current stress/fuzz tests |
| Portability | Required backends pass on each supported platform, or unsupported APIs have explicit `Decision` rows | Partial until the shipped CI workflow has passing native, oracle, and sanitizer runs across the release platform matrix |
| Documentation | Public behavior has executable reference examples where practical | Strong for current migrated families; keep this synchronized with public API additions |

The practical release rule is simple: a feature can be trusted when its
inventory row is `Done`, its reference docs are executable where practical,
and the verify gate passes locally and in CI for every supported platform.
Until the remaining `Partial` rows are closed or downgraded to explicit
`Decision` rows, the project is a reliable partial binding rather than a
complete pycairo migration.

## Test Tiers

Run these tiers in order while developing a slice.

### Tier 0: Interface And Build Checks

```sh
cairoon/scripts/configure-link-flags.sh --check
python3 cairoon/scripts/check-project-layout.py
python3 cairoon/scripts/check-source-size-budget.py
python3 cairoon/scripts/check-api-inventory.py
python3 cairoon/scripts/check-ffi-ownership.py
python3 cairoon/scripts/check-reliability-ledger.py
python3 cairoon/scripts/check-vector-backend-scenes.py
moon -C cairoon check --target native --deny-warn
moon -C cairoon info --target native
```

Review `src/pkg.generated.mbti` after `moon info`. Public additions, `raise`
annotations, and enum constructors must match the intended API.
Run `scripts/configure-link-flags.sh --check` before native checks when the
system Cairo installation may have changed. Run `scripts/check-api-inventory.py`
whenever the pycairo stub, public API, or inventory changes. Run
`scripts/check-ffi-ownership.py` whenever raw extern declarations change. Run
`scripts/check-project-layout.py` whenever package structure, root source files,
or `PROJECT_LAYOUT.md` changes. Run `scripts/check-source-size-budget.py`
whenever a source, script, test, native glue, or executable-doc file is added
or substantially expanded. Run
`scripts/check-reliability-ledger.py` whenever migration status, scorecard, or
CI/verify gate text changes. Run `scripts/check-vector-backend-scenes.py`
whenever backend oracle scene ids, native oracle stubs, stream-oracle wiring,
or Backend Differential Slices rows change. The full local gate includes all
of these checks.

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
  --pkg src/moon.pkg
```

For public C glue ownership changes, the local gate must also compile the
native-stub package itself with `moon test src/native --target native -v`; the
external black-box and oracle packages then prove those stubs link through the
published `CAIMEOX/cairoon` facade.

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
- Image PNG streams: path-vs-stream exact byte equality, read/write callback
  round trips, copied pixel-data equivalence after stream readback, and
  read/write error propagation.
- PDF/SVG/PS: create, finish, metadata, page behavior, stream writers, and
  normalized output, including direct-C comparisons for show/copy/show page
  transitions and clip/group/mask state-stack scenes with PDF tags and PS/SVG
  inertness checks.
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

- `moon check --target native --deny-warn`
- `moon test --target native --deny-warn`
- ASan/LSan native test run
- Differential pycairo/C oracle suite
- API inventory audit
- generated `src/pkg.generated.mbti` review

The current local gate is executable as:

```sh
./scripts/verify.sh
```

It runs `moon fmt --check`, `scripts/check-project-layout.py`,
`scripts/check-source-size-budget.py`, `scripts/configure-link-flags.sh --check`,
`scripts/check-ffi-ownership.py`, `scripts/check-api-inventory.py`,
`scripts/check-reliability-ledger.py`,
`scripts/check-vector-backend-scenes.py`, native
`moon check --target native --deny-warn`, the `src/native` native-stub package,
extracted external
test packages under
`src/tests/api` (version, enum, and pycairo `test_api.py` Unicode text/path
plus context/pattern lifetime parity),
`src/tests/status` (public status, `run_cairo`, and `CairoError`
classification),
`src/tests/value` (pure value APIs and pycairo value parity),
support packages under `src/core/constants`, `src/core/glyph`,
`src/internal/version`,
`src/internal/format`, `src/internal/status`, `src/internal/pdf`,
`src/internal/ps`, `src/internal/svg`,
`src/tests/matrix`,
`src/tests/region`,
`src/tests/surface/base`, `src/tests/surface/mime`,
`src/tests/surface/pycairo`, `src/tests/surface/subsurface`,
`src/tests/image/properties`, `src/tests/image/data`,
`src/tests/image/mapped`, `src/tests/image/png`,
`src/tests/image/buffer`, `src/tests/backend/pdf`,
`src/tests/backend/ps`, `src/tests/backend/recording`,
`src/tests/backend/svg`, `src/tests/backend/tee`,
`src/tests/context/pycairo`, `src/tests/context/clip`,
`src/tests/context/extents`, `src/tests/context/glyph`, `src/tests/context/group`,
`src/tests/context/matrix`, `src/tests/context/paint`,
`src/tests/context/path`, `src/tests/context/state`, `src/tests/context/tag`,
`src/tests/context/text`, `src/tests/context/text_to_glyphs`,
`src/tests/pattern/core`, `src/tests/pattern/mesh`,
`src/tests/pattern/pycairo`, `src/tests/pattern/gradient`,
`src/tests/pattern/raster`, `src/tests/font/face`,
`src/tests/font/options`, `src/tests/font/scaled`,
`src/tests/font/pycairo`, `src/tests/stream/surface`,
`src/tests/stream/device`,
`src/tests/path`, `src/tests/object`, `src/tests/lifetime/context`,
`src/tests/lifetime/owner`, `src/tests/lifetime/finalizer`,
`src/tests/lifetime/stream`,
`src/tests/lifetime/image_data`, `src/tests/lifetime/value`,
`src/tests/lifetime/raster`, and
`src/tests/oracle/native`, `src/tests/oracle/constants`,
`src/tests/oracle/scaled_font`, and
`src/tests/oracle/image`, `src/tests/oracle/pattern_raster`, and
`src/tests/oracle/vector_backend`, the full native test suite with
`moon test --target native --deny-warn`,
`moon info --target native`, and targeted ASan builds for all external test
packages when an ASan-capable `clang` is available. The public package root no
longer has a separate targeted `*_wbtest.mbt` list; those tests have been
converted into external oracle packages discovered by `scripts/verify.sh`.
Before the targeted ASan pass, `scripts/verify.sh` runs `moon clean` so a
compiler switch or Homebrew/Xcode clang update cannot reuse object files with
stale sanitizer runtime paths.
Set `CAIROON_VERIFY_ASAN=0` to skip the targeted ASan portion intentionally.

## Current Status

The current cairoon slice is not a full migration. It has native package setup,
pycairo-style C glue split into a `src/native` native-stub package with private
shared declarations plus per-family stub files, a first pure support package
seam for `Glyph` under
`src/core/glyph` with package-local pure value and glyph-array marshaling tests,
and a pure constants support package under `src/core/constants` with facade
`pub const` re-exports and package-local constant tests,
with private test-only oracle glue moved to the
`src/tests/oracle/native` support package and split into constants,
ScaledFont, common drawing, file/normalized-output comparison, ARGB32 image,
raster-owner, vector-output entry points, vector-output scene drawing, and
PDF/PS/SVG vector feature renderers,
opaque external-object wrappers for `Surface`,
`MappedImageSurface`, `Context`, `Path`, `Pattern`, `FontOptions`, `FontFace`,
`ScaledFont`, `Region`, and `Device`, pure value types including `Glyph` with
`UInt64` index width, many portable enums,
including enum-only `SurfaceObserverMode` pycairo compatibility,
expanded Context path, painting/page, target/source borrowed returns,
source-surface convenience, Context pointer equality/hash, clip, matrix, drawing-state including pycairo hairline mode,
compile-time Cairo
constants, group APIs, tag APIs, toy
text APIs including Unicode `show_text` smoke parity, glyph array APIs,
text-to-glyphs/show-text-glyphs APIs,
including glyph-only text conversion for pycairo's `with_clusters=False` path,
documented product decisions for `CAPI`, legacy uppercase enum alias
constants, and non-implemented FreeType/user-font classes,
hit-testing/extents APIs, typed Path segment iteration and stringification,
PNG filename load/save including Unicode filename round trips plus stream
read/write, pycairo `surface_destroy_before_context` and
`surface_destroy_before_surface_pattern` lifetime parity for stream-backed
surfaces retained by contexts and surface patterns, direct C Cairo oracle
comparisons for forty-three deterministic ARGB32 image scenes on ordinary and
buffer-backed image surfaces including toy-font `text_path`, toy-font
`show_text`, `glyph_path`, `show_glyphs`, `show_text_glyphs`,
source-surface offsets, mask-surface offsets, raster-source pattern repeat
rendering, dashed round-cap strokes, hairline strokes, clipped paint/fill output,
`OperatorClear` compositing output, group compositing output, mask pattern
compositing output, even-odd fill-rule output, and a surface-pattern
`Reflect`/`Nearest`/`DitherBest`/matrix combination plus transformed repeated
linear-gradient `Repeat`/`Nearest`/`DitherFast`/matrix output, transformed
radial-gradient `Reflect`/`Nearest`/`DitherGood`/matrix output,
surface-pattern `Pad`/`Bilinear`/`DitherDefault`/matrix and
`ExtendNone`/`Nearest`/`DitherNone`/matrix output, transformed linear-gradient
`Pad`/`Bilinear`/`DitherBest`/matrix output, transformed radial-gradient
`Repeat`/`Bilinear`/`DitherFast`/matrix output, surface-pattern
`Repeat`/`Bilinear`/`DitherGood`/matrix output, transformed linear-gradient
`ExtendNone`/`Good`/`DitherNone`/matrix output with duplicate-offset stops,
transformed radial-gradient `Pad`/`Good`/`DitherDefault`/matrix output,
curve/multi-patch mesh-pattern matrix output, and nested
surface/linear/radial/mask pattern-stack clip/save/restore/OperatorAtop output,
mesh/linear surface-mask group-compositing output, and
set_source_surface/repeated-surface-pattern/radial-mask group-compositing
output, surface-pattern device-offset mask with `OperatorScreen` group
compositing output, and surface/radial-gradient `OperatorOverlay` group-mask
output, and mesh/surface/linear pattern-stack `OperatorSoftLight` group-mask
output, and surface-pattern stroke `OperatorDifference` group-mask output, and radial-gradient `OperatorColorDodge` over transformed reflected surface-pattern output;
buffer-backed creation plus mutable `ImageData`
views for image and
mapped-image surfaces, pycairo-style scoped surface finish and mapped-image
unmap helpers with success/error cleanup coverage, portable
Surface base helpers such as similar-surface creation, rectangular child
surface creation with retained parent-wrapper lifetime, content/type queries,
pointer equality/hash for ordinary surfaces, dirty markers with
finished-status coverage, pycairo-derived surface context-manager/cmp-hash/
content-format/device-scale/create-for-rectangle/create-similar-image
fixtures, device offset/scale, fallback resolution,
show-text-glyphs support checks with finished-status coverage, invalid-size
error mapping for similar and rectangular child
surface construction, MIME constants, MIME data storage/query/clear support including
image/PDF/PS/SVG MIME support matrices, PDF JPEG MIME passthrough with direct C oracle coverage, PDF thumbnail direct C oracle coverage, pycairo-style PDF thumbnail resize/reset and post-finish error parity, and
RecordingSurface constructor/extents/ink-extents plus replay, mapped image
surface mapping/unmapping, PDFSurface filename/no-output/stream constructor,
version helpers, version restriction, size, metadata, custom metadata,
page-label, thumbnail reset, and single-flag and combined-flag outline helpers,
including subtype-mismatch checks for every bound PDF helper,
PSSurface
filename/no-output/stream constructor, level helpers, level restriction, EPS
mode, size and DSC helpers including subtype-mismatch checks for every bound PS
helper, SVGSurface filename/no-output/stream constructor,
version helpers, version
restriction, and document-unit helpers,
surface-pattern borrowed surface returns, Pattern pointer equality/hash
including independent solid-pattern identity,
pycairo solid-pattern default extend/filter/dither/matrix/clamped-RGBA,
setter round-trip, gradient point/color-stop/radial-circle, and mesh example
patch fixtures,
RasterSourcePattern
constructor/acquire/get-acquire/release callback glue with retained closure and acquired
surface owners, pycairo-derived callback-state/acquire-release paint fixtures,
finished-surface acquire failure injection, MeshPattern patch lifecycle/query
APIs, `FORMAT_INVALID` integer-sentinel coverage, FontOptions
state/accessor APIs, FontFace/ToyFontFace APIs, ScaledFont
basics including glyph extents, text-to-glyphs, and direct C Cairo oracle
comparison for font/text/glyph extents and empty, single/multi/spaced ASCII,
precomposed/decomposed Latin, CJK, Arabic RTL, and emoji UTF-8
text-to-glyph coordinate cases plus sheared font/CTM scale-matrix
composition, and
Device/ScriptDevice basics including status/type/equal/hash,
finish/flush/acquire/release, scoped acquire/finish, file/stream script devices,
pycairo-derived context-manager, cmp/hash, image-surface `get_device`,
script mode/comment, and recording replay fixtures, `Surface::get_device`,
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
64-step acquire-only retained-owner replacement fuzz, compatible target/extents
acquire rendering with device-offset source surfaces, and deterministic
callback replacement/failure fuzz with dynamic compatible source surfaces,
Cairo float
image-format creation/readback coverage, `Format::stride_for_width` coverage
for legacy, 16-bit, 30-bit, float, and invalid-width cases, stable
structural vector-output markers plus direct C oracle comparisons
for seventeen deterministic PDF/PS/SVG vector scenes covering paint, stroke,
fill/stroke rectangles, Bezier paths, transforms, linear/radial gradients,
toy-font text paths, toy-font `show_text`, `glyph_path`, `show_glyphs`, two-page paint, clip, dashed
stroke, repeated surface pattern, mask surface, and mesh pattern scenes, with
SVG dynamic `source-*` image-id normalization, three PDF-only tag oracle scenes,
three PDF-only text-tag oracle scenes, PS/SVG Link tag inertness oracle
scenes, PS/SVG destination and document-structure rectangle/text tag oracle
scenes, one cross-backend tagged multi-page text oracle scene, one
cross-backend tagged `show_text_glyphs` oracle scene, one cross-backend grouped
glyph/tag multi-page oracle scene, one cross-backend copy_page retained
two-page oracle scene, one cross-backend mixed
vector/tag/text oracle scene, one cross-backend layered
three-page clip/dash/surface-pattern/mask/tag/text oracle scene, one
cross-backend wide three-page URI/destination/document-structure tag/vector
oracle scene, PDF tagged `show_text_glyphs` marker checks, PDF grouped
glyph/tag marker checks, PDF copy_page retained two-page marker checks, PDF
mixed vector/tag/text marker checks, PDF layered three-page marker checks, PDF
wide three-page marker checks, three
PDF-only document-feature/page-operation oracle scenes including one text/tag-aware combined scene, one
PS-only DSC/multi-page oracle scene, one SVG-only
version/unit/multi-page oracle scene, PDF metadata/custom-metadata/page-label/
outline output markers, PDF/PS/SVG
multi-page output markers, PDF tagged multi-page text structure markers, PDF
tagged `show_text_glyphs` Link/structure markers, PDF JPEG MIME payload embedding and PDF thumbnail output with direct C oracle comparison,
image/PDF/PS/SVG MIME support matrix checks,
PDF URI link-tag annotation markers, PDF named-destination tag markers, PDF
document-structure tag markers, PS/SVG Link tag inert-output checks, PS/SVG
destination/document-structure rectangle/text tag output checks, PS/SVG
destination/document-structure, tagged `show_text_glyphs`, grouped glyph/tag,
mixed vector/tag/text, layered three-page, and wide three-page
negative checks for PDF-only tag metadata, and cross-backend tagged multi-page
text, tagged `show_text_glyphs`, grouped glyph/tag, mixed vector/tag/text,
layered three-page, and wide three-page checks with direct C Cairo oracle
comparison, mutable image/mapped-image data view tests, and initial tests. Pattern has executable
reference examples for solid/shared state, surface patterns, gradients, mesh
patches, raster-source callbacks, and checked subtype/index/lifecycle errors.
Backend surface black-box tests also cover extended PDF custom-metadata/
thumbnail/outline subtype mismatches, PS size/setup/page-setup subtype
mismatches, and SVG document-unit getters after `finish()`.
ImageData black-box tests cover ordinary, buffer-backed, and PNG-loaded
`get_data` after `finish()`, plus retained ordinary views observing
base-surface `SurfaceFinished` after the base surface is finished.
Path has executable reference examples and pycairo-derived fixtures for typed
segment iteration, pycairo-style string formatting, self comparison/hash,
flattened append behavior, copied-path ownership, and checked invalid-matrix
errors. Region now covers empty,
single-rectangle, and multi-rectangle construction plus predicates, pycairo
negative and positive rectangle-index fixtures, equality mapping through
MoonBit `Eq`, empty-region overlap and translate behavior, region boolean
operations, and rectangle boolean operations including XOR split semantics and
pycairo-style chainable boolean mutator returns; `region.mbt.md` adds
executable reference examples for the same family. Matrix has executable
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

Verified on 2026-07-02, 2026-07-03, 2026-07-04, 2026-07-05, 2026-07-06, and 2026-07-07:

- `./scripts/verify.sh`: passed. The local reliability gate ran
  `moon fmt --check`, `scripts/configure-link-flags.sh --check`,
  `scripts/check-ffi-ownership.py`, `scripts/check-api-inventory.py`,
  `scripts/check-reliability-ledger.py`, native `moon check`, targeted image,
  ScaledFont oracle,
  font-options/font-face/scaled-font, vector including PDF combined text
  document-feature plus PS DSC/SVG unit backend-feature oracle checks,
  surface base/ImageData tests,
  stream black-box/white-box tests, mapped-image, subsurface, recording,
  MIME, PDF/PS/SVG helper, TeeSurface, script-device, and object-trait tests,
  context lifetime/state/matrix/path/group/text/glyph/extents/clip/painting tests,
  Path tests,
  pattern/gradient/mesh tests, raster manual/owner/state white-box tests, and
  Region/lifetime-stress tests,
  the full native suite, `moon info --target native`, and targeted ASan
  image-oracle, font-options/font-face/scaled-font, vector-output, stream,
  surface base/ImageData, mapped-image, subsurface, recording, MIME,
  PDF/PS/SVG helpers, TeeSurface, script-device, object-trait,
  context-lifetime/state/matrix/path/group/text/glyph/extents/clip/painting, Path,
  pattern/gradient/mesh, raster manual/owner/state, and Region/lifetime-stress tests with
  leak detection disabled. The current run includes
  the surface-mask screen group image-oracle slice,
  the FontOptions variation embedded-NUL slice,
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
  the wide multi-page stream marker/equivalence slice,
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
  the wide multi-page vector/tag oracle slice,
  the packaging/pycairo-porting documentation slice, the layered multi-page
  vector/tag oracle slice, the mixed vector/tag/text marker slice, the direct
  C oracle slice, the PDF thumbnail direct C oracle slice, the PDF thumbnail
  stream equivalence slice, the PDF JPEG MIME stream equivalence slice, and
  the PDF text document-feature stream equivalence slice, the PDF
  page-operation document-feature stream equivalence slice, the non-text
  primitive vector stream equivalence slice, the backend feature/tag stream
  combo slice, the PS/SVG backend-combo stream inertness slice, the standalone
  text vector stream equivalence slice, and the single-page tag stream
  marker/equivalence stabilization slice.
- `moon -C cairoon check --target native`: passed.
- `moon -C cairoon test --target native`: 569 tests passed. The current run
  includes the expanded pattern-combo image oracle slice,
  the surface-mask screen group image-oracle slice,
  the mesh-mask group-compositing image oracle slice,
  the tag-heavy stream-to-direct-oracle differential slice,
  the backend stream-to-direct-oracle differential slice,
  the backend lifecycle-matrix differential slice,
  the backend tag-matrix differential slice,
  the resized backend page-sequence combo slice,
  the backend deep tag tree file/stream direct-oracle differential slice,
  the backend metadata-outline file/stream direct-oracle differential slice,
  the backend page-ops file/stream direct-oracle differential slice,
  the backend tag-metadata file/stream direct-oracle differential slice,
  the backend nested tag/page sequence slice,
  the backend surface-page feature/tag combo slice,
  the Context drawing-state all-enum round-trip slice,
  the pycairo raw C-int operator passthrough slice,
  the pycairo raw C-int context drawing-state enum passthrough slice,
  the pycairo raw C-int FontOptions enum passthrough slice,
  the FontOptions variation embedded-NUL slice,
  the pycairo raw C-int toy-font slant/weight parsing slice,
  the pycairo raw C-int content constructor slice,
  the pycairo raw C-int format constructor/getter slice,
  the pycairo context font-extents parity slice,
  the pycairo group-target stack-restoration slice,
  the pycairo rectangle path-extents slice,
  the pycairo 42x42 clip-extents, zero-radius arc, polygon path-extents,
  line in-stroke, empty stroke-extents, default coordinate-conversion, empty
  font-family selection, and font-size matrix parity slice,
  the pycairo hairline getter/setter and direct C hairline stroke oracle slice,
  the pycairo source RGBA round-trip slice,
  the pycairo empty-path clip `in_clip` slice,
  the pycairo mesh curve-first patch slice,
  the pycairo pattern gradient and mesh example fixture slice,
  the pycairo polygon fill-extents slice,
  the mapped-image scoped-error upload slice,
  the TeeSurface positive out-of-range status slice,
  the PDF/PS stream target lifetime slice, the pycairo append-path
  string equivalence slice, the pycairo close-path stringification slice, the
  gradient color-stop ordering/snapshot slice, the stream-vs-file vector output
  equivalence slice, the non-text primitive vector stream equivalence slice,
  the single-page tag stream marker/equivalence stabilization slice, the tagged
  multi-page stream marker/equivalence stabilization slice, the mixed/layered
  stream marker/equivalence stabilization slice, the wide multi-page stream
  marker/equivalence slice, the document-feature stream equivalence slice, the
  backend feature/tag stream combo slice, the vector
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
  the Pattern black-box test split slice,
  the raster-source black-box test split slice,
  the pycairo raw C-int pattern extend passthrough slice,
  the pycairo raw C-int pattern filter/dither passthrough slice,
  the Pattern raw enum documentation slice,
  the pycairo raw C-int context drawing-state enum passthrough slice,
  the pycairo raw C-int FontOptions enum passthrough slice,
  the pycairo raw C-int toy-font slant/weight parsing slice,
  the Pattern raw FFI family split slice, the Font C glue split slice,
  the Pattern C glue split slice, the raster-source callback C glue split
  slice, the Surface C glue split slice,
  the Context C glue split slice,
  the raster-source stale-release replacement slice, the raster-source
  acquire-only owner fuzz slice, the raster-source
  failed-acquire owner-count fuzz slice, the raster-source callback
  state-machine fuzz slice, the raster-source manual callback fuzz slice, the
  mixed vector/tag/text marker slice, the direct
  C oracle slice, the PS/SVG tag metadata absence slice, the PDF tagged
  multi-page text marker slice, the PS/SVG tagged multi-page text inertness
  slice, the PDF rectangle tag marker slice,
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
  text vector stream equivalence slice, the single-page tag stream
  marker/equivalence stabilization slice, and
  the earlier context `get_source`
  surface-pattern lifetime coverage for the path where both the original source
  wrapper and context scope have exited, plus the Path/Region lifetime gate,
  Surface/Device targeted gate, raw FFI split slices through context painting,
  the layered multi-page vector/tag oracle slice, and the wide multi-page
  vector/tag oracle slice.
- `moon -C cairoon test path_test.mbt --target native -v`: 7 black-box Path
  tests passed, covering empty paths, pycairo-compatible stringification
  including close-path continuation formatting, typed segment iteration, copied-path lifetime after the source context exits,
  flattened copies, and path equality/hash behavior.
- `moon -C cairoon test path_pycairo_parity_test.mbt --target native -v`: 4
  pycairo `test_path.py`-derived fixtures passed, covering empty path string
  behavior, `copy_path().to_string()` formatting, self comparison/hash
  operators, and iterator `PathDataType`/coordinate tuples.
- `moon -C cairoon test src/tests/api --target native --deny-warn -v`: 11
  black-box API package tests passed, covering version helpers, portable enums,
  pycairo `test_api.py` Unicode fixtures for
  `Context::show_text("ēxāmple.")`, PNG filename write/read round trips through
  `Surface::write_to_png` and `Surface::image_from_png`,
  `surface_destroy_before_context` and
  `surface_destroy_before_surface_pattern` lifetime fixtures for stream-backed
  surfaces retained by contexts and surface patterns,
  `Surface::has_show_text_glyphs` finished-surface error mapping, and the
  `Context::paint`/`OperatorSource` smoke fixture.
- `moon -C cairoon test src/tests/status --target native --deny-warn -v`: 2
  black-box status package tests passed, covering `run_cairo` success,
  `check_status`, public `Status::message`, and exhaustive `CairoError`
  suberror classification for every Cairo status exposed by the facade.
- `moon -C cairoon test src/tests/value --target native --deny-warn -v`: 14
  black-box value package tests passed, covering Rectangle, RectangleInt,
  Glyph, TextCluster, TextExtents, FontExtents, component access, invalid-index
  error mapping, hash/equality fixtures, numeric limits, clip-rectangle
  returns, recording extents, and Context/ScaledFont extents-return paths.
- `moon -C cairoon test src/tests/context/path --target native -v`: 11
  black-box Context path tests passed, covering current-point behavior,
  relative path operations, pycairo rectangle path-extents behavior,
  close-path current-point reset, arc current-point creation,
  path copy/append independence, pycairo-style append string
  equivalence after clearing the source context, flattened append behavior, and
  path error propagation.
- `moon -C cairoon test src/tests/context/pycairo --target native -v`: 36 black-box
  shared Context parity tests passed, including 35 pycairo parity fixtures split
  across `context_pycairo_parity_test.mbt`,
  `context_state_paint_pycairo_parity_test.mbt`, and
  `context_font_text_pycairo_parity_test.mbt`, covering the 42x42 default
  clip-extents fixture, zero-radius `arc`/`arc_negative` non-empty paths,
  context comparison/hash behavior from pycairo's `test_cmp_hash`,
  polygon `path_extents`, polygon `fill_extents`, empty `in_fill`, line
  `in_stroke`, rectangle `path_extents`, absolute move/line/curve
  current-point fixtures, relative path current-point updates, empty
  `stroke_extents`, default user/device coordinate conversions,
  matrix setter/translate/scale/transform/rotate fixtures, dash offset
  normalization, current-point state, drawing-state default getters and enum
  setter round trips, hairline getter/setter, raw operator C-int limit
  passthrough, save/restore
  drawing-state restoration, scalar line-width/miter-limit/tolerance setters,
  source RGBA round trips, explicit source-pattern round trips,
  copied `append_path` strings, empty clip/reset `in_clip` behavior, group
  stack push/pop variants, mask/mask-surface/alpha-paint pixel fixtures,
  font-face default/reset/custom round trips, `set_font_matrix` identity,
  font-options round trips, scaled-font round trips, empty
  `select_font_face("")`, `set_font_size(42)` font-matrix fixtures,
  text/font-extents/show-text/text-path fixtures, glyph-extents/show-glyphs/
  glyph-path fixtures, the PDF `show_text_glyphs` tuple fixture, and
  pycairo's `test_simple` method-smoke flow across `clip_preserve`,
  `copy_page`, `copy_path_flat`, `fill`, `fill_preserve`, `font_extents`,
  `identity_matrix`, `new_sub_path`, `show_page`, `stroke_preserve`, dash
  count, font matrix, group target, scalar getters, and final status.
- `moon -C cairoon test src/tests/context/clip --target native -v`: 7
  black-box Context clipping tests passed from a nested external package,
  covering clip extents, `in_clip`, reset behavior, path-clearing versus
  preserve behavior, rectangular clip-list copying, non-rectangular clip
  status mapping, and existing-context-error propagation.
- `moon -C cairoon test src/tests/context/paint --target native -v`: 7
  black-box Context painting tests passed from a nested external package,
  covering alpha paint, source RGB/RGBA round trips, mask and mask-surface
  behavior, source-surface sampling, preserve variants, page operations, and
  existing-context-error propagation.
- `moon -C cairoon test src/tests/context/state --target native -v`: 10
  black-box Context drawing-state tests passed from a nested external package,
  covering default state, typed and raw drawing-state enum round trips,
  save/restore state restoration, dash clearing and invalid-dash errors,
  invalid restore mapping, and existing-context-error propagation.
- `moon -C cairoon test src/tests/context/group --target native -v`: 5
  black-box Context group tests passed from a nested external package, covering
  `push_group`, `pop_group`, `pop_group_to_source`, raw-content
  `push_group_with_content`, group-target stack restoration to the original
  target, returned group patterns, and unmatched pop error mapping.
- `moon -C cairoon test src/tests/context/matrix --target native -v`: 4
  black-box Context matrix tests passed from a nested external package,
  covering get/set/identity, translate/scale/rotate/transform, user/device
  coordinate conversions, and invalid-matrix error propagation.
- `moon -C cairoon test src/tests/context/extents --target native -v`: 5
  black-box Context extents and hit-testing tests passed from a nested external
  package, covering fill/path/stroke extents, polygon fill-extents, hit tests,
  and existing-context-error propagation.
- `moon -C cairoon test src/tests/context/tag --target native -v`: 5
  black-box Context tag tests passed from a nested external package, covering
  matching begin/end, tag constants, embedded-NUL validation, nesting errors,
  and existing-context-error propagation.
- `moon -C cairoon test src/tests/context/text --target native -v`: 6
  black-box Context text tests passed from a nested external package, covering
  context/scaled-font font-extents and text-extents parity, `show_text`
  current-point advance, text path creation, embedded-NUL validation, and
  context error propagation.
- `moon -C cairoon test src/tests/context/glyph --target native -v`: 5
  black-box Context glyph tests passed from a nested external package, covering
  context/scaled-font glyph-extents parity, `show_glyphs`, `glyph_path`, empty
  glyph arrays, and context error propagation.
- `moon -C cairoon test src/tests/context/text_to_glyphs --target native -v`:
  5 black-box ScaledFont/Context text-to-glyph tests passed from a nested
  external package, covering empty/single/spaced text, renderable
  `show_text_glyphs` output, embedded-NUL validation, and context error
  propagation.
- `moon -C cairoon test src/tests/lifetime/context --target native -v`: 9
  black-box context lifetime tests passed, including `get_target`,
  `get_group_target`, `get_source`, and PDF/PS stream target wrappers that
  remain usable after their creating helper scopes exit.
- `moon -C cairoon test src/tests/surface/{base,mime,pycairo,subsurface}
  --target native -v`: 26 black-box Surface package tests passed, including
  base image/similar/state/status wrappers, pycairo surface parity,
  subsurfaces, MIME, and backend MIME-support matrix checks.
- `moon -C cairoon test src/tests/image/{properties,data,mapped,png,buffer}
  --target native -v`: 29 black-box image-family tests passed, including
  ImageSurface properties, raw image formats, buffer-backed image surfaces,
  mutable ImageData views, pycairo `test_image_surface_get_data` mutable-view
  sharing and post-paint flush update behavior, pycairo empty 0x0 image-surface
  `get_data` behavior, PNG path round trips, mapped images, float image
  formats, and invalid image-family errors.
- `moon -C cairoon test src/tests/backend/pdf --target native -v`: 8
  black-box PDF surface tests passed from a nested external package, covering
  version helpers, raw C-int enums, no-output/page/document APIs, thumbnails,
  metadata/outline/path validation, filename construction, subtype errors, and
  finished-surface errors.
- `moon -C cairoon test src/tests/backend/ps --target native -v`: 7
  black-box PS surface tests passed from a nested external package, covering
  level helpers, raw C-int enums, no-output/EPS/page/DSC APIs, DSC/path
  validation, filename construction, subtype errors, and setup/page-size
  errors.
- `moon -C cairoon test src/tests/backend/svg --target native -v`: 6
  black-box SVG surface tests passed from a nested external package, covering
  version helpers, raw C-int enums, no-output/unit/version APIs, filename
  construction, subtype errors, and finished-surface document-unit errors.
- `moon -C cairoon test src/tests/backend/recording --target native -v`: 5
  black-box Recording surface tests passed from a nested external package,
  covering bounded/unbounded extents, post-finish extents, raw content ints,
  replay through patterns, and subtype errors.
- `moon -C cairoon test src/tests/backend/tee --target native -v`: 4
  black-box Tee surface tests passed from a nested external package, covering
  fanout painting, retained targets, out-of-range index status, subtype errors,
  and index errors.
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
  callback allocation stress, and backend stream callback multi-seed fuzz.
- `moon -C cairoon test device_pycairo_parity_test.mbt --target native -v`: 8
  pycairo-derived fixtures passed, covering script-device
  context-manager cleanup, Device equality/hash through `Surface::get_device`,
  image-surface `get_device is None`, `HAS_SCRIPT_SURFACE`, script-device
  type queries, file-path construction, acquire/release, script mode/comment
  output, and
  recording-surface replay plus post-finish `DeviceFinished`, plus pycairo
  `test_surface.py`-derived script-surface create-for-target target-paint
  parity.
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
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_deep_tag_test.mbt
  --target native -v`: 5 white-box backend deep tag tree tests passed, comparing PDF/PS/SVG
  file output with a direct C Cairo oracle, checking stable PDF/PS/SVG markers,
  checking PDF stream markers, comparing PS/SVG stream output with file output
  after normalization, and checking PS/SVG file and stream negative
  tag-metadata markers for a two-page scene with `Document`/`Part`/`Sect`/
  `Div`/`P`/`Span`/`Figure`/`Table`/`TR`/`TH`/`TD` structure tags.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_metadata_outline_test.mbt
  --target native -v`: 4 white-box backend metadata-outline tests passed,
  comparing PDF/PS/SVG stream output with file output after normalization,
  comparing file output with a direct C Cairo oracle, checking stable PDF/PS/SVG
  markers, and checking PS/SVG file and stream negative tag-metadata markers
  for a three-page scene with PDF metadata/custom metadata/page labels/outlines,
  URI and named-destination links, `Document`/`Sect`/`H1` structure tags, PS DSC,
  SVG document units, retained `Surface::copy_page`, and backend page-size changes.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_page_ops_test.mbt
  --target native -v`: 4 white-box backend page-ops tests passed,
  comparing PDF/PS/SVG stream output with file output after normalization,
  comparing file output with a direct C Cairo oracle, checking stable PDF/PS/SVG
  markers, and checking PS/SVG file and stream negative tag-metadata markers
  for a four-page scene with mixed `Surface::show_page`,
  `Surface::copy_page`, `Context::copy_page`, and `Context::show_page`
  operations, PDF metadata/custom metadata/page labels/outlines, URI and
  named-destination links, document-structure tags, PS DSC, SVG document units,
  and backend page-size changes.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_tag_metadata_test.mbt
  --target native -v`: 4 white-box backend tag-metadata tests passed,
  comparing PDF/PS/SVG stream output with file output after normalization,
  comparing file output with a direct C Cairo oracle, checking stable PDF/PS/SVG
  markers, and checking PS/SVG file and stream negative tag-metadata markers
  for a three-page scene with PDF metadata/custom metadata/page labels/outlines,
  URI and named-destination links, `Document`/`Sect`/`P`/`Figure`/`Span`
  structure tags, retained `Surface::copy_page`, `Surface::show_page`,
  `Context::show_page`, PS DSC, SVG document units, and backend page-size
  changes.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_structure_sequence_test.mbt
  --target native -v`: 4 white-box backend structure-sequence tests passed,
  comparing PDF/PS/SVG stream output with file output after normalization,
  comparing file output with a direct C Cairo oracle, checking stable PDF/PS/SVG
  markers, and checking PS/SVG file and stream negative tag-metadata markers
  for a four-page scene with retained `Surface::copy_page`, retained
  `Context::copy_page`, cleared `Surface::show_page`, final
  `Context::show_page`, PDF metadata/custom metadata/page labels/outlines, URI
  and named-destination links, list/table/figure/paragraph structure tags, PS
  DSC, SVG point units, and backend page-size changes.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_outline_sequence_test.mbt
  --target native -v`: 4 white-box backend outline-sequence tests passed,
  comparing PDF/PS/SVG stream output with file output after normalization,
  comparing file output with a direct C Cairo oracle, checking stable PDF/PS/SVG
  markers, and checking PS/SVG file and stream negative PDF-metadata markers
  for a three-page scene with `Context::copy_page`, `Surface::copy_page`,
  `Surface::show_page`, PDF metadata/custom metadata/page labels/outlines, URI
  and named-destination links, Document/Sect/Figure structure tags, PS DSC, SVG
  point units, and backend page-size changes.
- `moon -C cairoon test src/tests/oracle/vector_backend/surface_stream_oracle_test.mbt
  --target native -v`: 7 white-box stream-to-direct-C oracle tests passed,
  covering primitive/text scenes 0 through 14, tag-heavy scenes 15 through 17
  and 22 through 30, single-backend document feature scenes 18 through 21 and
  34, retained `Context::copy_page`/`glyph_path`/`show_glyphs` scenes 31
  through 33, PDF JPEG MIME/thumbnail stream output, tagged font-matrix text
  scene 43, and backend feature scenes 35 through 42 and 44 through 50, so
  these PDF/PS/SVG stream callback outputs are compared with normalized direct
  C Cairo oracle files.
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
  text, PS/SVG wide three-page tag/vector scenes, plus PDF wide three-page
  stream marker coverage for the same tag/vector scene.
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
  ARGB32 fixture across forty-three scenes with `glyph_path`, `show_glyphs`,
  `show_text_glyphs`, source-surface offsets, mask-surface offsets, and
  raster-source pattern repeat rendering, dashed round-cap strokes, hairline strokes, and
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
  clip/save/restore/OperatorAtop output, and mesh/linear surface-mask
  group-compositing output, plus set_source_surface/repeated-surface-pattern/
  radial-mask group-compositing output, surface-pattern device-offset mask
  with `OperatorScreen` group-compositing output, and surface/radial-gradient
  `OperatorOverlay` group-mask output, plus mesh/surface/linear pattern-stack
  `OperatorSoftLight` group-mask output, plus surface-pattern stroke `OperatorDifference` group-mask output, plus radial-gradient `OperatorColorDodge` over transformed reflected surface-pattern output.
- `MOON_CC=/opt/homebrew/opt/llvm/bin/clang MOON_AR=/usr/bin/ar
  ASAN_OPTIONS=detect_leaks=0:fast_unwind_on_malloc=0 moon -C cairoon test
  image_oracle_wbtest.mbt --target native -v`: 2 ASan-compiled white-box image
  oracle tests passed with leak detection disabled, directly exercising the
  source/mask offset, raster-source repeat, dashed-stroke, clipped-output,
  operator-output, surface-pattern-combo, transformed-gradient-pattern,
  radial-pattern-combo, surface-pattern pad/none/repeat-bilinear,
  linear-pattern pad/none, radial-pattern repeat/pad, curve-mesh,
  mesh-pattern, pattern-stack, mesh-mask group-compositing,
  surface-mask screen group-compositing, group-compositing,
  mask-pattern, fill-rule, and radial color-dodge pattern-operator C oracle helper paths.
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
  recovery, and a four-seed callback state-machine fuzz with 72 transitions per
  seed covering clear, release-only, acquire-only, acquire+release, failed
  acquire, dynamic compatible-source, callback-introspection, and owner-count
  balance transitions.
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
  owner-count recovery, and the four-seed 72-step-per-seed callback
  state-machine fuzz.
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
- `moon -C cairoon test surface_pycairo_parity_test.mbt --target native -v`: 9
  pycairo `test_surface.py`-derived fixtures passed, covering surface
  context-manager cleanup, target equality/hash through `Context::get_target`,
  content/format getters, device-scale valid/extreme/invalid-matrix cases,
  device-offset normal/extreme round trips, fallback-resolution round trips,
  dirty/page operations, `create_for_rectangle`
  success/invalid-size/extreme numeric cases, `create_similar`
  success/invalid-size cases, and PDF-backed `create_similar_image`, including
  returned image usability after the creating PDF surface scope exits.
- `moon -C cairoon test surface_mime_test.mbt --target native -v`: 5
  black-box tests passed after adding image/PDF/PS/SVG
  `supports_mime_type` matrix coverage and invalid MIME type string coverage.
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
  reference examples passed, covering FontOptions state/raw enum
  compatibility/copy/merge, color palettes, toy font faces with raw slant/weight
  parsing, Surface/Context font options, ScaledFont matrices/metrics,
  text-to-glyphs, and checked font errors.
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
  The later image oracle slices added private C helpers for twenty deterministic
  ARGB32 scenes covering paint, stroke, fill/stroke rectangles, Bezier paths,
  transforms, RGBA compositing, linear/radial gradients, toy-font `text_path`,
  toy-font `show_text`, `glyph_path`, `show_glyphs`, `show_text_glyphs`,
  source-surface offset sampling, mask-surface offset compositing, and
  raster-source pattern repeat rendering, dashed round-cap stroke state,
  clipped paint/fill output, `OperatorClear` compositing output, and a
  surface-pattern `Reflect`/`Nearest`/`DitherBest`/matrix combination, without
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
  The later Matrix property-test slice added `matrix_property_test.mbt` with
  four deterministic property checks for multiplication associativity, inverse
  identity, composed point/distance transforms, and distance-vs-point-delta
  behavior, raising the native suite to 392 tests. The file is included in the
  targeted normal and ASan verification gate because it exercises value-level
  transform semantics used throughout drawing code.
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
  C Cairo. The later surface-pattern-combo image oracle slice expanded it to
  twenty scenes by comparing surface-pattern
  `Reflect`/`Nearest`/`DitherBest`/matrix combination output against direct C
  Cairo.
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
  suite to 315 tests. The later backend-feature oracle slice upgraded this test
  with a direct C Cairo output oracle.
  The later SVG version-unit multi-page vector-output marker slice added one
  pure MoonBit white-box test covering SVG 1.2 version restriction, `SvgUnitPx`
  state, px width/height output, and two-page drawing markers, raising the
  native suite to 316 tests. The later backend-feature oracle slice upgraded
  this test with a direct C Cairo output oracle.
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
  The later PDF combined text document-feature oracle slice upgraded the
  combined metadata/custom-metadata/page-label/outline/URI/named-destination/
  document-structure marker test with a second private PDF-only direct C
  vector scene that includes text under Link, Dest, and Document/Sect/P tags.
  This changed only test-helper C glue and one existing white-box test.
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
  The later surface-pattern-combo image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from nineteen to twenty scenes,
  adding `Reflect`/`Nearest`/`DitherBest`/matrix surface-pattern coverage
  without adding a new test case. The targeted `image_oracle_wbtest.mbt` run
  passed 2 tests, and the targeted ASan build passed 2 tests with leak detection
  disabled.
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
  run passed 2 tests, and the then-current full native suite remained at 485
  tests.
  The later pattern-stack image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from thirty-four to thirty-five
  scenes, adding nested surface/linear/radial/mask pattern-stack
  clip/save/restore/OperatorAtop output coverage without changing the public
  API. The targeted `src/tests/oracle/image` run passed 2 tests.
  The later mesh-mask group-compositing image oracle slice expanded the
  ordinary and buffer-backed direct C ARGB32 image oracle from thirty-five to
  thirty-six scenes, adding mesh-pattern source rendering over a transformed
  linear pattern inside a clipped group, then applying a transformed
  surface-pattern mask. This broadens pattern-stack parity without changing
  the public API. The targeted `src/tests/oracle/image` run passed 2 tests.
  The later surface-source/radial-mask group-compositing image oracle slice
  expanded the ordinary and buffer-backed direct C ARGB32 image oracle from
  thirty-six to thirty-seven scenes, combining non-zero
  `set_source_surface`, repeated surface-pattern painting, `OperatorMultiply`,
  clipped groups, and a transformed radial mask. The targeted
  `src/tests/oracle/image` run passed 2 tests.
  The later hairline image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from thirty-seven to thirty-eight
  scenes, adding `Context::set_hairline` stroke output parity against direct C
  Cairo. The targeted `src/tests/oracle/image` run passed 2 tests.
  The later surface-mask screen group-compositing image oracle slice expanded
  the ordinary and buffer-backed direct C ARGB32 image oracle from
  thirty-eight to thirty-nine scenes, combining a surface-pattern mask with
  device offset, transformed pattern matrix, clipped group compositing, and
  `OperatorScreen` output. The targeted `src/tests/oracle/image` run passed 2
  tests without changing public API or total test count.
  The later gradient/surface overlay image oracle slice expanded the ordinary
  and buffer-backed direct C ARGB32 image oracle from thirty-nine to forty
  scenes, combining a transformed reflected surface pattern, repeated radial
  gradient, `OperatorOverlay`, clipped group compositing, and a transformed
  linear mask. The targeted `src/tests/oracle/image` run passed 2 tests
  without changing public API or total test count.
  The later mesh/surface/linear soft-light image oracle slice expanded the
  ordinary and buffer-backed direct C ARGB32 image oracle from forty to
  forty-one scenes, combining a mesh pattern, transformed surface pattern,
  repeated linear gradient, radial mask, clipped group compositing, and
  `OperatorSoftLight`. The targeted `src/tests/oracle/image` run passed 2
  tests without changing public API or total test count.
  The later difference-stroke image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from forty-one to forty-two
  scenes, combining a transformed linear pattern, dashed transformed repeated
  surface-pattern stroke, clipped group compositing, radial mask, translucent
  fill, and `OperatorDifference`. The targeted `src/tests/oracle/image` run
  passed 2 tests without changing public API or total test count.
  The later radial color-dodge image oracle slice expanded the ordinary and
  buffer-backed direct C ARGB32 image oracle from forty-two to forty-three
  scenes, adding a separate pattern-operator oracle file that combines a
  transformed reflected surface pattern with a transformed radial gradient
  through `OperatorColorDodge`. The targeted `src/tests/oracle/image` run
  passed 2 tests without changing public API or total test count.
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
  The later wide multi-page stream marker/equivalence slice added
  `surface_stream_wbtest.mbt` coverage proving the PDF stream-writer output
  contains the stable three-page URI/destination/Document/Sect/P structure
  markers, while PS/SVG stream-writer output still matches file output after
  normalization for the same wide tag/vector scene. This raised
  `surface_stream_wbtest.mbt` to 4 tests and the full native suite to 383 tests.
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
  `pattern_raster_state_wbtest.mbt` with a deterministic transition test,
  now widened to four seeds with 72 transitions per seed, covering clear,
  release-only, acquire-only, acquire+release, failed acquire, dynamic
  compatible-source, callback-introspection, and owner-count balance paths.
  This raised the full native suite to 393 tests and added the file to the
  targeted normal and ASan verification gate.
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
  A later Context pycairo simple-smoke fixture slice extended
  `context_pycairo_parity_test.mbt`, covering pycairo's `test_simple`
  method-smoke flow across `clip_preserve`, `copy_page`, `copy_path_flat`,
  `fill`, `fill_preserve`, `font_extents`, `identity_matrix`, `new_sub_path`,
  `show_page`, `stroke_preserve`, dash count, font matrix, group target,
  scalar getters, and final status. It is included in the targeted normal and
  ASan verification gates and raises that parity file to 32 tests.
  A later Context pycairo hairline fixture slice extended
  `context_pycairo_parity_test.mbt`, covering pycairo's `set_hairline` and
  `get_hairline` fixture. It is included in the targeted normal and ASan
  verification gates and raises that parity file to 33 tests.
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
  A later Pattern pycairo gradient/mesh fixture slice extended
  `pattern_pycairo_parity_test.mbt`, covering pycairo's linear-gradient
  point/color-stop list fixture, radial-gradient circle fixture, and mesh
  example patch construction with corner colors and path extraction. It is
  included in the targeted normal and ASan verification gates and raises that
  parity file to 4 tests.
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
  `surface_stream_oracle_test.mbt`, comparing PDF/PS/SVG stream callback
  output for scenes 35 through 40 directly against normalized direct C Cairo
  oracle files. This covers the backend stream-combo, surface-page combo,
  nested-tag, resized page-sequence, tag-matrix, and lifecycle-matrix fixtures
  through the callback path, adds the file to the targeted normal/ASan verify
  gate, and raises the current full native suite to 484 tests.
  A later tag-heavy stream-to-direct-oracle differential slice extended
  `surface_stream_oracle_test.mbt` with matched 10x10 stream surfaces for
  scenes 15 through 17 and 22 through 30, comparing PDF/PS/SVG stream callback
  output directly with normalized direct C Cairo oracle files for URI-link,
  destination-link, document-structure, text-tag, tagged multi-page,
  mixed-tag/text, layered, wide, `show_text_glyphs`, and grouped glyph/tag
  vector scenes. It raises `surface_stream_oracle_test.mbt` to 2 tests and
  the current full native suite to 485 tests.
  A later tagged font-matrix text differential slice added scene 43 in the
  focused `cairoon_test_vector_text_state_scenes.c` oracle file, covering
  `Context::set_font_matrix`, transformed `show_text`, transformed
  `text_path`, URI and destination tags, and Document/Sect structure tags
  across PDF/PS/SVG. The slice adds direct-C file output equality,
  file-vs-stream normalized equality, stream-vs-direct-C oracle equality, PDF
  marker assertions, and PS/SVG negative PDF-metadata checks, raising the
  vector-backend package to 118 tests.
  A later backend text-state differential slice added scene 44 in the focused
  `cairoon_test_backend_text_state.c` oracle file, covering PDF metadata,
  custom-metadata deletion, page labels, outlines, retained copy/show
  multi-page output, PS DSC setup, SVG document units, and transformed toy-font
  `show_text`/`text_path` under URI, destination, and Document/Sect/H1/P tags.
  The slice adds file-vs-stream equality, file-vs-direct-C equality,
  stream-vs-direct-C equality through the backend oracle dispatcher, stable
  PDF/PS/SVG marker checks, and PS/SVG file/stream negative PDF-metadata
  checks, raising the vector-backend package to 122 tests.
  A later deep tag stream-to-direct-C oracle slice extended
  `surface_stream_oracle_test.mbt` so backend scene 45 is rendered through
  PDF/PS/SVG stream callbacks and compared against normalized direct C Cairo
  oracle files. This strengthens the deep tag tree fixture from PDF stream
  marker coverage plus PS/SVG stream-vs-file equality to full cross-backend
  stream-to-direct-C differential coverage without changing the public API or
  total test count.
  A later metadata-outline stream-to-direct-C oracle slice added scene 46 in
  the focused `cairoon_test_backend_metadata_outline.c` oracle file, covering
  PDF metadata/custom-metadata overwrite/removal, page labels, outline
  root/child/sibling/grandchild flags, URI and named-destination links,
  Document/Sect/H1 structure tags, retained `Surface::copy_page`, PDF/PS page
  resizing, PS Level 3 DSC, and SVG point units. The slice adds
  file-vs-stream equality, file-vs-direct-C equality, stream-vs-direct-C
  equality through the backend oracle dispatcher, stable PDF/PS/SVG marker
  checks, and PS/SVG file/stream negative PDF-metadata checks.
  A later page-ops stream-to-direct-C oracle slice added scene 47 in the
  focused `cairoon_test_backend_page_ops.c` oracle file, covering mixed
  `Surface::show_page`, `Surface::copy_page`, `Context::copy_page`, and
  `Context::show_page` behavior across four PDF/PS/SVG pages with metadata
  and custom-metadata removal, page labels, outline flags, URI links, named
  destinations, document-structure tags, PDF/PS page resizing, PS DSC markers,
  and SVG point units. The slice adds file-vs-stream equality,
  file-vs-direct-C equality, stream-vs-direct-C equality through the backend
  oracle dispatcher, stable PDF/PS/SVG marker checks, and PS/SVG file/stream
  negative PDF-metadata checks.
  A later FontOptions variation string-boundary slice added one black-box test
  proving `FontOptions::set_variations(Some(...))` rejects embedded NUL
  strings with `CairoInvalidArgument(InvalidString, _)` before FFI and leaves
  the previous valid variation value intact. This raises
  `font_options_test.mbt` to 9 tests and the expected full native suite to 558
  tests without changing public API.
  A later pycairo FontOptions variations parity slice extended
  `font_pycairo_parity_test.mbt` with the parent
  `test_font_options_variations` behavior: default `None`, string set/get, and
  clearing back to `None`. This raises the font pycairo parity file to 9 tests
  and the current full native suite to 664 tests without changing public API.
  A later pycairo ScaledFont getter parity slice extended
  `font_pycairo_parity_test.mbt` with the parent scaled-font extents,
  font-face/font-options, CTM, font-matrix, and scale-matrix getter behavior.
  This raises the font pycairo parity file to 10 tests and the current full
  native suite to 665 tests without changing public API.
  A later pycairo FontOptions enum setter parity slice extended
  `font_pycairo_parity_test.mbt` with the parent antialias, hint-metrics,
  hint-style, and subpixel-order setter/getter behavior. This raises the font
  pycairo parity file to 11 tests and the current full native suite to 666
  tests without changing public API.
  A later pycairo ScaledFont extents parity slice extended
  `font_pycairo_parity_test.mbt` with the parent text-extents and glyph-extents
  behavior, including positive text/glyph inputs and zeroed empty input
  extents. This raises the font pycairo parity file to 12 tests and the current
  full native suite to 667 tests without changing public API.
  A later Font family package split moved the external black-box tests into
  `src/tests/font/{face,options,scaled,pycairo}` so each font family links and
  runs as its own external package. The four focused font package gates cover
  39 tests, and the full native suite remains 677 tests without changing public
  API.
  A later tag-metadata stream-to-direct-C oracle slice added scene 48 in the
  focused `cairoon_test_backend_tag_metadata.c` oracle file, covering PDF
  metadata/custom-metadata overwrite/removal, page labels, outline parent/child
  links, URI links, named destinations, `Document`/`Sect`/`P`/`Figure`/`Span`
  structure tags, retained `Surface::copy_page`, `Surface::show_page`,
  `Context::show_page`, PDF/PS page resizing, PS Level 3 DSC markers, and SVG
  point units. The slice adds file-vs-stream equality, file-vs-direct-C
  equality, stream-vs-direct-C equality through the backend oracle dispatcher,
  stable PDF/PS/SVG marker checks, and PS/SVG file/stream negative
  PDF-metadata checks, raising the vector-backend package to 140 tests and the
  expected full native suite to 562 tests without changing public API.
  A later stream-tag stabilization slice replaced the tag-heavy PDF
  stream-vs-file equality assertions in `surface_stream_tag_test.mbt` with
  stable stream marker checks for the single-page rectangle/text tag scenes,
  mixed tag/vector/text, tagged `show_text_glyphs`, tagged font-matrix text,
  grouped glyph tags, layered multi-page tags, and tagged multi-page text.
  PS/SVG still use normalized file-vs-stream equality for the same scenes.
  This avoids Cairo PDF stream/file object-layout nondeterminism while
  preserving semantic tag coverage, raising the vector-backend package to 147
  tests and the expected full native suite to 569 tests without changing
  public API.
  A later structure-sequence stream-to-direct-C oracle slice added scene 49 in
  the focused `cairoon_test_backend_structure_sequence.c` oracle file,
  covering retained `Surface::copy_page`, retained `Context::copy_page`,
  cleared `Surface::show_page`, final `Context::show_page`, PDF
  metadata/custom-metadata overwrite/removal, page labels, nested outline
  links, URI links, named destinations, list/table/figure/paragraph structure
  tags, PDF/PS page resizing, PS Level 3 DSC markers, and SVG point units. The
  slice adds file-vs-stream equality, file-vs-direct-C equality, stable
  PDF/PS/SVG marker checks, and PS/SVG file/stream negative PDF-metadata
  checks, raising the vector-backend package to 151 tests and the expected full
  native suite to 573 tests without changing public API.
  A later surface-pattern pycairo parity slice added one black-box fixture for
  `Pattern::for_surface`, proving pycairo-compatible default
  `ExtendNone`/`Good`/`DitherDefault`/identity-matrix state and referenced
  `get_surface()` dimensions. This raises `pattern_pycairo_parity_test.mbt` to
  5 tests and the expected full native suite to 574 tests without changing
  public API.
  A later context absolute-path parity slice added one black-box fixture for
  `Context::move_to`, `Context::line_to`, and `Context::curve_to` current-point
  behavior, narrowing the remaining method-by-method context parity gap. This
  raises `context_pycairo_parity_test.mbt` to 34 tests and the expected full
  native suite to 575 tests without changing public API.
  A later outline-sequence stream-to-direct-C oracle slice added scene 50 in
  the focused `cairoon_test_backend_outline_sequence.c` oracle file, covering a
  three-page PDF/PS/SVG sequence with `Context::copy_page`,
  `Surface::copy_page`, and `Surface::show_page`, PDF
  metadata/custom-metadata overwrite/removal, page labels,
  root/child/sibling/grandchild outline flags, URI and named-destination tags,
  Document/Sect/Figure structure tags, PDF/PS page resizing, PS Level 3 DSC
  markers, and SVG point units. The slice adds file-vs-stream equality,
  file-vs-direct-C equality, stream-vs-direct-C equality through the backend
  oracle dispatcher, stable PDF/PS/SVG markers, and PS/SVG file/stream negative
  PDF-metadata checks, raising the vector-backend package to 155 tests and the
  expected full native suite to 579 tests without changing public API.
  A later page/glyph stream-to-direct-C oracle slice extended
  `surface_stream_oracle_test.mbt` with scenes 31 through 33, comparing
  PDF/PS/SVG stream callback output directly against normalized direct C Cairo
  oracle files for retained `Context::copy_page`, `glyph_path`, and
  `show_glyphs` vector scenes. This raises the vector-backend package to 156
  tests without changing public API.
  A later primitive/text stream-to-direct-C oracle slice extended
  `surface_stream_oracle_test.mbt` with scenes 0 through 14, comparing
  PDF/PS/SVG stream callback output directly against normalized direct C Cairo
  oracle files for paint/stroke/path/transform/gradient/text/page/clip/dash,
  surface-pattern, mask-surface, and mesh-pattern vector scenes. This raises
  the vector-backend package to 157 tests and the expected full native suite to
  587 tests without changing public API.
  A later single-backend feature stream-to-direct-C oracle slice extended
  `surface_stream_oracle_test.mbt` with scenes 18 through 21 and 34 plus PDF
  JPEG MIME and thumbnail stream output, comparing PDF/PS/SVG stream callback
  bytes directly against normalized direct C Cairo oracle files for PDF
  metadata/custom-metadata/page-label/outline/tag document features, PDF
  text-aware and page-operation document features, PS DSC/page setup, SVG
  version/document units, JPEG MIME passthrough, and PDF thumbnail output. This
  raises the vector-backend package to 159 tests and the expected full native
  suite to 589 tests without changing public API.
  A later PDF thumbnail pycairo parity slice added one pure MoonBit black-box
  test for `PDFSurface.set_thumbnail_size`, covering the upstream
  `10x10 -> 0x0 -> 1x1` resize/reset sequence before finish and checked
  `SurfaceFinished` mapping for a post-finish thumbnail update. This raises
  `surface_pdf_test.mbt` to 8 tests and the expected full native suite to 590
  tests without changing public API.
  A later context/pattern comparison parity slice added two pycairo
  `test_cmp_hash` fixtures: `Context` self-equality plus same-target
  different-context inequality, and repeated `Context.get_source()` pattern
  equality/hash behavior. This raises `context_pycairo_parity_test.mbt` to 35
  tests, `pattern_pycairo_parity_test.mbt` to 6 tests, and the expected full
  native suite to 581 tests without changing public API.
  A later Pattern mesh-detail parity slice added pycairo's
  `test_mesh_pattern_example1` and `test_mesh_pattern_rest` fixtures to
  `pattern_pycairo_parity_test.mbt`, covering Coons-patch construction, path
  extraction, corner-color queries, control-point queries, and invalid
  patch/corner/control-point index errors. This raises
  `pattern_pycairo_parity_test.mbt` to 8 tests and the expected full native
  suite to 583 tests without changing public API.
  A later Pattern independent-identity parity slice added pycairo's
  `test_pattern` identity/hash behavior for standalone solid patterns to
  `pattern_pycairo_parity_test.mbt`, proving that the same wrapper compares
  equal and hashes consistently while an independently allocated solid pattern
  with identical RGBA components compares unequal by Cairo pointer identity.
  This raises `pattern_pycairo_parity_test.mbt` to 9 tests and the expected
  full native suite to 591 tests without changing public API.
  A later Context/Pattern pycairo parity slice added pycairo's `test_tags`
  begin/end smoke fixture to `context_pycairo_parity_test.mbt` and pycairo's
  `test_mesh_pattern_error_states` lifecycle checks to
  `pattern_pycairo_parity_test.mbt`. The current context package and pattern
  family gates have 105 and 46 tests respectively without changing public API.
  A later Pattern family package split moved the remaining root pattern tests
  into `src/tests/pattern/{core,mesh,pycairo}`, leaving `src/tests/pattern` as
  a pure directory container. The focused counts are 12, 6, and 10 tests for
  those packages, preserving the same 28 root fixtures with no public API
  changes.
  A later Font pycairo parity fixture slice added
  `font_pycairo_parity_test.mbt` with eight pycairo `test_font.py`-derived
  black-box fixtures covering surface font-options default getters,
  FontOptions copy/equality/merge, color mode, color palette, custom palette
  colors and missing-index errors, FontFace and ScaledFont identity/hash
  behavior, toy-font family/slant/weight getters including Cairo's empty-family
  `Helvetica` normalization, ScaledFont matrix/font-options getters, and
  empty/single/spaced ASCII `text_to_glyphs` result shape. At that point, the
  font package gate had 35 tests without changing public API.
  A later pure value pycairo parity slice added `Hash` derivations for
  `Rectangle`, `RectangleInt`, `Glyph`, `TextCluster`, `TextExtents`, and
  `FontExtents`, plus `value_pycairo_parity_test.mbt` with six pycairo
  namedtuple-style fixtures covering fields, component order, equality/hash,
  numeric limits, `Context::copy_clip_rectangle_list`,
  `RecordingSurface::recording_get_extents`, and Context/ScaledFont
  text/font/glyph extents return paths. This raises the expected full native
  suite to 602 tests.
  A later Matrix pycairo parity slice added `matrix_pycairo_parity_test.mbt`
  with four pycairo `test_matrix.py`-derived fixtures covering equality,
  `init_rotate(0)`, component access including positive and negative invalid
  indexes, `Matrix(1, 1).invert()`, `multiply`, `translate`, scale-away then
  scale-back-to-identity, rotate/scale/translate composition smoke, and
  identity point/distance transforms. This raises the expected full native
  suite to 606 tests without changing public API.
  A later Region pycairo parity slice added `region_pycairo_parity_test.mbt`
  with five pycairo `test_region.py`-derived fixtures covering invalid
  negative/positive rectangle indexes, returned rectangle equality, Region
  equality/inequality through MoonBit `Eq`, empty-region overlap, point
  containment, mutating boolean operations returning the receiver, and
  translate behavior for empty and non-empty regions. This raises the expected
  full native suite to 611 tests without changing public API.
  A later Path pycairo parity slice added `path_pycairo_parity_test.mbt` with
  four pycairo `test_path.py`-derived fixtures covering empty path
  string/length behavior, `copy_path().to_string()` formatting including
  close-path continuation, self comparison/hash operators, and iterator
  `PathDataType`/coordinate tuples. This raises the expected full native suite
  to 615 tests without changing public API.
  A later Device pycairo parity slice added `device_pycairo_parity_test.mbt`
  with five pycairo `test_device.py`-derived fixtures covering script-device
  context-manager cleanup, Device equality/hash through `Surface::get_device`,
  image-surface `get_device is None`, script mode/comment output, and
  recording-surface replay plus post-finish `DeviceFinished`. This raises the
  expected full native suite to 620 tests without changing public API.
  A later Device parity extension raised that file to eight fixtures by
  covering pycairo's script feature constant, script-device type query,
  file-path constructor, basic acquire/release, and script-surface
  create-for-target target-paint parity. This raises the expected full native
  suite to 657 tests without changing public API.
  A later Pattern raster-source pycairo parity slice added
  `pattern_raster_pycairo_parity_test.mbt` with two pycairo
  `test_raster_source`-derived fixtures covering callback optional/clear
  states, compatible-image acquire with device offset, acquire/release event
  order, and red pixel output after `Context::paint`. This raises the expected
  full native suite to 622 tests without changing public API.
  A later Surface pycairo parity slice added `surface_pycairo_parity_test.mbt`
  with six pycairo `test_surface.py`-derived fixtures covering surface
  context-manager cleanup, target equality/hash through `Context::get_target`,
  content/format getters, device-scale valid/extreme/invalid-matrix cases,
  `create_for_rectangle` success/invalid-size/extreme numeric cases, and
  PDF-backed `create_similar_image`, including returned image usability after
  the creating PDF surface scope exits. A later Surface parity extension raised
  that file to nine fixtures by covering `create_similar`, device-offset
  normal/extreme round trips, fallback-resolution round trips, and dirty/page
  operations. This raises the expected full native suite to 631 tests without
  changing public API.
  A later pattern-tag stream-to-direct-C oracle slice added scene 51 in the
  focused `cairoon_test_backend_pattern_tag.c` oracle file, covering a
  transformed surface pattern, radial mask, PDF metadata/custom-metadata
  removal, page labels, outline flags, URI and named-destination links,
  `Document`/`Sect`/`P`/`Figure`/`Div`/`Span` structure tags, retained
  `Surface::copy_page`, `Surface::show_page`, PDF/PS page resizing, PS Level 3
  DSC markers, SVG point units, `Context::set_font_matrix`, and
  `ScaledFont::text_to_glyphs`. The slice adds file-vs-stream equality,
  file-vs-direct-C equality, stream-vs-direct-C equality through the backend
  oracle dispatcher, stable PDF/PS/SVG markers, and PS/SVG file/stream
  negative PDF-metadata checks. This raises the expected full native suite to
  635 tests without changing public API.
  A later vector backend scene wiring audit slice added
  `scripts/check-vector-backend-scenes.py` to keep backend scene enum entries,
  direct C dispatch, MoonBit stream-oracle match arms, aggregate stream-oracle
  scene lists, native stub registration, and Backend Differential Slices rows
  in sync. This keeps the expected full native suite at 635 tests while making
  missing backend oracle evidence a local verify-gate failure.
  A later source-size budget slice split the oversized ARGB32 image oracle
  scene dispatcher into focused basic, pattern, and pattern-stack scene files
  and added `scripts/check-source-size-budget.py` to the local verify gate.
  This keeps the expected full native suite at 635 tests while making future
  source/test/script/native-glue files above 900 lines fail local verification
  until they are split deliberately.
  A later PNG path/stream pycairo parity slice added a black-box fixture that
  writes one ARGB32 image through both `Surface::write_to_png` and
  `Surface::write_to_png_stream`, compares exact PNG bytes, and compares the
  copied image data after reading both outputs back. The observed full native
  suite is now 637 tests without changing public API.
  A later Context pycairo parity organization slice moved the font/text/glyph
  and simple-smoke pycairo fixtures from `context_pycairo_parity_test.mbt` into
  `context_font_text_pycairo_parity_test.mbt`. The shared Context pycairo
  parity package still carries the same 35 external pycairo parity fixtures,
  the observed full native suite remains 637 tests, and the largest Context
  pycairo parity file drops from 675 to 471 lines without changing public API.
  A later Context pycairo state/paint organization slice moved drawing-state,
  dash/scalar/source, copied-path, clip, group, and mask/alpha-paint pycairo
  fixtures into `context_state_paint_pycairo_parity_test.mbt`. The same 35
  external pycairo parity fixtures remain covered, the observed full native
  suite remains 637 tests, and `context_pycairo_parity_test.mbt` drops from 471
  to 272 lines without changing public API.
  A later vector-output oracle organization slice split direct-C vector oracle
  tests from `vector_output_oracle_test.mbt` into focused basic,
  tag/text-tag, page/glyph/multipage, and PDF document-feature files. The same
  oracle, marker, and inert-tag assertions remain covered, the observed full
  native suite remains 637 tests, and `vector_output_oracle_test.mbt` drops
  from 441 to 25 lines without changing public API.
  A later Surface/context test organization slice moved buffer-backed
  image-surface tests into `image_surface_data_test.mbt`, PNG path round-trip
  coverage into `surface_png_test.mbt`, and the context invalid-restore state
  error test into `context_state_test.mbt`. The observed full native suite
  remains 637 tests, `surface_context_test.mbt` drops from 525 to 348 lines, and
  no public API changes.
  A later Context state package split moved `context_state_test.mbt` into the
  nested external package `src/tests/context/state`. The observed focused
  counts are 96 tests in `src/tests/context` and 10 tests in
  `src/tests/context/state`, with no public API changes.
  A later Context family package split moved `context_path_test.mbt`,
  `context_clip_test.mbt`, and `context_painting_test.mbt` into nested
  external packages under `src/tests/context/{path,clip,paint}`. The observed
  focused counts are 71 tests in `src/tests/context`, 11 in
  `src/tests/context/path`, 7 in `src/tests/context/clip`, and 7 in
  `src/tests/context/paint`, with no public API changes.
  A later Context support package split moved group, matrix, extents, tag,
  text, glyph, and text-to-glyphs tests into nested external packages under
  `src/tests/context/`. The observed focused count for the shared parity root
  is now 36 tests, with all moved behavior still covered through separately
  linked public-package seams and no public API changes.
  A later Context pycairo package split moved the remaining shared parity root
  into `src/tests/context/pycairo`, leaving `src/tests/context` as a pure
  directory container. The observed focused count for the pycairo package is
  still 36 tests, with no public API changes.
  A later Surface image-property organization slice moved image-surface
  property, raw-format/raw-content, finished/subtype error, and Cairo
  float-format black-box tests into `surface_image_properties_test.mbt`. The
  same external behavior remains covered, `surface_context_test.mbt` drops
  from 348 to 246 lines, and no public API changes.
  A later vector-backend output test organization slice split the mixed
  PDF/PS/SVG marker checks from `vector_output_test.mbt` into
  `vector_output_pdf_test.mbt`, `vector_output_ps_test.mbt`, and
  `vector_output_svg_test.mbt`. The observed full native suite remains 637
  tests, the largest vector-output marker file drops from 490 to 383 lines, and
  no public API changes.
  A later lifetime stream stress organization slice split
  `lifetime_stream_stress_test.mbt` into focused helper, allocation-stress, and
  multi-seed fuzz files. The same 18 lifetime black-box tests remain covered,
  `lifetime_stream_stress_test.mbt` is replaced by 222/125/88-line files, and
  no public API changes.
  A later surface-stream organization slice split `surface_stream_test.mbt`
  into shared helper, vector-stream, PNG-stream, and retained-chunk files. The
  same 13 public stream black-box tests remain covered, the largest stream
  callback test file drops from 383 to 163 lines, and no public API changes.
  A later Stream surface package split moved those root stream callback tests
  into `src/tests/stream/surface`, leaving `src/tests/stream` as a pure
  directory container. The focused package has 14 tests, and
  `src/tests/stream/device` keeps 18 script device/surface tests with no public
  API changes.
  A later annotation-sequence stream-to-direct-C oracle slice added scene 52 as
  a focused PDF/PS/SVG backend fixture with annotation/list/table structure
  tags, metadata, page labels, outlines, URI/destination links, retained
  `Surface::copy_page`, stable marker checks, stream-to-direct-C normalized
  equality, and PS/SVG negative PDF-metadata checks. This raises the
  vector-backend package by four tests and the expected full native suite to
  641 tests without changing public API.
  A later semantic-index stream-to-direct-C oracle slice added scene 53 as a
  focused PDF/PS/SVG backend fixture with TOC/TOCI/Reference,
  Art/BlockQuote/NonStruct/Note, Figure/Caption structure tags, metadata, page
  labels, outlines, destination/URI links, retained `Surface::copy_page`,
  stable marker checks, stream-to-direct-C normalized equality, and PS/SVG
  negative PDF-metadata checks. This raises the vector-backend package by four
  tests and the expected full native suite to 645 tests without changing public
  API.
  A later bookmark-lattice stream-to-direct-C oracle slice added scene 54 as a
  focused PDF/PS/SVG backend fixture with list and figure structure tags,
  metadata/custom-metadata overwrite and removal, page labels, parent-child and
  root-sibling outlines, destination/URI links, `Surface::copy_page`,
  `Surface::show_page`, `Context::show_page`, stable marker checks,
  stream-to-direct-C normalized equality, and PS/SVG negative PDF-metadata
  checks. This adds four vector-backend tests without changing public API.
  A later ScriptSurface create-for-target parity slice added one public
  black-box fixture proving that drawing through `Surface::script_for_target`
  emits script output and produces the same target image bytes as drawing
  directly to an image surface. This adds one pycairo-derived fixture without
  changing public API.
  A later image-surface empty-data parity slice added one public black-box
  fixture proving that an ordinary 0x0 `Surface::image` exposes an empty
  `ImageData` view and empty copied image bytes, matching pycairo's
  `test_image_surface_get_data_empty` behavior without changing public API.
  A later create-for-data array parity slice added one public black-box
  fixture proving that a prefilled ARGB32 `FixedArray[Byte]` can back
  `Surface::image_for_data` with its default stride and be copied back
  byte-for-byte, matching the core storage-sharing behavior of pycairo's
  array-backed `ImageSurface.create_for_data` fixture without changing public
  API.
  A later PDF stream tag marker slice added one public black-box fixture for
  stream output with PDF metadata, custom metadata, page labels, parent/child
  outlines, URI links, named destinations, and document-structure tags. This
  keeps the recent CI failure mode covered by the normal external stream test
  package without requiring fragile PDF byte equality and without changing
  public API.

Remaining reliability work is now narrower and should be tracked as evidence,
not as an unstructured checklist:

- Broaden normalized PDF/PS/SVG differential coverage for combinations not yet
  represented by the current direct-C and direct stream-oracle fixtures:
  additional deep tag nests beyond scenes 37, 39, 40, 44, 45, 49, 51, 52, 53,
  and 54, more metadata/page-label/outline mixtures beyond scenes 38 through
  42, 44, 46, 47, 48, 49, 50, 51, 52, 53, and 54, and
  additional multi-page sequences beyond the current
  retained/resized/tag-matrix/lifecycle/text-state/page-ops/structure-sequence/outline-sequence/pattern-tag/annotation-sequence/semantic-index/bookmark-lattice
  page fixtures.
- Add broader platform coverage and finalizer fuzz beyond the
  deterministic raster-source owner-count, state-machine, manual
  get-callback, callback allocation, retained-owner, stream retention, and
  backend stream multi-seed callback and finalizer graph fuzz tests.
- Keep the CI workflow green and expand it as the supported release platform
  matrix grows; generated-interface review, differential oracles, and sanitizer
  gates should be required before release.
- Resolve the known macOS LSan reports for toy-font, scaled-font, toy-text,
  glyph rendering/path, and `show_text_glyphs`, or document a Cairo/upstream
  suppression with version bounds.
- Close each remaining `Partial` row in `API_INVENTORY.md` by adding the
  missing evidence or converting out-of-scope API families to explicit
  `Decision` rows.

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
