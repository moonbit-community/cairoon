# API Audit Delta History, Part 1

Historical snapshot of `API_INVENTORY.md` lines 15-582 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.

## Recent Audit Deltas

- 2026-07-20: The Ubuntu 24.04 system-Cairo lane now has full local x86_64
  execution evidence, not only a synthetic signature regression. An isolated
  Rosetta-backed Docker context passed 225/225 script tests, 841/841 native
  tests, 63/63 executable docs, all 668 byte-identical publication members, all
  6/6 consumer workflows in every mode, and every package under
  ASan/LSan/UBSan. The stripped recording package used exactly 16
  suppressions/9216 bytes, matching 16 x 576-byte x86_64 allocations; the PDF
  package used exactly 10/2284 plus 4/68. The matrix CLI now passes an explicit
  platform to both Docker build and run, isolates platform image tags, accepts
  an explicit Docker context, and makes pinned downloads retryable and
  resumable. Negative reliability mutations pin those contracts.
- 2026-07-19: Publication integrity now covers the complete archive rather than
  a critical-file whitelist. `scripts/check-publication-archive.py` derives
  the canonical publishable file set from the verified checkout and rejects
  every missing, unverified-extra file or directory, or byte-altered member
  across MoonBit code, C glue, tests, docs, and tooling. The checker, its
  behavior tests, and a 124-line fixture module are explicit required members;
  the behavior module remains split at 474 lines. One fail-first regression with altered MoonBit,
  missing C/support, and extra-source mutations brings the script suite to
  225/225 and the byte-identical archive to 668 members across 454 checked
  source files. Fetching `origin/main` confirms the pinned pycairo source is
  still current at `80ea3348`; public API and production FFI are unchanged.
- 2026-07-19: Mooncakes already contains the initial `0.1.0` preview, whose
  archive predates dependency pre-build/link propagation and whose public
  interface differs from the current tree. The next publishable line is
  therefore `0.2.0`, not a replacement `0.1.0` or compatibility-signaling
  patch. `CHANGELOG.md` records the breaking and release-reliability changes;
  both registry READMEs now pin `moon add CAIMEOX/cairoon@0.2.0`. The archive
  checker dynamically derives that version from packaged `moon.mod`, requires
  the changelog and both install commands to agree, and rejects missing native,
  dependency, pre-build, repository, or fixture-exclusion metadata. A strict
  wrapper also recognizes Moon CLI's current nonzero dry-run exit only after
  one complete exact 202/no-change response, two successful checks, matching
  identity, and the exact trailing failure banner; status 0 forbids that banner.
  Twelve focused regressions raise the script suite to 224/224; the changelog,
  wrapper, and its tests raise the verified publication to 667 members. The
  pinned pycairo upstream remains current at `80ea3348`; this slice does not
  change the current public interface or production FFI boundary.
- 2026-07-19: The separately named downstream fixture is now a six-workflow
  release contract under `integration/consumer/src/contract`, split into image
  rendering/path/pattern, mapped-image scoped ownership, Matrix/Region values,
  typed `CairoError`, PNG callback round-trip, and finished PDF-stream files.
  Source and extracted-package runs each pass 6/6 using only the public
  `CAIMEOX/cairoon` package and propagated native configuration. The archive
  runner copies an exact six-file manifest, while the reliability checker pins
  every filename and named workflow with three negative regressions. This
  raises the script suite to 212/212 without changing public signatures,
  production FFI symbols, native-test count, or the 664-member publication.
- 2026-07-19: The Ubuntu 24.04 stock-Cairo replay is now a first-class local
  release lane: `./scripts/test-cairo-matrix.sh ubuntu-24.04-system` builds the
  named `system-cairo` Docker target and rejects any linked version other than
  1.18.0. The Dockerfile shares only the pinned Ubuntu/MoonBit base and lane
  runner with the source-built `exact-cairo` target. Public-coverage scopes now
  support `<`, `>=`, `==`, and `!=`, with comma as AND and `|` as OR, so the
  1.18.0 PNG and FreeType status profile is represented exactly rather than
  hidden by a broad version range. The system lane and exact Cairo 1.15.10 and
  1.18.4 lanes each pass 209/209 script tests, 841/841 native tests, 63/63
  executable docs, both consumer paths, the unmodified 664-member host archive,
  and every discovered package under ASan/LSan/UBSan. The archive now requires
  the matrix Dockerfile, runner, and entry point byte-for-byte, with no public
  signature or production FFI change.
- 2026-07-19: GitHub Actions run `29678818105` passed macOS native but failed
  Ubuntu native on Cairo 1.18.0's malformed-PNG error-surface bug and stopped
  Ubuntu sanitizer on an unlisted 576-byte recording-snapshot layout. PNG path
  and stream tests now preserve Cairo's raw version contract: `PngError` on
  1.18.2+, the upstream `NoMemory` result on 1.16 through 1.18.0, and an error
  on older Cairo. The pure-C recording classifier accepts 576 bytes only with
  its existing exact two-allocation stack and total checks. An isolated Ubuntu
  replay also exposed the next stripped-symbol PDF/JBIG2 profile; named probe
  frames select a separate package-scoped wrapper suppression whose use must
  remain exactly 10 allocations/2284 bytes plus 4/68. The complete Ubuntu 24.04
  system-Cairo replay passes 841/841 native tests and every discovered package
  under ASan/LSan/UBSan. Both CI jobs now use Node-24-native
  `actions/checkout@v6`, enforced by a workflow regression. The current tree
  checks 446 source files, runs 208/208 script tests and 841/841 native tests,
  and validates 664 publication members without changing public signatures or
  production FFI symbols.
- 2026-07-19: `RawTextToGlyphs` now has a dedicated finalizer-only lifetime
  package instead of relying solely on public wrappers that release native
  glyph/cluster arrays deterministically. One 1000-iteration test covers an
  exact 334/333/333 distribution of clustered success, glyph-only success, and
  invalid-font result objects while deliberately omitting
  `text_to_glyphs_release_raw`. Owner-ledger schema v2 adds executable
  `forbidden_stress_anchors`; the checker rejects explicit release anywhere
  in the claimed helper, with 16 focused tests including 15 negative
  regressions. The current tree checks 446 source files, runs 205/205 script
  tests and 841/841 native tests, and validates 663 publication members without
  changing the public interface or production FFI boundary.
- 2026-07-19: The source-size gate now applies one 600-line ceiling to every
  checked MoonBit source/executable-doc module, C source/header, Python module,
  and shell script; the former 850-line general-source allowance is closed.
  Four focused regressions pin representative suffixes and reject line 601 for
  C, ordinary and test Python, MoonBit, executable docs, and shell sources. A
  current-toolchain seam probe also confirms that `pub using` cannot re-export
  ordinary enum or suberror constructors under facade-qualified names, so the
  remaining direct `src/` facade types stay frozen rather than breaking
  `@cairoon.<Constructor>` syntax. The current tree checks 445 source files,
  runs 203/203 script tests, and validates 660 publication members.
- 2026-07-19: Font-option enum representation helpers now live with their
  existing Antialias, SubpixelOrder, HintStyle, HintMetrics, and ColorMode
  owners in `src/enums.mbt`, rather than inflating family facades. The move is
  line-for-line: `enums.mbt`, `context_state.mbt`, and `font_options.mbt` are
  now 440, 527, and 518 lines while their aggregate stays 1,485 lines. The
  source-size gate adds a 600-line ceiling for every `.mbt` and `.mbt.md` file;
  a fourth boundary regression rejects line 601. That slice checked 445 source
  files, ran 203/203 script tests, and validated 660 publication members
  without changing public signatures, native behavior, or release policy.
- 2026-07-19: The 601-line reliability-ledger checker is now a 134-line CLI
  and path-assembly layer over focused Markdown, release-evidence, and gate
  modules of 158, 274, and 158 lines under `scripts/reliability/`. Three new
  root-aware delegation regressions retain the existing 29 behavior checks,
  while a sixteenth publication test requires the root checker and every
  implementation dependency byte-for-byte. That slice checked 445 source
  files, ran 202/202 script tests, and validated 660 publication members
  without changing public signatures, native behavior, or release policy.
- 2026-07-19: Reliability-ledger tests are no longer concentrated in one
  800-line mixed-domain module. Downstream/verify/workflow gates, current
  release evidence, and exact local-matrix wiring now live in focused files of
  384, 329, and 140 lines. The source-size gate adds a 600-line Python
  `test_*.py` ceiling beside the existing 600-line C/header and 850-line
  general limits; a third boundary test rejects line 601 without constraining
  ordinary Python tools. That slice checked 442 source files, ran 198/198
  script tests, and validated 657 publication members without changing
  public signatures, native behavior, or release policy.
- 2026-07-19: The project-layout audit is no longer a 750-line mixed-domain
  checker. A 258-line CLI now owns path assembly, compatibility wrappers,
  ordering, and output; common parsing, executable counters, metadata/docs/
  consumer rules, and native/package rules live in five focused
  `scripts/project_layout/` files of 1-276 lines. An eighteenth layout test
  pins all eleven root-aware delegations while retaining the prior seventeen
  positive and negative behavior tests. That slice checked 440 source files,
  ran 197/197 script tests, and validated 655 publication members
  without changing public signatures, native behavior, or package policy.
- 2026-07-19: The executable FFI ownership audit is no longer an 827-line
  mixed-responsibility script. Its 336-line CLI owns declaration annotations,
  facade/export parity, and compatibility wrappers; shared source extraction
  plus Device, Surface, and mapped-image cleanup rules live in five focused
  `scripts/ffi_ownership/` files of 1-279 lines. A seventh cleanup-guard test
  pins all six root-aware delegations. Publication validation now requires the
  complete six-file FFI audit toolchain byte-for-byte, with a fifteenth
  positive/negative archive test covering every missing and altered member.
  That slice checked 435 source files, ran 196/196 script tests, and validated
  650 publication members without changing public signatures,
  native behavior, or the production FFI symbol boundary.
- 2026-07-19: C architecture now has a stricter executable size contract.
  Overlay, SoftLight, and Difference image-oracle scenes moved from the
  835-line pattern-stack file into a dedicated 332-line blend-operator stub;
  the remaining stack file is 504 lines. A focused two-test regression pins a
  600-line budget for C sources and headers while retaining the 850-line
  general-source ceiling. That slice checked 430 source files, compiled 34
  production plus 51 oracle C stubs, ran 194/194 script tests, and validated
  645 publication members without changing public signatures, native behavior,
  documentation totals, or the production FFI symbol boundary.
- 2026-07-19: Ordinary-method accounting is now complete rather than silently
  portable-only. The API checker requires each of the 259 pycairo ordinary
  methods to have exactly one form of evidence: 255 map to public MoonBit
  interfaces, while `XCBSurface.set_size` and the three Xlib surface getters
  map individually to the existing conditional X11/XCB extension Decision.
  Missing, stale, dual, or unanchored mappings fail closed. Method mappings now
  live in their own reviewable module and are required source-identically in
  publication archives. The audited totals are 192/192 script tests, 428
  checked source files, and 643 publication members; public signatures, native
  tests, documentation totals, and the production FFI boundary are unchanged.
- 2026-07-19: The pycairo API snapshot is now a complete schema-v2 shape
  contract rather than a methods-only approximation. It pins 67 public
  top-level entries, 259 ordinary methods, 39 Python protocols/constructors,
  206 class attributes, 224 top-level constants, and 178 enum aliases.
  `scripts/check-api-inventory.py` requires all 39 protocols and all 206
  attributes to resolve to type-scoped MoonBit constructors, traits, fields,
  enum variants, functions, constants, structured error payloads, or explicit
  platform Decisions. Missing `Context::new` and `Matrix.xx` regressions prove
  the generated interface cannot satisfy the gate by count alone. The archive
  now requires source-identical snapshot/parser/mapping/checker support. This
  raises the audited totals to 191/191 script tests, 427 checked source files,
  and 642 publication members without changing public signatures, native
  tests, documentation totals, or the production FFI boundary.
- 2026-07-18: Sanitizer infrastructure is split into cohesive modules instead
  of one 852-line entry point. `run.py` now owns CLI and package orchestration,
  `toolchain.py` owns compiler/runtime isolation and ASan/UBSan/LSan preflights,
  and `leak_probes.py` owns the recording-snapshot and PDF/JBIG2 classifiers
  plus exact suppression accounting. Existing imports remain compatible via
  re-exports. The reliability checker pins markers to their owning module, the
  general source budget tightens from 900 to 850 lines, and the resulting
  release tree contains 425 checked source files and 640 publication members
  without changing public API or native FFI symbols.
- 2026-07-18: GitHub Actions capacity is now an executable reliability
  contract. Runs are grouped by workflow and Git ref, stale work is cancelled
  only when a newer run supersedes that same ref, and both native and sanitizer
  jobs have a 60-minute ceiling. The static workflow parser and existing
  negative-mutation suite reject disabled cancellation, a group that merges
  unrelated refs, missing timeouts, failure masking, conditional gates, and
  release-matrix drift. This saves hosted capacity without treating a cancelled
  or merely local run as shipped release evidence.
- 2026-07-18: Stream attachment-failure ownership now has dynamic fault
  injection in addition to the static cleanup gate. Shared Surface and Device
  helpers centralize all null-producer, native-status, and user-data attachment
  failures and destroy the partial Cairo producer before releasing its owned
  MoonBit writer state. A distinct oracle package constructs real PDF, PS, SVG,
  and ScriptDevice producers, simulates attachment failure, and runs under
  ASan/LSan/UBSan; the three surface backends prove destroy-time callbacks can
  still reach the live writer, while ScriptDevice cleanup remains free to emit
  zero or more backend-controlled callbacks. Nine negative mutations plus one
  baseline pin the shared helpers and every branch. This raises the audited
  totals to 185/185 script tests, 840/840 native tests, 423 source files, 638
  publication members, and 50 oracle C stubs without changing public
  signatures or the 349-local-plus-two-direct production FFI boundary.
- 2026-07-18: Finalizer graph fuzz now closes every operation-local scenario
  class. A second test-first counter exposed another correlated selector: the
  font/path/region operation required `value % 5 == 2`, then reused
  `value % 5` for five intended font sizes, so its actual distribution was
  `[0, 0, 25, 0, 0]`. The dispatcher now uses the remainder only for its
  five-way operation and passes the quotient to every operation. A dedicated
  coverage probe pins operation counts `33/38/25/36/28`, surface colors
  `14/19`, mapped error/explicit/implicit-unmap outcomes `18/7/13`, font sizes
  `3/5/8/5/4`, region widths `11/14`, raster success/failure `27/9`, and stream
  success/failure `19/9`. This changes no production code, public signature,
  test total, source-file total, FFI symbol, or publication member.
- 2026-07-18: Finalizer graph fuzz now proves the reachability of both script
  stream outcomes. A test-first counter exposed that operation dispatch selected
  stream cases only when `value % 5 == 4`, while the stream `WriteError` branch
  required `value % 5 == 0` and was therefore impossible. The dispatcher now
  passes the independent quotient to the stream scenario. The fixed seeds
  execute 28 stream cases: 19 successful finalizations and 9 `WriteError`
  exits, with nonzero runtime assertions for both classes. The focused package
  passes host ASan/UBSan and both exact-Cairo Linux lanes under
  ASan/LSan/UBSan. This test-only correction leaves 183 script tests, 838
  native tests, 421 source files, 634 publication members, public signatures,
  production C glue, and the 349-local-plus-two-direct FFI boundary unchanged.
- 2026-07-18: C glue now has an executable C11 warnings-as-errors contract.
  Both native-stub manifests apply the exact `-std=c11 -Wall -Wextra
  -Wpedantic -Werror` suffix after the `pkg-config` Cairo flags, covering all
  34 production stubs and 49 direct-C oracle stubs. The project-layout checker
  rejects any missing, reordered, or downgraded flag, and a parameterized
  negative test removes each required flag in turn. The exact Cairo 1.15.10
  lane exposed one 1.18-only oracle helper outside its compile guard; the
  helper now shares the call sites' version guard, and a second negative test
  rejects either missing guard boundary. This raises the script suite to
  183/183 without changing production C or MoonBit code, public signatures,
  the 349-local-plus-two-direct FFI boundary, 838 native tests, 421 source
  files, or 634 publication members.
- 2026-07-18: Native verification now treats MoonBit warning 73 as a release
  error. Compiler-guided cleanup removes 2,115 unnecessary package qualifiers
  from 129 external black-box/oracle test files without changing production
  code, C glue, public signatures, or test behavior. `scripts/verify.sh` runs
  `moon check --target native --deny-warn --warn-list +73`, and the reliability
  checker plus a negative mutation test reject restoring the weaker command.
  The audited totals are 181/181 script tests, 838/838 native tests, 421 source
  files, and 634 publication members; documentation, API, owner, and FFI totals
  are unchanged.
- 2026-07-18: Region, Path, Rectangle, and RectangleInt now have deterministic
  generated properties backed by independent pure-MoonBit models. Region uses
  a 16-by-16 half-open occupancy grid over 32 seeds to check construction,
  containment, extents, copy/translate/equality, and Region/rectangle boolean
  operations without asking Cairo for expected results. Path uses 32 generated
  18-command state machines to check absolute/relative lines and curves,
  close/new-subpath behavior, current points, copy isolation, append replay,
  and flattened line-only replay with Cairo's move/collinear normalization.
  Rectangle and RectangleInt use 128 signed-field cases plus six distant
  invalid indexes to pin components, aliases, equality, and exact
  `CairoInvalidArgument(InvalidIndex, _)` mapping. These nine tests raise the
  audited totals to 838/838 native tests, 421 source files, and 634 publication
  members; script, documentation, API, owner, and FFI totals are unchanged.
- 2026-07-18: External-object lifetime evidence is now an executable bijection.
  `scripts/lifetime/owners.json` maps all 12 discovered `Raw*` owner types to
  their exact FFI declaration, structurally named C struct/finalizer, all
  release actions, and a top-level allocation anchor exercised at least 1000
  times by a separately packaged sanitizer test.
  `scripts/check-external-owners.py` rejects missing or stale owners/finalizers,
  duplicate mappings, allocator struct drift, missing release actions, weak
  conditional loops/helpers/anchors, and stress files outside their exact
  MoonBit lifetime package; 14 focused tests, including 13 negative
  regressions, protect the checker. A public RasterSource
  regression also proves getter-returned acquire/release closures remain usable
  after replacement, clearing, and the original Pattern/source scope exits.
  The audited totals are 180/180 script tests, 829/829 native tests, 416 source
  files, and 629 publication members; public API and production FFI counts are
  unchanged.
- 2026-07-18: Raster-source callback FFI now follows the Pattern owner rather
  than the public facade. Seven registration, clearing, and introspection
  externs moved into `src/internal/pattern`; the child owns 45 raw externs and
  exchanges `RawSurface`, integer extents, raw callback closures, and `Int`
  statuses. Public `pattern_raster_source.mbt` alone adapts `Surface`,
  `RectangleInt`, `Status`, and checked `CairoError`. A package-local callback
  state/getter round-trip raises the native suite to 828/828. The public root
  now declares no C FFI, direct root implementation files fall to 37, the
  grandfather allowlist to 40, and the integrity-checked archive to 626
  members. Production remains 349 local plus two direct symbols in 36 FFI
  files, and the public interface hash remains unchanged.
- 2026-07-18: Surface stream callback FFI now follows the package owner rather
  than the public facade. PDF, PS, SVG, and PNG stream externs moved from four
  root FFI files into `src/internal/surface`; the child package owns callback
  chunk copying and exposes five raw wrappers, while the public package keeps
  status conversion and checked errors. At that slice boundary, internal
  Surface had 84 raw externs and the public root retained seven raster-source
  callback externs in one file. A package-local PDF/PS/SVG write and PNG
  write/read round-trip raises the native suite to 827/827. Direct root implementation
  files fall to 38, the grandfather allowlist to 41, production FFI files to
  36, and the integrity-checked archive to 625 members; the
  349-local-plus-two-direct symbol set and public interface hash remain
  unchanged.
- 2026-07-17: The published module now encodes its actual native-only backend
  contract with both `preferred_target = "native"` and
  `supported_targets = "native"`. Unsupported Wasm, WasmGC, JavaScript, and
  LLVM checks stop at the module boundary instead of emitting internal
  native-FFI missing-symbol errors. Project-layout and publication-archive
  regressions enforce the metadata, bringing the script suite to 165/165 while
  the archive remains 629 members.
- 2026-07-17: The API inventory is now self-contained in publication archives.
  `scripts/api/pycairo-api-snapshot.json` pins pycairo commit `80ea3348`, the
  exact `cairo/__init__.pyi` SHA-256, 67 public top-level entries, 259 total
  public class methods, 224 top-level constants, and 178 enum aliases.
  `scripts/check-api-inventory.py` rejects source/snapshot drift and reports the
  same 67 entries, 224 constants, and 255 portable methods with or without the
  parent pycairo checkout. Seven snapshot regressions plus an archive-presence
  regression bring the script suite to 161/161; the required snapshot and its
  split parser bring the integrity-checked archive to 629 members.
- 2026-07-17: Publication archives now carry the complete dual-license grant
  declared by `moon.mod`: a cairoon `COPYING` notice plus the unmodified
  LGPL-2.1 and MPL-1.1 texts inherited from pycairo. The archive validator
  requires those files, matching SPDX metadata, the public README/interface,
  and the module pre-build script; it also rejects duplicate canonical member
  paths. Five failure-path regressions bring the script suite to 153/153, and
  the integrity-checked archive contains 626 members.
- 2026-07-17: Native configuration is now portable across publication hosts.
  `scripts/build/cairo_config.py` uses MoonBit's pre-build config protocol to
  resolve Cairo 1.15.10 or newer through `pkg-config`, inject C-stub compiler
  flags into the two native-stub packages, and propagate linker flags from
  `CAIMEOX/cairoon/native`. Eighty-three package/consumer manifests no longer
  store concrete host paths or repeat `cc-link-flags`. The source and extracted
  consumers require no manual link configuration, and both exact-Cairo Linux
  lanes consume the same unmodified host-generated zip before configuring the
  disposable source checkout. Protocol, quoting, minimum-version, failure,
  environment-redaction, layout, and archive-mode regressions bring the script
  suite to 148/148; the integrity-checked archive contains 623 members.
- 2026-07-17: The package-isolated native safety gate now combines ASan, LSan,
  and UBSan. A signed-overflow preflight fails closed unless UBSan reports the
  intentional error; the existing intentional-leak preflight still proves
  LSan. Linux exposed Clang `function`-sanitizer metadata incompatibility at
  otherwise ABI-correct MoonBit `FuncRef` calls. The C typedefs remain exact,
  while four non-inlined dispatch helpers alone disable that subcheck for
  stream read/write and raster-source acquire/release. A script regression
  pins exactly those four annotations and forbids global function-sanitizer
  disablement. The script suite is 148/148; public API, native-test count,
  documentation, and the 349-local-plus-two-direct production FFI boundary are
  unchanged. Exact Cairo 1.15.10 and 1.18.4 lanes each pass 826/826 native
  tests, 63/63 executable docs, both isolated consumers, all 623 publication
  members, and every discovered package under ASan/LSan/UBSan.
- 2026-07-17: Public-facade branch coverage is now executable release
  evidence. Twenty-six family-local black-box tests cover object
  `Hash::hash_combine`, complete value component order, typed
  pattern/font/content/image/PDF/SVG enums, raw unbounded recordings, raster
  callback clearing, Region status, exact backward text-cluster script output,
  deterministic PNG errors, and real PDF `Jbig2GlobalMissing` propagation. The
  first audit reduced 85 uncovered lines and a Linux rerun closed a
  host-dependent `Rgb16_565` gap. The final ledger has 53 stable
  file/function/source anchors with strict semver scopes: instrumented analysis
  activates 50 on Cairo 1.15.10 and 43 on 1.18.4, rejecting both unexpected
  uncovered branches and stale exceptions. Exact Linux lanes each pass
  826/826 native tests, 116/116 script tests, 63/63 executable docs, both
  isolated consumers, all 619 publication members, and every discovered
  package under ASan/LSan. Pure-C probes constrain Cairo's recording-snapshot
  suppression to the vector package and its JBIG2-missing PDF finish
  suppression to the PDF package with exact per-version counts and bytes.
- 2026-07-16: All 25 PDF declarations now document point-sized file/no-output
  and retained-writer construction, runtime version support, immutable outline
  flag sets, restriction and page-size timing, standard/custom metadata,
  current-page labels, thumbnail state, outline hierarchy, and typed/raw error
  boundaries. Native guards reject restriction ids absent from
  `PDFVersion::supported()` before Cairo can mutate ActualText state and reject
  metadata ids outside 0..6 before Cairo's unchecked conversion path. New
  regressions pin negative/positive unknown raw ids, linked-version-dependent
  PDF 1.7 behavior, non-poisoning errors, and exact raw flag preservation.
  Documentation reaches 579 of 579 declarations with zero debt. Exact Linux
  Cairo 1.15.10 and 1.18.4 each pass 800/800 native tests, 90/90 script tests,
  63/63 executable docs, both isolated consumers, all 602 publication members,
  and every package under ASan/LSan. The public interface and production FFI
  symbol set remain unchanged.
- 2026-07-16: All 13 PostScript declarations now document point-sized and
  per-page construction, file/writer ownership, copied level arrays/strings,
  restriction timing, EPS single-page rules, current/subsequent page sizing,
  DSC section transitions, 255-byte/comment-string constraints, and checked
  receiver errors. A native range guard makes negative level-string lookup
  portable before calling Cairo. Regressions pin `-1`/`99` failures, emitted
  Level 2 output after raw restriction sentinel `99`, non-rewinding PageSetup
  comment placement, default and emitted EPS state, exact 255/256-byte DSC
  boundaries, missing-percent errors, and embedded-NUL rejection. Documentation
  reaches 554 of 579 declarations with 25 exact debt
  entries. Exact Linux Cairo 1.15.10 and 1.18.4 each pass 798/798, 90/90 script
  tests, both isolated consumers, all 602 publication members, and every
  package under ASan/LSan. Public interface and production FFI remain unchanged.
- 2026-07-16: All 11 SVG declarations now document point-sized construction,
  filename and retained-writer ownership, finish-time write errors, copied
  version arrays/strings, restriction-before-drawing, root document units
  without coordinate rescaling, the Cairo 1.15.10 development-floor/1.16
  stable API boundary, and typed versus raw receiver/error behavior. Regressions
  pin negative and positive invalid raw version strings plus the tested positive
  sentinel `99` no-op for raw restriction/unit calls; other out-of-range values
  remain unsupported. Documentation reaches 541
  of 579 declarations with 38 exact debt entries. Exact Linux Cairo 1.15.10 and
  1.18.4 each pass 798/798, 90/90 script checks, both isolated consumers, all
  602 publication members, and every package under ASan/LSan. The public
  interface and 349-local-plus-two-direct-symbol production FFI boundary remain
  unchanged.
- 2026-07-16: Stream constructor failure ownership is now explicit and
  executable. PDF/PS/SVG surfaces and ScriptDevice keep the owned writer state
  alive until a partially constructed Cairo producer is destroyed, then release
  it exactly once; the shared attach helpers consume state only after successful
  user-data attachment. `scripts/check-stream-cleanup.py` statically pins the
  successful transfer plus native-status and attachment-failure order for all
  four constructors, with seven negative mutations and one passing baseline
  raising the script suite to 90. On exact Cairo 1.15.10 and 1.18.4, stream
  surfaces pass 16/16, ScriptDevice passes 19/19, and stream lifetime stress
  passes 2/2 in both ordinary and package-isolated ASan/LSan runs. These dynamic
  runs cover callback lifetime but do not inject Cairo allocator failure.
  Production FFI symbols and public API remain unchanged.
- 2026-07-16: All 8 RecordingSurface and TeeSurface declarations now document
  native and MoonBit owner edges, recording-space extents and snapshots,
  typed/raw content behavior, indexed-result ownership, sticky removal errors,
  and finished/type/index status mapping. The Tee audit found that calling
  `tee_index` first after `finish` let Cairo's unsupported error-surface path
  turn `SurfaceFinished` into `NoMemory`; the native precondition now preserves
  cairoon's explicit finished marker before indexing. New tests prove that an
  indexed target survives removal and all creator scopes, all Tee operations
  preserve `SurfaceFinished`, absent removal stores sticky `InvalidIndex`, and
  recording extents remain readable after finish while ink measurement is
  terminal. Documentation reaches 530 of 579 declarations with 49 exact debt
  entries. Exact Linux Cairo 1.15.10 and 1.18.4 each pass 798/798, both isolated
  consumers, all 600 publication members, and every package under ASan/LSan;
  the public interface remains byte-for-byte unchanged.
- 2026-07-16: All 15 ScaledFont declarations now document native ownership,
  pointer identity, referenced/copied getter results, matrix coordinate rules,
  UTF-8/NUL behavior, glyph/cluster ownership, and checked errors. The audit
  corrected `text_to_glyphs_only` to pass null cluster outputs exactly like
  pycairo's `with_clusters=False`, preserved FontFace/FontOptions error status
  through raw construction, and made copied Cairo output arrays release
  deterministically with an idempotent finalizer fallback. The direct-C oracle
  now copies and frees its own arrays instead of sharing production
  marshalling, and a user-font probe observes the actual null-output boundary.
  Focused packages pass 3/3, 9/9, and 4/4, while the 1000-iteration value
  lifetime test exercises both text conversion modes. Documentation reaches
  522 of 579 declarations with 57 exact debt entries. Exact Linux Cairo
  1.15.10 and 1.18.4 each pass 796/796, both isolated consumers, all 600
  publication members, and every package under ASan/LSan. The public interface
  remains byte-for-byte unchanged.
- 2026-07-16: All 35 base Surface declarations now document native ownership,
  pointer identity, parent and caller-buffer retention, typed/raw state,
  coordinate units, finish/flush/dirty protocols, font-option snapshots, MIME
  copy semantics, and PNG path/stream errors. The lifecycle audit found that a
  sticky surface status could skip `cairo_surface_finish` and retained image
  data release, while `with_finished` could replace a closure error with the
  cleanup error. Native finish now always performs backend and retained-data
  cleanup before reporting the original sticky status, and scoped error paths
  perform best-effort raw cleanup before re-raising the closure error. Static
  cleanup-order guards, six focused guard tests, and two black-box regressions
  pin both behaviors. The native suite reaches 792 tests and documentation
  reaches 507 of 579
  declarations with 72 exact debt entries. Exact Linux Cairo 1.15.10 and
  1.18.4 each pass the complete suite, both isolated consumers, the 600-member
  publication archive, and every package under ASan/LSan; the public interface
  remains unchanged.
- 2026-07-16: All 53 Pattern-family declarations now document native ownership,
  pointer identity, typed/raw state boundaries, pattern-space geometry, mesh
  patch lifecycle, independently owned returns, and raster callback retention
  and error rules. The lifecycle audit found a reentrant use-after-free when a
  raster release closure cleared or replaced its own registration, plus a
  paired-owner leak risk when acquire changed registration before Cairo's
  release. Callback state replacement is now deferred until every acquisition
  using the old pair is released. Three regressions cover release-side clear,
  acquire-side clear with zero retained owners, and sticky `InvalidMatrix`.
  Exact Cairo 1.15.10 and 1.18.4 each pass 790/790 plus full
  package-isolated ASan/LSan. Documentation reaches 472 of 579 declarations
  with 107 exact debt entries; the public interface remains unchanged.
- 2026-07-15: All 31 ImageData, ImageSurface, and MappedImageSurface
  declarations now document live-view ownership, zero-copy caller buffers,
  stride/padding rules, flush/dirty obligations, mapped exact-once cleanup,
  and typed/raw format boundaries. The lifecycle audit found that explicit
  unmap could return early on a finished or sticky-error base and that
  `with_unmapped` could replace the closure error with a cleanup error. A
  shared native cleanup path, static order guards, two black-box regressions,
  and a 9/9 focused ASan run pin the corrected behavior. Documentation reaches
  419 of 579 declarations with 160 exact debt entries, and the native suite
  reaches 787 without changing the public interface.
- 2026-07-15: All 11 FontFace declarations now document single-owner lifetime,
  native identity, toy-text limitations, UTF-8/NUL handling, copied family
  strings, typed/raw enum boundaries, subtype mismatch, and exact
  `InvalidSlant`/`InvalidWeight` behavior. Existing focused allocation,
  cross-scope, Context-return, pycairo parity, and raw-enum tests pass 10/10 and
  12/12. Documentation coverage reaches 388 of 579 declarations with 191
  exact debt entries; the public interface and native suite are unchanged.
- 2026-07-15: All 20 public Device/script declarations now document native
  ownership, stream callback retention, script-surface reference behavior,
  exact acquire/release pairing, terminal finish semantics, and checked error
  precedence. The audit found and fixed cleanup paths that previously let a
  sticky device status skip `cairo_device_release` or `cairo_device_finish`;
  scoped error paths now attempt raw cleanup before preserving the closure
  error. `scripts/check-ffi-ownership.py` enforces both C cleanup order and
  MoonBit scope behavior, the Device package passes 19/19 normally and under
  focused ASan, and the native suite reaches 785. Documentation coverage is
  now 377 of 579 declarations with 202 exact debt entries.
- 2026-07-15: The public-documentation gate distinguishes substantive MoonBit
  `///` Markdown comments from empty `///|` block markers and now recognizes
  MoonBit's default-abstract types and all intentionally published support
  packages as public API. The corrected inventory has 579 declarations across
  45 files. Errors, statuses, enums, formats, versions, matrices, paths,
  rectangles, text metrics, clusters, glyph values, support-package constants,
  the native anchor, the complete Region and FontOptions families, and the
  Context core, path, clipping/extents, matrix, drawing-state,
  source/painting/page, and font/text/glyph families now document 357 entries;
  the exact grandfather ledger records the remaining 222
  and rejects new undocumented APIs, stale entries, or
  malformed/unsorted/duplicate debt. The Docs row remains `Partial` until that
  ledger reaches zero.
- 2026-07-15: All 11 non-callback public-root FFI declarations move into the
  Context, Pattern, and Device child packages. Typed facade methods now perform
  exhaustive enum-to-`Int` conversion before calling raw functions; the public
  root retains exactly 12 callback bridges in five files. One package-local
  Context test raises the native suite to 784. The FFI gate proves one-to-one
  parity between 348 cairoon externs and native exports, permits only two exact
  libcairo direct symbols, and rejects test-only exports from the production C
  package. The public generated interface remains byte-for-byte unchanged.
- 2026-07-15: The Surface object seam moves `RawSurface`,
  `RawMappedImageSurface`, `RawImageData`, and 79 raw externs into
  `src/internal/surface`; Context, Pattern, and Device child packages exchange
  those handles directly. Eight package-local boundary tests bring the native
  suite to 783 while the public generated interface and 357-symbol production
  C API set remain unchanged. The FFI gate rejects duplicate C declarations.
- 2026-07-15: The executable reference package now has dedicated enum,
  status/version/error, and pure-value documents in addition to the eight
  object-family references. All 11 files compile as downstream black-box
  documentation tests. `scripts/check-project-layout.py` requires the complete
  set, a level-one title, at least one executable `mbt check` block, and an
  exact index entry in both repository and package READMEs; eight focused
  layout tests lock the passing contract and seven failure paths.
- 2026-07-15: Scene 66 closes the finite Cairo 1.18 Tags and Links matrix:
  URI and explicit multi-rectangle links, named and page-position links,
  external-file links, internal and extent-derived destinations, and
  `TAG_CONTENT`/`TAG_CONTENT_REF` are matched against direct C output for
  PDF/PS/SVG file and stream surfaces. Invalid attributes and nesting map to
  `TagError`. The vector checker requires 10 valid-attribute dimensions and 5
  runtime evidence tests, so the `Tags` row advances from `Partial` to `Done`.
- 2026-07-15: Pinned CModule, Typing, SurfaceNumpy, and SurfacePygame ledgers
  close the final 8 upstream tests with 10 MoonBit runtime anchors, 12 required
  generated signatures, 1 deliberately absent CAPI signature, 3
  family-local product-decision anchors, and 1 mandatory verify-gate anchor.
  The parity checker now rejects duplicate upstream source declarations and,
  when a pycairo checkout is detected, any unclaimed `tests/test_*.py` file;
  all 288 tests across all 20 source files are therefore enumerated exactly.
- 2026-07-15: Pinned API and FilePaths ledgers map all 17 upstream tests to 18
  MoonBit runtime anchors, 36 required generated signatures, 4 deliberately
  absent signatures, and 1 explicit product-decision anchor. The parity
  checker now permits a runtime-less mapping only when it cites an exact
  `API_INVENTORY.md` decision and supplies a non-empty MoonBit adaptation;
  `get_include()` uses that path because it is a CPython extension packaging
  helper rather than a Cairo runtime operation.
- 2026-07-15: Pinned Enum and Error ledgers map all 11 upstream tests to 6
  family-local runtime anchors, 15 required generated signatures, and 4
  deliberately absent legacy enum aliases. The parity checker now accepts a
  genuinely empty TypeError set and detects TypeError inside tuple-form
  `pytest.raises` assertions, so Python-specific exception protocol checks
  cannot silently escape static-evidence requirements.
- 2026-07-15: Pinned Glyph, TextCluster, and TextExtents ledgers map all 8
  upstream tests to 5 family-local runtime anchors, 16 required generated
  signatures, and 3 deliberately absent deprecated glyph-count signatures.
  `TextCluster::at` and `TextExtents::at` provide checked index syntax. Glyph
  keeps its heterogeneous `(UInt64, Double, Double)` components instead of
  losing index precision through a homogeneous runtime-index return type.
