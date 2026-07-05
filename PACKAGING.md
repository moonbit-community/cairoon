# Packaging And Release

`cairoon` is a native MoonBit package backed by Cairo C FFI. A releasable tree
must build against the local Cairo installation and must keep the generated
public interface, audit files, and reliability gate in sync.

## Native Dependencies

Required:

- MoonBit toolchain with native target support.
- Cairo development headers and library.
- `pkg-config` that can resolve `cairo`.

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

## Local Reliability Gate

Use:

```sh
./scripts/verify.sh
```

The gate runs formatting, link-flag drift checks, native type checking,
targeted image/scaled-font/vector/pattern oracle tests, the full native test
suite, `moon info --target native`, and targeted ASan tests when an ASan-capable
`clang` is available.

Set `CAIROON_VERIFY_ASAN=0` only when intentionally skipping the targeted ASan
portion. Set `MOON_CC` and `MOON_AR` to force a specific compiler pair.

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
- A dedicated Ubuntu ASan job with `clang` and leak detection disabled, matching
  the local targeted sanitizer gate.

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
