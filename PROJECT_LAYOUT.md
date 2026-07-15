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
`src/native/` native-stub package, test-only C oracles live in
`src/tests/oracle/native/`, and executable family reference docs live in the
external `src/docs/` package. An independently named downstream module lives
under `integration/consumer`; `integration/moon.work` resolves the local
cairoon dependency without folding that fixture into the published module.
The public package root is now frozen by
`scripts/public-package-root-allowlist.txt`: the existing direct `src/` files
are grandfathered migration debt, and new implementation or test files must go
into a MoonBit subpackage unless the layout plan is deliberately revised in the
same commit.
The root and public-package-root allowlists are exact ledgers, not open-ended
exemptions: when a file moves out of the repository root or direct `src/`, the
same commit must remove its allowlist entry so an identically named file cannot
silently return later.

- 61 `.mbt` implementation files directly in `src/`.
- 1 `.mbt` implementation file and 1 package-local `*_test.mbt` file in
  `src/core/constants/`.
- 1 `.mbt` implementation file and 1 package-local `*_test.mbt` file in
  `src/core/glyph/`.
- 1 `.mbt` implementation file and 1 package-local `*_test.mbt` file in
  `src/internal/cstring/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/device/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/font_face/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/font_options/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/version/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/format/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/pdf/`.
- 2 `.mbt` implementation files and 0 package-local `*_test.mbt` files in
  `src/internal/path/`. Path is producer-only at this layer, so real Context
  and mesh Pattern black-box tests replace a test-only raw constructor.
- 5 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/pattern/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/ps/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/region/`.
- 4 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/scaled_font/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/status/`.
- 1 `.mbt` implementation file and 1 package-local `*_test.mbt` file in
  `src/internal/stream/`.
- 2 `.mbt` implementation files and 1 package-local `*_test.mbt` file in
  `src/internal/svg/`.
- 1 `.mbt` prelude file and 11 executable `.mbt.md` docs in `src/docs/`.
- 1 native-package MoonBit anchor file in `src/native/`.
- 132 `*_test.mbt` files under `src/tests/`, including black-box and oracle
  packages.
- 0 white-box `*_wbtest.mbt` files in `src/`.
- 34 public C implementation files owned by `src/native/moon.pkg`.
- 1 public C header in `src/native/`.
- 48 oracle C implementation files in `src/tests/oracle/native/`.
- 2 oracle C headers in `src/tests/oracle/native/`.
- 1 executable `.mbt.md` doc in `src/`.

This is still migration debt, but the repository root and the public package
root no longer carry standalone white-box test files or family reference docs,
and public C glue is no longer compiled by `src/moon.pkg`. The remaining work
is to split the large `src/` MoonBit implementation package into public,
support, oracle, and family packages in reviewed slices.

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
  integration/
    moon.work
    consumer/
      moon.mod
      src/
        smoke/
          moon.pkg
          consumer_smoke_test.mbt
  scripts/
    matrix/
      Dockerfile
      run-lane.sh
    parity/
      api.json
      cmodule.json
      context.json
      device.json
      enums.json
      error.json
      font.json
      fspaths.json
      glyph.json
      matrix.json
      path.json
      pattern.json
      rectangle.json
      region.json
      surface.json
      surface_numpy.json
      surface_pygame.json
      textcluster.json
      textextents.json
      typing.json
    sanitizers/
      lsan-cairo-recording-snapshot-stripped.supp
      lsan-cairo-recording-snapshot.supp
      policy.py
      run.py
      probes/
        cairo_recording_snapshot_probe.c
    tests/
      test_pycairo_test_parity.py
      test_sanitizer_policy.py
    test-cairo-matrix.sh
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
      device/
        moon.pkg
        ffi.mbt
        device.mbt
        device_test.mbt
      font_face/
        moon.pkg
        ffi.mbt
        font_face.mbt
        font_face_test.mbt
      font_options/
        moon.pkg
        ffi.mbt
        font_options.mbt
        font_options_test.mbt
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
      path/
        moon.pkg
        ffi.mbt
        path.mbt
      pattern/
        moon.pkg
        ffi.mbt
        ffi_mesh.mbt
        pattern.mbt
        gradient.mbt
        mesh.mbt
        pattern_test.mbt
      ps/
        moon.pkg
        ffi.mbt
        ps.mbt
        ps_test.mbt
      region/
        moon.pkg
        ffi.mbt
        region.mbt
        region_test.mbt
      scaled_font/
        moon.pkg
        ffi.mbt
        ffi_text_to_glyphs.mbt
        scaled_font.mbt
        text_to_glyphs.mbt
        scaled_font_test.mbt
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
    docs/
      moon.pkg
      prelude.mbt
      matrix.mbt.md
      surface.mbt.md
      ...
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
        enums/
          moon.pkg
        pycairo/
          moon.pkg
        version/
          moon.pkg
      status/
        core/
          moon.pkg
      value/
        core/
          moon.pkg
        pycairo/
          moon.pkg
      matrix/
        core/
          moon.pkg
        property/
          moon.pkg
        pycairo/
          moon.pkg
      region/
        core/
          moon.pkg
        pycairo/
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
        buffer/
          moon.pkg
        data/
          moon.pkg
        mapped/
          moon.pkg
        png/
          moon.pkg
        properties/
          moon.pkg
      context/
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
        pycairo/
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
        core/
          moon.pkg
        gradient/
          moon.pkg
        mesh/
          moon.pkg
        pycairo/
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
      stream/
        device/
          moon.pkg
        surface/
          moon.pkg
      path/
        core/
          moon.pkg
        pycairo/
          moon.pkg
      object/
        core/
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
        context/
          moon.pkg
        finalizer/
          moon.pkg
        image_data/
          moon.pkg
        owner/
          moon.pkg
        raster/
          moon.pkg
        stream/
          moon.pkg
        value/
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
| Internal implementation packages | `src/internal/<family>/` | May own native-gated externs and helpers when the public `CAIMEOX/cairoon` facade remains unchanged. Version, format, status, PDF, PS, SVG, stream, and C-string helpers keep public enums, errors, and object wrappers in the facade. Region, FontOptions, FontFace, Path, Device, ScaledFont, and Pattern are facade-owned object seams: each child owns the sole GC-managed raw handle and uses raw `Int` status/enum values; checked public methods alone wrap or unwrap it. The ScaledFont child additionally owns private `RawTextToGlyphs`, whose arrays are copied into public pure values. Context/Surface and internal ScaledFont pass `RawFontOptions`, Context and internal ScaledFont pass `RawFontFace`, Context and internal Pattern pass `RawPath`, script/recording Surface bridges pass `RawDevice`, Context font bridges pass `RawScaledFont`, and Context/SurfacePattern/raster bridges pass `RawPattern`. Every native-importing child carries Cairo link flags and links independently. A producer-only child such as Path is tested through real external producers, not a test-only C constructor. Callback-owning bridges such as Device and raster Pattern must prove owned-closure cleanup and retained-object safety under ASan/LSan. |
| Native stubs | `src/native/` | Owns public C glue compilation through `src/native/moon.pkg`. Every `.c` file beside that package file must be listed by bare filename in its `native-stub` list; `src/moon.pkg` imports `CAIMEOX/cairoon/native` and must not own `native-stub` entries. Headers in `src/native/` are private to those stubs. |
| Black-box tests | `src/tests/<family>/` | Import `CAIMEOX/cairoon`; assert only public behavior. Any package that imports cairoon must carry Cairo `cc-link-flags`, because native link flags are not propagated to external test executables. |
| White-box oracles | `src/tests/oracle/<family>/` plus shared C support in `src/tests/oracle/native/` | Import `CAIMEOX/cairoon` for the public API and declare test-only direct-C oracle externs locally; public binding wrappers must never import oracle packages. Test-only C symbols are provided by the oracle-native support package, not `src/moon.pkg`. |
| Documentation | `src/docs/`, `src/README.mbt.md`, and repository `docs/` | Narrative docs live outside source packages; the public package README stays at `src/README.mbt.md` for `moon.mod`, and family executable reference docs live in the external `src/docs` package so they compile like downstream user code through `CAIMEOX/cairoon`. |
| Downstream integration | `integration/moon.work` and `integration/consumer/` | The consumer must remain a separately named MoonBit module with a versioned dependency on `CAIMEOX/cairoon`; its test package imports only the public package, carries platform Cairo link flags, and proves native drawing/readback against both the source checkout and an extracted publication zip. Root `moon.mod` must exclude `integration/` from publication. |
| Release verification tooling | `scripts/matrix/` and `scripts/sanitizers/` | Pinned Cairo build lanes and sanitizer policy stay outside MoonBit packages. Standalone C diagnostics live only in `scripts/sanitizers/probes/`, end in `_probe.c`, compile directly with `pkg-config`, and must not be referenced by any `native-stub` list. |

Do not split a family across packages until the type names, method call syntax,
generated `.mbti`, and `moon test --target native` behavior are proven in a
small package-seam commit.

Do not add new source-like files directly under `src/`. The direct public
package files listed in `scripts/public-package-root-allowlist.txt` are
grandfathered only so the migration can proceed in reviewable slices. New
MoonBit implementation belongs in `src/core/<family>/`,
`src/internal/<family>/`, `src/<family-package>/`, or another explicit package
role; new executable reference docs belong under `src/docs/` unless they are
the package README; new tests belong under `src/tests/<family>/`; new public C
glue belongs under `src/native/`; new oracle C glue belongs under
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
   package-local tests. `src/internal/region` is the first object-handle seam:
   the GC-managed raw Region handle and every Region extern moved out of the
   public package, and their child-package interface uses raw `Int` status and
   overlap values to avoid importing facade-owned enums or errors. The facade
   keeps a private abstract wrapper around that handle, all public Region
   methods, `RegionOverlap` conversion, and `CairoError` mapping. Generated
   interface comparison plus external Region and lifetime tests prove that the
   published `type Region`, method syntax, behavior, and finalizer ownership
   remain unchanged. `src/internal/font_options` is the second object-handle
   seam and the first one with cross-family producers and consumers. It owns
   `RawFontOptions` and all FontOptions-specific externs; Context, Surface, and
   ScaledFont externs pass that raw handle without importing the facade. Public
   `FontOptions` remains an abstract single-field wrapper and continues to own
   typed/raw enum conversion, string validation, and `CairoError` mapping.
   Package-local raw copy/merge/state tests, external font/context/lifetime
   tests, and generated-interface comparison must all pass before this pattern
   is reused for another cross-family object. `src/internal/font_face` is the
   third object-handle seam. It owns `RawFontFace` and all eight declared
   FontFace-specific externs; Context and ScaledFont pass that raw handle below
   the facade. Public `FontFace` retains string validation, typed/raw slant and
   weight conversion, traits, and `CairoError` mapping. Package-local raw
   status/accessor tests plus external FontFace, Context, ScaledFont, oracle,
   and lifetime tests must pass before the seam is accepted.
   `src/internal/path` is the fourth object-handle seam and the first
   producer-only child package. It owns `RawPath` and all seven Path-specific
   externs; Context copy/append paths and mesh Pattern get-path exchange that
   raw handle below the facade. Public `Path` remains an abstract single-field
   wrapper and retains segment parsing, `PathDataType` conversion, traits,
   UTF-8 decoding, and `CairoError` mapping. Because the child layer has no
   production constructor, it deliberately has no package-local fixture API:
   Context, Path, mesh Pattern, and lifetime black-box tests must cover both
   producers, append consumption, status failures, source-scope independence,
   and finalization under ASan/LSan. Generated public-interface comparison
   must remain empty before this seam is accepted.
   `src/internal/device` is the fifth object-handle seam and the first whose
   production constructor transfers a MoonBit callback closure into native
   state. It owns `RawDevice` and all 13 Device-only constructor, identity,
   lifecycle, type, and script-state externs. The five cross-family externs in
   public `ffi_device.mbt` continue to own the recording/script Surface bridge,
   but exchange `RawDevice` rather than the public wrapper. Public `Device`
   remains an abstract single-field wrapper and retains status/error mapping,
   `DeviceType`/`ScriptMode` conversion, validation, traits, and scoped
   lifecycle helpers. The child stream constructor copies call-scoped chunks
   before user code can retain them, and the C stream state remains the sole
   owner responsible for releasing the `#owned` writer closure. Package-local
   raw state/lifecycle tests, external Device/ScriptSurface and pycairo parity
   tests, stream-retention/finalizer stress, generated-interface comparison,
   and package-isolated ASan/LSan must pass before this seam is accepted.
   `src/internal/scaled_font` is the sixth object-handle seam and owns both the
   sole `RawScaledFont` owner and private `RawTextToGlyphs` result owner. Its
   two focused FFI files hold 18 raw constructor, identity, getter, matrix,
   extents, conversion, and result-accessor declarations, matching the
   `cairoon_scaled_font.c` and `cairoon_glyph.c` split. Public `ScaledFont`
   remains an abstract single-field wrapper and retains typed status/flag
   conversion, value assembly, string validation, traits, and error mapping;
   Context get/set bridges alone exchange `RawScaledFont` across families.
   Package-local raw identity/matrix/text-result tests, external font/context/
   glyph/oracle/lifetime tests, unchanged generated public interface, and
   package-isolated ASan/LSan must pass before this seam is accepted.
   `src/internal/pattern` is the seventh object-handle seam. It owns the sole
   `RawPattern` owner, 22 object-only core/solid/gradient externs, and all 13
   mesh externs in focused FFI files. Public `Pattern` remains an abstract
   single-field wrapper and retains typed enum/status conversion, Matrix/value
   assembly, traits, callback APIs, and error mapping. Public
   `ffi_pattern.mbt` keeps two SurfacePattern and three typed-enum bridges;
   `ffi_pattern_raster_source.mbt` keeps nine facade callback/content bridges,
   while Context source/group/mask bridges exchange `RawPattern`. Three
   package-local raw identity/state/gradient/mesh tests, external Pattern,
   Context, image/vector oracle, callback-owner/fuzz, value/finalizer tests,
   unchanged generated public interface, and package-isolated ASan/LSan must
   pass before this seam is accepted.
7. **Executable docs package split**: started. Keep `src/README.mbt.md` as the
   `moon.mod` readme and move family executable reference docs into
   `src/docs/`, which imports `CAIMEOX/cairoon` and carries Cairo link flags so
   the examples are checked as downstream black-box code.
8. **Family package migration**: move one Cairo family per commit. C files,
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
- every current `src/core/**/moon.pkg` and `src/internal/**/moon.pkg` package
  has an explicit `Current Layout` counter in this document, discovered from
  the package tree rather than a hand-maintained checker allowlist;
- every child package that imports `CAIMEOX/cairoon` or
  `CAIMEOX/cairoon/native` carries Cairo `cc-link-flags`, so both black-box
  tests and internal native-gated implementation packages link independently;
- the `Current Layout` file counts in this document match the actual package
  tree, so project-management evidence cannot silently drift as files are
  moved or new test/oracle slices are added;
- `src/moon.pkg` imports `CAIMEOX/cairoon/native` and owns no `native-stub`
  entries;
- every production raw `src/**/ffi*.mbt` file outside `src/tests/` is listed
  in the adjacent `moon.pkg` `targets` map as native-only, and stale native
  target entries for moved raw FFI files are rejected;
- every `.c` file under `src/native/` is referenced by `src/native/moon.pkg`
  `native-stub`, every `native-stub` entry is a bare filename beside its
  owning `moon.pkg`, headers stay with their owning native-stub package, oracle
  C source/header files live beside `src/tests/oracle/native/moon.pkg`, and any
  future nested C source/header files live beside the `moon.pkg` that owns
  them;
- the only C files outside a MoonBit native-stub package are standalone
  diagnostics directly under `scripts/sanitizers/probes/` with `_probe.c`
  names; these probes are compiled by release tooling, not shipped or linked
  into cairoon;
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
