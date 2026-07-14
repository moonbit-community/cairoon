# Packaging And Release

`cairoon` is a native MoonBit package backed by Cairo C FFI. A releasable tree
must build against the local Cairo installation and must keep the generated
public interface, audit files, and reliability gate in sync.

## Native Dependencies

Required:

- MoonBit toolchain with native target support.
- Cairo development headers and library.
- `pkg-config` that can resolve `cairo`.
- Python 3 for static FFI ownership and API-inventory linting.

Optional but recommended:

- An ASan-capable `clang`; on macOS, Homebrew LLVM is preferred.

## Fresh Checkout Setup

From this directory:

```sh
scripts/configure-link-flags.sh
moon check --target native
moon test --target native
```

`moon.pkg` stores concrete native link flags because MoonBit native stubs need
real compiler and linker flags. On another machine, run
`scripts/configure-link-flags.sh` before local testing. Commit `moon.pkg` flag
changes only when intentionally refreshing the package for the release host.

## Downstream Consumer Smoke Test

Before relying on a local checkout from another MoonBit project, verify both
module resolution and native Cairo linking from the consumer package.

For a local workspace:

```sh
moon work init
moon work use /path/to/cairoon /path/to/consumer
```

The consumer module must declare the versioned dependency in `moon.mod`:

```moonbit
import {
  "CAIMEOX/cairoon@0.1.0",
}
```

The consumer package that builds an executable or black-box tests must import
cairoon in `moon.pkg` and carry native Cairo link flags. If only tests use the
binding, keep the import test-scoped:

```moonbit
import {
  "CAIMEOX/cairoon",
} for "test"

options(
  link: {
    "native": {
      "cc-link-flags": "-lcairo",
    },
  },
)
```

Use the platform-specific `cc-link-flags` reported by `pkg-config --libs
cairo` when `-lcairo` is not enough. A minimal black-box smoke test is:

```moonbit
///|
test "consumer can draw through cairoon" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 8, 8)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.flush()
  inspect(surface.status() == @cairoon.Success, content="true")
}
```

Run the consumer package itself:

```sh
moon test . --target native --deny-warn -v
```

In a workspace, plain `moon test --target native` may also run cairoon's own
test packages. That is useful for release verification, but it is not the
fastest downstream smoke test.

## Local Reliability Gate

Use:

```sh
./scripts/verify.sh
```

The gate runs formatting, link-flag drift checks, static FFI ownership linting,
top-level pycairo API inventory linting, pinned pycairo Context, Font, Matrix,
Pattern, and Surface test parity, native type checking, targeted
image/scaled-font/vector/pattern oracle tests, the full native test suite,
`moon info --target native`, and targeted ASan tests when an ASan-capable
`clang` is available.

Set `CAIROON_VERIFY_ASAN=0` only when intentionally skipping the targeted ASan
portion. Set `CAIROON_ASAN_CC` and `CAIROON_ASAN_AR` to force the compiler pair
used by that targeted sanitizer pass without changing the ordinary native gate.

## Release Checklist

1. Update `version` in `moon.mod`.
2. Ensure `repository`, `license`, `keywords`, and `description` are correct in
   `moon.mod`.
3. Run `scripts/configure-link-flags.sh` on the release host, then inspect the
   `moon.pkg` link flags.
4. Run `./scripts/verify.sh`; the release cannot proceed if this fails.
5. Run `git diff -- pkg.generated.mbti` after `moon info --target native`.
   Public API changes must be intentional and documented.
6. Update `API_INVENTORY.md`, `AUDIT.md`, and `TESTING.md` with the exact API
   and verification state.
7. Confirm new public APIs have executable docs in the appropriate
   `*.mbt.md` reference file.
8. Commit the release state and tag it from a clean worktree.

## CI Guidance

The repository ships `.github/workflows/ci.yml`. It runs:

- Native verification on `ubuntu-latest` and `macos-latest` with ASan disabled.
- A dedicated Ubuntu ASan job with `CAIROON_ASAN_CC=clang`,
  `CAIROON_ASAN_AR=llvm-ar`, and leak detection disabled, matching the local
  targeted sanitizer gate while leaving the ordinary full native gate on the
  default compiler.

Custom CI should install Cairo and `pkg-config`, then run:

```sh
scripts/configure-link-flags.sh
./scripts/verify.sh
```

If the CI image lacks an ASan-capable compiler, set `CAIROON_VERIFY_ASAN=0` and
run the ASan job separately on an image that provides `clang` plus Cairo.

## Package Scope

- `preferred_target = "native"` is intentional.
- Do not add package-wide `supported-targets = ["native"]`; gate FFI-only files
  with package targets instead.
- Keep C stubs split by Cairo API family. Test-only C helpers belong in
  `cairoon_test_*.c`, not in the runtime stub files.
- Keep `pkg.generated.mbti` committed so reviewers can audit public API changes.
