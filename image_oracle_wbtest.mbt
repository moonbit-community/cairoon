///|
fn draw_image_oracle_scene(ctx : Context, scene : Int) -> Unit raise CairoError {
  match scene {
    0 => {
      ctx.set_source_rgb(0.0, 0.0, 1.0)
      ctx.paint()
    }
    1 => {
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.set_line_width(2.0)
      ctx.move_to(2.5, 2.5)
      ctx.line_to(13.5, 13.5)
      ctx.stroke()
    }
    2 => {
      ctx.rectangle(2.0, 2.0, 10.0, 10.0)
      ctx.set_source_rgba(0.0, 1.0, 0.0, 0.75)
      ctx.fill_preserve()
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.set_line_width(2.0)
      ctx.stroke()
    }
    3 => {
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.set_line_width(2.0)
      ctx.move_to(2.0, 14.0)
      ctx.curve_to(5.0, 1.0, 11.0, 15.0, 14.0, 2.0)
      ctx.stroke()
    }
    4 => {
      ctx.translate(8.0, 8.0)
      ctx.rotate(0.25)
      ctx.scale(1.2, 0.8)
      ctx.rectangle(-4.0, -3.0, 8.0, 6.0)
      ctx.set_source_rgb(1.0, 0.5, 0.0)
      ctx.fill()
    }
    5 => {
      ctx.set_source_rgba(1.0, 0.0, 0.0, 0.5)
      ctx.paint()
    }
    6 => {
      let pattern = Pattern::linear(0.0, 0.0, 16.0, 0.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 0.0, 0.0, 1.0)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 1.0)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    7 => {
      let pattern = Pattern::radial(8.0, 8.0, 1.0, 8.0, 8.0, 8.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 1.0)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 0.0, 1.0)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    8 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(8.0)
      ctx.move_to(2.0, 10.0)
      ctx.text_path("Hi")
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.fill()
    }
    9 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(8.0)
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.move_to(2.0, 10.0)
      ctx.show_text("Hi")
    }
    10 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(12.0)
      ctx.glyph_path([Glyph::new(0UL, 2.0, 12.0)])
      ctx.set_source_rgb(0.0, 0.0, 1.0)
      ctx.fill()
    }
    11 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(12.0)
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.show_glyphs([Glyph::new(0UL, 2.0, 12.0)])
    }
    12 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(12.0)
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      let run = ctx.get_scaled_font().text_to_glyphs(2.0, 12.0, "a")
      ctx.show_text_glyphs("a", run.glyphs, run.clusters, flags=run.flags)
    }
    13 => {
      let source = Surface::image(Argb32, 2, 2)
      let source_ctx = Context::new(source)
      source_ctx.set_source_rgb(1.0, 0.0, 0.0)
      source_ctx.rectangle(0.0, 0.0, 1.0, 1.0)
      source_ctx.fill()
      source_ctx.set_source_rgb(0.0, 1.0, 0.0)
      source_ctx.rectangle(1.0, 0.0, 1.0, 1.0)
      source_ctx.fill()
      source_ctx.set_source_rgb(0.0, 0.0, 1.0)
      source_ctx.rectangle(0.0, 1.0, 1.0, 1.0)
      source_ctx.fill()
      source_ctx.set_source_rgb(1.0, 1.0, 1.0)
      source_ctx.rectangle(1.0, 1.0, 1.0, 1.0)
      source_ctx.fill()
      ctx.set_source_surface(source, x=7.0, y=6.0)
      ctx.paint()
    }
    14 => {
      let mask = Surface::image(Argb32, 2, 2)
      let mask_ctx = Context::new(mask)
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
      mask_ctx.rectangle(0.0, 0.0, 1.0, 1.0)
      mask_ctx.fill()
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 0.5)
      mask_ctx.rectangle(1.0, 0.0, 1.0, 1.0)
      mask_ctx.fill()
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
      mask_ctx.rectangle(1.0, 1.0, 1.0, 1.0)
      mask_ctx.fill()
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.mask_surface(mask, x=7.0, y=6.0)
    }
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn render_image_oracle_scene(scene : Int) -> Bytes raise CairoError {
  let surface = Surface::image(Argb32, 16, 16)
  let ctx = Context::new(surface)
  draw_image_oracle_scene(ctx, scene)
  surface.copy_data()
}

///|
fn render_buffered_image_oracle_scene(
  scene : Int,
) -> (Bytes, Bytes) raise CairoError {
  let width = 16
  let height = 16
  let stride = Format::stride_for_width(Argb32, width)
  let backing : FixedArray[Byte] = FixedArray::make(stride * height, b'\x00')
  let surface = Surface::image_for_data(backing, Argb32, width, height, stride~)
  let ctx = Context::new(surface)
  draw_image_oracle_scene(ctx, scene)
  surface.flush()
  (Bytes::from_array(backing), surface.copy_data())
}

///|
test "image rendering scenes match direct cairo C oracle" {
  for scene in 0..<15 {
    let actual = render_image_oracle_scene(scene)
    let expected = test_argb32_scene_oracle_ffi(scene, 16, 16)
    inspect(expected.length(), content="1024")
    inspect(actual == expected, content="true")
  }
}

///|
test "buffer backed image rendering scenes match direct cairo C oracle" {
  for scene in 0..<15 {
    let (actual, copied) = render_buffered_image_oracle_scene(scene)
    let expected = test_argb32_scene_oracle_ffi(scene, 16, 16)
    inspect(expected.length(), content="1024")
    inspect(copied == actual, content="true")
    inspect(actual == expected, content="true")
  }
}
