# cairoon

cairoon is a native MoonBit binding for the
[Cairo graphics library](https://cairographics.org/).

This project is temporarily unstable. It is useful for experiments and for
light Cairo-dependent MoonBit projects, but the public API, package layout,
native link configuration, and release process may still change before a stable
release. Treat versions before `1.0` as beta releases and pin them deliberately.

cairoon is inspired by pycairo: it tries to stay close to Cairo's C API, while
using MoonBit-native value types, checked `CairoError` suberrors, explicit
stream callbacks, and GC-managed external objects for Cairo handles.

The package is intentionally native-only while the binding depends on Cairo C
FFI. Module metadata declares native as the sole supported target;
WebAssembly, WasmGC, JavaScript, and LLVM backends are not supported.

## Requirements

- MoonBit with native target support.
- Cairo 1.15.10 or newer development headers and library.
- `pkg-config` that can resolve `cairo`.
- Python 3 for native pre-build configuration and repository verification.

## Native Link Configuration

`moon.mod` registers `scripts/build/cairo_config.py` with MoonBit's experimental
pre-build config protocol. Native builds resolve this machine's Cairo compiler
and linker flags through `pkg-config`; the native package propagates linking to
all downstream packages, so consumers must not duplicate `cc-link-flags`.
Because dependencies execute this script, use only trusted cairoon releases.

## Example

```mbt check
///|
test "README quick start draws a curve" {
  let surface = Surface::image(Argb32, 200, 200)
  let context = Context::new(surface)
  context.scale(200.0, 200.0)
  context.set_line_width(0.04)
  context.move_to(0.1, 0.5)
  context.curve_to(0.4, 0.9, 0.6, 0.1, 0.9, 0.5)
  context.stroke()
  context.set_source_rgba(1.0, 0.2, 0.2, 0.6)
  context.set_line_width(0.02)
  context.move_to(0.1, 0.5)
  context.line_to(0.4, 0.9)
  context.move_to(0.6, 0.1)
  context.line_to(0.9, 0.5)
  context.stroke()
  inspect(surface.copy_data().length() > 0, content="true")
}
```

## Features

- Object-oriented MoonBit wrappers for Cairo surfaces, contexts, patterns,
  paths, fonts, regions, and devices.
- Checked status handling through `Status` and `CairoError` suberrors instead
  of unchecked integer status returns.
- Image surfaces, buffer-backed image surfaces, PNG file/stream I/O, MIME data,
  mapped images, and mutable image-data views.
- PDF, PS, SVG, recording, tee, and script backend helpers for portable Cairo
  builds.
- Solid, surface, gradient, mesh, and raster-source patterns.
- Toy font faces, font options, scaled fonts, text extents, glyph extents,
  `text_to_glyphs`, and `show_text_glyphs`.
- Executable MoonBit reference examples in this file and in the family
  `*.mbt.md` documents listed below.

## Current Stability

cairoon is suitable for light native use when the required inventory rows are
marked `Done`, `./scripts/check-downstream-consumer.sh` passes, and the exact
version or commit is pinned. The complete portable API scope and all 20 pinned
pycairo test families are covered, and all 579 published declarations have
substantive API documentation.

Local release-candidate matrices on exact Cairo 1.15.10 and 1.18.4 pass 208/208
script tests, 841/841 native tests, 63/63 executable docs, 12/12 raw external
owners with exact finalizer and 1000-iteration stress evidence, including one
raw-result stress path that bans explicit release, source and extracted
consumers plus the unmodified cross-host archive consumer, all 664 publication
members, and every package under ASan/LSan/UBSan. The sole global `Partial` row
is shipped test/release-platform evidence: GitHub run 29678818105 passed macOS
native but failed both Ubuntu jobs on the prior release commit. The local fix
commit still needs passing Ubuntu and macOS native jobs plus the Ubuntu
ASan/LSan/UBSan job. It does not represent an unimplemented portable API
family, but it must close before a full-product claim. There is still no
source-compatibility promise before `1.0`.

Separately, an isolated Ubuntu 24.04 replay with its system Cairo 1.18.0 passes
all 841 native tests and every package under ASan/LSan/UBSan, including the
stripped-symbol fallback paths. This local replay does not replace the shipped
release-commit evidence required above.

The uppercase `CAIRO_VERSION*` and `HAS_*` constants are generated release
source snapshots. When consuming the same source archive with different Cairo
headers, use `cairo_version()` and `cairo_version_string()` for runtime version
decisions. This build-tool limitation is part of the pre-`1.0` instability
contract.

Platform-specific Xlib, XCB, and Win32 surfaces are outside the first portable
scope. Python-specific pycairo APIs such as `CAPI`, `get_include()`, Python
file objects, pickle behavior, and legacy uppercase enum aliases are not part
of the MoonBit API.

## Documentation

Additional executable reference notes are split by API family:

- `src/docs/status_and_version.mbt.md`: Cairo versions, feature constants,
  status diagnostics, and checked suberrors.
- `src/docs/enums.mbt.md`: typed enum families and raw compatibility
  boundaries.
- `src/docs/value_types.mbt.md`: rectangles, glyphs, text clusters, and
  extents.
- `src/docs/matrix.mbt.md`: pure-value affine transforms.
- `src/docs/surface.mbt.md`: image surfaces, buffer-backed data, mapped
  images, PNG/MIME helpers, and checked surface errors.
- `src/docs/backend_surfaces.mbt.md`: PDF/PS/SVG, recording, tee, and script
  backends.
- `src/docs/context.mbt.md`: drawing state, transforms, paths, clips, groups,
  text, and checked context errors.
- `src/docs/font.mbt.md`: FontOptions, FontFace, ScaledFont, text-to-glyphs,
  and checked font errors.
- `src/docs/path.mbt.md`: typed path segments and path ownership.
- `src/docs/pattern.mbt.md`: solid, surface, gradient, mesh, and raster-source
  patterns.
- `src/docs/region.mbt.md`: Region construction, rectangle queries, boolean
  operations, and checked error mapping.

Packaging, CI, and release rules live in the repository `PACKAGING.md`.
pycairo migration notes live in `PORTING_FROM_PYCAIRO.md`.

## Executable Smoke Tests

```mbt check
///|
test {
  inspect(cairo_version() > 0, content="true")
  inspect(cairo_version_string().contains("."), content="true")
  inspect(CAIRO_VERSION > 0, content="true")
  inspect(HAS_IMAGE_SURFACE, content="true")
  inspect(MIME_TYPE_JPEG, content="image/jpeg")
}

///|
test {
  let surface = Surface::image(Argb32, 16, 16)
  let ctx = Context::new(surface)
  ctx.translate(5.0, 7.0)
  ctx.scale(2.0, 3.0)
  ctx.set_dash([2.0, 1.0], offset=0.5)
  inspect(ctx.get_dash_count(), content="2")
  if CAIRO_VERSION >= 11800 {
    ctx.set_hairline(true)
    inspect(ctx.get_hairline(), content="true")
  } else {
    match run_cairo(() => ctx.set_hairline(true)) {
      Err(CairoError(InvalidStatus, _)) => ()
      _ => fail("expected hairline API to require Cairo 1.18")
    }
  }
  debug_inspect(ctx.user_to_device(1.0, 1.0), content="(7, 10)")
  ctx.identity_matrix()
  ctx.move_to(1.0, 1.0)
  ctx.rel_line_to(4.0, 0.0)
  inspect(ctx.has_current_point(), content="true")
  debug_inspect(ctx.get_current_point(), content="(5, 1)")
  ctx.new_path()
  ctx.rectangle(2.0, 2.0, 4.0, 4.0)
  debug_inspect(ctx.path_extents(), content="(2, 2, 6, 6)")
  debug_inspect(ctx.fill_extents(), content="(2, 2, 6, 6)")
  inspect(ctx.in_fill(3.0, 3.0), content="true")
  ctx.clip()
  inspect(ctx.in_clip(3.0, 3.0), content="true")
  inspect(ctx.in_clip(0.0, 0.0), content="false")
  inspect(ctx.copy_clip_rectangle_list().length(), content="1")
}

///|
test {
  let mask = Surface::image(Argb32, 1, 1)
  let mask_ctx = Context::new(mask)
  mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
  mask_ctx.paint()

  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  let source = ctx.get_source()
  inspect(source.status().is_success(), content="true")
  ctx.paint_with_alpha(0.5)
  ctx.mask_surface(mask)
  ctx.set_source_surface(mask)
  ctx.paint()
  ctx.copy_page()
  ctx.show_page()
  inspect(ctx.get_target().get_width(), content="1")
  inspect(ctx.status().is_success(), content="true")
}

///|
test {
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.push_group()
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  ctx.pop_group_to_source()
  ctx.paint()
  inspect(surface.copy_data()[2].to_int(), content="255")
}

///|
test {
  let ctx = Context::new(Surface::image(Argb32, 1, 1))
  ctx.tag_begin("foo", "")
  ctx.tag_end("foo")
  inspect(TAG_DEST, content="cairo.dest")
}

///|
test {
  let path = "/tmp/cairoon_readme_png_roundtrip.png"
  let surface = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(0.0, 1.0, 0.0, 0.5)
  ctx.paint()
  surface.write_to_png(path)
  let loaded = Surface::image_from_png(path)
  inspect(loaded.get_width(), content="1")
  inspect(loaded.copy_data() == surface.copy_data(), content="true")
}

///|
test {
  let surface = Surface::image(Argb32, 1, 1)
  let jpeg = @utf8.encode("encoded-bytes")
  surface.set_mime_data("image/jpeg", Some(jpeg))
  match surface.get_mime_data("image/jpeg") {
    Some(bytes) => inspect(bytes == jpeg, content="true")
    None => fail("expected image/jpeg MIME data")
  }
  surface.set_mime_data("image/jpeg", None)
  inspect(surface.get_mime_data("image/jpeg") is None, content="true")
}

///|
test {
  let data : FixedArray[Byte] = FixedArray::make(4, b'\x00')
  let surface = Surface::image_for_data(data, Argb32, 1, 1)
  let ctx = Context::new(surface)
  ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  ctx.paint()
  surface.flush()
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
test {
  let surface = Surface::image(Argb32, 4, 4)
  debug_inspect(surface.get_type(), content="SurfaceTypeImage")
  debug_inspect(surface.get_content(), content="ContentColorAlpha")
  surface.set_device_offset(2.0, -1.0)
  debug_inspect(surface.get_device_offset(), content="(2, -1)")
  surface.set_device_scale(2.0, 3.0)
  debug_inspect(surface.get_device_scale(), content="(2, 3)")
  surface.mark_dirty_rectangle(0, 0, 2, 2)

  let similar = surface.create_similar(ContentColor, 2, 2)
  debug_inspect(similar.get_content(), content="ContentColor")

  let image = surface.create_similar_image(Rgb24, 2, 3)
  debug_inspect(image.get_type(), content="SurfaceTypeImage")
  debug_inspect(image.get_format(), content="Rgb24")
  inspect(image.get_height(), content="3")

  let child = surface.create_for_rectangle(1.0, 1.0, 2.0, 2.0)
  inspect(child.status().is_success(), content="true")
}

///|
test {
  let device = Device::script("/tmp/cairoon_readme_script.cs")
  debug_inspect(device.get_type(), content="DeviceTypeScript")
  let acquired_type = device.with_acquired(() => device.get_type())
  debug_inspect(acquired_type, content="DeviceTypeScript")

  let surface = Surface::script(device, ContentColorAlpha, 4.0, 4.0)
  match surface.get_device() {
    Some(other) => inspect(device.equal(other), content="true")
    None => fail("expected script surface device")
  }
  device.script_write_comment("README smoke")
  device.flush()
}

///|
test {
  let recording = Surface::recording(
    ContentColorAlpha,
    extents=Some(Rectangle::new(0.0, 0.0, 1.0, 1.0)),
  )
  let recorder = Context::new(recording)
  recorder.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  recorder.paint()
  match recording.recording_get_extents() {
    Some(rect) => debug_inspect(rect.components(), content="(0, 0, 1, 1)")
    None => fail("expected recording extents")
  }
  inspect(recording.recording_ink_extents().width > 0.0, content="true")

  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
  ctx.set_source(Pattern::for_surface(recording))
  ctx.paint()
  inspect(target.copy_data()[2].to_int(), content="255")
}

///|
test {
  let version : SVGVersion = SvgVersion1_2
  inspect(SVGVersion::supported().any(item => item == version), content="true")
  inspect(version.to_string().contains("SVG"), content="true")

  let surface = Surface::svg(12.0, 12.0)
  surface.svg_set_document_unit(SvgUnitPx)
  debug_inspect(surface.svg_get_document_unit(), content="SvgUnitPx")
  surface.svg_restrict_to_version(version)
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
test {
  let version : PDFVersion = PdfVersion1_4
  inspect(PDFVersion::supported().any(item => item == version), content="true")
  inspect(version.to_string().contains("PDF"), content="true")

  let surface = Surface::pdf(12.0, 12.0)
  surface.pdf_restrict_to_version(version)
  surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon PDF")
  surface.pdf_set_page_label("page one")
  surface.pdf_set_thumbnail_size(2, 2)
  let outline_kinds : Array[PDFOutlineFlags] = [PdfOutlineOpen, PdfOutlineBold]
  let outline_flags = PDFOutlineFlagSet::combine(outline_kinds[:])
  let outline_id = surface.pdf_add_outline_with_flags(
    PDF_OUTLINE_ROOT,
    "chapter",
    "page=1",
    outline_flags,
  )
  inspect(outline_id > PDF_OUTLINE_ROOT, content="true")
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
test {
  let level : PSLevel = PsLevel3
  inspect(PSLevel::supported().any(item => item == level), content="true")
  inspect(level.to_string().contains("PS"), content="true")

  let surface = Surface::ps(12.0, 12.0)
  surface.ps_set_eps(true)
  inspect(surface.ps_get_eps(), content="true")
  surface.ps_restrict_to_level(PsLevel2)
  surface.ps_dsc_comment("%%Title: Cairoon PS")
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
test {
  let surface = Surface::image(Rgb24, 2, 1)
  let mapped = surface.map_to_image(
    extents=Some(RectangleInt::new(x=0, y=0, width=1, height=1)),
  )
  let ctx = Context::new_for_mapped_image(mapped)
  ctx.set_source_rgb(1.0, 1.0, 1.0)
  ctx.paint()
  mapped.unmap()
  let data = surface.copy_data()
  inspect(data[0].to_int(), content="255")
  inspect(data[4].to_int(), content="0")
}

///|
test {
  let gradient = Pattern::linear(0.0, 0.0, 10.0, 0.0)
  gradient.add_color_stop_rgb(0.0, 1.0, 0.0, 0.0)
  gradient.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 0.5)
  inspect(gradient.get_color_stop_count(), content="2")
  if CAIRO_VERSION >= 11800 {
    gradient.set_dither(DitherGood)
    debug_inspect(gradient.get_dither(), content="DitherGood")
  } else {
    match run_cairo(() => gradient.set_dither(DitherGood)) {
      Err(CairoError(InvalidStatus, _)) => ()
      _ => fail("expected dither API to require Cairo 1.18")
    }
  }
  debug_inspect(gradient.get_linear_points(), content="(0, 0, 10, 0)")
  let surface_pattern = Pattern::for_surface(Surface::image(Argb32, 2, 3))
  inspect(surface_pattern.get_surface().get_height(), content="3")
}

///|
test {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  source_ctx.paint()

  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_acquire(fn(_, _) { source })
  match pattern.raster_get_acquire() {
    Some((_, None)) => ()
    _ => fail("expected raster acquire callback")
  }

  let target = Surface::image(Argb32, 1, 1)
  let ctx = Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()
  inspect(target.copy_data()[2].to_int(), content="255")
}

///|
test {
  let pattern = Pattern::mesh()
  pattern.mesh_begin_patch()
  pattern.mesh_move_to(0.0, 0.0)
  pattern.mesh_line_to(2.0, 0.0)
  pattern.mesh_line_to(0.0, 2.0)
  pattern.mesh_set_corner_color_rgba(0, 1.0, 0.0, 0.0, 1.0)
  pattern.mesh_set_corner_color_rgba(1, 1.0, 0.0, 0.0, 1.0)
  pattern.mesh_set_corner_color_rgba(2, 1.0, 0.0, 0.0, 1.0)
  pattern.mesh_end_patch()

  inspect(pattern.mesh_get_patch_count(), content="1")
  let path = pattern.mesh_get_path(0)
  inspect(path.length() > 0, content="true")
}

///|
test {
  let surface = Surface::image(Argb32, 8, 8)
  let ctx = Context::new(surface)
  ctx.line_to(1.0, 2.0)
  ctx.line_to(2.0, 3.0)
  ctx.curve_to(0.0, 1.0, 2.0, 3.0, 4.0, 5.0)
  ctx.close_path()
  let path = ctx.copy_path()
  inspect(path.length(), content="5")
  debug_inspect(path.segments()[0].data_type(), content="PathMoveTo")
  inspect(path.segments()[2].coordinates().length(), content="6")
  inspect(path.to_string().contains("curve_to"), content="true")
}

///|
test {
  let region = Region::from_rectangles([
    RectangleInt::new(x=0, y=0, width=2, height=2),
    RectangleInt::new(x=10, y=0, width=3, height=2),
  ])
  inspect(region.num_rectangles(), content="2")
  debug_inspect(
    region.get_extents(),
    content="{ x: 0, y: 0, width: 13, height: 2 }",
  )
  inspect(region.contains_point(10, 1), content="true")
}

///|
test {
  let options = FontOptions::new()
  options.set_antialias(AntialiasGray)
  options.set_hint_style(HintStyleSlight)
  debug_inspect(options.get_antialias(), content="AntialiasGray")
  if CAIRO_VERSION >= 11600 {
    options.set_variations(Some("wght=200"))
    match options.get_variations() {
      Some(variations) => inspect(variations, content="wght=200")
      None => fail("expected font variations")
    }
  } else {
    match run_cairo(() => options.set_variations(Some("wght=200"))) {
      Err(CairoError(InvalidStatus, _)) => ()
      _ => fail("expected variations API to require Cairo 1.16")
    }
  }
  let copied = options.copy()
  inspect(options.equal(copied), content="true")
}

///|
test {
  let face = FontFace::toy(
    "serif",
    slant=FontSlantItalic,
    weight=FontWeightBold,
  )
  inspect(face.get_family(), content="serif")
  debug_inspect(face.get_slant(), content="FontSlantItalic")
  debug_inspect(face.get_weight(), content="FontWeightBold")

  let surface = Surface::image(Rgb24, 8, 8)
  let ctx = Context::new(surface)
  ctx.set_font_face(Some(face))
  inspect(ctx.get_font_face().equal(face), content="true")
  ctx.select_font_face("sans-serif")
  inspect(ctx.get_font_face().get_family(), content="sans-serif")
  ctx.set_font_face(None)
  inspect(ctx.get_font_face().status().is_success(), content="true")
}

///|
test {
  let surface = Surface::image(Rgb24, 32, 16)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.move_to(2.0, 12.0)
  let extents = ctx.text_extents("foo")
  inspect(extents.x_advance > 0.0, content="true")
  ctx.show_text("foo")
  let (x, _) = ctx.get_current_point()
  inspect(x > 2.0, content="true")
  ctx.text_path("bar")
  let (x1, _, x2, _) = ctx.path_extents()
  inspect(x2 > x1, content="true")
}

///|
test {
  let surface = Surface::image(Rgb24, 32, 16)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  let glyphs = [Glyph::new(0UL, 2.0, 12.0)]
  inspect(
    ctx.glyph_extents(glyphs) == ctx.get_scaled_font().glyph_extents(glyphs),
    content="true",
  )
  ctx.glyph_path(glyphs)
  ctx.show_glyphs(glyphs)
  let run = ctx.get_scaled_font().text_to_glyphs(2.0, 12.0, "a")
  inspect(run.glyphs.length(), content="1")
  let glyphs_only = ctx.get_scaled_font().text_to_glyphs_only(2.0, 12.0, "a")
  inspect(glyphs_only.length(), content="1")
  ctx.show_text_glyphs("a", run.glyphs, run.clusters, flags=run.flags)
}

///|
test {
  let face = FontFace::toy("serif", weight=FontWeightBold)
  let options = FontOptions::new()
  options.set_antialias(AntialiasGray)
  let scaled = ScaledFont::new(
    face,
    Matrix::new(xx=12.0, yy=12.0),
    Matrix::new(),
    options,
  )
  inspect(scaled.extents().height > 0.0, content="true")
  inspect(scaled.text_extents("foo").x_advance > 0.0, content="true")

  let surface = Surface::image(Rgb24, 8, 8)
  let ctx = Context::new(surface)
  ctx.set_scaled_font(scaled)
  inspect(ctx.font_extents().height > 0.0, content="true")
  inspect(ctx.get_scaled_font().status().is_success(), content="true")
}
```

## License

cairoon is available under `LGPL-2.1-only OR MPL-1.1`. Publication archives
include `COPYING`, `COPYING-LGPL-2.1`, and `COPYING-MPL-1.1` at their root.
