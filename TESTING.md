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

1. API shape: the public API appears in `pkg.generated.mbti`, has no raw
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

## Test Tiers

Run these tiers in order while developing a slice.

### Tier 0: Interface And Build Checks

```sh
moon -C cairoon check --target native
moon -C cairoon info --target native
```

Review `pkg.generated.mbti` after `moon info`. Public additions, `raise`
annotations, and enum constructors must match the intended API.

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
  --pkg moon.pkg
```

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
- PDF/SVG/PS: create, finish, metadata, page behavior, and normalized output.
- Recording/script/tee: only mark Done when the backend is available and tests
  run in CI.
- Platform APIs such as Win32/XCB/Xlib: require a platform-specific test job or
  an explicit product-scope Decision.

### Tier 5: Release Matrix

A release candidate must pass on all supported platforms:

- `moon check`
- `moon test`
- ASan/LSan native test run
- Differential pycairo/C oracle suite
- API inventory audit
- generated `pkg.generated.mbti` review

## Current Status

The current cairoon slice is not a full migration. It has native package setup,
pycairo-style C glue split into private shared declarations plus per-family
stub files, opaque external-object wrappers for `Surface`,
`MappedImageSurface`, `Context`, `Path`, `Pattern`, `FontOptions`, `FontFace`,
`ScaledFont`, and `Region`, pure value types, many portable enums, expanded
Context path, painting/page, target/source borrowed returns, clip, matrix,
drawing-state, hit-testing/extents APIs, typed Path segment iteration and
stringification, PNG filename load/save and buffer-backed creation for image
surfaces, portable Surface base helpers such as similar-surface creation,
content/type queries, dirty markers, device offset/scale, fallback resolution,
show-text-glyphs support checks, and mapped image surface mapping/unmapping,
surface-pattern borrowed surface returns, FontOptions state/accessor APIs,
FontFace/ToyFontFace APIs, ScaledFont basics, and initial tests. Region now
covers empty, single-rectangle, and
multi-rectangle construction plus predicates and boolean operations.

Verified on 2026-07-02:

- `moon -C cairoon check --target native`: passed.
- `moon -C cairoon test --target native -v`: 122 tests passed.
- ASan/LSan via `run-asan.py`: ran the 108-test native suite after the PNG
  filename API slice, the 113-test native suite after the
  `Surface::image_for_data` slice, and the 114-test native suite after the
  cairo-surface user-data lifetime fix, and the 117-test native suite after the
  portable Surface base API slice, and the 122-test native suite after the
  mapped image surface slice; these runs failed in LeakSanitizer. The most
  recent leak report is rooted in `cairo_toy_font_face_create`,
  `cairo_select_font_face`, macOS
  FontRegistry/CoreGraphics frames, and scaled-font Quartz/CoreText paths such
  as `cairo_scaled_font_create`, `CGFontCopyURL`, and `CTFontCreateWithGraphicsFont`;
  no AddressSanitizer invalid-access report appeared before LSan failed.
  Summary: `91797 byte(s) leaked in 1305 allocation(s)`.

The missing reliability pieces are substantial: automated differential tests,
the open macOS toy-font/scaled-font LSan failure, finalizer stress tests, CI
wiring, vector-output normalization, and the remaining API families from
`API_INVENTORY.md`.

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
