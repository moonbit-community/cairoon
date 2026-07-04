# cairoon: MoonBit Cairo Binding Engineering Guide

This directory is the MoonBit workspace for a Cairo binding. Treat this file as
the binding specification and implementation checklist.

## Required Context

Before changing binding code, read the `moonbit-c-binding` skill. The relevant
MoonBit rules are:

- Native C FFI is the first supported target. The LLVM backend is not a target
  for this binding until MoonBit documents FFI support for it.
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

Use this layout unless there is a concrete reason to change it:

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
  ffi_font.mbt
  ffi_image_data.mbt
  ffi_pattern.mbt
  ffi_pattern_mesh.mbt
  ffi_pattern_raster_source.mbt
  ffi_path.mbt
  ffi_pdf_surface.mbt
  ffi_ps_surface.mbt
  ffi_surface.mbt
  ffi_svg_surface.mbt
  ffi_tee_surface.mbt
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
  cairoon_raster_source_pattern.c
  cairoon_mesh_pattern.c
  cairoon_font_options.c
  cairoon_font_face.c
  cairoon_scaled_font.c
  cairoon_scaled_font_oracle.c
  cairoon_region.c
  tests/
```

The module config must prefer native builds:

```moonbit
preferred_target = "native"
```

The package config must gate raw FFI code to native and compile the stub:

```moonbit
options(
  "native-stub": [
    "cairoon_objects.c",
    "cairoon_stream.c",
    "cairoon_misc.c",
    "cairoon_test_common.c",
    "cairoon_test_file.c",
    "cairoon_test_vector.c",
    "cairoon_test_vector_scenes.c",
    "cairoon_test_pdf_vector.c",
    "cairoon_test_ps_vector.c",
    "cairoon_test_svg_vector.c",
    "cairoon_test_image.c",
    "cairoon_device.c",
    "cairoon_surface.c",
    "cairoon_surface_png.c",
    "cairoon_surface_mime.c",
    "cairoon_surface_state.c",
    "cairoon_surface_font_options.c",
    "cairoon_image_surface.c",
    "cairoon_mapped_image_surface.c",
    "cairoon_recording_surface.c",
    "cairoon_image_data.c",
    "cairoon_pdf_surface.c",
    "cairoon_ps_surface.c",
    "cairoon_svg_surface.c",
    "cairoon_tee_surface.c",
    "cairoon_context.c",
    "cairoon_context_font_text.c",
    "cairoon_context_matrix.c",
    "cairoon_context_state.c",
    "cairoon_context_path.c",
    "cairoon_context_clip_extents.c",
    "cairoon_context_paint.c",
    "cairoon_glyph.c",
    "cairoon_path.c",
    "cairoon_pattern.c",
    "cairoon_raster_source_pattern.c",
    "cairoon_mesh_pattern.c",
    "cairoon_font_options.c",
    "cairoon_font_face.c",
    "cairoon_scaled_font.c",
    "cairoon_scaled_font_oracle.c",
    "cairoon_region.c",
  ],
  targets: {
    "ffi.mbt": ["native"],
    "ffi_context_core.mbt": ["native"],
    "ffi_context_font_text.mbt": ["native"],
    "ffi_device.mbt": ["native"],
    "ffi_font.mbt": ["native"],
    "ffi_image_data.mbt": ["native"],
    "ffi_pattern.mbt": ["native"],
    "ffi_pattern_mesh.mbt": ["native"],
    "ffi_pattern_raster_source.mbt": ["native"],
    "ffi_path.mbt": ["native"],
    "ffi_pdf_surface.mbt": ["native"],
    "ffi_ps_surface.mbt": ["native"],
    "ffi_surface.mbt": ["native"],
    "ffi_svg_surface.mbt": ["native"],
    "ffi_tee_surface.mbt": ["native"],
    "ffi_region.mbt": ["native"]
  },
)
```

The legacy `moon.mod.json` format is still accepted by MoonBit, but this
workspace uses the current `moon.mod`/`moon.pkg` DSL generated by MoonBit
0.1.20260604 and documented in the MoonBit 0.10.1 toolchain docs.

Link to the system Cairo installation. Do not vendor Cairo into this repository
for the initial binding. Use `pkg-config --cflags --libs cairo` during setup to
derive `cc-flags` and `cc-link-flags`, then record the concrete flags in
`moon.pkg` for the target platform. Refresh those checked-in flags with
`scripts/configure-link-flags.sh`, and keep `scripts/configure-link-flags.sh
--check` in the local verification gate so `moon.pkg` cannot silently drift
away from the target platform's `pkg-config` result.

## Raw FFI File Boundaries

Raw `extern "C"` declarations may be split by Cairo concept family, mirroring
the C glue split. Keep object type declarations and very small module-level
exports in `ffi.mbt`; move larger families into files named
`ffi_<family>.mbt`, and add every such file to `moon.pkg` `targets` with
`["native"]`. For example, `ffi_font.mbt` owns the raw `FontOptions`,
`FontFace`, `ScaledFont`, and text-to-glyphs extern declarations that call
`cairoon_font_options.c`, `cairoon_font_face.c`,
`cairoon_scaled_font.c`, and `cairoon_scaled_font_oracle.c`;
`ffi_pattern.mbt` owns raw base/surface/solid/gradient `Pattern` extern
declarations that call `cairoon_pattern.c`; `ffi_pattern_mesh.mbt` owns raw
mesh-pattern extern declarations that call `cairoon_mesh_pattern.c`;
`ffi_pattern_raster_source.mbt` owns raw raster-source-pattern extern
declarations that call `cairoon_raster_source_pattern.c`;
`ffi_context_clip_extents.mbt` owns raw `Context` clip, extents, and
hit-testing extern declarations that call `cairoon_context_clip_extents.c`;
`ffi_context_core.mbt` owns raw `Context` construction, status, identity,
save/restore, tag, target/source, and group extern declarations that call the
core `cairoon_context.c` file;
`ffi_context_font_text.mbt` owns raw `Context` font-options, font-face, toy-font
selection, font-matrix, text, glyph, show-text-glyphs, and scaled-font extern
declarations that call `cairoon_context_font_text.c`;
`ffi_context_matrix.mbt` owns raw `Context` transform, current-transformation
matrix, identity-matrix, and user/device coordinate-conversion extern
declarations that call `cairoon_context_matrix.c`;
`ffi_context_path.mbt` owns raw `Context` path construction, current-point,
copy-path, and append-path extern declarations that call
`cairoon_context_path.c`;
`ffi_context_paint.mbt` owns raw `Context` source, paint, mask, fill, stroke,
and page-operation extern declarations that call `cairoon_context_paint.c`;
`ffi_context_state.mbt` owns raw `Context` drawing-state, line-style, and dash
extern declarations that call `cairoon_context_state.c`;
`ffi_device.mbt` owns raw `Device`, script-device, script-surface, and
surface-get-device extern declarations that call `cairoon_device.c`;
`ffi_image_data.mbt` owns raw `ImageData` and image/mapped get-data extern
declarations that call `cairoon_image_data.c`;
`ffi_path.mbt` owns raw `Path` extern declarations that call `cairoon_path.c`;
`ffi_pdf_surface.mbt` owns raw PDF surface extern declarations that call
`cairoon_pdf_surface.c`;
`ffi_ps_surface.mbt` owns raw PostScript surface extern declarations that call
`cairoon_ps_surface.c`;
`ffi_surface.mbt` owns raw image, recording, base surface, mapped-image-surface,
PNG stream, MIME-data, and surface font-options extern declarations that call
`cairoon_surface.c`, `cairoon_surface_png.c`,
`cairoon_surface_mime.c`, `cairoon_surface_state.c`,
`cairoon_surface_font_options.c`, `cairoon_image_surface.c`,
`cairoon_mapped_image_surface.c`, `cairoon_recording_surface.c`, and Cairo's
`cairo_format_stride_for_width`;
`ffi_svg_surface.mbt` owns raw SVG surface extern declarations that call
`cairoon_svg_surface.c`; `ffi_tee_surface.mbt` owns raw Tee surface extern
declarations that call `cairoon_tee_surface.c`; and `ffi_region.mbt` owns raw
`Region` extern declarations that call `cairoon_region.c`.

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
payload types and cross-file helpers declared in `cairoon_private.h`.

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
- `cairoon_raster_source_pattern.c`: raster-source callback and owner
  lifecycle exports.
- `cairoon_font_options.c`, `cairoon_font_face.c`,
  `cairoon_scaled_font.c`, and `cairoon_scaled_font_oracle.c`: font-options,
  toy-font-face, scaled-font, and scaled-font oracle exports.
- `cairoon_region.c`: `Region` exports.
- `cairoon_test_common.c`, `cairoon_test_file.c`,
  `cairoon_test_vector.c`, `cairoon_test_vector_scenes.c`,
  `cairoon_test_pdf_vector.c`, `cairoon_test_ps_vector.c`,
  `cairoon_test_svg_vector.c`, and `cairoon_test_image.c`: private white-box
  oracle helpers only. Keep public binding exports out of these files, and
  keep test oracles out of `cairoon_misc.c` except for truly tiny module-level
  probes. Keep vector-output exports in `cairoon_test_vector.c`; shared vector
  scene ids and prototypes belong in `cairoon_test_vector_private.h`; common
  drawing scenes belong in `cairoon_test_vector_scenes.c`; backend-specific
  feature renderers belong in the PDF/PS/SVG vector files.

When a new Cairo family is migrated, create a new C file named after that
family instead of adding unrelated code to an existing file. Keep files small
enough to review as a coherent object-family binding. If a file grows past the
scale of pycairo's corresponding file without a concrete reason, split it before
adding more API surface.

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
| `cairo_t *` | `type Context` | External object; finalizer calls `cairo_destroy`. |
| `cairo_surface_t *` | `type Surface` | External object; finalizer calls `cairo_surface_destroy`. |
| Image/PDF/SVG/PS/Recording/Tee surfaces | Constructors and checked methods returning/accepting `Surface` | Do not create a second MoonBit owner for the same `cairo_surface_t *`. |
| `cairo_pattern_t *` | `type Pattern` | External object; finalizer calls `cairo_pattern_destroy`. |
| Solid/surface/gradient/mesh/raster-source patterns | Constructors and checked methods returning/accepting `Pattern` | Do not duplicate pattern ownership for subtypes. |
| `cairo_font_face_t *` | `type FontFace` | External object; finalizer calls `cairo_font_face_destroy`. |
| `cairo_scaled_font_t *` | `type ScaledFont` | External object; finalizer calls `cairo_scaled_font_destroy`. |
| `cairo_font_options_t *` | `type FontOptions` | External object; finalizer calls `cairo_font_options_destroy`. |
| `cairo_region_t *` | `type Region` | External object; finalizer calls `cairo_region_destroy`. |
| `cairo_device_t *` | `type Device` | External object; finalizer calls `cairo_device_destroy`. |
| `cairo_path_t *` | `type Path` | External object; finalizer calls `cairo_path_destroy`. |
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
- `Context` created from a `Surface` must keep the target surface alive. Store
  the MoonBit `Surface` object inside the `Context` external payload and retain
  it with `moonbit_incref`; release it in the context finalizer.
- A `Pattern` created from a `Surface`, and any object whose C resource may
  borrow another Cairo resource, must retain the base MoonBit object in the
  same way.
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
  `cairo_scaled_font_text_to_glyphs` must be wrapped in an internal temporary
  external object whose finalizer calls the matching Cairo free functions. The
  public MoonBit wrapper must copy the arrays into pure values before exposing
  them.
- Mapped image surfaces require a dedicated payload containing the base surface
  and mapped surface. Its finalizer must call `cairo_surface_unmap_image(base,
  mapped)` if the mapping is still active. The base `Surface` object must be
  retained while the mapping exists.

## FFI Ownership Annotations

Use these annotation defaults:

- Borrow all object handles for ordinary methods:

  ```moonbit
  #borrow(ctx)
  extern "C" fn context_paint_ffi(ctx : Context) -> Int = "cairoon_context_paint"
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

1. Build skeleton: `moon.mod`, `moon.pkg`, `ffi.mbt`,
   `cairoon_private.h`, and split `cairoon_*.c` stub files.
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

What is missing for MoonBit reliability:

- ASan/LSan runs for every C stub path.
- Stress tests that force MoonBit GC/finalizers while Cairo objects reference
  each other.
- Differential rendering tests comparing cairoon output with pycairo or direct
  C Cairo output.
- Property tests for matrix, region, path, and rectangle operations.
- Fuzz tests for invalid enum/status/string/buffer/stride inputs.
- Explicit callback error-propagation tests.
- Cross-platform CI across Linux and macOS, with Cairo 1.15.10 and a current
  Cairo 1.18.x build.

## Reliability Evaluation Plan

Use four gates. A feature is not migrated until it passes every applicable gate.

### Gate 1: API Inventory

Maintain a migration table derived from `cairo/__init__.pyi`.

Each public item is one of:

- `Done`: implemented, tested, documented, and included in
  `pkg.generated.mbti`.
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

## Definition Of Done

A migrated API is done only when:

- Public MoonBit wrappers compile with `moon check --target native`.
- Tests pass with `moon test --target native`.
- ASan run is clean.
- Every non-primitive FFI parameter has an explicit `#borrow` or `#owned`.
- Every Cairo-owned pointer has exactly one MoonBit external-object owner.
- Every borrowed Cairo return that escapes to MoonBit is referenced before
  wrapping.
- Every public failing operation raises `CairoError` or a documented suberror
  variant.
- The API inventory marks the item as `Done` with a test reference.
