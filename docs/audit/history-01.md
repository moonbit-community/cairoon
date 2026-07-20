# Migration Audit History, Part 1

Historical snapshot of `AUDIT.md` lines 1-561 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

# cairoon Migration Audit

## Current Slice

Implemented in this workspace:

- Publication archive integrity now covers the complete release payload rather
  than a selected tooling whitelist. The checker derives every publishable
  non-hidden checkout file, rejects missing or unverified-extra canonical file
  or directory members, and compares all MoonBit, C, test, documentation, and
  tooling bytes. Its own checker/test/fixture trio is explicitly required. One
  fail-first regression covers altered MoonBit, missing C/support, and extra-source
  mutations; all 24 publication tests and the 225-test script suite pass. The
  split checker, fixtures, and behavior tests are 325, 124, and 474 lines, and
  the resulting archive has 668 byte-identical members across 454 checked
  source files. A fresh `origin/main` fetch confirms pycairo remains pinned to
  its current upstream head `80ea3348`; public API and production FFI are
  unchanged.
- The registry release line is now explicit. Mooncakes already contains the
  July 6 `0.1.0` preview, whose manifest omits dependency-side Cairo discovery
  and whose generated public interface differs from the current tree. The
  unreleased candidate is therefore `0.2.0`. A new changelog records the
  compatibility and reliability delta, both package READMEs pin the matching
  `moon add` command, and the integration consumer depends on the same version.
  Publication validation derives name/version from the archived `moon.mod` and
  rejects version drift plus missing repository, native-only, dependency,
  pre-build, or fixture-exclusion metadata. A strict dry-run wrapper accepts
  Moon CLI's current status 255 only with one complete exact 202/no-change
  response, two successful package checks, matching identity, and the exact
  trailing failure banner; status 0 forbids an error banner. Twelve focused
  regressions bring the script suite to 224/224; all 23 publication and 6
  dry-run parser tests pass, producing an integrity-checked 667-member archive
  across 453
  source-size-checked files. The pycairo source snapshot remains current at
  upstream `80ea3348`, and the current public interface and production FFI
  symbols are unchanged by this release-preparation slice.
- The release consumer is no longer a one-operation smoke package. Its
  separately named `integration/consumer/src/contract` package has six
  responsibility-split public-only workflows for deterministic image/path/
  pattern drawing, `MappedImageSurface::with_unmapped`, Matrix/Region values,
  structured `CairoError` matching, PNG read/write callbacks, and PDF stream
  finalization. Source and extracted 664-member publication runs pass 6/6.
  Archive mode copies an explicit six-file list; the reliability checker pins
  that exact order, exact source set, and all six names. Three negative tests
  reject manifest, file, or workflow loss, raising the script suite to 212/212.
  The tree now has 451 checked source files. Public signatures, the 841-test
  native suite, production C glue, and archive membership are unchanged.
- The Ubuntu 24.04 system-Cairo replay is now the named local release lane
  `./scripts/test-cairo-matrix.sh ubuntu-24.04-system`. The Dockerfile separates
  `matrix-base`, `lane-runner`, `system-cairo`, and `exact-cairo`; the system
  target requires Cairo 1.18.0, while source lanes still require their pinned
  URL, SHA-256, prefix, and exact linked version. Coverage scopes now express
  the 1.18.0 status profile exactly with `<`, `>=`, `==`, `!=`, comma-AND, and
  `|`-OR terms. The system lane plus exact 1.15.10 and 1.18.4 lanes each pass
  209/209 script tests, 841/841 native tests, 63/63 docs, both downstream
  consumers, the unmodified 664-member host archive, and every package under
  ASan/LSan/UBSan. Publication integrity requires all three matrix support
  files byte-for-byte. Public signatures and the production FFI boundary are
  unchanged.
- GitHub Actions run `29678818105` passed macOS native but exposed two Ubuntu
  compatibility gaps. The native job stopped on Cairo 1.18.0's upstream
  malformed-PNG error-surface bug, which reports `NoMemory` until Cairo 1.18.2
  correctly propagates `PngError`; path and stream tests now assert that exact
  version boundary. The sanitizer job's pure-C recording probe found the known
  leak with an x86_64-specific 576-byte layout, now accepted only under the
  existing exact stack/count/total constraints. A local Ubuntu system-Cairo
  replay also proved the next stripped PDF/JBIG2 profile and its separate
  package-scoped wrapper suppression at exactly 10 allocations/2284 bytes plus
  4/68. That stock-Cairo replay now passes all 841 native tests and every
  discovered package under ASan/LSan/UBSan. Both CI checkouts now use
  Node-24-native `actions/checkout@v6`, and the reliability checker rejects a
  downgrade. The current tree has 446 checked source files, 208 script tests,
  841 native tests, and 664 publication members without changing public
  signatures or production FFI symbols.
- `RawTextToGlyphs` finalizer fallback now has direct lifetime evidence rather
  than being inferred from public methods that release glyph/cluster arrays
  eagerly. A dedicated package drops 1000 raw results across an exact
  334/333/333 clustered-success, glyph-only-success, and invalid-font
  distribution. Owner-ledger schema v2 adds `forbidden_stress_anchors`, so the
  checker rejects any explicit release in that helper; 16 focused checker
  tests include 15 negative regressions. The current tree has 446 checked
  source files, 205 script tests, 841 native tests, and 663 publication members
  without changing public signatures or production FFI symbols.
- The source-size gate now applies one 600-line ceiling to every checked
  MoonBit source/executable-doc module, C source/header, Python module, and
  shell script; no 850-line general-source allowance remains. Four focused
  regressions pin representative suffixes and reject line 601 for C, ordinary
  and test Python, MoonBit, executable docs, and shell sources. A pinned-
  compiler seam probe separately confirms that `pub using` cannot preserve
  facade-qualified ordinary enum or suberror constructors, so direct `src/`
  facade types remain frozen instead of changing public syntax. The current
  tree has 445 checked source files, 203 script tests, and 660 publication
  members.
- Font-option enum representation helpers now live with the existing
  `Antialias`, `SubpixelOrder`, `HintStyle`, `HintMetrics`, and `ColorMode`
  owners in `src/enums.mbt`, rather than inflating family facades. The move is
  line-for-line: `enums.mbt`, `context_state.mbt`, and `font_options.mbt` are
  now 440, 527, and 518 lines while their aggregate remains 1,485 lines. The
  source-size gate adds a 600-line ceiling for every `.mbt` and `.mbt.md` file;
  a fourth boundary regression rejects line 601. That slice checked 445 source
  files, ran 203 script tests, and validated 660 publication members without
  changing public signatures, native behavior, or release policy.
- The 601-line reliability-ledger checker is split into a 134-line CLI and
  path-assembly layer plus 158-line visible-Markdown parsing, 274-line
  canonical release-evidence, and 158-line shell/matrix gate modules under
  `scripts/reliability/`. The existing 29 behavior regressions remain green;
  three root-aware delegation tests pin the new boundaries. Publication
  validation now requires all six checker/support files byte-for-byte, and its
  sixteenth regression rejects every missing or altered dependency. The
  slice checked 445 source files, ran 202 script tests, and validated 660
  publication members.
- The 800-line reliability-ledger test module is split by rule domain into
  384-line downstream/verify/workflow, 329-line current-release-evidence, and
  140-line exact-local-matrix suites. All 29 existing ledger regressions remain
  discovered; release-evidence count normalization now handles Markdown line
  wrapping. The source-size gate adds a 600-line Python-test ceiling and a
  third boundary regression while retaining 600-line C/header and 850-line
  general budgets. That slice brought the tree to 442 checked source files,
  198 script tests, and 657 publication members.
- The 750-line project-layout checker is split into a 258-line path assembly,
  compatibility-wrapper, ordering, and CLI entry point plus focused common
  parsing, executable-counter, metadata/docs/consumer, and native/package
  modules of at most 276 lines. Eighteen layout tests retain the seventeen
  behavior checks and pin all eleven root-aware delegations. That slice
  brought the tree to 440 checked source files, 197 script tests,
  and 655 publication members.
- The 827-line FFI ownership checker is split into a 336-line declaration,
  facade, export-parity, and CLI entry point plus focused shared-source,
  Device, Surface, and mapped-image cleanup modules of at most 279 lines.
  Seven cleanup-guard tests pin behavior and all six root-aware delegations.
  Publication validation requires the complete modular checker byte-for-byte;
  its fifteenth focused test rejects every missing or altered dependency. That
  slice brought the tree to 435 checked source files, 196 script tests,
  and 650 publication members.
- The 835-line pattern-stack C oracle is split by responsibility: stack,
  mesh, and mask scenes remain in a 504-line file, while Overlay, SoftLight,
  and Difference scenes live in a 332-line blend-operator file. The source-size
  gate now enforces 600 lines for every C source/header and 850 for other
  checked source, with two focused boundary tests. That slice brought the tree
  to 430 checked source files and 34 production plus 51 oracle C stubs.
- Sanitizer tooling is no longer concentrated in an 852-line entry point.
  `scripts/sanitizers/run.py` contains CLI and package orchestration,
  `toolchain.py` owns compiler discovery, preflights, wrappers, and shadow
  toolchains, and `leak_probes.py` owns strict upstream-Cairo leak signatures
  and suppression-use accounting. Existing test imports remain available via
  entry-point re-exports. The reliability gate requires each critical marker
  in its owning module. That slice established the 850-line general source
  ceiling; the later C-specific 600-line ceiling is described above.
- Eleven family-scoped executable reference documents under `src/docs/`,
  including dedicated enum, status/version/error, and pure-value guides. The
  external docs package passes 63/63 tests, and the project-layout gate
  requires every reference to have an executable block and exact entries in
  both documentation indexes.
- Stream user-data attachment failures now have executable lifetime evidence.
  Shared Surface and Device cleanup helpers cover every null producer,
  native-status error, and attachment error; each null-checks and destroys the
  partial Cairo producer before releasing the owned MoonBit writer state. A
  separate oracle package simulates attachment failure with real PDF, PS, SVG,
  and ScriptDevice producers under ASan/LSan/UBSan. The three surface cases
  prove destroy-time output reaches the still-live writer; the ScriptDevice
  case verifies state release without assuming a backend callback count. Ten
  focused checker tests include nine negative mutations across the helpers and
  constructor branches.
- External-object lifetime evidence is now exact rather than inferred from a
  broad sanitizer pass. `scripts/lifetime/owners.json` maps all 12 discovered
  raw owners to one FFI declaration, structurally named native payload/finalizer,
  complete release actions, and a top-level allocation anchor reached inside a
  top-level 1000-iteration lifetime test.
  `scripts/check-external-owners.py` independently discovers the declarations
  and finalizers, verifies the allocator/finalizer/`sizeof` pairing, and fails
  on missing, duplicate, stale, swapped, conditional, or unpackaged evidence.
  Fourteen focused tests include thirteen negative regressions. A new
  RasterSource black-box
  test saves getter-returned acquire/release closures, replaces and clears the
  registration, exits the Pattern/source scope, and then calls the saved pair,
  directly proving the getter's strong-reference contract.
- Region, Path, Rectangle, and RectangleInt now have independent generated
  property evidence. A pure-MoonBit 16-by-16 occupancy grid checks Region
  construction, positive-area containment, extents, copy/translation/equality,
  and all four Region/rectangle boolean operations over 32 seeds. A separate
  Path state model checks 32 generated 18-command sequences, current points,
  copy isolation, append replay, and flattened line-only replay. Rectangle
  types cover 128 signed-field values and exact invalid-index suberrors. The
  nine tests do not derive expected values from cairoon or Cairo.
- Native verification now enables MoonBit warning 73 as an error. A
  compiler-guided mechanical cleanup removes 2,115 unnecessary package
  qualifiers from 129 external black-box/oracle test files while leaving
  production code, C glue, public signatures, and behavior unchanged.
  `scripts/verify.sh` runs the exact strict check, and a negative reliability
  checker mutation rejects the former command without `+73`.
- Public-package branch instrumentation is audited by
  `scripts/check-public-coverage.py`: every portable reachable branch found by
  the audit has a black-box test. The ledger has 53 stable source keys with
  strict semver scopes and substantive reasons; instrumented analysis activates
  50 exceptions on Cairo 1.15.10 and 43 on Cairo 1.18.4. The `--analyze` mode
  selects the linked-version profile and rejects both newly uncovered lines and
  stale exceptions. Real PDF/JBIG2 missing-global and PNG stream/file failures
  cover the portable status paths rather than classifying them as platform
  exceptions.
- All seven raster-source callback registration, clearing, and introspection
  externs now live with `RawPattern` in `src/internal/pattern`. The owner
  package has 45 raw externs and accepts only `RawSurface`, integer extents,
  raw closures, and `Int` statuses at this boundary. The public facade alone
  adapts `Surface`, `RectangleInt`, `Status`, and checked `CairoError`. The
  public package root now contains no C FFI; a package-local four-state
  callback/getter test brings the native suite to 828 without changing the
  public interface hash or production symbol set.
- PDF, PS, SVG, and PNG stream callback externs now live with their raw Surface
  owners in `src/internal/surface`, including callback chunk copying and raw
  status transport. Five child-package wrappers replace four public-root FFI
  files; the public facade retains checked status conversion. The child owns 84
  raw externs; that preceding slice left seven raster-source callback externs
  in one root file. Package-local vector-write and PNG write/read round trips bring
  the native suite to 827 tests without changing the public interface hash or
  the 349-local-plus-two-direct production symbol set.
- MoonBit native package initialization with `moon.mod` and `src/moon.pkg`.
- The module declares native as both its preferred and sole supported target.
  Four layout/archive regressions require that contract in source and
  publication metadata; unsupported target checks now stop cleanly before
  native-gated FFI internals instead of emitting 152 misleading undefined-name
  errors on WasmGC.
- Publication legal metadata now matches `moon.mod`: `COPYING` records the
  dual-license grant and the archive carries the complete LGPL-2.1 and MPL-1.1
  texts. The archive gate also requires the public README/interface and
  dependency pre-build script, and rejects duplicate canonical members.
- The pycairo API audit is self-contained: a strict snapshot pins the upstream
  commit, stub SHA-256, 67 public entries, 259 ordinary methods, 39
  protocols/constructors, 206 class attributes, 224 constants, and 178 enum
  aliases. Source and standalone-archive modes both enforce the same 255-method
  portable mapping, four method-level X11/XCB Decisions, and exact type-scoped
  protocol and attribute evidence.
- Portable system-Cairo configuration through `scripts/build/cairo_config.py`.
  MoonBit's pre-build protocol resolves Cairo 1.15.10 or newer via `pkg-config`,
  injects `${build.CAIRO_CFLAGS}` into the two native-stub packages, appends
  the exact `-std=c11 -Wall -Wextra -Wpedantic -Werror` contract for all 34
  production and 51 oracle C stubs, and propagates linker flags from
  `CAIMEOX/cairoon/native`. The layout checker and a parameterized negative
  test reject omission, reordering, or downgrading of those flags. All 89 package and
  consumer manifests are free of concrete host paths and repeated
  `cc-link-flags`; eight focused protocol tests cover quoting, version floors,
  process failures, deterministic JSON, and environment redaction.
- Exact local release lanes for Cairo 1.15.10 and 1.18.4, built from pinned
  source URLs and SHA-256 digests on a pinned Ubuntu base image. Both lanes
  pass all static gates, 841/841 native tests, 209/209 script tests, and 63/63
  executable documentation tests with the pinned MoonBit
  `0.10.4+4f2e8f7dc-nightly` compiler. In each lane, the source-checkout and
  extracted-publication-zip consumers also pass 1/1 independently. Each lane
  additionally consumes the same unmodified host-generated zip, so
  producer-specific include/library paths cannot be hidden by lane setup. The
  integrity-checked publication archive contains 664 members, and every
  discovered package passes ASan/LSan/UBSan. Each pinned lane also runs
  instrumented public-facade coverage and requires the exact linked-version
  ledger profile.
- Linux ASan/LSan/UBSan now runs every discovered MoonBit package in a separate
  process. Intentional signed-overflow and leak preflights prove UBSan and LSan
  are active; the runner creates a temporary `MOON_TOOLCHAIN_ROOT` with an
  allocator-free shadow runtime, leaving the installed MoonBit toolchain
  untouched.
- Clang's `function` subcheck cannot validate compiler-specific metadata on
  MoonBit-native `FuncRef` targets even though the official ABI and emitted
  calling convention match the C callback typedef. Exactly four non-inlined
  C helpers disable only that subcheck while dispatching stream read/write and
  raster-source acquire/release. Script tests require those four and no others,
  and reject global `-fno-sanitize=function`; all surrounding C and all other
  UBSan checks remain instrumented and fail-fast.
- The unsuppressed sanitizer pass found and fixed a real stream callback leak
  in `src/native/cairoon_stream.c`: a fresh `moonbit_make_bytes` result already
  owns its call-scoped reference and must not be incremented before passing it
  to a borrowed `FuncRef` argument.
- Cairo 1.15.10 and 1.18.4 both reproduce an SVG recording-surface snapshot
  leak in a standalone C program that does not link cairoon. The probe must
  report exactly two direct allocations with either the internal
  `_cairo_recording_surface_snapshot` frame or the constrained stripped stack
  described below before one LSan suppression can apply. It applies only to
  `src/tests/oracle/vector_backend`. The 1.15.10 vector package reports 16
  suppressed allocations/7424 bytes; 1.18.4 reports 16 allocations/9344
  bytes. No package other than the vector oracle uses this suppression.
- Cairo 1.15.10 and 1.18.4 also reproduce the PDF missing-JBIG2-global finish
  leak in a standalone C program. Only `src/tests/backend/pdf` receives the two
  `_cairo_pdf_interchange_init`/`_cairo_paginated_surface_finish`
  suppressions, and the runner requires exact use: 6 allocations/948 bytes plus
  3/40 on 1.15.10, and 10/2284 plus 4/68 on 1.18.4. Any additional matching or
  unsuppressed leak fails the package; all packages outside these two isolated
  cases remain unsuppressed.
- Ubuntu 24.04's stock Cairo 1.18.0 strips the recording-snapshot internal
  function name and uses architecture-specific layouts: the failed GitHub
  x86_64 probe reports two 576-byte allocations, while the local arm64 replay
  reports two 584-byte allocations. In either case the pure-C stack must
  contain `cairo_surface_destroy`, `cairo_pattern_destroy`, `cairo_restore`,
  and the probe's `render_document` frame before a `cairo_restore` fallback is
  selected; the vector run then enforces exactly 16 suppressions and the
  probe-derived byte total. The same distro library strips the two PDF/JBIG2
  private frames, so named pure-C probe frames select separate
  `cairoon_pdf_surface_create_for_stream` and `cairoon_surface_finish`
  suppressions. The PDF package still must report exactly 10/2284 plus 4/68.
- Static raw FFI ownership linting through
  `scripts/check-ffi-ownership.py`, wired into `scripts/verify.sh`, so every
  non-primitive production `src/**/ffi*.mbt` parameter must be annotated with
  `#borrow` or `#owned`; test oracle `*_ffi_test.mbt` files are deliberately
  outside this production-boundary lint.
- Static complete pycairo API-shape inventory linting through
  `scripts/check-api-inventory.py`, wired into `scripts/verify.sh`, so every
  public class/function in parent `cairo/__init__.pyi` must have an
  implementation or explicit product-decision anchor in `API_INVENTORY.md`, and
  every portable ordinary method, Python protocol/constructor, and class
  attribute must have exact public MoonBit evidence in its owning generated
  package interface or an explicit platform Decision.
- Executable pycairo family test parity through
  `scripts/check-pycairo-test-parity.py` and the ledgers under
  `scripts/parity/`, wired into `scripts/verify.sh`. Twenty family ledgers pin
  every upstream `tests/test_*.py` source by commit and SHA-256 and require all
  288 tests to map to existing MoonBit black-box tests, exact inventory
  decisions, or mandatory static verify gates. Python runtime `TypeError`
  assertions also require present or deliberately absent generated public
  signatures. Runtime-less decisions must cite an exact `API_INVENTORY.md`
  anchor; static-gate mappings must cite a command that is actually present in
  `scripts/verify.sh`; both must state the MoonBit adaptation. The checker
  rejects duplicate ledger sources and unclaimed upstream test files. Its
  positive and negative fixtures run from `scripts/tests`, and pinned snapshots
  keep the gate usable in a standalone cairoon checkout without the parent
  pycairo source tree. When the parent pycairo marker is present, a missing
  ledger source is an error instead of a snapshot fallback; strict environments
  can also pass `--require-source`.
- Static reliability-ledger linting through
  `scripts/check-reliability-ledger.py`, wired into `scripts/verify.sh`, so
  migration status rows use accepted statuses, `Partial` rows state remaining
  gaps explicitly, and the current Tests evidence stays below 1200 characters
  while naming both source-pinned Cairo lanes, the Ubuntu system-Cairo lane,
  exact suite/archive/API counts, local sanitizer coverage, and the shipped-CI
  gap. The checker derives the script
  count from `unittest` discovery, scopes sanitizer policy to TESTING Tier 3,
  scopes the package stability claim to its current section, and confirms CI
  continues to run native and ASan/LSan/UBSan verify gates.
- Initial external black-box API package extraction under
  `src/tests/api/{version,enums,pycairo}`. Root-level `tests/` packages are
  intentionally forbidden while `moon.mod source = "src"` keeps the public
  import path as `CAIMEOX/cairoon`. External test packages that import cairoon
  carry no Cairo flags; the native package's module-level link configuration
  propagates to each independently linked test executable, and the layout gate
  rejects regressions to package-local `cc-link-flags`.
- The external API black-box packages cover version helpers, portable enum
  constructors, `Format::stride_for_width`, `FORMAT_INVALID`, and pycairo
  `test_api.py` smoke/lifetime fixtures. The pinned Enum ledger maps all 7
  upstream enum tests to typed constructor, raw-value, status, flag, observer,
  stride, and explicit Python-only protocol decisions.
- Status/error black-box tests now live in `src/tests/status/core`, importing
  only the public `CAIMEOX/cairoon` API. This validates `check_status`,
  `run_cairo`, public `Status::message`, and all `CairoError` suberror classes
  through the published package seam; the pinned Error ledger maps all 4
  upstream error tests to exhaustive classification and real Context failure
  evidence.
- Pure public value black-box tests now live in
  `src/tests/value/{core,pycairo}`, importing only the public
  `CAIMEOX/cairoon` API. This validates rectangles, glyphs, text clusters, and
  font/text extents, including component access, invalid-index error mapping,
  checked Rectangle/TextCluster/TextExtents index syntax, heterogeneous Glyph
  components, type-appropriate equality/hash fixtures, numeric limits, all 12
  pinned upstream Rectangle/Glyph/TextCluster/TextExtents tests, and return
  paths from Context, ScaledFont, recording surfaces, and clip extents through
  separately linked published-package seams.
- Matrix black-box tests now live in
  `src/tests/matrix/{core,property,pycairo}`, importing only the public
  `CAIMEOX/cairoon` API. This validates external-package access to public
  types, methods, checked errors, deterministic Matrix properties, Matrix-only
  multiplication, checked index syntax, and pycairo-derived component/transform
  fixtures through separately linked published-package seams.
- Region black-box tests now live in `src/tests/region/{core,pycairo}`,
  importing only the public `CAIMEOX/cairoon` API. This validates Region
  lifetime/copy behavior, rectangle construction, containment, overlap enums,
  mutating boolean operations, cairoon's explicit checked-chaining extension,
  `RectangleInt` equality without generic hashing/ordering, all 12 pinned
  upstream Region tests, and invalid-index error mapping through separately
  linked published-package seams.
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
  helpers, raw script content mapping, stream error mapping, and all 11 pinned
  upstream Device tests through separately linked published-package seams;
  backend stream oracle tests remain white-box.
- Path black-box tests now live in `src/tests/path/{core,pycairo}`, importing
  only the public `CAIMEOX/cairoon` API. This validates Path formatting,
  iteration, flattening, scope survival, and pycairo-derived comparison/hash
  behavior, including all 4 pinned upstream Path tests, through separately
  linked published-package seams.
- Object trait black-box tests now live in `src/tests/object/core`, importing
  only the public `CAIMEOX/cairoon` API. This validates Eq/Hash semantics
  across external object wrappers through the published package seam.
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
  surfaces through the published API, including current pattern-operator
  scenes for `OperatorColorDodge` and `OperatorHslHue` group-mask output.
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
  discovered by `scripts/verify.sh` with Cairo linking propagated from the
  native package.
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
- `src/internal/region` is the first facade-owned object implementation seam.
  It owns the GC-managed raw Region handle, all 21 Region extern wrappers, and
  package-local raw geometry/status tests. Its interface deliberately exposes
  Cairo status and overlap values only as `Int`, so it neither imports the
  facade nor duplicates `Status`, `RegionOverlap`, or `CairoError`. Public
  `src/region.mbt` remains the owner of the abstract `Region` wrapper, all
  published methods, enum conversion, and error mapping. The generated public
  interface is unchanged; external core/parity tests and finalizer/value
  lifetime tests cover behavior and ownership through `CAIMEOX/cairoon`.
- `src/internal/font_options` is the second facade-owned object seam and the
  first with cross-family producers and consumers. It owns the sole
  `RawFontOptions` external object, all 28 FontOptions-specific externs, and
  package-local raw state/copy/merge tests. Its interface uses `Int` for Cairo
  statuses and enum values and does not import the facade. Context, Surface,
  and ScaledFont externs in the public package pass `RawFontOptions` directly;
  checked facade methods wrap returned handles and unwrap arguments. Public
  `FontOptions` still owns typed/raw enum conversion, variation string
  validation, color APIs, traits, and `CairoError` mapping. The generated
  public interface is unchanged, while font, context, scaled-font, and
  lifetime tests cover the cross-family ownership paths.
- `src/internal/font_face` is the third facade-owned object seam. It owns the
  sole `RawFontFace` external object, all eight declared FontFace-specific
  externs, and package-local raw status/accessor tests. Its interface uses
  `Int` for Cairo statuses, slants, and weights and does not import the facade.
  Context and ScaledFont externs pass `RawFontFace` directly; checked facade
  methods wrap returned handles and unwrap arguments. Public `FontFace` still
  owns string validation, typed/raw enum conversion, traits, and `CairoError`
  mapping. Its generated public interface is unchanged, while FontFace,
  Context, ScaledFont, oracle, and lifetime tests cover cross-family ownership.
- `src/internal/path` is the fourth facade-owned object seam and the first
  producer-only child package. It owns the sole `RawPath` external object and
  all seven Path-specific externs using raw `Int` status and path-data values.
  Context copy/append and mesh Pattern get-path FFI exchange `RawPath` below
  the facade; checked public methods alone wrap returned handles and unwrap
  append arguments. Public `Path` retains segments, enum conversion, traits,
  string decoding, and `CairoError` mapping, and its generated interface is
  unchanged. The child deliberately has no test-only constructor: Path,
  Context, mesh Pattern, value-stress, and finalizer black-box tests cover both
  real producers, append consumption, error paths, source-scope independence,
  and sole-owner finalization.
- `src/internal/device` is the fifth facade-owned object seam and the first
  with a production constructor that transfers a MoonBit callback closure to
  native state. It owns the sole `RawDevice` external object and all 13
  Device-only constructor, identity, lifecycle, type, and script-state externs
  using raw `Int` status and enum values. The five recording/script Surface
  bridge externs remain in public `ffi_device.mbt` but exchange `RawDevice`;
  checked `Device` and `Surface` facade methods alone wrap or unwrap it. The
  child stream wrapper copies callback chunks before user code can retain them,
  while the existing native stream state remains responsible for releasing the
  `#owned` writer closure on failures and finalization. Package-local raw tests
  cover identity, mode state, acquire/release, and finish behavior; external
  Device/ScriptSurface, stream-retention, value-stress, and finalizer tests
  cover the cross-family and callback ownership paths.
