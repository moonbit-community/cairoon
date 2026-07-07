# cairoon Project Layout Plan

This document is the project-management contract for moving cairoon from the
current single-package migration workspace into a maintained MoonBit package
tree. It is intentionally operational: each rule is either enforced now by
`scripts/check-project-layout.py` or names the verification gate required before
the next layout slice can be committed.

## Current Layout

As of the black-box, oracle, and oracle-native extraction slices, the
repository root is project management space and contains no grandfathered
source-like files. The current public MoonBit package lives in `src/`;
external black-box tests live in `src/tests/*`, public C stubs live in the
`src/native/` native-stub package, and test-only C oracles live in
`src/tests/oracle/native/`. The public package root is now frozen by
`scripts/public-package-root-allowlist.txt`: the existing direct `src/` files
are grandfathered migration debt, and new implementation or test files must go
into a MoonBit subpackage unless the layout plan is deliberately revised in the
same commit.
The root and public-package-root allowlists are exact ledgers, not open-ended
exemptions: when a file moves out of the repository root or direct `src/`, the
same commit must remove its allowlist entry so an identically named file cannot
silently return later.

- 69 `.mbt` implementation files directly in `src/`.
- 1 `.mbt` implementation file and 1 package-local `*_test.mbt` file in
  `src/core/constants/`.
- 1 `.mbt` implementation file and 1 package-local `*_test.mbt` file in
  `src/core/glyph/`.
- 1 `.mbt` implementation file and 1 package-local `*_test.mbt` file in
  `src/internal/cstring/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/version/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/format/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/pdf/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/ps/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/status/`.
- 1 `.mbt` implementation file and 1 package-local `*_test.mbt` file in
  `src/internal/stream/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/svg/`.
- 1 native-package MoonBit anchor file in `src/native/`.
- 120 `*_test.mbt` files under `src/tests/`, including black-box and oracle
  packages.
- 0 white-box `*_wbtest.mbt` files in `src/`.
- 34 public C implementation files owned by `src/native/moon.pkg`.
- 1 public C header in `src/native/`.
- 37 oracle C implementation files in `src/tests/oracle/native/`.
- 2 oracle C headers in `src/tests/oracle/native/`.
- 9 executable `.mbt.md` docs in `src/`.

This is still migration debt, but the repository root and the public package
root no longer carry standalone white-box test files, and public C glue is no
longer compiled by `src/moon.pkg`. The remaining work is to split the large
`src/` MoonBit implementation package into public, support, oracle, and family
packages in reviewed slices.

## Target Shape

The target repository separates project management, public MoonBit code,
private native glue, black-box tests, white-box oracle tests, and docs:

```text
cairoon/
  README.md
  AGENTS.md
  PROJECT_LAYOUT.md
  API_INVENTORY.md
  AUDIT.md
  TESTING.md
  PACKAGING.md
  PORTING_FROM_PYCAIRO.md
  moon.mod
  scripts/
  src/
    moon.pkg
    README.mbt.md
    pkg.generated.mbti
    core/
      constants/
        moon.pkg
        constants.mbt
        constants_test.mbt
      glyph/
        moon.pkg
        glyph.mbt
        glyph_test.mbt
    internal/
      cstring/
        moon.pkg
        cstring.mbt
        cstring_test.mbt
      format/
        moon.pkg
        ffi.mbt
        format.mbt
        format_test.mbt
      pdf/
        moon.pkg
        ffi.mbt
        pdf.mbt
        pdf_test.mbt
      ps/
        moon.pkg
        ffi.mbt
        ps.mbt
        ps_test.mbt
      status/
        moon.pkg
        ffi.mbt
        status.mbt
        status_test.mbt
      stream/
        moon.pkg
        stream.mbt
        stream_test.mbt
      svg/
        moon.pkg
        ffi.mbt
        svg.mbt
        svg_test.mbt
      version/
        moon.pkg
        ffi.mbt
        version.mbt
        version_test.mbt
    native/
      moon.pkg
      native_anchor.mbt
      pkg.generated.mbti
      cairoon_private.h
      cairoon_objects.c
      cairoon_surface.c
      ...
    oracle/
      moon.pkg
    tests/
      api/
        moon.pkg
      status/
        moon.pkg
      value/
        moon.pkg
      matrix/
        moon.pkg
      surface/
        base/
          moon.pkg
        mime/
          moon.pkg
        pycairo/
          moon.pkg
        subsurface/
          moon.pkg
      image/
        moon.pkg
      context/
        moon.pkg
        clip/
          moon.pkg
        extents/
          moon.pkg
        glyph/
          moon.pkg
        group/
          moon.pkg
        matrix/
          moon.pkg
        paint/
          moon.pkg
        path/
          moon.pkg
        state/
          moon.pkg
        tag/
          moon.pkg
        text/
          moon.pkg
        text_to_glyphs/
          moon.pkg
      pattern/
        moon.pkg
        gradient/
          moon.pkg
        raster/
          moon.pkg
      font/
        face/
          moon.pkg
        options/
          moon.pkg
        pycairo/
          moon.pkg
        scaled/
          moon.pkg
      path/
        moon.pkg
      region/
        moon.pkg
      backend/
        pdf/
          moon.pkg
        ps/
          moon.pkg
        recording/
          moon.pkg
        svg/
          moon.pkg
        tee/
          moon.pkg
      lifetime/
        moon.pkg
      oracle/
        native/
          moon.pkg
          cairoon_test_private.h
          cairoon_test_common.c
        vector_backend/
          moon.pkg
  docs/
    reference/
```

The `src/moon.pkg` package keeps the published import path
`CAIMEOX/cairoon`. The move from root to `src/` must be paired with
`moon.mod source = "src"` so downstream imports do not change.
Because `source = "src"` limits MoonBit's package search path, executable
MoonBit test packages live under `src/tests/`, not repository-root `tests/`.

## Package Roles

Use these package roles unless a later proof-of-concept demonstrates a better
MoonBit package shape without weakening the public interface.

| Role | Intended location | Interface rule |
|---|---|---|
| Public package | `src/` | Owns the stable `CAIMEOX/cairoon` interface and public external object types until a facade proof proves otherwise. |
| Pure support packages | `src/core/` | May hold pure values/helpers only after their public names can be preserved or intentionally re-exported. `src/core/glyph` is the first accepted seam: the public package exposes `pub type Glyph = @glyph.Glyph`, owns `@glyph.field_arrays` for glyph-array marshaling preparation, and tests prove `@cairoon.Glyph::new`, field access, dot-method syntax, and glyph-array FFI paths still work through the facade. `src/core/constants` is the second accepted seam: it owns generated primitive Cairo constants, while the facade preserves `@cairoon.CAIRO_VERSION`, `@cairoon.HAS_*`, `@cairoon.MIME_TYPE_*`, tag constants, `PDF_OUTLINE_ROOT`, and `COLOR_PALETTE_DEFAULT` through `pub const` aliases. |
| Internal implementation packages | `src/internal/<family>/` | May hold native-gated extern declarations and implementation helpers for small public facade functions when the public `CAIMEOX/cairoon` API remains unchanged. `src/internal/version` owns the raw version externs and UTF-8 decoding while `src/version.mbt` remains a thin facade. `src/internal/format` owns the raw `cairo_format_stride_for_width` extern while `src/format.mbt` keeps the public `Format` enum, constructors, and methods. `src/internal/status` owns the raw status-message extern while `src/status.mbt` keeps the public `Status` enum and methods. `src/internal/pdf` owns raw PDF version query/string helpers while `src/pdf_surface.mbt` keeps `PDFVersion` constructors and PDF surface wrappers. `src/internal/ps` owns raw PostScript level query/string helpers while `src/ps_surface.mbt` keeps `PSLevel` constructors and PS surface wrappers. `src/internal/svg` owns raw SVG version query/string helpers while `src/svg_surface.mbt` keeps `SVGVersion` constructors and SVG surface wrappers. `src/internal/stream` owns pure callback chunk-copy helpers used by stream-writing facade wrappers. `src/internal/cstring` owns pure embedded-NUL scanning used by facade string validators. Any package that imports `CAIMEOX/cairoon/native` must carry Cairo `cc-link-flags` so package-local tests link independently. |
| Native stubs | `src/native/` | Owns public C glue compilation through `src/native/moon.pkg`. Every `.c` file beside that package file must be listed by bare filename in its `native-stub` list; `src/moon.pkg` imports `CAIMEOX/cairoon/native` and must not own `native-stub` entries. Headers in `src/native/` are private to those stubs. |
| Black-box tests | `src/tests/<family>/` | Import `CAIMEOX/cairoon`; assert only public behavior. Any package that imports cairoon must carry Cairo `cc-link-flags`, because native link flags are not propagated to external test executables. |
| White-box oracles | `src/tests/oracle/<family>/` plus shared C support in `src/tests/oracle/native/` | Import `CAIMEOX/cairoon` for the public API and declare test-only direct-C oracle externs locally; public binding wrappers must never import oracle packages. Test-only C symbols are provided by the oracle-native support package, not `src/moon.pkg`. |
| Documentation | `docs/` and public package `.mbt.md` files | Narrative docs live outside source packages; executable reference docs stay with the package they test. |

Do not split a family across packages until the type names, method call syntax,
generated `.mbti`, and `moon test --target native` behavior are proven in a
small package-seam commit.

Do not add new source-like files directly under `src/`. The direct public
package files listed in `scripts/public-package-root-allowlist.txt` are
grandfathered only so the migration can proceed in reviewable slices. New
MoonBit implementation belongs in `src/core/<family>/`,
`src/internal/<family>/`, `src/<family-package>/`, or another explicit package
role; new tests belong under `src/tests/<family>/`; new public C glue belongs
under `src/native/`; new oracle C glue belongs under
`src/tests/oracle/native/`.

## Migration Order

Follow this order. Each step gets its own commit and must pass
`./scripts/verify.sh`.

1. **Root freeze**: completed. The layout gate rejected new root-level
   `.mbt`, `.mbt.md`, `.mbti`, `.c`, or `.h` files during the transition.
2. **Source-root extraction**: completed. The current MoonBit package files
   live in `src/`, `moon.mod` sets `source = "src"`, scripts locate the
   package root explicitly, and `CAIMEOX/cairoon` remains the public package.
3. **Black-box test extraction**: started. Move pure `*_test.mbt` files into
   `src/tests/<family>/` packages that import `CAIMEOX/cairoon`; keep test names
   and behavioral assertions unchanged.
4. **Native-stub package extraction**: completed. Public C stubs live under
   `src/native/`, are compiled by `src/native/moon.pkg`, and are linked into
   the public facade through the `CAIMEOX/cairoon/native` package import.
5. **White-box oracle extraction**: completed for MoonBit tests and C oracle
   support. Direct-C oracle tests now live under `src/tests/oracle/*`, and
   test-only C oracle helpers live under `src/tests/oracle/native` as a
   separate native-stub package imported only by oracle tests. Public binding C
   files must not depend on oracle packages.
6. **Family package probes**: started. Primitive Cairo constants now live in
   `src/core/constants`, while the public facade preserves the pycairo-style
   top-level constant names with `pub const` aliases and
   `scripts/configure-link-flags.sh` updates the child package source of truth.
   `Glyph` now lives in
   `src/core/glyph`, while the public facade exposes it with a type alias. This
   proves a pure value type can move into a support package while preserving
   external constructor, field, and method syntax; the glyph support package now
   also owns the field-array preparation used by Context and ScaledFont FFI
   wrappers. Types whose methods raise `CairoError` still require an
   error/status seam proof before they move, because child packages must not
   import the public facade. Direct `Status`/`CairoError` facade extraction is
   currently blocked by MoonBit constructor re-export semantics: `pub type`
   aliases do not expose enum variants or suberror constructors as
   `@cairoon.<Constructor>`. A facade alias also cannot grow extra facade-local
   methods for the child type, so a type should move only when its full public
   method set can move with it or when a wrapper/seam design has been proven.
   `src/internal/version` is the first implementation-package seam: the raw
   version externs and UTF-8 decoding moved out of the public package, while
   `@cairoon.cairo_version()` and `@cairoon.cairo_version_string()` remain
   facade functions with unchanged public signatures. `src/internal/format`
   proves a narrower enum-adjacent seam: the raw stride extern moved out, but
   public `Format` and its constructors stay in the facade because constructor
   syntax such as `@cairoon.Argb32` is part of the public API.
   `src/internal/status` applies the same enum-adjacent rule to
   `Status::message()`: the raw Cairo status-string extern moved out, but the
   public `Status` enum, constructors, and `CairoError` suberror family stay in
   the facade. `src/internal/pdf` applies the backend-helper variant of this
   rule to PDF version queries and strings: raw `Int` helpers moved out, while
   public `PDFVersion` constructors and all `Surface::pdf*` object wrappers
   stay in the facade. `src/internal/ps` applies the same backend-helper
   pattern to PostScript level queries and strings: raw `Int` helpers moved out,
   while public `PSLevel` constructors and all `Surface::ps*` object wrappers
   stay in the facade. `src/internal/svg` applies the same backend-helper
   pattern to SVG version queries and strings: raw `Int` helpers moved out,
   while public `SVGVersion` constructors and all `Surface::svg*` object
   wrappers stay in the facade. `src/internal/stream` applies the pure-helper
   variant of this rule to stream callback chunk copying: the public PDF, PS,
   SVG, PNG, and script-device stream wrappers remain in the facade while the
   callback byte-copy helper lives in an internal package with package-local
   tests. `src/internal/cstring` applies the same pure-helper rule to embedded
   NUL scanning: string/path validators and the `InvalidString` error mapping
   remain in the facade while byte scanning lives in an internal package with
   package-local tests.
7. **Family package migration**: move one Cairo family per commit. C files,
   raw externs, and wrappers move together only when the public package seam is
   proven.

## Root Freeze Rules

The repository root is now project-management space, not a place for new
binding implementation.

- New MoonBit implementation files go into the package directory selected by
  the current migration step, not the repository root or the direct `src/`
  public package root.
- New black-box tests go under `src/tests/<family>/` once the test extraction
  step starts. Until then, extend an existing `src/*_test.mbt` file instead of
  creating a new root test file.
- New public C stubs go under `src/native/` and must be listed in
  `src/native/moon.pkg` `native-stub` as bare filenames. Future family
  packages may keep C stubs beside their own `moon.pkg` only after a
  package-seam proof.
- Any new root-level `.mbt`, `.mbt.md`, `.mbti`, `.c`, or `.h` file must fail
  the layout gate unless the project layout plan is intentionally revised in
  the same commit.
- Any new direct `src/` `.mbt`, `.mbt.md`, `.mbti`, `.c`, `.h`, or `moon.pkg`
  file must fail the layout gate unless it is an intentional public package
  root exception documented by this layout plan.
- The root and direct-`src/` allowlists must exactly match the files they
  grandfather. Moving a file into a child package must remove its allowlist
  entry in the same commit; stale allowlist names are layout regressions.

## Verification

`./scripts/verify.sh` must run `python3 ./scripts/check-project-layout.py`
before MoonBit compilation. The layout check proves:

- no source-like files have appeared in the repository root;
- no new source-like files have appeared directly under `src/`, so the public
  package root cannot grow while family packages are being extracted;
- the root and public-package-root allowlists are exact ledgers with no stale
  names left behind after a migration slice moves files into child packages;
- `scripts/check-source-size-budget.py` keeps source, test, script, native
  glue, and executable-doc files under the 900-line review budget so large
  oracles and glue families are split deliberately instead of growing in place;
- `src/moon.pkg`, `src/pkg.generated.mbti`, and `moon.mod source = "src"`
  are present;
- repository-root `tests/` does not contain MoonBit packages or source-like
  files, because it is outside the package search path;
- every non-root `src/**/moon.pkg` has an adjacent `pkg.generated.mbti`, so
  package seams are reviewed through `moon info --target native`;
- every child package that imports `CAIMEOX/cairoon` or
  `CAIMEOX/cairoon/native` carries Cairo `cc-link-flags`, so both black-box
  tests and internal native-gated implementation packages link independently;
- the `Current Layout` file counts in this document match the actual package
  tree, so project-management evidence cannot silently drift as files are
  moved or new test/oracle slices are added;
- `src/moon.pkg` imports `CAIMEOX/cairoon/native` and owns no `native-stub`
  entries;
- every `.c` file under `src/native/` is referenced by `src/native/moon.pkg`
  `native-stub`, every `native-stub` entry is a bare filename beside its
  owning `moon.pkg`, headers stay with their owning native-stub package, oracle
  C source/header files live beside `src/tests/oracle/native/moon.pkg`, and any
  future nested C source/header files live beside the `moon.pkg` that owns
  them;
- `PROJECT_LAYOUT.md`, `scripts/root-layout-allowlist.txt`, and
  `scripts/public-package-root-allowlist.txt` exist.

The layout gate does not prove the package split is complete. It proves only
that the root has become project-management space and that public C
source/header files are isolated in the `src/native` native-stub package while
oracle C source/header files are isolated in `src/tests/oracle/native`, both
with explicit `native-stub` ownership. It also proves the public package root is
not allowed to absorb new migration work, and that internal implementation
packages are first-class support packages in the verification gate. Completion
is proved only when every package role above has a passing targeted
verification entry in `AUDIT.md`.
