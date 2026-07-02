# cairoon

MoonBit native bindings for the Cairo graphics library.

This package is intentionally native-only while MoonBit's LLVM backend does not
support FFI. See `AGENTS.md` for the migration and audit rules.

```mbt check
///|
test {
  inspect(cairo_version() > 0, content="true")
  inspect(cairo_version_string().contains("."), content="true")
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
