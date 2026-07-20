# Migration Audit History, Part 8

Historical snapshot of `AUDIT.md` lines 3784-3931 before the 2026-07-20 documentation split.
It is retained for traceability; a part may continue a long original list item at a sentence boundary.


The executable backend example previously sent `%%Title` after entering Setup;
it now emits the title in Header, then transitions through Setup and PageSetup.
The pycairo-derived out-of-order transition fixture now locates both custom
comments between generated `%%BeginPageSetup`/`%%EndPageSetup` markers, proving
Cairo's non-rewinding behavior. A native range guard rejects negative level
strings before Cairo can index its static table. Focused tests also cover
invalid raw level strings at `-1` and `99`, retained Level 2 output after the
exact `99` restriction no-op, ordinary/EPS state and `EPSF` output, 255/256 byte
DSC boundaries, missing `%`, and embedded NUL. The first exact matrix correctly
rejected an accidental test anchor rename; restoring the stable parity name
made the full ledger pass.

Exact Linux Cairo 1.15.10 and 1.18.4 each pass 8/8 PS tests, 63/63 executable
docs, 798/798 native tests, 90/90 script tests, both 1/1 consumer paths, all 602
publication members, and every package under ASan/LSan. The only suppression is
the independently reproduced recording-snapshot leak: 16 allocations/7424
bytes on 1.15.10 and 16 allocations/9344 bytes on 1.18.4. Documentation reaches
554 of 579 with 25 exact debt entries. No public API or production FFI symbol
changed.

## Pattern Raster Callback Package Audit

The 2026-07-18 Pattern callback ownership slice removes the final public-root
FFI file. `src/internal/pattern/ffi_raster_callbacks.mbt` owns the seven exact
C symbols beside the existing core and mesh FFI families, and
`raster_callbacks.mbt` owns native anchoring, four-state registration,
introspection, and raw getter dispatch. `#owned` remains on closures transferred
to C state, while patterns, dispatch `FuncRef`s, and status refs remain
borrowed. The C trampoline and its retain/decref protocol are unchanged.

`pattern_raster_source.mbt` now converts public acquire/release callbacks at the
facade boundary: target and returned surfaces wrap or unwrap `RawSurface`, and
`RectangleInt` becomes four integer fields. The package-local test directly
invokes retrieved raw callbacks and checks argument identity, extents,
acquire-only, release-only, clear, and subtype mismatch. Existing external
black-box, owner-count, exhaustive transition, manual callback, fuzz, and
1000-iteration lifetime tests pass unchanged. Exact Cairo 1.15.10 and 1.18.4
lanes pass all 828 native tests and every package under ASan/LSan/UBSan; the
Pattern and raster packages require no suppression.

## Deterministic Callback Fuzz Distribution Audit

The 2026-07-18 callback-fuzz replay found no currently unreachable stream or
raster selector combination, but it did find that four suites could lose an
individual backend/status or mode/color case while aggregate `> 0` assertions
continued to pass. Selector-derived coverage is now an exact contract; callback
invocation multiplicity controlled by linked Cairo remains a semantic
inequality unless Cairo documents a stable count.

The four-seed stream suite pins operation counts
`10/20/12/11/16/10/17`. For PDF, PS, SVG, PNG-write, and ScriptDevice rows, the
flattened Success/WriteError/LastStatus matrix is
`3/4/3, 8/4/8, 2/4/6, 3/5/3, 6/4/6`; this yields exactly 22 writer successes,
47 failures, 26 invalid-status fallbacks, 10 successful PNG readers, and 17
short-read failures. The public 25-step raster suite pins release-only/clear
installation counts `5/4`, failure/dynamic/static outcomes `5/5/15`, their
three-color matrix `2/1/2, 2/1/2, 5/6/4`, and manual-acquire colors `2/2/1`.

The four-seed raster state oracle pins seven operation totals
`45/41/36/33/54/34/45` and all 21 operation/color cells. The three-seed manual
oracle pins eight mode totals `21/26/14/17/18/13/19/16`, all 24 mode/color
cells, manual-acquire mode totals `0/0/0/6/4/1/7/7`, and exact semantic
outcomes: 14 failed paints, 83 successful paints, 25 manual acquires, 21 manual
releases, 4 acquire-only calls, and 26 release-only calls. These changes touch
only tests and reliability specifications; production code, public signatures,
the 349-local-plus-two-direct FFI boundary, and the 838-test inventory remain
unchanged. The affected packages pass host ASan/UBSan and both exact-Cairo
Linux lanes under ASan/LSan/UBSan; the full lanes remain at 183 script checks,
838 native tests, 63 executable-doc tests, and 634 publication members.

## Downstream Consumer Evidence

The local release gate includes a separately named MoonBit consumer module
under `integration/consumer`. Its versioned dependency is resolved through
`integration/moon.work`, while its test package imports only
`CAIMEOX/cairoon` and carries no Cairo compiler or linker flags. MoonBit runs
the trusted module pre-build script for the dependency, then propagates the
native package's resolved linker flags to the consumer executable. Six split
tests cover deterministic image/path/pattern drawing, scoped mapped-image
ownership, Matrix/Region values, typed status errors, PNG callback round-trip,
and finished PDF stream output. The source package passes 6/6.

`moon package --list` confirms that the integration fixture is absent from the
release archive. The gate integrity-checks that exact zip, extracts it into a
fresh workspace, and reruns the consumer against the packaged module. The two
exact Linux Cairo lanes additionally consume the same host-generated zip
without rewriting its manifests or running the repository constants updater.
This catches producer-specific include and library paths that source-copy lane
setup would otherwise hide. The current 668-member archive is an exact
byte-for-byte image of the publishable checkout set and also contains the
declared dual-license notice, complete license texts, and version-matched
changelog/install metadata; source, freshly
extracted, and unmodified cross-host archive modes each pass 6/6 against Cairo
1.15.10, Ubuntu system Cairo 1.18.0, and Cairo 1.18.4.

## Known Gaps

- Mooncakes `0.1.0` is an historical preview and is not the current release
  candidate: its archive lacks dependency pre-build/link propagation. Version
  `0.2.0` is prepared and passes local package validation but must not be
  uploaded until the hosted release-commit evidence below is green.
- Current tests are strong enough for the `Done` inventory rows when
  `./scripts/verify.sh` passes on the target platform, but they are not enough
  for a full pycairo migration claim. The public documentation ledger is
  already complete at 579/579 declarations with zero debt. Full-product status
  still requires the release-evidence `Partial` row to gain passing CI coverage
  for the Ubuntu and macOS native jobs plus the Ubuntu package-isolated
  ASan/LSan/UBSan job, or for genuinely unsupported scope to become an explicit
  `Decision`.
- Cairo 1.18's finite portable tag-attribute contract is closed by Scene 66:
  all 10 official Link/Dest/content/content-reference dimensions have
  MoonBit and direct-C evidence, invalid forms map to `TagError`, and
  normalized PDF/PS/SVG file and stream outputs have stable positive or
  negative markers. Additional scene combinations are optional regression
  depth, not an open migration requirement.
- Broader release-platform coverage and finalizer fuzz remain global release
  evidence beyond the current deterministic owner-count, state-machine,
  callback, retained-owner, stream-retention, and finalizer-graph tests.
- `Surface::copy_data` still copies Cairo image data into MoonBit `Bytes`;
  `Surface::get_data` is the mutable image-surface view and intentionally
  retains the surface wrapper instead of exposing a raw pointer.
- Native configuration depends on MoonBit's explicitly experimental pre-build
  protocol and executes trusted Python from the dependency. Its output is
  narrow and tested, but the protocol may change before MoonBit stabilizes it;
  cairoon therefore cannot promise build-system compatibility before `1.0`.
  Consumers also need Python 3 and a `pkg-config`-discoverable Cairo install.
- `CAIRO_VERSION*` and `HAS_*` are MoonBit `pub const` values generated in the
  release source tree. An archive can now compile and link unchanged on another
  host, but those uppercase constants remain the producer's header snapshot if
  that host uses different Cairo headers. Use `cairo_version()` and
  `cairo_version_string()` for runtime decisions. Making uppercase constants
  consumer-generated would require an undocumented source-mutating pre-build
  step or a future MoonBit generated-source facility, so this remains an
  explicit pre-`1.0` limitation rather than hidden release evidence.
- The CI workflow runs native verify on Ubuntu and macOS plus an Ubuntu
  package-isolated ASan/LSan/UBSan job. It no longer disables leak detection or
  repeats the ordinary native gate in the sanitizer job. Runs are grouped by
  workflow and Git ref, newer work cancels only a stale run for that same ref,
  and both jobs have a 60-minute ceiling. The local workflow checker rejects
  capacity-policy drift as well as failure masking. Release evidence still
  requires those jobs to pass for the release commit; this checkout was
  deliberately not pushed merely to trigger CI.
- Linux is the authoritative LSan/UBSan platform. macOS ASan/UBSan is an
  optional local gate; the shipped macOS CI job intentionally runs ordinary
  native verify with duplicate sanitizer work disabled. Exact leak and
  undefined-behavior evidence comes from the pinned Linux lanes and Ubuntu
  sanitizer job, whose intentional preflights prove both runtimes are active.
