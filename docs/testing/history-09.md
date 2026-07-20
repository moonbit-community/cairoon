# Testing Evidence History, Part 9

Historical snapshot of `TESTING.md` lines 4366-4734 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.


Focused ordinary and package-isolated ASan/LSan runs pass 3/3 for internal
ScaledFont ownership/status/release, 9/9 for public matrices/lifetimes/errors,
4/4 for independent C oracle and UTF-8/null-output behavior, and 1/1 for the
1000-iteration value-wrapper stress package. The full exact Linux Cairo
1.15.10 and 1.18.4 lanes each pass 796/796, both 1/1 downstream consumer paths,
publication-archive integrity for 600 members, and every package under
ASan/LSan. The sole suppression remains the pure-C-probe-confirmed recording
snapshot: 16 allocations/7424 bytes on Cairo 1.15.10 and 16 allocations/9344
bytes on Cairo 1.18.4. The production FFI boundary contains 349 local symbols
plus two direct libcairo symbols, while `src/pkg.generated.mbti` remains
byte-for-byte unchanged at SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.

The subsequent RecordingSurface and TeeSurface lifecycle/documentation replay
adds substantive contracts for all 8 declarations and raises documentation
coverage to 530 of 579 with 49 exact debt entries. Recording docs pin Cairo's
operation snapshots, optional pixel extents, raw content values, replay
coordinates, and the deliberate post-finish distinction: configured extents
remain readable like pycairo, while ink measurement follows cairoon's terminal
surface policy. Tee docs pin the primary and replica owner edges, duplicate and
removal behavior, independent indexed results, and all checked index/status
cases.

The native audit found that `tee_index` as the first operation after `finish`
could bypass cairoon's finished marker. Cairo then represented
`SurfaceFinished` with an unsupported nil error surface whose status degraded
to `NoMemory`. Tee subtype validation now uses the shared checked Surface
precondition before all operations. Regressions prove independent indexed
target lifetime after removal and creator-scope exit, exact finished status for
index/add/remove, absent-target sticky `InvalidIndex`, and recording
post-finish behavior. Focused Recording and Tee packages pass 5/5 and 6/6 in
ordinary and package-isolated ASan/LSan runs on both exact Cairo versions; the
executable docs package passes 63/63.

The full exact Linux Cairo 1.15.10 and 1.18.4 lanes each pass 798/798, both 1/1
downstream consumer paths, publication-archive integrity for 600 members, and
every package under ASan/LSan. The sole suppression remains the independently
reproduced recording-snapshot leak in the vector oracle package: 16
allocations/7424 bytes on Cairo 1.15.10 and 16 allocations/9344 bytes on Cairo
1.18.4. The production FFI boundary remains 349 local symbols plus two direct
libcairo symbols, and `src/pkg.generated.mbti` remains byte-for-byte unchanged
at SHA-256
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.

The subsequent stream-constructor ownership audit found that shared
`cairoon_stream_attach` helpers released an owned callback state immediately
when Cairo user-data attachment failed. PDF/PS/SVG and ScriptDevice callers then
destroyed the partially constructed native producer, whose backend finalizer
could still invoke the now-freed writer. Attachment helpers now consume state
only on success. Shared Surface and Device cleanup helpers cover null producer,
native-status, and attachment failures; each destroys any producer while the
state is live before releasing that state exactly once.

The dedicated `scripts/check-stream-cleanup.py` makes the required transfer and
failure order a static release gate without enlarging the existing FFI checker.
Nine negative mutations reject missing or malformed attachment, helper-side
failure consumption, missing shared cleanup or pre-attach status checks, and
reversed Surface or Device helper order; one passing baseline contributes ten
script tests. The separate `src/tests/oracle/stream_failure` package constructs
real PDF, PS, SVG, and ScriptDevice stream producers, arms the MoonBit writer,
and calls the production cleanup helper as though user-data attachment failed.
PDF/PS/SVG destruction must invoke the still-live writer with nonzero output;
ScriptDevice output count remains backend-controlled, while ASan/LSan/UBSan
detects leaks, use-after-free, and double release. On exact Linux Cairo 1.15.10
and 1.18.4, this oracle passes 2/2 alongside 17/17 stream-surface, 19/19
ScriptDevice, and 2/2 stream-lifetime tests in ordinary and package-isolated
sanitizer runs. Public API and the 349-local-plus-two-direct production FFI
boundary are unchanged.

The subsequent SVG contract/documentation replay covers all 11 public
declarations. Constructor docs pin point-sized pages, optional filename output,
writer retention, independent callback chunks, and finish-time write errors.
Version helpers document copied arrays/strings and raw invalid-value mapping;
surface methods pin restriction-before-drawing, document units that affect root
size attributes without rescaling coordinates, Cairo's 1.15.10 development
floor/1.16 stable API boundary, and typed versus raw receiver behavior.

Focused regressions cover raw version strings at `-1` and `99`, unknown raw
unit `99` preserving the prior pixel unit, and unknown raw version restriction
`99` remaining a Cairo no-op with `Success`; other out-of-range integers remain
unsupported. SVG and executable-doc packages pass 6/6 and 63/63 normally and
under package-isolated ASan/LSan on exact Linux
Cairo 1.15.10 and 1.18.4. The full lanes each pass 798/798, 90/90 script tests,
both 1/1 downstream consumers, archive integrity for 602 members, and every
package under ASan/LSan. The sole suppression remains the pure-C-probe-confirmed
recording snapshot: 16 allocations/7424 bytes on Cairo 1.15.10 and 16
allocations/9344 bytes on Cairo 1.18.4. Documentation reaches 541 of 579 with
38 exact debt entries; public interface SHA-256 remains
`6c647f7e0c12188c36330a66681141a4449558884ce948d2c74e462a91b2f0f3`.

The subsequent PostScript contract/documentation replay covers all 13 public
declarations. Constructors specify point-sized, per-page output and file or
retained-writer ownership. Level helpers specify copied results, the
before-drawing restriction rule, valid typed/raw values, and the exact tested
`99` raw no-op boundary. EPS docs pin pre-page timing and the single-page
requirement; page-size docs pin current/subsequent-page behavior after
`show_page` or `copy_page`. DSC docs make Header, Setup, and PageSetup
transitions explicit and specify percent prefix, 255 UTF-8 byte, newline, NUL,
sticky-error, and Cairo-generated-comment constraints.

The focused 8/8 package adds a native pre-Cairo range guard plus `-1`/`99`
level-string errors, emitted Level 2 output after raw restriction sentinel `99`,
output-position proof that an out-of-order Setup call does not rewind
PageSetup, default/true EPS state plus an `EPSF` file marker, accepted 255 byte
and rejected 256 byte DSC comments, missing-percent rejection, and NUL mapping.
The executable example now places `%%Title` in Header before changing to
Setup/PageSetup. PS and docs packages pass 8/8 and 63/63 normally and under
package-isolated ASan/LSan on exact Linux Cairo 1.15.10 and 1.18.4. The full
lanes each pass 798/798, 90/90 script tests, both 1/1 consumers, archive
integrity for 602 members, and every package under ASan/LSan. The sole
suppression remains the pure-C-probe-confirmed recording snapshot: 16
allocations/7424 bytes on Cairo 1.15.10 and 16 allocations/9344 bytes on Cairo
1.18.4. Documentation reaches 554 of 579 with 25 exact debt entries; no public
signature or production FFI symbol changed.

The subsequent PDF contract/documentation replay covers all 25 remaining public
declarations. Constructors specify point-sized file, no-output, and retained
writer ownership; version helpers distinguish the four typed constructors from
the list supported by linked Cairo; metadata, page labels, thumbnail state, and
outline hierarchy now carry exact timing, format, availability, string, and
typed/raw contracts. The PDF review found that an unknown restriction integer
can leave the selected version unchanged while still toggling Cairo's internal
ActualText mode, and that an unknown metadata enum can allocate converted text
without a switch arm to own it. Native guards now reject restriction ids absent
from `PDFVersion::supported()` and metadata ids outside 0..6 before those
state-changing paths. Regressions cover negative and positive unknown ids,
linked-version-dependent PDF 1.7 behavior, valid calls after rejected raw
inputs, and exact known/unknown outline bits. The executable backend guide also
covers empty-string custom metadata removal, one-dimension thumbnail disabling,
and all three outline entry points; a file-output regression proves that
empty-string removal emits neither the custom key nor its previous value.

The subsequent public-facade coverage audit adds exact PDF/JBIG2 missing-global
status propagation, deterministic PNG decode errors through both stream and raw
file-status paths, exact PDF/SVG version strings, script-backend proof of
backward asymmetric UTF-8 text clusters, and linked-version setter coverage.
Its semver-scoped ledger is checked statically and against instrumented runs on
both pinned Cairo versions. The JBIG2 error is portable and executable, but its
upstream Cairo finish path leaks after returning the required status; the
standalone
`scripts/sanitizers/probes/cairo_pdf_jbig2_missing_probe.c` must reproduce the
exact signature before two suppressions can apply only to the PDF test package.

The preceding Surface stream FFI ownership slice moves PDF, PS, SVG, and PNG
callback externs and callback chunk copying into `src/internal/surface` while
leaving checked error conversion in the public facade. A package-local test
constructs and finishes all three vector stream surfaces, then writes and reads
a PNG through callbacks. It catches missing child-package imports, incorrect
callback status transport, and callback lifetime regressions before public
black-box coverage runs. The public interface hash and production symbol set
remain unchanged while four public-root FFI files disappear.

The current Pattern callback ownership slice moves all seven raster-source
callback externs into `src/internal/pattern`. Its raw boundary now receives
`RawSurface` handles, integer extents, raw closures, and `Int` statuses; the
public facade alone constructs `RectangleInt`, wraps `Surface`, and raises
checked `CairoError`. A package-local test exercises acquire+release,
acquire-only, release-only, clear, getter invocation, callback arguments, and
subtype mismatch. Existing public raster black-box, transition-matrix,
owner-count, manual callback, and 1000-iteration lifetime tests pass unchanged.
The public root now contains no C FFI, while the public interface hash and
production symbol set remain unchanged.

The external-owner evidence slice adds a structured registry for all 12 raw
external objects and a default verify gate that cross-checks declarations,
native finalizers, allocator source/payload pairs, structural owner naming,
complete release actions, and the exact
1000-iteration stress helpers executed under package-isolated sanitizers.
Fourteen focused script tests, including thirteen negative regressions, prevent
weakening the registry. The corresponding
RasterSource behavior test proves that getter-returned callback closures own
their MoonBit references independently of subsequent replacement, clearing,
after the original Pattern and captured-source bindings leave local scope.

The strict MoonBit warning slice removes 2,115 compiler-identified unnecessary
package qualifiers from 129 external black-box and oracle test files. The
transformation changes no production implementation, C glue, or public
signature. Native verification now runs
`moon check --target native --deny-warn --warn-list +73`; the reliability
checker tokenizes the active shell command, and a negative mutation test proves
the former command without `+73` cannot satisfy the gate.

The strict C stub slice applies
`-std=c11 -Wall -Wextra -Wpedantic -Werror` after the generated Cairo flags in
both native-stub packages. This covers all 34 production C files and 50
test-only direct-C oracle files. The layout checker requires the exact ordered
flag string, while a parameterized negative test removes each flag in turn and
proves the release gate fails closed. Cairo 1.15.10 then exposed the
1.18-only tag-attribute text helper as unused; the helper now shares its call
sites' compile guard, and a checker regression rejects either missing guard
boundary. No production C source, production MoonBit code, public signature,
native test, or FFI symbol changed in this slice.

The geometry property-oracle slice adds nine deterministic tests whose
expected values do not come from Cairo or cairoon. A 16-by-16 half-open
occupancy grid checks Region construction, positive-area containment, extents,
copy/translation/equality, and all four Region/rectangle boolean operations
over 32 seeds. A separate Path command-state model generates 18 absolute and
relative move/line/curve/close/new-subpath commands for each of 32 seeds, then
checks current points, copy isolation, append replay, and flattened line-only
replay with Cairo's move and collinear-line normalization. Rectangle and
RectangleInt each cover 128 signed-field values, structural equality,
component/index aliases, and six out-of-range indexes with exact
`CairoInvalidArgument(InvalidIndex, _)` matching.

The finalizer-fuzz reachability slice repairs a false coverage claim without
changing production code. The five-way dispatcher previously selected the
script-device operation only for values congruent to 4 modulo 5, while that
operation selected `WriteError` only for values congruent to 0 modulo 5. A new
failure counter first demonstrated the branch was unreachable. The dispatcher
now passes the independent quotient as the operation-local scenario, and
runtime counters prove the fixed seeds execute 19 successful and 9
`WriteError` exits across 28 script-device cases. The isolated finalizer package
passes normally, under host ASan/UBSan, and in both exact-Cairo Linux lanes
under ASan/LSan/UBSan.

A follow-up exact-distribution counter exposed the same correlation in the
font/path/region operation: dispatch required `value % 5 == 2`, so reusing that
remainder for five intended font sizes produced `[0, 0, 25, 0, 0]`. The
dispatcher now uses the remainder only for operation selection and gives every
operation the quotient as its local scenario. `FinalizerFuzzCoverage` pins all
five operation counts plus both surface colors, three mapped-image outcomes,
five font sizes, two region widths, raster-source success/failure, and script
stream success/`WriteError`; the exact distributions are recorded in
`API_INVENTORY.md` and checked in the runtime test.

The callback-fuzz distribution audit then replayed every fixed stream/raster
seed and step. It found no additional unreachable branch, but aggregate
nonzero assertions could not detect the loss of a particular backend/status or
mode/color pair. The stream suite now asserts all seven operation totals and
the complete five-writer-by-three-status matrix, including exact totals of 22
successes, 47 failures, 26 invalid-status fallbacks, 10 successful readers,
and 17 failed readers. Public raster fuzz pins callback-state, outcome/color,
and manual-acquire/color profiles. The raster state and manual oracles pin all
operation/color and mode/color cells plus selector-derived paint and manual
acquire/release totals. Backend-controlled callback invocation multiplicity
remains checked relationally because Cairo does not promise a fixed call count.
The focused stream, public raster, and raster oracle packages pass 2/2, 16/16,
and 9/9 respectively under host ASan/UBSan and both exact-Cairo Linux
ASan/LSan/UBSan lanes, without changing the 838-test inventory.

The stream attachment-failure slice adds a shared producer-before-state cleanup
helper for all three Surface backends and ScriptDevice. Ten static checker tests
pin every transfer and failure branch, including nine negative mutations. A
distinct two-test oracle dynamically simulates user-data attachment failure on
real producers; PDF/PS/SVG prove destroy-time writes cannot outlive the closure,
and ScriptDevice state release is checked without assuming a callback count.
The package passes normally and under ASan/LSan/UBSan on both exact Cairo lanes.

The `RawTextToGlyphs` finalizer-fallback slice upgrades the external-owner
ledger to schema v2 and gives this temporary native result its own lifetime
package. Its 1000 iterations have an exact 334/333/333 distribution across
clustered success, glyph-only success, and invalid-font results. The helper
never calls `text_to_glyphs_release_raw`; `forbidden_stress_anchors` makes that
absence executable, and two new negative checker regressions reject an
explicit release plus malformed anchor arrays.

GitHub Actions run `29678818105` passed macOS native and failed both Ubuntu
jobs. Ubuntu native reproduced Cairo 1.18.0's upstream malformed-PNG
error-surface bug: that release reports `NoMemory`, while Cairo 1.18.2+ reports
`PngError`. Path and stream tests now assert those exact version contracts.
Ubuntu sanitizer observed the known recording-snapshot leak as two 576-byte
allocations on x86_64; the classifier accepts that size only under the existing
two-direct-leak, stack, and total-byte constraints. The first-class
`ubuntu-24.04-system` lane then exercised the stripped PDF/JBIG2 path, whose
package run used exactly 10 allocations/2284 bytes at the PDF stream constructor
and 4/68 at Surface finish. That lane now passes 225/225 script tests, 841/841
native tests, 63/63 docs, all three 6/6 consumer modes, the unmodified 668-member
host archive, and every discovered package under ASan/LSan/UBSan on both local
arm64 and Rosetta-backed x86_64. Its arm64 stripped recording path uses exactly
16 suppressions/9344 bytes at `cairo_restore`; x86_64 uses exactly 16/9216,
matching 16 x 576-byte allocations. The CI workflow
also uses `actions/checkout@v6`, and a negative workflow mutation rejects a
return to the Node-20-based v4 action.

Exact Linux Cairo 1.15.10 and 1.18.4 each pass 841/841 native tests, 224/224
script tests, 63/63 executable docs, the source, extracted, and unmodified
host-archive consumer modes at 6/6, publication
archive integrity for 667 members, and every discovered package under
ASan/LSan/UBSan. The pure-C recording-snapshot probe still limits the vector
package to 16 suppressions/7424 bytes on Cairo 1.15.10 and 16/9344 on Cairo
1.18.4. The pure-C PDF/JBIG2 probe limits the PDF package to two rows totaling
9 allocations/988 bytes on 1.15.10 and 14/2352 on 1.18.4. Every other package
is unsuppressed. Documentation reaches 579 of 579 declarations with zero debt,
so the Documentation inventory row is Done. Public signatures and the
349-local-plus-two-direct-symbol production FFI boundary remain unchanged.

The release-version replay found that Mooncakes already holds `0.1.0`, while
that preview lacks the dependency pre-build/link contract now required for
downstream use and has a different generated public interface. The unreleased
line is therefore `0.2.0`. Twenty-three publication-validator tests now include
six negative release-tooling cases: missing changelog, changelog version
drift, install-command version drift, and missing dependency pre-build wiring.
The dry-run checker itself must also be present and source-identical. Six parser
tests pin the fixed non-uploading argv, one complete exact 202/no-change line,
extracted-check and identity semantics, and status-0/status-255 error-banner
consistency. The packaged name/version is parsed from the archive itself, not
duplicated in the checker, and both checker and parser tests must be
source-identical in the package. The resulting 667-member zip passes extraction
and native checking through Moon's official publish dry-run path; an actual
registry upload remains forbidden until the hosted release-commit evidence
closes the Tests row.

The all-member publication follow-up replaces the critical-file identity
whitelist with an exact checkout-set contract. Missing C/support files,
altered MoonBit source, and unverified extra file or directory members now fail
before downstream compilation; hidden VCS/CI/dependency roots, `_build`,
`integration`, and Python bytecode caches remain deliberately excluded. The
archive checker, its 124-line fixture module, and 474-line behavior module are
explicit required members. All 24 publication regressions and 225 script tests
pass, and the current package contains 668 byte-identical members across 454
source-size-checked files without changing public API or production FFI.

The sanitizer runner is split by responsibility: `run.py` owns CLI and
per-package orchestration, `toolchain.py` owns compiler discovery, runtime
isolation, wrappers, and preflights, and `leak_probes.py` owns strict leak
classification and suppression accounting. The reliability checker requires
critical markers in those exact modules. Together they compile every native
package with
`-fsanitize=address,undefined` and sets fail-fast UBSan options with stack
traces. Its signed-overflow preflight proves the undefined-behavior runtime is
active before MoonBit tests begin. Linux function sanitization cannot compare
Clang's call-site metadata with MoonBit-native `FuncRef` target metadata, so
exact C callback typedefs alone produce false incompatible-function reports.
Only four non-inlined dispatch helpers disable the `function` subcheck: stream
read/write and raster-source acquire/release. A static regression requires
exactly these four annotations and verifies the runner does not globally add
`-fno-sanitize=function`; every other UBSan category remains enabled.

Remaining reliability work is now narrower and should be tracked as evidence,
not as an unstructured checklist:

- Add broader release-platform coverage and finalizer fuzz beyond the
  branch-reachability-asserted deterministic raster-source owner-count,
  state-machine, manual
  get-callback, exhaustive transition-matrix, callback allocation,
  retained-owner, stream retention, and backend stream multi-seed callback and
  finalizer graph fuzz tests, plus the finalizer-only raw text-result stress
  path. This is global release evidence rather than an unbounded
  `RasterSourcePattern` API requirement.
- Keep the CI workflow green and expand it as the supported release platform
  matrix grows; generated-interface review, differential oracles, and sanitizer
  gates should be required before release. Preserve the ref-scoped concurrency
  group, stale-run cancellation, and 60-minute native/sanitizer ceilings so
  superseded work cannot consume unbounded hosted capacity.
- Keep Linux as the authoritative LSan/UBSan platform. The shipped macOS job
  runs the ordinary native gate; optional local macOS runs may enable
  ASan/UBSan. Release leak and undefined-behavior evidence comes from the
  pinned Linux lanes where both runtimes are preflighted instead of inferred.
- Close the remaining `Partial` Tests row in `API_INVENTORY.md` by obtaining
  shipped release-platform evidence without weakening unsupported scope into a
  vague success claim.

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
