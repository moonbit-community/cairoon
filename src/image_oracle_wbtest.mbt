///|
fn paint_image_oracle_quad_surface(surface : Surface) -> Unit raise CairoError {
  let source_ctx = Context::new(surface)
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
}

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
      paint_image_oracle_quad_surface(source)
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
    15 => {
      let source = Surface::image(Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let pattern = Pattern::raster_source(ContentColorAlpha, 2, 2)
      pattern.raster_set_acquire(
        fn(_, _) { source },
        release=Some(fn(_) { () }),
      )
      pattern.set_extend(Repeat)
      pattern.set_filter(Nearest)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    16 => {
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.set_line_width(2.0)
      ctx.set_line_cap(LineCapRound)
      ctx.set_dash([2.0, 2.0], offset=0.0)
      ctx.move_to(2.0, 8.0)
      ctx.line_to(14.0, 8.0)
      ctx.stroke()
    }
    17 => {
      ctx.rectangle(4.0, 4.0, 8.0, 8.0)
      ctx.clip()
      ctx.set_source_rgb(0.0, 1.0, 0.0)
      ctx.paint()
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.rectangle(4.0, 4.0, 4.0, 4.0)
      ctx.fill()
    }
    18 => {
      ctx.set_source_rgb(0.0, 0.0, 1.0)
      ctx.paint()
      ctx.set_operator(OperatorClear)
      ctx.rectangle(4.0, 4.0, 8.0, 8.0)
      ctx.fill()
      ctx.set_operator(OperatorOver)
      ctx.set_source_rgba(1.0, 0.0, 0.0, 0.5)
      ctx.rectangle(0.0, 0.0, 8.0, 8.0)
      ctx.fill()
    }
    19 => {
      let source = Surface::image(Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let pattern = Pattern::for_surface(source)
      pattern.set_extend(Reflect)
      pattern.set_filter(Nearest)
      pattern.set_dither(DitherBest)
      pattern.set_matrix(
        Matrix::new(xx=0.75, yx=0.2, xy=-0.25, yy=0.8, x0=-1.0, y0=0.5),
      )
      ctx.set_source_rgb(0.125, 0.125, 0.125)
      ctx.paint()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    20 => {
      let pattern = Pattern::linear(0.0, 0.0, 4.0, 0.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 0.0, 0.0, 1.0)
      pattern.add_color_stop_rgba(0.5, 0.0, 1.0, 0.0, 0.75)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 1.0)
      pattern.set_extend(Repeat)
      pattern.set_filter(Nearest)
      pattern.set_dither(DitherFast)
      pattern.set_matrix(
        Matrix::new(xx=0.6, yx=0.1, xy=-0.2, yy=0.9, x0=-2.0, y0=1.0),
      )
      ctx.set_source_rgb(0.125, 0.125, 0.125)
      ctx.paint()
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    21 => {
      let pattern = Pattern::mesh()
      pattern.mesh_begin_patch()
      pattern.mesh_move_to(0.0, 0.0)
      pattern.mesh_line_to(10.0, 0.0)
      pattern.mesh_line_to(10.0, 10.0)
      pattern.mesh_line_to(0.0, 10.0)
      pattern.mesh_set_corner_color_rgba(0, 1.0, 0.0, 0.0, 1.0)
      pattern.mesh_set_corner_color_rgba(1, 0.0, 1.0, 0.0, 1.0)
      pattern.mesh_set_corner_color_rgba(2, 0.0, 0.0, 1.0, 0.75)
      pattern.mesh_set_corner_color_rgba(3, 1.0, 1.0, 0.0, 1.0)
      pattern.mesh_end_patch()
      ctx.rectangle(0.0, 0.0, 10.0, 10.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    22 => {
      ctx.set_source_rgb(0.0, 0.0, 0.25)
      ctx.paint()
      ctx.push_group_with_content(ContentColorAlpha)
      ctx.set_source_rgba(1.0, 0.0, 0.0, 0.8)
      ctx.rectangle(2.0, 2.0, 11.0, 10.0)
      ctx.fill()
      ctx.set_source_rgba(0.0, 1.0, 0.0, 0.55)
      ctx.rectangle(5.0, 5.0, 9.0, 9.0)
      ctx.fill()
      ctx.pop_group_to_source()
      ctx.paint_with_alpha(0.6)
    }
    23 => {
      let mask = Pattern::linear(0.0, 0.0, 16.0, 16.0)
      mask.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.0)
      mask.add_color_stop_rgba(0.45, 1.0, 1.0, 1.0, 0.35)
      mask.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 1.0)
      ctx.set_source_rgb(0.0, 0.0, 0.25)
      ctx.paint()
      ctx.rectangle(2.0, 2.0, 12.0, 12.0)
      ctx.clip()
      ctx.set_source_rgba(1.0, 0.25, 0.0, 0.9)
      ctx.mask(mask)
    }
    24 => {
      ctx.set_source_rgb(0.0, 0.0, 0.25)
      ctx.paint()
      ctx.set_fill_rule(FillEvenOdd)
      ctx.rectangle(2.0, 2.0, 12.0, 12.0)
      ctx.rectangle(5.0, 5.0, 6.0, 6.0)
      ctx.set_source_rgba(0.0, 0.85, 0.25, 0.9)
      ctx.fill()
    }
    25 => {
      let pattern = Pattern::radial(4.0, 4.0, 1.0, 11.0, 11.0, 6.5)
      pattern.add_color_stop_rgba(0.0, 1.0, 0.0, 0.0, 1.0)
      pattern.add_color_stop_rgba(0.4, 0.0, 1.0, 0.0, 0.65)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 0.9)
      pattern.set_extend(Reflect)
      pattern.set_filter(Nearest)
      pattern.set_dither(DitherGood)
      pattern.set_matrix(
        Matrix::new(xx=0.8, yx=-0.15, xy=0.25, yy=0.7, x0=-1.5, y0=1.25),
      )
      ctx.set_source_rgb(0.125, 0.125, 0.125)
      ctx.paint()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    26 => {
      let source = Surface::image(Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let pattern = Pattern::for_surface(source)
      pattern.set_extend(Pad)
      pattern.set_filter(Bilinear)
      pattern.set_dither(DitherDefault)
      pattern.set_matrix(
        Matrix::new(xx=0.55, yx=0.10, xy=0.20, yy=0.65, x0=-1.25, y0=-0.75),
      )
      ctx.set_source_rgb(0.125, 0.125, 0.125)
      ctx.paint()
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    27 => {
      let source = Surface::image(Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let pattern = Pattern::for_surface(source)
      pattern.set_extend(ExtendNone)
      pattern.set_filter(Nearest)
      pattern.set_dither(DitherNone)
      pattern.set_matrix(
        Matrix::new(xx=0.45, yx=-0.05, xy=0.12, yy=0.50, x0=-3.0, y0=-2.0),
      )
      ctx.set_source_rgba(0.08, 0.09, 0.10, 1.0)
      ctx.paint()
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    28 => {
      let pattern = Pattern::linear(2.0, 0.0, 12.0, 16.0)
      pattern.add_color_stop_rgba(0.0, 0.95, 0.20, 0.05, 1.0)
      pattern.add_color_stop_rgba(0.30, 0.20, 0.85, 0.25, 0.80)
      pattern.add_color_stop_rgba(0.75, 0.10, 0.20, 0.95, 0.65)
      pattern.add_color_stop_rgba(1.0, 0.98, 0.92, 0.25, 1.0)
      pattern.set_extend(Pad)
      pattern.set_filter(Bilinear)
      pattern.set_dither(DitherBest)
      pattern.set_matrix(
        Matrix::new(xx=0.70, yx=-0.10, xy=0.15, yy=0.85, x0=-1.0, y0=2.0),
      )
      ctx.set_source_rgb(0.125, 0.125, 0.125)
      ctx.paint()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    29 => {
      let pattern = Pattern::radial(3.0, 3.0, 1.0, 9.0, 10.0, 5.0)
      pattern.add_color_stop_rgba(0.0, 0.95, 0.10, 0.10, 0.95)
      pattern.add_color_stop_rgba(0.35, 0.15, 0.85, 0.25, 0.70)
      pattern.add_color_stop_rgba(0.70, 0.10, 0.25, 0.95, 0.65)
      pattern.add_color_stop_rgba(1.0, 0.95, 0.95, 0.95, 0.90)
      pattern.set_extend(Repeat)
      pattern.set_filter(Bilinear)
      pattern.set_dither(DitherFast)
      pattern.set_matrix(
        Matrix::new(xx=0.65, yx=0.18, xy=-0.12, yy=0.75, x0=-2.25, y0=0.40),
      )
      ctx.set_source_rgb(0.125, 0.125, 0.125)
      ctx.paint()
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    30 => {
      let source = Surface::image(Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let pattern = Pattern::for_surface(source)
      pattern.set_extend(Repeat)
      pattern.set_filter(Bilinear)
      pattern.set_dither(DitherGood)
      pattern.set_matrix(
        Matrix::new(xx=0.70, yx=-0.18, xy=0.22, yy=0.58, x0=-0.80, y0=1.35),
      )
      ctx.set_source_rgba(0.05, 0.07, 0.09, 1.0)
      ctx.paint()
      ctx.rectangle(1.0, 0.0, 14.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    31 => {
      let pattern = Pattern::linear(-2.0, 1.0, 14.0, 11.0)
      pattern.add_color_stop_rgba(0.0, 0.05, 0.10, 0.20, 1.0)
      pattern.add_color_stop_rgba(0.45, 0.10, 0.90, 0.80, 0.60)
      pattern.add_color_stop_rgba(0.45, 0.95, 0.90, 0.20, 0.80)
      pattern.add_color_stop_rgba(1.0, 0.95, 0.10, 0.65, 0.95)
      pattern.set_extend(ExtendNone)
      pattern.set_filter(Good)
      pattern.set_dither(DitherNone)
      pattern.set_matrix(
        Matrix::new(xx=0.85, yx=0.05, xy=-0.18, yy=0.72, x0=2.5, y0=-1.0),
      )
      ctx.set_source_rgb(0.12, 0.12, 0.14)
      ctx.paint()
      ctx.rectangle(0.0, 1.0, 16.0, 14.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    32 => {
      let pattern = Pattern::radial(2.0, 13.0, 0.5, 12.0, 4.0, 7.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 0.95, 0.25, 1.0)
      pattern.add_color_stop_rgba(0.25, 0.95, 0.30, 0.10, 0.75)
      pattern.add_color_stop_rgba(0.80, 0.10, 0.20, 0.95, 0.65)
      pattern.add_color_stop_rgba(1.0, 0.02, 0.03, 0.08, 1.0)
      pattern.set_extend(Pad)
      pattern.set_filter(Good)
      pattern.set_dither(DitherDefault)
      pattern.set_matrix(
        Matrix::new(xx=0.78, yx=-0.08, xy=0.16, yy=0.92, x0=-0.60, y0=1.80),
      )
      ctx.set_source_rgb(0.04, 0.05, 0.08)
      ctx.paint()
      ctx.rectangle(2.0, 0.0, 14.0, 15.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    33 => {
      let pattern = Pattern::mesh()
      pattern.mesh_begin_patch()
      pattern.mesh_move_to(1.0, 1.0)
      pattern.mesh_curve_to(6.0, -2.0, 12.0, 4.0, 14.0, 2.0)
      pattern.mesh_curve_to(15.0, 7.0, 11.0, 14.0, 8.0, 15.0)
      pattern.mesh_curve_to(3.0, 13.0, -1.0, 9.0, 1.0, 1.0)
      pattern.mesh_set_corner_color_rgba(0, 0.95, 0.10, 0.05, 1.0)
      pattern.mesh_set_corner_color_rgba(1, 0.10, 0.85, 0.20, 0.85)
      pattern.mesh_set_corner_color_rgba(2, 0.10, 0.20, 0.95, 0.75)
      pattern.mesh_set_corner_color_rgba(3, 0.95, 0.90, 0.10, 1.0)
      pattern.mesh_set_control_point(0, 4.0, 3.0)
      pattern.mesh_set_control_point(1, 11.0, 2.0)
      pattern.mesh_end_patch()
      pattern.mesh_begin_patch()
      pattern.mesh_move_to(4.0, 4.0)
      pattern.mesh_line_to(14.0, 6.0)
      pattern.mesh_line_to(10.0, 14.0)
      pattern.mesh_line_to(2.0, 10.0)
      pattern.mesh_set_corner_color_rgba(0, 0.00, 0.00, 0.00, 0.60)
      pattern.mesh_set_corner_color_rgba(1, 1.00, 1.00, 1.00, 0.40)
      pattern.mesh_set_corner_color_rgba(2, 0.95, 0.20, 0.70, 0.65)
      pattern.mesh_set_corner_color_rgba(3, 0.20, 0.95, 0.95, 0.70)
      pattern.mesh_end_patch()
      pattern.set_matrix(
        Matrix::new(xx=0.90, yx=0.10, xy=-0.08, yy=0.85, x0=0.50, y0=-0.50),
      )
      ctx.set_source_rgb(0.03, 0.04, 0.08)
      ctx.paint()
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
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
  for scene in 0..<34 {
    let actual = render_image_oracle_scene(scene)
    let expected = test_argb32_scene_oracle_ffi(scene, 16, 16)
    inspect(expected.length(), content="1024")
    inspect(actual == expected, content="true")
  }
}

///|
test "buffer backed image rendering scenes match direct cairo C oracle" {
  for scene in 0..<34 {
    let (actual, copied) = render_buffered_image_oracle_scene(scene)
    let expected = test_argb32_scene_oracle_ffi(scene, 16, 16)
    inspect(expected.length(), content="1024")
    inspect(copied == actual, content="true")
    inspect(actual == expected, content="true")
  }
}
