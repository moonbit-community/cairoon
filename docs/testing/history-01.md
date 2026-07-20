# Testing Evidence History, Part 1

Historical snapshot of `TESTING.md` lines 1-392 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

# cairoon Testing And Reliability Strategy

This document defines how cairoon evaluates migration reliability. The pycairo
test suite is a required source of behavioral cases, but it is not sufficient
by itself to claim a complete MoonBit Cairo binding.

## Assessment Of The pycairo Test Suite

The parent repository has broad pytest coverage across context, surface,
pattern, font, path, region, value types, errors, file-system paths, optional
third-party buffer integrations, and the pycairo C API. The pinned source
checkout contains exactly 288 pytest test functions across 20
`tests/test_*.py` files; the parity gate rejects an omitted or duplicate source
file declaration.

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
5. Lifetime and native safety: every external object path is exercised under
   AddressSanitizer/LeakSanitizer/UndefinedBehaviorSanitizer, including normal
   finalization, explicit `finish`/`flush`, retained base objects, callback
   dispatch, and error exits.
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
migration because one row is intentionally still `Partial`: release evidence
from the shipped CI jobs.

Evaluate each slice with this scorecard:

| Dimension | Required Evidence | Current State |
|---|---|---|
| API surface | Public entries appear in generated package interfaces; Python-only pycairo APIs are recorded as `Decision`; `scripts/check-api-inventory.py` passes against both the parent `cairo/__init__.pyi` and the pinned standalone snapshot | Strong for current portable APIs; source and archive modes enforce the same 67 public top-level entries, all 259 ordinary methods as 255 portable mappings plus 4 method-level X11/XCB Decisions, 39 protocols/constructors, 206 class attributes, 224 top-level constants, and 178 enum aliases. Protocol and attribute evidence is checked against the owning generated MoonBit type, including the Glyph child package; source SHA, snapshot shape, mapping, or public-interface drift fails closed. |
| Reliability ledger | `API_INVENTORY.md` statuses are `Done`, `Partial`, or `Decision`; every `Partial` row names its remaining gap; this scorecard and CI/verify gate are checked by `scripts/check-reliability-ledger.py` | Exact for current migrated slices; 33 behavior regressions are split into downstream/verify/workflow, current release-evidence, and exact local-matrix test modules, each below the 600-line Python-test budget. Three root-aware delegation tests pin the CLI over focused Markdown, release-evidence, shell/matrix, and hosted-workflow implementations. The one remaining `Partial` row names shipped release-platform evidence, and the full-product claim still requires it to reach `Done` or an explicit scope `Decision` |
| FFI boundary safety | Production raw `src/**/ffi*.mbt` declarations are native-gated in their owning `moon.pkg`, mark every non-primitive C FFI parameter with `#borrow` or `#owned`, and `scripts/check-project-layout.py`, `scripts/check-ffi-ownership.py`, `scripts/check-external-owners.py`, plus `scripts/check-stream-cleanup.py` pass | Strong for current raw externs, including internal helper packages; the ownership gates enforce Device, Surface, mapped-image, and stream-constructor cleanup order plus scoped-error precedence. The 336-line FFI CLI owns declaration/facade/export parity while focused `scripts/ffi_ownership/` modules own shared parsing and family cleanup rules; seven guard tests pin all six root-aware delegations. The 258-line layout CLI owns path assembly and output while focused `scripts/project_layout/` modules own parsing, metadata/docs/consumer, native/package, and counter rules; eighteen tests include all eleven root-aware delegations. All 34 production and 51 oracle C stubs compile under the exact C11 `-Wall -Wextra -Wpedantic -Werror` contract, and the layout gate rejects any downgrade. The external-owner gate independently discovers all 12 raw owner declarations, native finalizers, and external-object allocators; enforces structural owner naming; and requires exact release plus top-level 1000-iteration lifetime evidence |
| Behavioral parity | pycairo-derived black-box cases, independent pure-MoonBit property models, or direct C Cairo primitive oracles cover normal and invalid inputs | Strong for image, context, path, font, pattern, region, surface/device, and backend helpers already listed in the inventory; all 288 tests from all 20 upstream test files are pinned and mapped to 197 family-local MoonBit runtime anchors, 291 required generated static API anchors, 29 deliberately absent signatures, 4 explicit inventory decisions, and 1 mandatory static verify gate. Deterministic Matrix, Region, Path, Rectangle, and RectangleInt properties use independent algebra, occupancy-grid, command-state, and generated-value models. The public-facade ledger has 53 stable source anchors with semver scopes; exact analysis activates 50 exceptions on Cairo 1.15.10 and 43 on Cairo 1.18.4, while every portable reachable branch found by the audit is covered. |
| Rendering parity | Deterministic image pixels or normalized PDF/PS/SVG bytes match direct C Cairo output | Strong for the portable migration scope. Scene 66 closes Cairo 1.18's finite tag-attribute contract across URI, multi-rectangle, destination, page-position, external-file, content, and content-reference cases; it joins the enumerated image and vector fixtures with file/stream/direct-C comparisons and stable positive or negative backend markers |
| Lifetime safety | External-object ownership, borrowed returns, callback retention, integer/pointer operations, and error exits run under ASan/LSan/UBSan or stress tests | Strong for the current portable scope: all 12 raw owners have an exact C finalizer/release mapping and a top-level 1000-iteration allocation path in a separately packaged lifetime test. The `RawTextToGlyphs` path covers clustered, glyph-only, and invalid-font result objects while schema-v2 owner evidence forbids explicit release in its stress helper. Linux runs every MoonBit package in a separate ASan/LSan/UBSan process; stream constructors retain callback state until partial native producers are destroyed on failure, and saved raster getter closures survive replacement, clearing, and their original local bindings leaving scope. Two upstream Cairo paths have pure-C-probe-verified, exact-count LSan suppressions isolated to the vector-oracle and PDF backend packages; every other package remains unsuppressed. |
| Callback safety | C-held MoonBit callbacks and callback arguments are retained across the callback invocation and released deterministically | Strong for stream writers/readers and raster-source callbacks covered by current stress/fuzz tests; reentrant raster registration changes are deferred until the old acquire/release pairs finish, with ASan and retained-owner regressions for clear from both callback directions |
| Portability | Required backends pass on each supported platform, or unsupported APIs have explicit `Decision` rows | Strong local evidence at the exact Cairo 1.15.10 compatibility floor, Ubuntu 24.04's stock Cairo 1.18.0, the recommended exact 1.18.4 release, and the host lane. Module metadata declares native as the sole supported backend, and layout/archive regressions reject drift; unsupported targets stop before native FFI checking. All three Linux lanes consume the same unmodified host-generated zip through module-level `pkg-config` discovery. GitHub runs are grouped by workflow and ref with stale-run cancellation and 60-minute native/sanitizer ceilings, all enforced by negative workflow mutations; still Partial until the release commit's shipped Ubuntu/macOS CI jobs pass |
| Documentation | Public declarations have substantive MoonBit `///` comments, family workflows have executable examples where practical, and `scripts/check-public-docs.py` reports zero debt | Done: all 579 public declarations have substantive comments, the exact grandfather ledger is empty, executable downstream-style family notes include complete PDF/PS/SVG workflows, and new undocumented APIs or ledger drift fail the gate |
| Downstream consumption | A separately named MoonBit module resolves the versioned local dependency, imports only public `CAIMEOX/cairoon`, carries no native flags, receives propagated Cairo linking, exercises representative core, lifetime, value/error, PNG, and PDF-stream workflows against checkout and extracted publication zip, and stays outside that archive | Strong local evidence through six split workflows in `integration/consumer/src/contract` and `scripts/check-downstream-consumer.sh`; source and extracted runs pass 6/6, `--archive` recompiles the producer-host zip unchanged in all three Linux lanes, and the reliability gate rejects a missing manifest file or named workflow |
| Publication integrity | The zip contains the declared dual-license notice and full texts, version-matched release metadata, native dependency/pre-build configuration, the complete MoonBit/C product and test tree, docs, and release tooling; its canonical file set exactly matches every publishable non-hidden checkout file, every payload is byte-identical, paths are unique and safe, CRCs pass, and excluded integration/build/dependency fixtures remain absent | Done locally: `scripts/check-publication-archive.py` checks all 668 members, derives the exact checkout member set, compares every payload, and retains focused metadata/license/API/owner/FFI/reliability/matrix/sanitizer/dry-run requirements. Its 24 tests cover valid and excluded-source cases plus missing, extra, altered, duplicate, unsafe, fixture-leaking, empty, corrupt, or release-inconsistent archives. Six separate dry-run tests pin the fixed non-uploading argv, one complete exact 202/no-change response, status-0/status-255 error-banner consistency, extracted checks, and identity; both validators and their split tests/support are required archive members |

The practical release rule is simple: a feature can be trusted when its
inventory row is `Done`, its reference docs are executable where practical,
and the verify gate passes locally and in CI for every supported platform.
Until the remaining `Partial` row is closed or converted to an explicit
`Decision` row, the project is a reliable partial binding rather than a
complete pycairo migration.

## Test Tiers

Run these tiers in order while developing a slice.

### Tier 0: Interface And Build Checks

```sh
cairoon/scripts/configure-cairo-constants.sh --check
python3 -m unittest discover -s cairoon/scripts/tests -p 'test_*.py'
python3 cairoon/scripts/check-project-layout.py
python3 cairoon/scripts/check-source-size-budget.py
python3 cairoon/scripts/check-api-inventory.py
python3 cairoon/scripts/check-public-docs.py
python3 cairoon/scripts/check-public-coverage.py
python3 cairoon/scripts/check-pycairo-test-parity.py
python3 cairoon/scripts/check-ffi-ownership.py
python3 cairoon/scripts/check-external-owners.py
python3 cairoon/scripts/check-reliability-ledger.py
python3 cairoon/scripts/check-vector-backend-scenes.py
moon -C cairoon check --target native --deny-warn --warn-list +73
./cairoon/scripts/check-downstream-consumer.sh
moon -C cairoon info --target native
```

Review `src/pkg.generated.mbti` after `moon info`. Public additions, `raise`
annotations, and enum constructors must match the intended API.
Run `scripts/configure-cairo-constants.sh --check` before native checks when the
system Cairo installation may have changed. The build-script and layout tests
also reject concrete host paths, repeated Cairo linker flags, or either
native-stub package omitting or reordering the exact
`-std=c11 -Wall -Wextra -Wpedantic -Werror` suffix. Run
`scripts/check-api-inventory.py`
whenever the pycairo stub, public API, or inventory changes. Run
`scripts/check-public-docs.py` whenever a public declaration or doc comment
changes; its exact debt ledger must shrink in the same commit as newly added
documentation and may never grow for a new API. Run
`scripts/check-public-coverage.py` to validate that every exception still maps
to the named MoonBit function and source branch. Before a release candidate or
after public implementation/test changes, run
`scripts/check-public-coverage.py --analyze`; it instruments every test package
and fails on either a newly uncovered branch or a stale exception. It obtains
the linked Cairo version from `pkg-config`. Scope expressions admit only `<`,
`>=`, `==`, and `!=`; comma joins AND terms and `|` joins OR alternatives.
The 53 ledger anchors activate as 50 exceptions on Cairo 1.15.10 and 43 on
both Cairo 1.18.0 and 1.18.4; they are limited to linked-version
boundaries, defensive native-value guards, backend-dependent output,
native-result invariants, platform backends, and platform-only statuses. Run
all three local matrix commands to reproduce those exact profiles; each lane
invokes `--analyze` before its ordinary and sanitizer suites. Run
`scripts/check-pycairo-test-parity.py` whenever a tracked pycairo test file,
its family black-box tests, or a generated family signature changes. Each
ledger pins the upstream source digest and maps every upstream test to runtime,
inventory-decision, or mandatory static-gate evidence. A runtime-less product
decision must cite an exact inventory anchor and state its MoonBit adaptation;
a static gate must cite a command in `scripts/verify.sh` and explain the same.
Every Python runtime `TypeError` assertion also requires present or deliberately
absent static API evidence. A detected parent pycairo source tree must contain
every ledger source; use `--require-source` to enforce this in other strict
environments. The current 20 family ledgers cover all 288 upstream tests with
197 family-local runtime anchors, 291 required public signatures, 29
deliberately absent signatures, 4 explicit inventory decisions, and 1
mandatory static verify gate. A detected source checkout must have exactly one
ledger for every `tests/test_*.py` file. Run
`scripts/check-ffi-ownership.py` whenever raw extern declarations change. Run
`scripts/check-project-layout.py` whenever package structure, root source files,
or `PROJECT_LAYOUT.md` changes. Run `scripts/check-source-size-budget.py`
whenever a source, script, test, native glue, or executable-doc file is added
or substantially expanded. It enforces one 600-line ceiling for every checked
MoonBit, C, header, Python, and shell source file. Run
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

Run the repository-owned ASan/LSan/UBSan gate after every C stub, callback, or
finalizer change:

```sh
CAIROON_SANITIZER_LEAKS=on python3 ./scripts/sanitizers/run.py
```

On Linux, the runner executes a signed-overflow preflight and an
intentional-leak preflight. It fails closed unless UBSan reports the intentional
signed overflow and LSan reports the intentional allocation, then runs every
discovered MoonBit package in a separate process.
`scripts/sanitizers/probes/cairo_recording_snapshot_probe.c` and
`scripts/sanitizers/probes/cairo_pdf_jbig2_missing_probe.c` are compiled and
executed without suppressions. A suppression is allowed only when the relevant
probe reproduces its pinned Cairo-version signature, only for the affected
vector-oracle or PDF package, and only for the exact predicted rows and bytes.
Every other package runs without a suppression.

Clang's function sanitizer is disabled only on exactly four non-inlined helpers
that dispatch already type-checked MoonBit `FuncRef` values. ASan, LSan, and all
other UBSan checks remain active around those helpers. Any expansion of this
exception requires a minimal reproducer, a dedicated checker test, and both
pinned Cairo matrices.

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
- Finalizer-only fallback paths whose normal public wrapper releases eagerly;
  their lifetime-ledger helper must be statically forbidden from calling the
  explicit release entry point.

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

- `moon check --target native --deny-warn --warn-list +73`
- `moon test --target native --deny-warn`
- All production and direct-C oracle stubs compiled as C11 with
  `-Wall -Wextra -Wpedantic -Werror`
- Package-isolated ASan/LSan/UBSan on the authoritative Linux lane; macOS
  follows the platform policy below
- Differential pycairo/C oracle suite
- API inventory audit
- generated `src/pkg.generated.mbti` review

The current local gate is executable as:

```sh
./scripts/verify.sh
```

Release candidates additionally run all three Linux Cairo lanes:

```sh
./scripts/test-cairo-matrix.sh ubuntu-24.04-system
./scripts/test-cairo-matrix.sh cairo-1.15.10
./scripts/test-cairo-matrix.sh cairo-1.18.4
```

Cross-architecture local evidence uses explicit build and execution platforms.
On Apple Silicon, use an isolated Rosetta-backed Docker context rather than
QEMU's unstable long-running compiler emulation:

```sh
./scripts/test-cairo-matrix.sh ubuntu-24.04-system \
  --platform linux/amd64 \
  --docker-context colima-cairoon-rosetta
```

All lanes pin the Ubuntu base image and MoonBit toolchain. The system target
requires Ubuntu's Cairo package to resolve exactly to 1.18.0; exact targets pin
the Cairo source URL, archive SHA-256, install prefix, and linked version. The
checkout is mounted read-only and tested from a disposable copy, so platform
link-flag configuration cannot modify host files.

It runs `moon fmt --check`, the checker unit tests under `scripts/tests`,
`scripts/check-project-layout.py`,
`scripts/check-source-size-budget.py`, `scripts/configure-cairo-constants.sh --check`,
`scripts/check-ffi-ownership.py`, `scripts/check-api-inventory.py`,
`scripts/check-public-docs.py`,
`scripts/check-public-coverage.py`,
`scripts/check-pycairo-test-parity.py`,
`scripts/check-reliability-ledger.py`,
`scripts/check-vector-backend-scenes.py`, native
`moon check --target native --deny-warn --warn-list +73`, the isolated
`integration/consumer` module's six public-only core/lifetime/value/error/
stream workflows against both checkout and extracted publication zip, archive
integrity and fixture exclusion checks, the `src/native` native-stub package,
extracted external
test packages under
`src/tests/api/version` (version helpers),
`src/tests/api/enums` (portable enums and `Format` helpers),
`src/tests/api/pycairo` (pycairo `test_api.py` Unicode text/path plus
surface-constructor smoke, context/pattern lifetime, and recording-extents
parity),
`src/tests/status/core` (public status, `run_cairo`, and `CairoError`
classification),
`src/tests/value/core` (pure value APIs),
`src/tests/value/pycairo` (pycairo value parity),
support packages under `src/core/constants`, `src/core/glyph`,
`src/internal/version`,
`src/internal/font_face`, `src/internal/font_options`, `src/internal/format`,
`src/internal/status`,
`src/internal/pdf`,
`src/internal/path`, `src/internal/ps`, `src/internal/region`,
`src/internal/svg`,
`src/tests/matrix/core`, `src/tests/matrix/property`,
`src/tests/matrix/pycairo`,
`src/tests/region/core`,
`src/tests/region/pycairo`,
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
`src/tests/path/core`, `src/tests/path/pycairo`, `src/tests/object/core`,
`src/tests/lifetime/context`,
`src/tests/lifetime/owner`, `src/tests/lifetime/finalizer`,
`src/tests/lifetime/stream`,
`src/tests/lifetime/image_data`, `src/tests/lifetime/value`,
`src/tests/lifetime/raster`, and
`src/tests/oracle/native`, `src/tests/oracle/constants`,
`src/tests/oracle/scaled_font`, and
`src/tests/oracle/image`, `src/tests/oracle/pattern_raster`, and
`src/tests/oracle/vector_backend`, the full native test suite with
`moon test --target native --deny-warn`,
`moon info --target native`, and package-isolated ASan/LSan/UBSan builds for
every discovered package when a sanitizer-capable `clang` is available. The
public package root no longer has a separate targeted `*_wbtest.mbt` list;
those tests have been converted into external oracle packages discovered by
`scripts/verify.sh`.
Before the sanitizer pass, the runner executes `moon clean` so a compiler
switch or Homebrew/Xcode clang update cannot reuse object files with stale
sanitizer runtime paths. It creates a temporary `MOON_TOOLCHAIN_ROOT` whose
bundled allocator object is replaced in the shadow copy only; the user's
MoonBit installation is never modified. The instrumented build is cleaned
afterward.
Set `CAIROON_VERIFY_ASAN=0` to skip the sanitizer portion intentionally.
Set `CAIROON_ASAN_CC` and `CAIROON_ASAN_AR` to choose the compiler pair for that
sanitizer pass without changing the ordinary full native gate.

## Current Status
