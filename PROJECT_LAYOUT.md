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
external black-box tests live in `src/tests/*`, public-package C stubs live in
`src/native/`, and test-only C oracles live in `src/tests/oracle/native/`.

- 71 `.mbt` implementation files directly in `src/`.
- 76 black-box `*_test.mbt` files in `src/tests/*`.
- 0 white-box `*_wbtest.mbt` files in `src/`.
- 34 public-package C implementation files in `src/native/`.
- 1 public-package C header in `src/native/`.
- 17 oracle C implementation files in `src/tests/oracle/native/`.
- 2 oracle C headers in `src/tests/oracle/native/`.
- 9 executable `.mbt.md` docs in `src/`.

This is still migration debt, but the repository root and the public package
root no longer carry standalone white-box test files. The remaining work is to
split the large `src/` implementation package into public, support, native,
oracle, and family packages in reviewed slices.

## Target Shape

The target repository separates project management, public MoonBit code,
private native glue, black-box tests, white-box oracle tests, and docs:

```text
cairoon/
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
      moon.pkg
    native/
      cairoon_private.h
      cairoon_objects.c
      cairoon_surface.c
      ...
    oracle/
      moon.pkg
    tests/
      api/
        moon.pkg
      matrix/
        moon.pkg
      surface/
        moon.pkg
      context/
        moon.pkg
      pattern/
        moon.pkg
      font/
        moon.pkg
      path/
        moon.pkg
      region/
        moon.pkg
      backend/
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
`caimeo/cairoon`. The move from root to `src/` must be paired with
`moon.mod source = "src"` so downstream imports do not change.
Because `source = "src"` limits MoonBit's package search path, executable
MoonBit test packages live under `src/tests/`, not repository-root `tests/`.

## Package Roles

Use these package roles unless a later proof-of-concept demonstrates a better
MoonBit package shape without weakening the public interface.

| Role | Intended location | Interface rule |
|---|---|---|
| Public package | `src/` | Owns the stable `caimeo/cairoon` interface and public external object types until a facade proof proves otherwise. |
| Pure support packages | `src/core/` | May hold pure values/helpers only after their public names can be preserved or intentionally re-exported. |
| Native stubs | `src/native/` while owned by `src/moon.pkg`; later `src/native/<family>/` packages only after a facade proof | Every `.c` file under `src/native/` must be listed by `src/moon.pkg` `native-stub`; headers in `src/native/` are private to those stubs. |
| Black-box tests | `src/tests/<family>/` | Import `caimeo/cairoon`; assert only public behavior. Any package that imports cairoon must carry Cairo `cc-link-flags`, because native link flags are not propagated to external test executables. |
| White-box oracles | `src/tests/oracle/<family>/` plus shared C support in `src/tests/oracle/native/` | Import `caimeo/cairoon` for the public API and declare test-only direct-C oracle externs locally; public binding wrappers must never import oracle packages. Test-only C symbols are provided by the oracle-native support package, not `src/moon.pkg`. |
| Documentation | `docs/` and public package `.mbt.md` files | Narrative docs live outside source packages; executable reference docs stay with the package they test. |

Do not split a family across packages until the type names, method call syntax,
generated `.mbti`, and `moon test --target native` behavior are proven in a
small package-seam commit.

## Migration Order

Follow this order. Each step gets its own commit and must pass
`./scripts/verify.sh`.

1. **Root freeze**: completed. The layout gate rejected new root-level
   `.mbt`, `.mbt.md`, `.mbti`, `.c`, or `.h` files during the transition.
2. **Source-root extraction**: completed. The current MoonBit package files
   live in `src/`, `moon.mod` sets `source = "src"`, scripts locate the
   package root explicitly, and `caimeo/cairoon` remains the public package.
3. **Black-box test extraction**: started. Move pure `*_test.mbt` files into
   `src/tests/<family>/` packages that import `caimeo/cairoon`; keep test names
   and behavioral assertions unchanged.
4. **Native-stub directory extraction**: completed. Public-package C stubs live
   under `src/native/`, and `src/moon.pkg` references them with `native/...`
   `native-stub` paths.
5. **White-box oracle extraction**: completed for MoonBit tests and C oracle
   support. Direct-C oracle tests now live under `src/tests/oracle/*`, and
   test-only C oracle helpers live under `src/tests/oracle/native` as a
   separate native-stub package imported only by oracle tests. Public binding C
   files must not depend on oracle packages.
6. **Family package probes**: for one low-risk family, prove whether MoonBit can
   preserve the public facade while moving implementation into a family package.
   The proof must include `moon info --target native` review.
7. **Family package migration**: move one Cairo family per commit. C files,
   raw externs, and wrappers move together only when the public package seam is
   proven.

## Root Freeze Rules

The repository root is now project-management space, not a place for new
binding implementation.

- New MoonBit implementation files go into the package directory selected by
  the current migration step, not the repository root.
- New black-box tests go under `src/tests/<family>/` once the test extraction
  step starts. Until then, extend an existing `src/*_test.mbt` file instead of
  creating a new root test file.
- New public-package C stubs go under `src/native/` and must be listed in
  `src/moon.pkg` `native-stub`. Future family packages may keep C stubs beside
  their own `moon.pkg` only after a package-seam proof.
- Any new root-level `.mbt`, `.mbt.md`, `.mbti`, `.c`, or `.h` file must fail
  the layout gate unless the project layout plan is intentionally revised in
  the same commit.

## Verification

`./scripts/verify.sh` must run `python3 ./scripts/check-project-layout.py`
before MoonBit compilation. The layout check proves:

- no source-like files have appeared in the repository root;
- `src/moon.pkg`, `src/pkg.generated.mbti`, and `moon.mod source = "src"`
  are present;
- repository-root `tests/` does not contain MoonBit packages or source-like
  files, because it is outside the package search path;
- every `src/tests/**/moon.pkg` has an adjacent `pkg.generated.mbti`, so
  package seams are reviewed through `moon info --target native`;
- external black-box test packages that import `caimeo/cairoon` carry Cairo
  `cc-link-flags`;
- every `.c` file under `src/native/` is referenced by `src/moon.pkg`
  `native-stub`, headers stay with that native stub directory, oracle C
  source/header files live beside `src/tests/oracle/native/moon.pkg`, and any
  future nested C source/header files outside `src/native/` live beside a
  `moon.pkg`;
- `PROJECT_LAYOUT.md` and `scripts/root-layout-allowlist.txt` exist.

The layout gate does not prove the package split is complete. It proves only
that the root has become project-management space and that public-package C
source/header files are isolated in `src/native/` while oracle C source/header
files are isolated in `src/tests/oracle/native`, both with explicit
`native-stub` ownership. Completion is proved only when every package role
above has a passing targeted verification entry in `AUDIT.md`.
