# cairoon: MoonBit Cairo Binding Engineering Guide

This directory is the MoonBit workspace for a Cairo binding. Treat this file as
the binding specification and implementation checklist.

## Required Context

Before changing binding code, read the `moonbit-c-binding` skill. The relevant
MoonBit rules are:

- Native C FFI is the only supported target for the `0.x` product. The module
  must declare `preferred_target = "native"` and
  `supported_targets = "native"`; the LLVM, Wasm, WasmGC, and JavaScript
  backends are not targets until MoonBit documents a compatible Cairo FFI
  path.
- C resources owned by MoonBit must be represented by abstract MoonBit types
  backed by `moonbit_make_external_object`.
- Every non-primitive FFI parameter must be annotated with `#borrow` or
  `#owned`.
- `#external type T` is a raw `void *` and is not reference counted by MoonBit.
  Do not use it for resources that MoonBit is responsible for destroying.
- `Bytes`, `String`, `FixedArray[T]`, and abstract `type T` values are managed
  MoonBit objects. If C stores one beyond the current call, C must retain it
  with `moonbit_incref` or receive it as `#owned` and release it later with
  `moonbit_decref`.

Primary references used for this specification:

- MoonBit FFI documentation:
  https://docs.moonbitlang.com/en/latest/language/ffi.html
- MoonBit error handling documentation:
  https://docs.moonbitlang.com/en/latest/language/error-handling.html
- Cairo language-binding appendix:
  https://www.cairographics.org/manual/language-bindings.html
- Cairo binding memory management:
  https://www.cairographics.org/manual/bindings-memory.html
- Cairo binding error handling:
  https://www.cairographics.org/manual/bindings-errors.html
- Cairo binding streams and file I/O:
  https://www.cairographics.org/manual/bindings-streams.html

## Project Shape

`PROJECT_LAYOUT.md` is the active project-management contract for package
structure. The current `src/` package is a transition state, not the target
architecture, but the repository root is now project-management space. Do not
add new root-level `.mbt`, `.mbt.md`, `.mbti`, `.c`, or `.h` files;
`scripts/check-project-layout.py` enforces an empty root source allowlist while
the package tree is migrated. Because `moon.mod` sets `source = "src"`,
executable MoonBit black-box test packages live under `src/tests/<family>/`;
root-level `tests/` files are outside MoonBit's package search path.
Public C source/header files live in the `CAIMEOX/cairoon/native` package under
`src/native/`; every `.c` file there must appear in `src/native/moon.pkg`
`native-stub`, and `src/moon.pkg` must import `CAIMEOX/cairoon/native` rather
than owning any `native-stub` entries itself.

Use the historical flat layout below only to understand old audit references
from before source-root extraction:

```text
cairoon/
  AGENTS.md
  TESTING.md
  moon.mod
  moon.pkg
  ffi.mbt
  ffi_context_core.mbt
  ffi_context_font_text.mbt
  ffi_device.mbt
  ffi_font_face.mbt
  ffi_font_options.mbt
  ffi_image_data.mbt
  ffi_image_surface.mbt
  ffi_mapped_image_surface.mbt
  ffi_pattern.mbt
  ffi_pattern_mesh.mbt
  ffi_pattern_raster_source.mbt
  ffi_path.mbt
  ffi_pdf_surface.mbt
  ffi_ps_surface.mbt
  ffi_recording_surface.mbt
  ffi_surface.mbt
  ffi_surface_font_options.mbt
  ffi_surface_mime.mbt
  ffi_surface_png.mbt
  ffi_surface_state.mbt
  ffi_svg_surface.mbt
  ffi_tee_surface.mbt
  ffi_scaled_font.mbt
  ffi_text_to_glyphs.mbt
  ffi_region.mbt
  error.mbt
  types.mbt
  device.mbt
  matrix.mbt
  surface.mbt
  image_surface.mbt
  surface_png.mbt
  surface_mime.mbt
  surface_state.mbt
  surface_font_options.mbt
  recording_surface.mbt
  tee_surface.mbt
  pattern.mbt
  pattern_gradient.mbt
  pattern_mesh.mbt
  pattern_raster_source.mbt
  context.mbt
  font.mbt
  region.mbt
  cairoon_private.h
  cairoon_objects.c
  cairoon_stream.c
  cairoon_misc.c
  cairoon_test_common.c
  cairoon_test_file.c
  cairoon_test_vector_private.h
  cairoon_test_vector.c
  cairoon_test_vector_scenes.c
  cairoon_test_vector_tag_scenes.c
  cairoon_test_backend_combo.c
  cairoon_test_backend_nested.c
  cairoon_test_backend_sequence.c
  cairoon_test_pdf_vector.c
  cairoon_test_ps_vector.c
  cairoon_test_svg_vector.c
  cairoon_test_image.c
  cairoon_device.c
  cairoon_surface.c
  cairoon_surface_png.c
  cairoon_surface_mime.c
  cairoon_surface_state.c
  cairoon_surface_font_options.c
  cairoon_image_surface.c
  cairoon_mapped_image_surface.c
  cairoon_recording_surface.c
  cairoon_image_data.c
  cairoon_pdf_surface.c
  cairoon_ps_surface.c
  cairoon_svg_surface.c
  cairoon_tee_surface.c
  cairoon_context.c
  cairoon_context_font_text.c
  cairoon_context_matrix.c
  cairoon_context_state.c
  cairoon_context_path.c
  cairoon_context_clip_extents.c
  cairoon_context_paint.c
  cairoon_glyph.c
  cairoon_path.c
  cairoon_pattern.c
  cairoon_raster_source_callbacks.c
  cairoon_raster_source_pattern.c
  cairoon_mesh_pattern.c
  cairoon_font_options.c
  cairoon_font_face.c
  cairoon_scaled_font.c
  cairoon_scaled_font_oracle.c
  cairoon_region.c
  tests/
```

The module config must prefer native builds and reject unsupported backends
before package checking reaches native-only declarations:

```moonbit
preferred_target = "native"
supported_targets = "native"
```

The public package config must import the native-stub package and raw owner
packages. It has no `targets` block because it declares no C FFI directly:

```moonbit
import {
  "CAIMEOX/cairoon/internal/context" @context_impl,
  "CAIMEOX/cairoon/internal/device" @device_impl,
  "CAIMEOX/cairoon/internal/font_face" @font_face_impl,
  "CAIMEOX/cairoon/internal/font_options" @font_options_impl,
  "CAIMEOX/cairoon/internal/path" @path_impl,
  "CAIMEOX/cairoon/internal/pattern" @pattern_impl,
  "CAIMEOX/cairoon/internal/region" @region_impl,
  "CAIMEOX/cairoon/internal/scaled_font" @scaled_font_impl,
  "CAIMEOX/cairoon/internal/surface" @surface_impl,
  "CAIMEOX/cairoon/native",
}
```

Context, Device, FontFace, FontOptions, Path, Pattern, Region, ScaledFont, and
Surface keep their public facade wrappers in `src/`, while their
`src/internal/<family>/moon.pkg` files import `CAIMEOX/cairoon/native`,
and native-gate their own FFI files. Native linking propagates from
`CAIMEOX/cairoon/native`; child and consumer packages must not repeat Cairo
link flags. The public package imports them as
`@context_impl`, `@device_impl`, `@font_face_impl`, `@font_options_impl`,
`@path_impl`, `@pattern_impl`, `@region_impl`, `@scaled_font_impl`, and
`@surface_impl`; it must not redeclare their raw handle types or object-only
family externs.

The `src/native/moon.pkg` package owns all public C glue compilation. Its
`native-stub` entries are plain filenames beside that package file, never paths
back into another package. The checked-in `src/native/moon.pkg` is the
executable source of truth for this list: every `.c` beside it must appear in
`native-stub`, every `native-stub` entry must exist beside it, and its
`stub-cc-flags` must be exactly
`"${build.CAIRO_CFLAGS} -std=c11 -Wall -Wextra -Wpedantic -Werror"`.
The test-only `src/tests/oracle/native/moon.pkg` package must use the same exact
flag string for all oracle glue. Keep the `pkg-config`-derived flags first and
the strict C11 warning flags in the shown order; omission, reordering, or
warning downgrades are release failures enforced by
`scripts/check-project-layout.py` and its negative unit tests.
`scripts/build/cairo_config.py` resolves Cairo with `pkg-config`, emits that
build variable, and propagates the linker flags from the native package to all
dependents. `scripts/check-project-layout.py` and the build-script unit tests
enforce these rules; concrete host paths and package-local `cc-link-flags` are
forbidden in every checked-in `moon.pkg`.

The legacy `moon.mod.json` format is deprecated by MoonBit. This workspace uses
the current `moon.mod`/`moon.pkg` DSL and pins the CI toolchain declared in the
workflow. The pre-build config API is explicitly experimental, so its protocol,
archive inclusion, source consumer, extracted consumer, and cross-host matrix
behavior are executable release contracts while cairoon remains unstable.

Link to the system Cairo installation. Do not vendor Cairo into this repository
for the initial binding. `moon.mod` must register
`scripts/build/cairo_config.py` as `--moonbit-unstable-prebuild`. The script must
invoke `pkg-config` without a shell, require Cairo 1.15.10 or newer, preserve
quoted compiler/linker arguments, emit only protocol JSON on stdout, and never
print the supplied environment. It emits compile flags through
`${build.CAIRO_CFLAGS}` and one propagated link configuration owned by
`CAIMEOX/cairoon/native`. Python 3 and `pkg-config` are therefore downstream
build requirements. `scripts/configure-cairo-constants.sh` remains responsible
only for committed compile-time version/feature constants; it must never edit
package manifests.

Those uppercase `CAIRO_VERSION*` and `HAS_*` constants are release-source
snapshots, not a promise that a cross-host consumer has identical headers.
Downstream capability checks must use `cairo_version()` and
`cairo_version_string()`. The module pre-build script must not mutate dependency
source to regenerate constants; that is not a documented MoonBit build
contract. A future generated-source design may replace this rule only with an
official dependency-safe mechanism and cross-host regression coverage.

## Raw FFI File Boundaries

Raw `extern "C"` declarations are split by Cairo concept family, mirroring the
C glue split. Every GC-managed object handle and callback declaration has one
owner in `src/internal/<family>/`; the public package declares no C FFI.
Facade enums, values, and callback arguments must be converted to raw handles
and primitive fields before entering a child package and are never grounds for
a root FFI declaration. Every FFI file is
native-gated by its owning `moon.pkg`. A child package must
expose raw statuses and enum values as `Int`, must not import
`CAIMEOX/cairoon`, and must not map failures to facade-owned `CairoError`.
For example, `src/internal/font_face/ffi.mbt` owns
`RawFontFace` and the toy-font-face/FontFace extern declarations that call
`cairoon_font_face.c`; `src/internal/font_options/ffi.mbt` owns
`RawFontOptions` and the FontOptions-specific extern declarations that call
`cairoon_font_options.c`;
`src/internal/scaled_font/ffi.mbt` owns `RawScaledFont` and the 12 constructor,
identity, getter, matrix, and extents externs that call
`cairoon_scaled_font.c`; its `ffi_text_to_glyphs.mbt` owns
`RawTextToGlyphs`, the scaled-font conversion extern, and the five result
accessors that call `cairoon_scaled_font.c` or `cairoon_glyph.c`;
`src/internal/pattern/ffi.mbt` owns `RawPattern` and 25 constructor, identity,
common-state, matrix, solid, gradient, SurfacePattern, and raw raster-source
externs; its `ffi_mesh.mbt` owns all 13 mesh-pattern externs and exchanges
`RawPath` with `src/internal/path`; its `ffi_raster_callbacks.mbt` owns all
seven raster callback registration/introspection externs and exchanges only
`RawSurface`, integer extents, and raw `Int` statuses. Typed enum setters and
public callback adapters convert facade values before calling the child raw
functions. No Pattern extern remains in the public package.
The callback exports live in `cairoon_raster_source_pattern.c`;
retained callback state, acquired-surface owner tracking, and Cairo
acquire/release trampolines live in `cairoon_raster_source_callbacks.c`;
`src/internal/context` owns the sole `RawContext` external object and 109 raw
Context externs. Its FFI files must match the C split exactly: `ffi.mbt` owns
16 core declarations, `ffi_clip_extents.mbt` 11, `ffi_font_text.mbt` 19,
`ffi_matrix.mbt` 11, `ffi_paint.mbt` 14, `ffi_path.mbt` 17, and
`ffi_state.mbt` 21. Context enum setters, toy-font selection, and
`show_text_glyphs` convert facade values to primitive arrays and `Int` values
before calling the child package. No public Context FFI file is permitted.
The child exchanges raw FontOptions, FontFace, Path, Pattern, ScaledFont,
Surface, and MappedImageSurface handles with their internal packages;
`src/internal/device/ffi.mbt` owns `RawDevice` and all 17 raw Device/script
externs, including `Surface::get_device`, the recording-surface path, and the
raw script-surface paths. No public Device FFI file is permitted;
`src/internal/path/ffi.mbt` owns `RawPath` and the Path-specific extern
declarations that call `cairoon_path.c`;
`src/internal/surface` owns the sole `RawSurface`, `RawMappedImageSurface`, and
`RawImageData` external objects plus exactly 84 raw externs. Its 13 FFI files
are an executable family ledger: base 9, state/page 12, image 7, mapped image
10, image data 7, PNG 4, MIME 4, font options 1, recording 3, PDF 9, PS 9,
SVG 5, and Tee 4. The package imports `src/internal/font_options`,
`src/internal/stream`, and `src/native`; cross-object users import
`src/internal/surface`, never the reverse. PDF, PS, SVG, and PNG stream
callbacks use raw `Int` statuses in the child, copy call-scoped chunks there,
and adapt to facade `Status` values only in checked public methods. The public
package retains no Surface extern declarations, so no production C symbol is
declared twice. Raw
PDF/PS/SVG version query/string helpers remain in
`src/internal/pdf`, `src/internal/ps`, and `src/internal/svg`; format stride
remains in `src/internal/format`. Deleted root files such as
`ffi_image_data.mbt`, `ffi_mapped_image_surface.mbt`,
`ffi_surface_state.mbt`, `ffi_surface_mime.mbt`,
`ffi_surface_font_options.mbt`, `ffi_tee_surface.mbt`, `ffi_surface.mbt`,
`ffi_image_surface.mbt`, `ffi_recording_surface.mbt`,
`ffi_pdf_surface.mbt`, `ffi_ps_surface.mbt`, `ffi_surface_png.mbt`,
`ffi_svg_surface.mbt`,
`ffi_context_font_text.mbt`, `ffi_context_state.mbt`, `ffi_device.mbt`, and
`ffi_pattern.mbt`, `ffi_pattern_raster_source.mbt` must not return.
`src/internal/font_face/ffi.mbt` owns the
abstract `RawFontFace` external object and every declared FontFace-specific
extern; the internal Context and ScaledFont packages may accept or return that
raw handle, but only checked public facade methods may wrap or unwrap it.
The child interface uses `Int` for statuses, slants, and weights and must not
import `CAIMEOX/cairoon`. `src/internal/font_options/ffi.mbt` owns the
abstract `RawFontOptions` external object and every FontOptions-specific extern;
the internal Context, ScaledFont, and Surface packages may accept or return
that raw handle, but only checked facade methods may wrap or unwrap it.
The child interface uses `Int` for statuses and enum values and must not import
`CAIMEOX/cairoon`. `src/internal/region/ffi.mbt` owns the abstract
`RawRegion` external object and every Region extern that calls
`cairoon_region.c`; its public child-package functions expose status and
overlap values only as `Int` and must not import `CAIMEOX/cairoon`. The public
`region.mbt` facade owns the abstract `Region` wrapper, converts those raw
values to `Status` and `RegionOverlap`, and maps failures to `CairoError`.
`src/internal/path/ffi.mbt` owns the abstract `RawPath` external object and all
seven Path-specific externs. Context copy-path and mesh get-path externs return
`RawPath`, while append-path accepts a borrowed `RawPath`; only checked facade
methods may wrap those returned handles or unwrap public `Path` arguments. The
child interface uses `Int` for Cairo statuses and path-data kinds and must not
import `CAIMEOX/cairoon`. Public `path.mbt` retains the abstract single-field
`Path` wrapper, `PathSegment`, `PathDataType` conversion, traits, UTF-8
decoding, and all `CairoError` mapping.
`src/internal/device/ffi.mbt` owns the abstract `RawDevice` external object and
all 17 raw Device/script externs. Its child interface uses `Int` for statuses,
`DeviceType`, `ScriptMode`, and stream callback results, and it must not import
`CAIMEOX/cairoon`. Public `device.mbt` retains the abstract single-field
`Device` wrapper, typed enum conversion, path/string validation, traits,
scoped lifecycle helpers, and all `CairoError`/`CairoIOError` mapping.
`Surface::get_device` and all script-surface paths exchange `RawSurface` in the
child after facade enum conversion. The child stream constructor owns the
writer closure, copies each call-scoped chunk before invoking it, and relies on
native stream state to release the closure exactly once. A stream attach helper
consumes that state only after `cairo_*_set_user_data` succeeds. Before
transfer, a null producer, producer status failure, or user-data attachment
failure must call the shared Surface/Device cleanup helper; that helper must
null-check the producer, destroy it before destroying the stream state, and
perform no other ownership transfer. Keep this rule executable with static
negative mutations for every failure branch and a test-only runtime
attachment-failure oracle under ASan/LSan/UBSan. Surface or device destruction
may invoke the writer, but exact backend-controlled callback counts are not a
portable contract.
`src/internal/scaled_font` owns the abstract `RawScaledFont` and private
`RawTextToGlyphs` external objects plus all 18 ScaledFont/result externs. Its
child interface uses `Int` for Cairo statuses and text-cluster flags and must
not import `CAIMEOX/cairoon`. Public `scaled_font.mbt` retains the abstract
single-field `ScaledFont` wrapper, typed status/flag conversion, Matrix,
FontExtents, TextExtents, Glyph, TextCluster, and TextGlyphRun assembly, string
validation, traits, and all `CairoError` mapping. Context get/set bridge externs
may return or borrow `RawScaledFont`, but only checked facade methods may wrap
or unwrap it. No `RawTextToGlyphs` value may escape the facade as public API.
`src/internal/pattern` owns the abstract `RawPattern` external object and all
45 raw solid, gradient, common-state, mesh, SurfacePattern, raster-source, and
raster callback externs. Its child interface uses `Int` for Cairo statuses and
raw enum values, imports `src/internal/path` and `src/internal/surface`, and
must not import
`CAIMEOX/cairoon`. Public `pattern.mbt` retains the abstract single-field
`Pattern` wrapper, typed enum/status conversion, Matrix/value assembly,
traits, and all `CairoError` mapping. Public raster callbacks are adapted to
raw `RawSurface` callbacks plus integer rectangle fields before crossing into
the child; no facade `Surface`, `RectangleInt`, `Status`, or `CairoError` type
may appear in Pattern FFI. Context source/group/mask paths exchange
`RawPattern`; only checked facade methods may wrap or unwrap it.
`src/internal/context` owns the abstract `RawContext` external object and all
109 raw Context externs. Its seven FFI and seven wrapper files
must preserve the core, clip/extents, font/text, matrix, paint, path, and state
C-family split; no catch-all Context file may be added. Public `context*.mbt`
files retain the abstract single-field `Context` wrapper, typed enum/status and
value conversion, string validation, traits, and every `CairoError` mapping.
No public Context FFI file is permitted; only checked facade methods may wrap
or unwrap `RawContext`. The child constructs real contexts from `RawSurface` or
`RawMappedImageSurface`; package-local tests must cover both constructors,
target/group-target returns, and surface source/mask calls. External tests must
still cover status failures, source-scope lifetime, callbacks, and
package-isolated ASan/LSan runs.
`src/internal/surface` owns `RawSurface`, `RawMappedImageSurface`, and
`RawImageData`; these are the only MoonBit external-object owners for their C
payloads. Public `Surface`, `MappedImageSurface`, and `ImageData` are private
single-field wrappers with no finalizer. The child has 84 externs in 13 exact
families and package-local tests must exercise base/image/state, mapped/data,
MIME/font-options/recording/Tee, PDF/PS/SVG paths, and retained stream
callbacks. Context, Pattern, and Device child packages may exchange these raw
handles. No package may declare a second raw Surface-family type or recreate
one of the deleted root externs.

Do not add public wrappers to `ffi_*.mbt`; these files are private native FFI
plumbing only. Public MoonBit APIs stay in focused wrapper files such as
`surface.mbt`, `image_surface.mbt`, `surface_png.mbt`, `surface_mime.mbt`,
`surface_state.mbt`, `surface_font_options.mbt`, `recording_surface.mbt`,
`tee_surface.mbt`, `font_options.mbt`, `font_face.mbt`, `scaled_font.mbt`,
`pattern.mbt`, `pattern_gradient.mbt`, `pattern_mesh.mbt`,
`pattern_raster_source.mbt`, `path.mbt`, and `region.mbt`. For `Surface`, keep
string helpers, similar/subsurface constructors, identity/status/type/device,
and finish/with-finished wrappers in `surface.mbt`; keep image-surface
constructors/properties/data in `image_surface.mbt`; PNG path/stream helpers in
`surface_png.mbt`; MIME helpers in `surface_mime.mbt`; dirty/state/page helpers
in `surface_state.mbt`; surface font-options in `surface_font_options.mbt`;
recording-surface helpers in `recording_surface.mbt`; and TeeSurface helpers in
`tee_surface.mbt`. For `Pattern`, keep solid/surface/common-state wrappers in
`pattern.mbt`, gradient constructors and color-stop/geometry queries in
`pattern_gradient.mbt`, mesh-patch methods in `pattern_mesh.mbt`, and
raster-source callback accessors in `pattern_raster_source.mbt`.

## C Glue File Boundaries

Follow pycairo's architecture: one C file per Cairo concept family, with shared
payload types and cross-file helpers declared in `cairoon_private.h`. All C
file basenames in this section are relative to `src/native/`.

- `cairoon_private.h`: external-object payload structs, wrapper constructors,
  copied-string helper, and cross-family status prototypes.
- `cairoon_objects.c`: finalizers, `wrap_owned`/`wrap_borrowed` helpers, and
  other lifetime primitives shared by object families.
- `cairoon_misc.c`: version/status string helpers and small module-level C
  exports.
- `cairoon_device.c`: `Device`, script-device, script-surface, and
  `Surface::get_device` exports.
- `cairoon_surface.c`: base `Surface` creation/status/equality/hash/type and
  finish exports.
- `cairoon_surface_png.c`: PNG file and stream writer exports.
- `cairoon_surface_mime.c`: MIME data and MIME support exports.
- `cairoon_surface_state.c`: flush, dirty markers, device offset/scale,
  fallback resolution, show-text-glyphs support, and page-operation exports.
- `cairoon_surface_font_options.c`: surface font-options export.
- `cairoon_image_surface.c`: image-surface constructors, PNG-read helpers,
  image queries, and copy-data exports.
- `cairoon_mapped_image_surface.c`: mapped-image lifecycle and query exports.
- `cairoon_recording_surface.c`: recording-surface constructors and extents.
- `cairoon_pdf_surface.c`: PDF surface exports.
- `cairoon_ps_surface.c`: PostScript surface exports.
- `cairoon_svg_surface.c`: SVG surface exports.
- `cairoon_context.c`: core `Context` construction/status/tag/target/source
  and group exports.
- `cairoon_context_font_text.c`, `cairoon_context_matrix.c`,
  `cairoon_context_state.c`, `cairoon_context_path.c`,
  `cairoon_context_clip_extents.c`, and `cairoon_context_paint.c`: split
  context font/text, transform, drawing-state, path, clip/extents/hit-test,
  and source/paint/page exports.
- `cairoon_glyph.c`: shared `cairo_glyph_t` array marshaling helpers used by
  context and scaled-font exports.
- `cairoon_path.c`: `Path` data decoding, stringification, and status/equality
  helpers.
- `cairoon_pattern.c`: base/surface/solid/gradient pattern exports.
- `cairoon_mesh_pattern.c`: mesh-pattern operations.
- `cairoon_raster_source_pattern.c`: public raster-source constructor and
  callback accessor exports.
- `cairoon_raster_source_callbacks.c`: retained raster-source callback state,
  acquired-surface owner tracking, and Cairo acquire/release trampolines.
- `cairoon_font_options.c`, `cairoon_font_face.c`,
  and `cairoon_scaled_font.c`: font-options, toy-font-face, and scaled-font
  exports.
- `cairoon_region.c`: `Region` exports.

Test-only C oracle helpers live under `src/tests/oracle/native/`, not
`src/native/`, and are compiled by that package's own `native-stub` list. Keep
constants probes in `cairoon_test_constants.c`, scaled-font direct-C probes in
`cairoon_scaled_font_oracle.c`, raster-source owner-count probes in
`cairoon_test_raster_source.c`, ARGB32 image oracles in
`cairoon_test_image.c`, base pattern scene helpers in
`cairoon_test_pattern_scenes.c`, pattern extend/filter/matrix combinations in
`cairoon_test_pattern_combo_scenes.c`, pattern stack/mesh/mask combinations in
`cairoon_test_pattern_stack_scenes.c`, raster-source and basic mesh pattern
scenes in `cairoon_test_pattern_special_scenes.c`, common drawing helpers in
`cairoon_test_common.c`, normalized file comparison helpers in
`cairoon_test_file.c`, vector-output
exports in `cairoon_test_vector.c`, shared vector scene ids and prototypes in
`cairoon_test_vector_private.h`, primitive/common vector scenes in
`cairoon_test_vector_scenes.c`, tag-heavy vector scenes in
`cairoon_test_vector_tag_scenes.c`, tagged vector text-state scenes in
`cairoon_test_vector_text_state_scenes.c`, cross-backend feature combinations in
focused files such as `cairoon_test_backend_combo.c`,
`cairoon_test_backend_nested.c`, `cairoon_test_backend_sequence.c`,
`cairoon_test_backend_tag_matrix.c`, and
`cairoon_test_backend_lifecycle.c`, text-state backend combinations in
`cairoon_test_backend_text_state.c`, and single-backend feature renderers in the
PDF/PS/SVG vector files. Public binding C exports must not be added to this
oracle-native package.

## Package Seam Rules

Pure support packages may live under `src/core/<family>/` after a focused seam
probe proves external call sites still work through `CAIMEOX/cairoon`. The first
accepted probe is `src/core/glyph`: the public package imports it and exposes
`Glyph` with `pub type Glyph = @glyph.Glyph`. This keeps external construction,
field access, and method syntax such as `@cairoon.Glyph::new(...)`,
`glyph.index`, and `glyph.components()` valid while the implementation lives in
a subpackage. The same package owns `field_arrays`, the MoonBit-side
preparation step for `cairo_glyph_t` array marshaling; public context and
scaled-font wrappers should call `@glyph.field_arrays` instead of re-expanding
glyph fields in the facade package. The second accepted probe is
`src/core/constants`: it owns pure primitive Cairo version, feature, MIME, tag,
PDF outline, and color-palette constants, while the facade re-exports the same
public names with `pub const` aliases. `scripts/configure-cairo-constants.sh` must
update and check the child package constants so `pkg-config` remains the source
of truth for generated version and feature constants.

Internal implementation packages may live under `src/internal/<family>/` when a
family's public API can remain in the facade while raw externs or helper logic
move out of the public package root. Pure helper packages under `src/internal/`
must not import the facade or raise facade-owned errors; the facade keeps error
mapping. The first accepted probe is
`src/internal/version`: it owns the raw Cairo version externs and UTF-8 decoding,
while `src/version.mbt` keeps the published `@cairoon.cairo_version()` and
`@cairoon.cairo_version_string()` functions as thin wrappers. The second
accepted probe is `src/internal/format`: it owns the raw
`cairo_format_stride_for_width` extern while `src/format.mbt` keeps the public
`Format` enum, constructors, and methods. The third accepted probe is
`src/internal/status`: it owns the raw status-message extern and UTF-8 decoding
while `src/status.mbt` keeps the public `Status` enum, constructors, and
methods. The fourth accepted probe is `src/internal/pdf`: it owns raw PDF
version query/string helpers while `src/pdf_surface.mbt` keeps public
`PDFVersion` constructors and object-surface wrappers. The fifth accepted probe
is `src/internal/ps`: it owns raw PostScript level query/string helpers while
`src/ps_surface.mbt` keeps public `PSLevel` constructors and object-surface
wrappers. The sixth accepted probe is `src/internal/svg`: it owns raw SVG
version query/string helpers while `src/svg_surface.mbt` keeps public
`SVGVersion` constructors and object-surface wrappers. The seventh accepted
probe is `src/internal/stream`: it owns pure stream callback chunk-copy helpers
used by the Device and Surface raw owner packages, while public stream methods
and `Status` conversion stay in the facade. The eighth accepted probe is
`src/internal/cstring`: it owns pure
embedded-NUL byte scanning, while `check_no_embedded_nul` and the
`CairoInvalidArgument(InvalidString, _)` mapping stay in the facade. The ninth
accepted object seam is `src/internal/surface`: it owns all Surface-family raw
handles and externs, including retained PDF/PS/SVG/PNG callbacks, while the
public wrappers preserve every
constructor name, enum type, error, and generated interface entry. A native
ABI probe proved that an abstract public single-field wrapper around an
external raw handle is pointer-transparent across packages. Production FFI
must still use the explicit raw type; accepting public `Surface` directly is
forbidden even when its current representation is pointer-transparent. Raster
callbacks adapt through `RawSurface` plus primitive extents in the Pattern
child and retain black-box owner/lifetime coverage. Adding a second field to
any object facade remains a compatibility change requiring interface and
behavior review.
Keep enum
constructors in the facade unless a compatibility proof shows that
`@cairoon.<Constructor>` syntax survives. Any internal package that imports
`CAIMEOX/cairoon/native` receives propagated Cairo linker flags from the module
build script; internal packages must not carry `cc-link-flags`, and
`moon test src/internal/<family> --target native` must link independently. A
child package that can construct a valid value through its own production API
must have package-local tests. A producer-only handle package such as
`src/internal/path`, whose valid values can only come from facade-owned Context
or Pattern APIs, must not add a test-only constructor or C export merely to
manufacture a local fixture. Instead, external black-box tests must cover every
real producer and consumer, output and object status errors, use after the
source object's scope ends, and finalizer/allocation stress under ASan/LSan.

Do not move a type whose methods raise `CairoError` into a subpackage until the
error/status family has its own proven non-cyclic package seam. A child package
must not import the public `CAIMEOX/cairoon` facade just to reuse facade errors,
because the facade imports child packages. Also do not move public enums or
suberrors whose constructors are part of the facade syntax until a compatibility
proof exists: MoonBit `pub type` aliases preserve the type and its methods, but
they do not re-export enum variants or suberror constructors as
`@cairoon.<Constructor>`. This currently blocks moving `Status`, `CairoError`,
`PathDataType`, and similar facade-constructor enums directly into child
packages. `src/internal/status` is not a proof that `Status` or `CairoError`
can move; it is only a non-cyclic raw-message helper because it accepts raw
`Int` status values and returns `String`. A facade alias also cannot define
additional methods for the child type, so a moved value type must carry its
complete public method set in the child package. Keep values such as text/font
extents in the facade until their error dependencies can move with them or a
wrapper design is proven. Backend helper packages such as `src/internal/pdf`,
`src/internal/ps`, and `src/internal/svg` must not import the public `Surface`
wrapper. When a backend needs an object handle, it must use
`@surface_impl.RawSurface` and preserve an acyclic package graph. Pure internal
helper packages
such as `src/internal/stream` and `src/internal/cstring` may expose small
public helper functions to the facade when they have no dependency on
facade-owned types, enum constructors, or `CairoError` suberrors.

The public package root is frozen migration debt. Do not add new source-like
files directly under `src/`; put new implementation in the package selected by
the current migration step and update `PROJECT_LAYOUT.md` only when a deliberate
new root exception is unavoidable. The layout gate checks
`scripts/public-package-root-allowlist.txt` to make this enforceable. Treat the
root and public-package-root allowlists as exact ledgers: when a migration slice
moves a grandfathered file into a child package, remove that filename from the
matching allowlist in the same commit so the old location cannot reappear under
the same name.

When a new Cairo family is migrated, create a new C file named after that
family instead of adding unrelated code to an existing file. Public C files
must live beside `src/native/moon.pkg`; test-only oracle C files must live
beside `src/tests/oracle/native/moon.pkg`. Keep files small enough to review as
a coherent object-family binding. If a file grows past the scale of pycairo's
corresponding file without a concrete reason, split it before adding more API
surface.

## Public API Policy

Follow Cairo's C API closely, adjusted only for MoonBit's type and error
system.

- Public APIs must be safe wrappers. Raw `extern "C"` declarations stay private
  in `ffi.mbt` or native-gated `ffi_*.mbt` files.
- Public APIs that can observe a Cairo error must be declared
  `raise CairoError`.
- Do not expose `cairo_reference`, `cairo_destroy`, `cairo_surface_reference`,
  `cairo_surface_destroy`, or the equivalent reference-management functions for
  patterns, fonts, regions, devices, or paths.
- Do not expose raw pointers.
- Do not rely on MoonBit payload `struct` or payload `enum` layout across FFI.
  When a C struct must cross the boundary, split it into primitive fields in a
  C stub or keep it in a MoonBit-managed external object.
- The first full-product scope is the portable pycairo API surface that can be
  built and verified on this workspace's Cairo installation: image, PDF, PS,
  SVG, recording, script, tee, device, context, pattern, font, path, and region
  families. Platform-native pycairo surfaces such as Win32, XCB, and Xlib are
  explicit product decisions out of this portable scope until cairoon grows a
  separately designed conditional extension layer with matching headers,
  link flags, and CI/test environments.

## Object Mapping

Cairo has an object taxonomy with subtype-like surface and pattern kinds.
MoonBit does not need to mimic CPython inheritance. The binding must preserve
ownership first, then expose convenience APIs.

| Cairo concept | MoonBit representation | Ownership rule |
|---|---|---|
| `cairo_t *` | Public `type Context` wrapping internal `RawContext` | `RawContext` is the sole external object and its finalizer calls `cairo_destroy`; `Context` holds exactly one strong reference and has no second finalizer. |
| `cairo_surface_t *` | Public `Surface` wrapping internal `RawSurface` | `RawSurface` is the sole external object and its finalizer calls `cairo_surface_destroy`; `Surface` holds exactly one strong reference and has no second finalizer. |
| Image/PDF/SVG/PS/Recording/Tee/script surfaces | Constructors and checked methods returning/accepting `Surface` | Every subtype uses the same `RawSurface` owner; never introduce subtype-specific owners or finalizers. |
| `cairo_surface_map_to_image` result | Public `MappedImageSurface` wrapping internal `RawMappedImageSurface` | The raw mapped payload owns the active map and retains its base `RawSurface`; explicit unmap or its finalizer unmaps exactly once and releases the base. The facade has no finalizer. |
| Mutable image data view | Public `ImageData` wrapping internal `RawImageData` | The raw view retains its `RawSurface` or `RawMappedImageSurface` owner, never owns the pixel pointer, and releases only that retained owner. Access after finish/unmap raises the owner status. |
| `cairo_pattern_t *` | Public `type Pattern` wrapping internal `RawPattern` | `RawPattern` is the sole external object and its finalizer calls `cairo_pattern_destroy`; `Pattern` holds exactly one strong reference and has no second finalizer. |
| Solid/surface/gradient/mesh/raster-source patterns | Constructors and checked methods returning/accepting `Pattern` | Do not duplicate pattern ownership for subtypes; cross-family bridges exchange `RawPattern` beneath the facade. |
| `cairo_font_face_t *` | Public `type FontFace` wrapping internal `RawFontFace` | `RawFontFace` is the sole external object and its finalizer calls `cairo_font_face_destroy`; `FontFace` holds exactly one strong reference and has no second finalizer. |
| `cairo_scaled_font_t *` | Public `type ScaledFont` wrapping internal `RawScaledFont` | `RawScaledFont` is the sole external object and its finalizer calls `cairo_scaled_font_destroy`; `ScaledFont` holds exactly one strong reference and has no second finalizer. |
| `cairo_scaled_font_text_to_glyphs` result | Internal `RawTextToGlyphs` | Private external object; its finalizer frees Cairo glyph and cluster arrays exactly once. Public APIs copy all fields into pure MoonBit values before the raw result becomes unreachable. |
| `cairo_font_options_t *` | Public `type FontOptions` wrapping internal `RawFontOptions` | `RawFontOptions` is the sole external object and its finalizer calls `cairo_font_options_destroy`; `FontOptions` holds exactly one strong reference and has no second finalizer. |
| `cairo_region_t *` | Public `type Region` wrapping internal `RawRegion` | `RawRegion` is the sole external object and its finalizer calls `cairo_region_destroy`; `Region` holds exactly one strong reference and has no second finalizer. |
| `cairo_device_t *` | Public `type Device` wrapping internal `RawDevice` | `RawDevice` is the sole external object and its finalizer calls `cairo_device_destroy`; `Device` holds exactly one strong reference and has no second finalizer. |
| `cairo_path_t *` | Public `type Path` wrapping internal `RawPath` | `RawPath` is the sole external object and its finalizer calls `cairo_path_destroy`; `Path` holds exactly one strong reference and has no second finalizer. |
| `cairo_matrix_t` | Pure MoonBit value, e.g. `struct Matrix { xx : Double, yx : Double, xy : Double, yy : Double, x0 : Double, y0 : Double }` | No external finalizer. C stubs convert to/from fields. |
| `cairo_rectangle_t` | Pure MoonBit value with `Double` fields | No external finalizer. |
| `cairo_rectangle_int_t` | Pure MoonBit value with `Int` fields | No external finalizer. |
| `cairo_glyph_t` | Pure MoonBit value with `UInt`/`Double` fields | Marshal arrays through C stubs. |
| `cairo_text_cluster_t` | Pure MoonBit value with `Int` fields | Marshal arrays through C stubs. |
| `cairo_text_extents_t`, `cairo_font_extents_t` | Pure MoonBit values | Return as values from safe wrappers. |
| C enums and flags | MoonBit constant enums with explicit integer values | Keep values synchronized with Cairo headers. |

If a future typed wrapper such as `ImageSurface` is added, it must be a pure
MoonBit wrapper around one `Surface` owner. It must not own or finalize the
same C pointer separately.

`scripts/lifetime/owners.json` is the executable owner registry. It must contain
exactly one row for every `Raw*` type declared by production `ffi*.mbt` files
and exactly one row for every finalizer in `src/native/cairoon_objects.c`.
The names are structural: `RawX` must map to `CairoonX` and the snake-case
`cairoon_x_finalize`; aliases or exceptions are forbidden.
Each row names the declaration file, C payload struct, finalizer, every release
action, and a helper reached unconditionally inside a top-level loop of at
least 1000 iterations in a `*_test.mbt` file beside its own
`src/tests/lifetime/**/moon.pkg`. The helper's allocation anchor must also be a
top-level executed expression, not a comment, literal, or conditional branch.
Any new raw owner, moved declaration, changed allocator struct, changed release
action, or replacement stress path must update the registry in the same commit.
`scripts/check-external-owners.py` must reject missing, duplicate, and stale
rows rather than inferring that a broad sanitizer run probably covered them.

Subtype-specific surface methods, such as recording/PDF/SVG/PS helpers, must
first check `cairo_surface_status`, then check `cairo_surface_get_type` in the C
stub. A valid surface of the wrong subtype must return
`CAIRO_STATUS_SURFACE_TYPE_MISMATCH` and surface in MoonBit as `CairoError`.

Subtype-specific device methods, such as script-device helpers, must first
check `cairo_device_status`, then check `cairo_device_get_type` in the C stub.
A valid device of the wrong subtype must return
`CAIRO_STATUS_DEVICE_TYPE_MISMATCH` and surface in MoonBit as `CairoError`.

Matrix methods use MoonBit value semantics. Methods corresponding to pycairo's
mutating `translate`, `scale`, `rotate`, and `invert` return a transformed copy
instead of modifying the receiver in place. This is the project-level parity
rule for `Matrix`; tests must compare the returned value with Cairo/pycairo
behavior.

## C Stub Rules

Every external object wrapper uses this pattern:

```c
typedef struct {
  cairo_surface_t *ptr;
} CairoonSurface;

static void cairoon_surface_finalize(void *self) {
  CairoonSurface *surface = (CairoonSurface *)self;
  if (surface->ptr != NULL) {
    cairo_surface_destroy(surface->ptr);
    surface->ptr = NULL;
  }
  /* Never free self. MoonBit owns the external object container. */
}

MOONBIT_FFI_EXPORT
CairoonSurface *cairoon_surface_wrap_owned(cairo_surface_t *ptr) {
  CairoonSurface *surface = moonbit_make_external_object(
    cairoon_surface_finalize,
    sizeof(CairoonSurface)
  );
  surface->ptr = ptr;
  return surface;
}
```

Concrete requirements:

- A wrapper named `wrap_owned` consumes one Cairo reference and must either
  return a MoonBit object or destroy that reference before returning an error.
- A wrapper named `wrap_borrowed` must call the matching Cairo `*_reference`
  before calling `wrap_owned`.
- Finalizers must be idempotent: check `ptr != NULL`, destroy once, then set it
  to `NULL`.
- Public `finish` methods call Cairo's `*_finish` but must not clear the stored
  pointer. The finalizer still owns and destroys the resource.
- Every Surface constructor or borrowed-return bridge produces exactly one
  `RawSurface`. An owned Cairo pointer is wrapped without incrementing it; a
  borrowed Cairo pointer is first referenced. Public `Surface::from_raw` adds
  no ownership and no finalizer.
- Every Context constructor returns one newly owned `RawContext`. The native
  payload must keep its target `RawSurface` or `RawMappedImageSurface` alive
  with `moonbit_incref` and release it in the `RawContext`
  finalizer. Public `Context` is only a strong single-field wrapper around that
  raw owner and has no independent finalizer.
- `Context::get_target` and `Context::get_group_target` receive borrowed Cairo
  surfaces; their raw C bridges must create referenced `RawSurface` owners and
  retain the correct MoonBit base. `Context::get_source` receives a borrowed
  pattern and must call `cairo_pattern_reference` before returning
  `RawPattern`; `Context::pop_group` already receives an owned pattern and must
  not add a reference. Font-options, font-face, and scaled-font getters must
  preserve their existing copy/reference contracts, while setters borrow raw
  handles only for the synchronous call.
- A `Pattern` created from a `RawSurface`, and any object whose C resource may
  borrow another Cairo resource, must retain the base MoonBit object in the
  same way.
- Every Pattern constructor wraps one newly owned `cairo_pattern_t *` exactly
  once as `RawPattern`. `Context::get_source` receives a borrowed Cairo
  pattern and the C bridge must call `cairo_pattern_reference`; `pop_group`
  returns an owned pattern. Context source/mask calls borrow `RawPattern` only
  for the call. A public `Pattern` is only a strong single-field wrapper around
  the raw owner and has no independent finalizer.
- `Context::copy_path`, `Context::copy_path_flat`, and
  `Pattern::mesh_get_path` return newly owned `cairo_path_t *` values and must
  wrap them exactly once as `RawPath`. A public `Path` is only a strong
  single-field wrapper around that raw owner. `Context::append_path` borrows
  the raw handle for the duration of the call; copied paths are independent
  and do not retain their source Context or Pattern.
- `Device::script` and `Device::script_stream` return newly owned
  `cairo_device_t *` values and must wrap them exactly once as `RawDevice`.
  `Surface::get_device` receives a borrowed Cairo device; the C bridge must
  call `cairo_device_reference` before returning the sole raw owner, and the
  facade must wrap it exactly once. Script-surface bridges borrow `RawDevice`
  only for the call; the resulting Cairo surface holds any native device
  reference required by Cairo.
- A script-stream writer closure crosses the call boundary and therefore must
  be `#owned`. Native stream state releases it on every construction failure
  or when the device is destroyed. The callback must copy its call-scoped
  `Bytes` chunk before invoking user code so a user-retained chunk remains
  valid after the native callback returns.
- `ScaledFont::new` wraps the newly owned `cairo_scaled_font_t *` exactly once
  as `RawScaledFont`. `Context::get_scaled_font` receives a borrowed Cairo
  scaled font; the C bridge must call `cairo_scaled_font_reference` before
  returning the sole raw owner. Context set only borrows `RawScaledFont` for
  the call, after which Cairo owns any native reference it requires.
- Temporary Cairo result containers such as `cairo_rectangle_list_t` must not
  cross the FFI boundary. The C stub must copy their primitive fields into a
  MoonBit-owned array, capture the Cairo status, destroy the Cairo container
  before returning, and let the public MoonBit wrapper rebuild pure value
  objects such as `Rectangle`.
- Temporary Cairo input arrays such as `cairo_glyph_t[]` and
  `cairo_text_cluster_t[]` must be built inside C stubs from primitive
  MoonBit-owned arrays. Public wrappers accept `ArrayView[Glyph]` or
  `ArrayView[TextCluster]`, split them into FixedArrays of primitive fields,
  borrow those arrays for one synchronous FFI call, and the C helper frees any
  temporary Cairo array before returning.
- Cairo-allocated output arrays such as the result of
  `cairo_scaled_font_text_to_glyphs` must be wrapped exactly once as internal
  `RawTextToGlyphs`; its finalizer calls the matching Cairo free functions. The
  public MoonBit wrapper must check the raw status and array dimensions, copy
  the arrays into pure values, convert raw flags, and never expose the raw
  result.
- Mapped image surfaces require a dedicated payload containing the base surface
  and mapped surface. Its finalizer must call `cairo_surface_unmap_image(base,
  mapped)` if the mapping is still active. The base `RawSurface` object must be
  retained while the mapping exists. Explicit unmap must null both C pointers
  and release the retained base so finalization cannot unmap or decref twice.
- `RawImageData` is a non-owning pixel view with an owning MoonBit edge. A view
  from an image surface retains that `RawSurface`; a view from a mapped image
  retains that `RawMappedImageSurface`. Its finalizer only clears its borrowed
  C pointers and decrefs the retained owner. Every access rechecks owner status,
  bounds, and mapped-image liveness before touching the pixel pointer.

## FFI Ownership Annotations

`scripts/check-ffi-ownership.py` is the executable declaration policy. Its raw
object set must include `RawSurface`, `RawMappedImageSurface`, and
`RawImageData`; production FFI must not use public `MappedImageSurface` or
`ImageData` in place of those handles. Public object types remain recognized
by the checker so any accidental facade-typed extern still requires explicit
ownership and is visible in review, but production callback ABIs must use raw
owner-package handles. The checker must reject duplicate C symbol
declarations and exports, missing `MOONBIT_FFI_EXPORT` definitions, native
exports with no production extern, and drift in the exact public-facade callback
set. The 349 cairoon production externs and native exports must be a one-to-one
set; only `cairo_version` and `cairo_format_stride_for_width` may bind directly
to libcairo. The exact public-facade callback set is empty: `src/*.mbt` must
contain no `extern "C"` declarations. Pattern, Surface, and Device callbacks
live in their raw owner packages and expose callback statuses as `Int`. A typed
facade method converts its enum to
the child package's raw `Int`; it must not redeclare the same C symbol with a
facade enum or `Ref[Status]`, because clean native compilation would otherwise
emit incompatible generated-C prototypes. Test-only MoonBit-callable C probes
must be exported by `src/tests/oracle/native`, never by `src/native`.

Use these annotation defaults:

- Borrow all object handles for ordinary methods:

  ```moonbit
  #borrow(ctx)
  extern "C" fn context_paint_ffi(ctx : RawContext) -> Int = "cairoon_context_paint"
  ```

- Borrow pure input buffers only if Cairo does not store the pointer after the
  call.
- Use `#owned(buffer)` when Cairo stores a MoonBit buffer. Store that object in
  the C payload and call `moonbit_decref(buffer)` in the finalizer.
- Use `#borrow(out)` for `Ref[Int]`, `Ref[Double]`, and other output cells.
- Never leave a non-primitive parameter without an explicit ownership
  annotation.

For `ImageSurface.create_for_data`, Cairo keeps the pixel pointer. Therefore:

- The public API should accept a mutable byte buffer type suitable for pixels.
- The C stub must validate `height * stride <= buffer_length` before calling
  Cairo.
- The C stub must keep the MoonBit buffer alive until the surface is destroyed.
- This API must not be implemented with a borrowed buffer.

## Strings And Bytes

Cairo string APIs expect UTF-8 `const char *`.

- Do not pass MoonBit `String` directly to C.
- Public APIs may accept `String`, but must encode it to UTF-8 `Bytes` before
  FFI.
- Raw FFI declarations must accept `Bytes` for C strings.
- Validate that input strings do not contain embedded NUL before calling C APIs
  that use NUL-terminated strings.
- C-to-MoonBit strings must be returned as `Bytes` created by
  `moonbit_make_bytes`, then decoded by the MoonBit wrapper.
- Any `const char *` returned by Cairo is borrowed unless the Cairo manual says
  otherwise. Copy it into MoonBit-owned bytes before returning.

## Error Model

Define one public suberror family:

```moonbit
suberror CairoError {
  CairoError(status~ : Status, message~ : String)
  CairoMemoryError(status~ : Status, message~ : String)
  CairoIOError(status~ : Status, message~ : String)
  CairoInvalidArgument(status~ : Status, message~ : String)
} derive(Debug)
```

The `Status` type must represent `cairo_status_t` with explicit integer values.

All safe wrappers follow this rule:

```moonbit
pub fn Surface::flush(self : Surface) -> Unit raise CairoError {
  check_status(surface_flush_ffi(self))
}
```

Mapping rules:

- `CAIRO_STATUS_SUCCESS` returns normally.
- `CAIRO_STATUS_NO_MEMORY` raises `CairoMemoryError`.
- `CAIRO_STATUS_READ_ERROR`, `CAIRO_STATUS_WRITE_ERROR`, and
  `CAIRO_STATUS_PNG_ERROR` raise `CairoIOError`.
- Input validation failures detected before calling Cairo raise
  `CairoInvalidArgument`.
- All other non-success statuses raise `CairoError`.

Important Cairo-specific rules:

- Cairo constructors often return non-null "nil" objects in an error state.
  Every constructor wrapper must check the new object's status before returning.
- Mutating context methods must check `cairo_status(ctx)` after the C call.
- Mutating surface methods must check `cairo_surface_status(surface)` after the
  C call.
- Pattern/font/device/region methods must check the matching object status when
  Cairo can store an error on that object.
- Methods returning status directly must map that status immediately.
- Do not make users call `status()` to discover errors. `status()` may exist
  for diagnostics, but it is not the primary error path.

For a non-raising API layer, expose explicit result adapters rather than
duplicating the binding:

```moonbit
pub fn run_cairo[T](f : () -> T raise CairoError) -> Result[T, CairoError] {
  Ok(f()) catch { e => Err(e) }
}
```

## Callback APIs

Implement callbacks only after the non-callback surface/context/pattern core is
stable under ASan.

Initial callback policy:

- Filename APIs come first: PNG/PDF/SVG/PS creation by path is required before
  stream APIs.
- A callback crossing Cairo must not let a MoonBit error unwind through Cairo C
  frames.
- If the callback can fail, the trampoline must catch or encode the failure,
  return the appropriate `cairo_status_t`, and let the public wrapper raise
  after Cairo returns.
- C-held callback state must retain every MoonBit closure or object it stores
  with `moonbit_incref` and release it with `moonbit_decref`.
- Raster source patterns, user fonts, PNG streams, and PDF/SVG/PS stream
  surfaces require dedicated lifetime tests before they are considered done.

If no tested error-propagation trampoline exists for a callback family, expose
only `noraise` callbacks or defer the API.

## Migration Order

Implement in this order:

1. Build skeleton: `moon.mod`, `src/moon.pkg`, `ffi.mbt`,
   `src/native/moon.pkg`, `cairoon_private.h`, and split `cairoon_*.c` stub
   files.
2. Version and enums: `cairo_version`, `cairo_version_string`, constants.
3. Value types: `Matrix`, `Rectangle`, `RectangleInt`, extents structs.
4. `Surface` and `ImageSurface` constructors, `flush`, `finish`,
   `write_to_png(path)`, `get_width`, `get_height`, `get_stride`,
   `get_format`, `get_data` if a safe view design exists.
5. `Context` with basic drawing: `new`, `scale`, `set_line_width`, `move_to`,
   `line_to`, `curve_to`, `rectangle`, `set_source_rgb(a)`, `paint`, `fill`,
   `stroke`, `save`, `restore`.
6. `Pattern`: solid, surface pattern, linear/radial gradients.
7. `Region`, font options, toy font face, scaled font, path copy/iteration.
8. PDF/SVG/PS/Recording/Tee/device backends behind Cairo feature gates.
9. Callback-heavy APIs: streams, raster source, user fonts.

Do not start a later phase by weakening ownership or error rules from an
earlier phase.

## Public Documentation Contract

Every user-facing declaration in the public facade or an intentionally
published support package must have a substantive MoonBit `///` Markdown doc
comment immediately before the declaration. The empty `///|` block marker is
required for source structure but does not count as documentation. Public
methods re-exported through a facade type alias, such as `Glyph`, must be
documented in their owning package as well.

MoonBit types are abstract and externally nameable by default. A declaration
such as `struct Context(...)` is therefore public documentation surface even
without a `pub` modifier; only `priv` types are excluded from the audit.

Documentation must state the behavior a caller needs to use the API correctly:

- ownership or retained-lifetime behavior for object-returning and callback
  APIs;
- raised `CairoError` classes and important finished/type-mismatch cases;
- Cairo version or backend requirements where behavior is conditional;
- raw-integer compatibility semantics for every `*_raw` entry point;
- units, coordinate spaces, buffer layout, and mutation effects where they are
  not obvious from the signature.

Use executable `mbt check` examples in `src/docs/*.mbt.md` for family workflows
and nontrivial edge cases. A doc comment may link to those family notes instead
of repeating a large example, but a bare method name or signature is not a
description.

`scripts/check-public-docs.py` audits every public declaration in direct
`src/*.mbt` facade files and the three intentionally published support owners:
`src/core/constants/constants.mbt`, `src/core/glyph/glyph.mbt`, and
`src/native/native_anchor.mbt`. The executable `src/docs/prelude.mbt` package
contains only `pub using` aliases whose declarations are audited at their
owners, so aliases are not counted a second time. Declarations in `internal`
packages and test-only source files are not downstream product API and are
excluded.

`scripts/public-docs-debt.txt` is an exact, sorted grandfather list: it may only
shrink, and documenting a declaration must remove its entry in the same commit.
New public declarations must be documented when introduced and must never be
added to the debt ledger. The Docs inventory row remains `Partial` until the
checker reports zero debt entries.

## Test Suite Assessment

`TESTING.md` is the executable testing and reliability strategy. This section
summarizes the reasoning that led to those gates.

The pycairo repository has 20 Python test files and 288 `test_` functions.
The largest groups are:

- `test_surface.py`: 68 tests
- `test_context.py`: 68 tests
- `test_font.py`: 35 tests
- `test_pattern.py`: 31 tests
- `test_api.py`: 16 tests
- `test_region.py`: 12 tests
- `test_matrix.py`: 11 tests
- `test_device.py`: 11 tests

This is a strong reference suite for API behavior, but it is not sufficient by
itself to prove a MoonBit migration reliable.

What it covers well:

- Method-level behavior for contexts, surfaces, patterns, fonts, regions, paths,
  rectangles, matrices, glyphs, text clusters, and text extents.
- Cairo status-to-error translation for many invalid operations.
- Optional Cairo feature gates such as PDF/SVG/PS/script/tee and newer Cairo
  versions.
- File path and PNG round trips.
- Some buffer lifetime cases, mapped image surfaces, MIME data, and raster
  source callbacks.
- pycairo's external C API via `tests/cmodule`.

What does not transfer directly:

- CPython type errors, `memoryview`, GIL behavior, reference counts,
  `PyCapsule`, `PyBuffer`, and Python extension API tests.
- Static typing tests for `cairo/__init__.pyi`.
- Python file-like object behavior. Cairoon represents these paths with
  explicit MoonBit stream callbacks instead of Python file objects.
- Python-specific object identity and subclass behavior.

MoonBit reliability requirements and remaining work:

- `moon check --target native --deny-warn --warn-list +73` must pass from a
  clean build. `scripts/verify.sh` must run that exact command, and
  `scripts/check-reliability-ledger.py` must reject a downgrade that omits the
  unnecessary-annotation check.
- ASan/LSan runs for every C stub path.
- Keep sanitizer infrastructure split by responsibility:
  `scripts/sanitizers/run.py` owns only CLI and per-package orchestration,
  `toolchain.py` owns compiler discovery, sanitizer preflights, wrappers, and
  the isolated MoonBit toolchain, `leak_probes.py` owns standalone Cairo leak
  classification and exact suppression accounting, and `policy.py` owns
  option construction. Re-exporting compatibility names from `run.py` is
  allowed; moving their implementations back into the entry point is not.
- Stress tests that force MoonBit GC/finalizers while Cairo objects reference
  each other.
- Differential rendering tests comparing cairoon output with pycairo or direct
  C Cairo output.
- Keep deterministic property tests for matrix, region, path, and rectangle
  operations. The required suites live in `src/tests/matrix/property`,
  `src/tests/region/core`, `src/tests/path/core`, and `src/tests/value/core`.
  Region tests must use an independent discrete-coverage oracle; Path tests
  must use an independent command/current-point model and replay checks;
  Rectangle tests must generate signed dimensions and invalid indexes. Do not
  replace these with assertions derived from the implementation under test.
- Fuzz tests for invalid enum/status/string/buffer/stride inputs.
- Explicit callback error-propagation tests.
- Cross-platform CI across Linux and macOS, with Cairo 1.15.10 and a current
  Cairo 1.18.x build.
- Keep CI capacity bounded without weakening release evidence. The workflow
  must group runs by workflow and Git ref, cancel an older in-progress run only
  when a newer run supersedes that same ref, and cap both native and sanitizer
  jobs at 60 minutes. `scripts/check-reliability-ledger.py` and its negative
  mutations must reject a broader concurrency group, disabled cancellation,
  removed timeout, conditional gate, or failure masking.

## Reliability Evaluation Plan

Use four gates. A feature is not migrated until it passes every applicable gate.

### Gate 1: API Inventory

Maintain a migration table derived from `cairo/__init__.pyi`.

The derivation must remain executable outside the parent pycairo checkout.
`scripts/api/pycairo-api-snapshot.json` pins the upstream commit, exact stub
SHA-256, top-level APIs, ordinary class methods, Python protocols/constructors,
class attributes, constants, and enum aliases. The API checker must reject
source/snapshot drift and require every ordinary method, protocol, and
attribute to have exactly one type-scoped MoonBit interface mapping or explicit
product Decision. It must report the same complete counts when the parent stub
is absent from an extracted publication archive.

Each public item is one of:

- `Done`: implemented, tested, documented, and included in
  `src/pkg.generated.mbti`.
- `Partial`: some API or behavior exists, but feature parity is not proven.
- `Todo`: no MoonBit binding yet.
- `Decision`: product scope or platform policy must be pinned before
  implementation.

For MVP, require `Done` or an explicit documented `Decision` for every item in:

- version functions
- enums/status
- `Matrix`
- `Surface`/`ImageSurface`
- core `Context`
- solid/surface/linear/radial `Pattern`

### Gate 2: Behavioral Parity

Port the pycairo tests that express Cairo semantics rather than Python
semantics.

Required MVP parity tests:

- Matrix construction, multiplication, inversion, transform point/distance.
- Image surface construction, stride calculation, flush/finish, PNG round trip.
- Core context drawing and status errors such as invalid restore/pop group.
- Solid and gradient pattern creation and color stop inspection.
- Region boolean operations and rectangle bounds.
- Error mapping for no memory, invalid matrix, invalid restore, invalid stride,
  read/write errors where reachable.

Do not port tests whose only assertion is Python argument parsing behavior.
Replace them with MoonBit type-checking or explicit invalid-value tests.

### Gate 3: Differential Rendering

For every drawing feature, create a deterministic rendering case:

1. Render with pycairo to ARGB32 PNG or raw image bytes.
2. Render the same scene with cairoon.
3. Compare width, height, stride, format, and pixel bytes.

Use exact byte equality for image surfaces rendered by the same Cairo version.
If different Cairo versions are used, allow a documented per-channel tolerance
only for antialiasing-sensitive cases.

MVP scenes:

- solid fill
- stroked line
- rectangle fill and stroke
- Bezier curve
- scale/translate/rotate matrix
- RGBA source over transparent background
- linear gradient
- radial gradient
- text only after font APIs are ported

### Gate 4: Memory And Lifetime

Run all native tests under ASan before merging any C-stub change.

Required lifetime tests:

- Dropping a `Surface` after dropping every `Context` that used it.
- Dropping a `Context` while its target `Surface` is still live.
- Returning borrowed resources such as `get_target`, `get_source`, or
  `get_font_face` and dropping either the parent or returned object first.
- `ImageSurface.create_for_data`: drop the original MoonBit buffer variable,
  draw, flush, read pixels, then drop the surface.
- `SurfacePattern`: drop the source `Surface` before the pattern and use the
  pattern.
- Mapped image surface: drop without explicit unmap, explicit unmap then drop,
  wrong-base unmap, double unmap.
- Callback APIs: register callback, force collection pressure, invoke callback,
  then clear callback and verify no use-after-free or leak under ASan.

All finalizers must be exercised by tests that allocate and release at least
1000 objects in a loop under ASan.

Deterministic fuzz tests must derive operation dispatch and operation-local
scenario selection from independent values. Reusing one remainder for both is
forbidden when it can make a claimed success, error, cleanup, or ownership path
unreachable. Every claimed path class must increment an explicit runtime
counter. Fixed-seed finalizer graph suites must assert the exact expected
counter distribution, not merely that every counter is nonzero.
Fixed-seed or fixed-step callback fuzz suites whose behavior depends on two
selectors must also assert the exact flattened cross-distribution (for example,
operation by status or mode by color). Marginal totals and nonzero assertions
are insufficient. Keep backend-controlled callback invocation counts out of
that exact selector contract unless Cairo documents a stable count.

## Definition Of Done

A migrated API is done only when:

- Public MoonBit wrappers compile with
  `moon check --target native --deny-warn --warn-list +73`.
- Tests pass with `moon test --target native --deny-warn`.
- `scripts/verify.sh` treats MoonBit compiler warnings as release blockers for
  native check, support-package tests, extracted black-box/oracle tests, full
  native tests, and targeted clang/ASan test-package runs.
- All production and oracle C stubs compile as C11 with `-Wall -Wextra`,
  `-Wpedantic`, and `-Werror`; the project-layout gate rejects removal or
  reordering of any required flag.
- ASan run is clean.
- Every non-primitive parameter in production `src/**/ffi*.mbt` raw FFI files
  has an explicit `#borrow` or `#owned`.
- Every Cairo-owned pointer has exactly one MoonBit external-object owner.
- `scripts/check-external-owners.py` proves every raw owner has one native
  finalizer and an allocation anchor reached by a 1000-iteration lifetime test.
- Every borrowed Cairo return that escapes to MoonBit is referenced before
  wrapping.
- Every public failing operation raises `CairoError` or a documented suberror
  variant.
- Every publication archive contains `COPYING`, the complete LGPL-2.1 and
  MPL-1.1 texts declared by `moon.mod`, the package README/interface, and the
  dependency pre-build script plus the pinned pycairo API snapshot; duplicate,
  unsafe, corrupt, or integration members fail
  `scripts/check-publication-archive.py`.
- The API inventory marks the item as `Done` with a test reference.
