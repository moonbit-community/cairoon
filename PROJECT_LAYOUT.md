# cairoon Project Layout Plan

This document is the project-management contract for moving cairoon from the
current single-package migration workspace into a maintained MoonBit package
tree. It is intentionally operational: each rule is either enforced now by
`scripts/check-project-layout.py` or names the verification gate required before
the next layout slice can be committed.

## Current Baseline

As of this layout-management slice, the repository root is still the only
MoonBit package. It contains:

- 145 root-level `.mbt` files.
- 50 root-level black-box `*_test.mbt` files.
- 24 root-level white-box `*_wbtest.mbt` files.
- 49 root-level C implementation/oracle files.
- 2 root-level C headers.
- 9 root-level executable `.mbt.md` docs.

This baseline is migration debt. It is not the desired architecture. The root
source allowlist in `scripts/root-layout-allowlist.txt` exists only to prevent
new root debt while the existing files are moved in reviewed slices.

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
      surface/
        moon.pkg
      context/
        moon.pkg
      pattern/
        moon.pkg
    oracle/
      moon.pkg
  tests/
    api/
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
  docs/
    reference/
```

The `src/moon.pkg` package keeps the published import path
`caimeo/cairoon`. The move from root to `src/` must be paired with
`moon.mod source = "src"` so downstream imports do not change.

## Package Roles

Use these package roles unless a later proof-of-concept demonstrates a better
MoonBit package shape without weakening the public interface.

| Role | Intended location | Interface rule |
|---|---|---|
| Public package | `src/` | Owns the stable `caimeo/cairoon` interface and public external object types until a facade proof proves otherwise. |
| Pure support packages | `src/core/` | May hold pure values/helpers only after their public names can be preserved or intentionally re-exported. |
| Native FFI packages | `src/<family>/` or `src/native/<family>/` | Each package that lists `native-stub` must keep its C files in the same directory as its `moon.pkg`. |
| Black-box tests | `tests/<family>/` | Import `caimeo/cairoon`; assert only public behavior. |
| White-box oracles | `src/oracle/` or `tests/oracle/` | May expose test-only direct-C oracle helpers; must never be imported by the public package. |
| Documentation | `docs/` and public package `.mbt.md` files | Narrative docs live outside source packages; executable reference docs stay with the package they test. |

Do not split a family across packages until the type names, method call syntax,
generated `.mbti`, and `moon test --target native` behavior are proven in a
small package-seam commit.

## Migration Order

Follow this order. Each step gets its own commit and must pass
`./scripts/verify.sh`.

1. **Root freeze**: keep the current root files as an explicit allowlist and
   reject any new root-level `.mbt`, `.mbt.md`, `.mbti`, `.c`, or `.h` file.
2. **Source-root extraction**: move the current MoonBit package files into
   `src/`, set `moon.mod source = "src"`, update scripts to locate the package
   root, and prove `caimeo/cairoon` remains the public package.
3. **Black-box test extraction**: move pure `*_test.mbt` files into
   `tests/<family>/` packages that import `caimeo/cairoon`; keep test names and
   behavioral assertions unchanged.
4. **White-box oracle extraction**: move direct-C oracle helpers and
   `*_wbtest.mbt` tests into oracle packages. Oracle packages may have their
   own `native-stub` lists, but public binding C files must not depend on them.
5. **Family package probes**: for one low-risk family, prove whether MoonBit can
   preserve the public facade while moving implementation into a family package.
   The proof must include `moon info --target native` review.
6. **Family package migration**: move one Cairo family per commit. C files,
   raw externs, and wrappers move together only when the public package seam is
   proven.

## Root Freeze Rules

The repository root is now project-management space, not a place for new
binding implementation.

- New MoonBit implementation files go into the package directory selected by
  the current migration step, not the repository root.
- New black-box tests go under `tests/<family>/` once the test extraction step
  starts. Until then, extend an existing root test file instead of creating a
  new root test file.
- New C stubs go beside the `moon.pkg` that lists them in `native-stub`.
- Existing root files may be moved or deleted. Missing allowlisted files are
  allowed because migration should shrink the baseline.
- Any new root-level `.mbt`, `.mbt.md`, `.mbti`, `.c`, or `.h` file must fail
  the layout gate unless the project layout plan is intentionally revised in
  the same commit.

## Verification

`./scripts/verify.sh` must run `python3 ./scripts/check-project-layout.py`
before MoonBit compilation. The layout check proves:

- no new source-like files have appeared in the repository root outside the
  transition allowlist;
- nested C source/header files live beside a `moon.pkg`, matching MoonBit's
  `native-stub` constraint;
- `PROJECT_LAYOUT.md` and `scripts/root-layout-allowlist.txt` exist.

The layout gate does not prove the package split is complete. Completion is
proved only when the root allowlist is empty or contains no implementation,
test, oracle, or C glue files, and every package role above has a passing
targeted verification entry in `AUDIT.md`.
