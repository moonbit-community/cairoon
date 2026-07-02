# cairoon

MoonBit native bindings for the Cairo graphics library.

This package is intentionally native-only while MoonBit's LLVM backend does not
support FFI. See `AGENTS.md` for the migration and audit rules.

```mbt check
///|
test {
  inspect(cairo_version() > 0, content="true")
  inspect(cairo_version_string().contains("."), content="true")
  inspect(CAIRO_VERSION == cairo_version(), content="true")
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
  gradient.set_dither(DitherGood)
  inspect(gradient.get_color_stop_count(), content="2")
  debug_inspect(gradient.get_dither(), content="DitherGood")
  debug_inspect(gradient.get_linear_points(), content="(0, 0, 10, 0)")
  let surface_pattern = Pattern::for_surface(Surface::image(Argb32, 2, 3))
  inspect(surface_pattern.get_surface().get_height(), content="3")
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
  options.set_variations(Some("wght=200"))
  debug_inspect(options.get_antialias(), content="AntialiasGray")
  match options.get_variations() {
    Some(variations) => inspect(variations, content="wght=200")
    None => fail("expected font variations")
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
  let glyphs = [Glyph::new(0U, 2.0, 12.0)]
  inspect(
    ctx.glyph_extents(glyphs) == ctx.get_scaled_font().glyph_extents(glyphs),
    content="true",
  )
  ctx.glyph_path(glyphs)
  ctx.show_glyphs(glyphs)
  let run = ctx.get_scaled_font().text_to_glyphs(2.0, 12.0, "a")
  inspect(run.glyphs.length(), content="1")
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
