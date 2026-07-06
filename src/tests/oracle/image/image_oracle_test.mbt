///|
fn init {
  ignore(@native.oracle_native_anchor())
}

///|
extern "C" fn test_argb32_scene_oracle_ffi(
  scene : Int,
  width : Int,
  height : Int,
) -> Bytes = "cairoon_test_argb32_scene_oracle"

///|
fn paint_image_oracle_quad_surface(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let source_ctx = @cairoon.Context::new(surface)
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
fn draw_image_oracle_scene(
  ctx : @cairoon.Context,
  scene : Int,
) -> Unit raise @cairoon.CairoError {
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
      let pattern = @cairoon.Pattern::linear(0.0, 0.0, 16.0, 0.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 0.0, 0.0, 1.0)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 1.0)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    7 => {
      let pattern = @cairoon.Pattern::radial(8.0, 8.0, 1.0, 8.0, 8.0, 8.0)
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
      ctx.glyph_path([@cairoon.Glyph::new(0UL, 2.0, 12.0)])
      ctx.set_source_rgb(0.0, 0.0, 1.0)
      ctx.fill()
    }
    11 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(12.0)
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.show_glyphs([@cairoon.Glyph::new(0UL, 2.0, 12.0)])
    }
    12 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(12.0)
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      let run = ctx.get_scaled_font().text_to_glyphs(2.0, 12.0, "a")
      ctx.show_text_glyphs("a", run.glyphs, run.clusters, flags=run.flags)
    }
    13 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      ctx.set_source_surface(source, x=7.0, y=6.0)
      ctx.paint()
    }
    14 => {
      let mask = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      let mask_ctx = @cairoon.Context::new(mask)
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
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let pattern = @cairoon.Pattern::raster_source(
        @cairoon.ContentColorAlpha,
        2,
        2,
      )
      pattern.raster_set_acquire(
        fn(_, _) { source },
        release=Some(fn(_) { () }),
      )
      pattern.set_extend(@cairoon.Repeat)
      pattern.set_filter(@cairoon.Nearest)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    16 => {
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.set_line_width(2.0)
      ctx.set_line_cap(@cairoon.LineCapRound)
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
      ctx.set_operator(@cairoon.OperatorClear)
      ctx.rectangle(4.0, 4.0, 8.0, 8.0)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.set_source_rgba(1.0, 0.0, 0.0, 0.5)
      ctx.rectangle(0.0, 0.0, 8.0, 8.0)
      ctx.fill()
    }
    19 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let pattern = @cairoon.Pattern::for_surface(source)
      pattern.set_extend(@cairoon.Reflect)
      pattern.set_filter(@cairoon.Nearest)
      pattern.set_dither(@cairoon.DitherBest)
      pattern.set_matrix(
        @cairoon.Matrix::new(xx=0.75, yx=0.2, xy=-0.25, yy=0.8, x0=-1.0, y0=0.5),
      )
      ctx.set_source_rgb(0.125, 0.125, 0.125)
      ctx.paint()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    20 => {
      let pattern = @cairoon.Pattern::linear(0.0, 0.0, 4.0, 0.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 0.0, 0.0, 1.0)
      pattern.add_color_stop_rgba(0.5, 0.0, 1.0, 0.0, 0.75)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 1.0)
      pattern.set_extend(@cairoon.Repeat)
      pattern.set_filter(@cairoon.Nearest)
      pattern.set_dither(@cairoon.DitherFast)
      pattern.set_matrix(
        @cairoon.Matrix::new(xx=0.6, yx=0.1, xy=-0.2, yy=0.9, x0=-2.0, y0=1.0),
      )
      ctx.set_source_rgb(0.125, 0.125, 0.125)
      ctx.paint()
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    21 => {
      let pattern = @cairoon.Pattern::mesh()
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
      ctx.push_group_with_content(@cairoon.ContentColorAlpha)
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
      let mask = @cairoon.Pattern::linear(0.0, 0.0, 16.0, 16.0)
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
      ctx.set_fill_rule(@cairoon.FillEvenOdd)
      ctx.rectangle(2.0, 2.0, 12.0, 12.0)
      ctx.rectangle(5.0, 5.0, 6.0, 6.0)
      ctx.set_source_rgba(0.0, 0.85, 0.25, 0.9)
      ctx.fill()
    }
    25 => {
      let pattern = @cairoon.Pattern::radial(4.0, 4.0, 1.0, 11.0, 11.0, 6.5)
      pattern.add_color_stop_rgba(0.0, 1.0, 0.0, 0.0, 1.0)
      pattern.add_color_stop_rgba(0.4, 0.0, 1.0, 0.0, 0.65)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 0.9)
      pattern.set_extend(@cairoon.Reflect)
      pattern.set_filter(@cairoon.Nearest)
      pattern.set_dither(@cairoon.DitherGood)
      pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.8,
          yx=-0.15,
          xy=0.25,
          yy=0.7,
          x0=-1.5,
          y0=1.25,
        ),
      )
      ctx.set_source_rgb(0.125, 0.125, 0.125)
      ctx.paint()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    26 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let pattern = @cairoon.Pattern::for_surface(source)
      pattern.set_extend(@cairoon.Pad)
      pattern.set_filter(@cairoon.Bilinear)
      pattern.set_dither(@cairoon.DitherDefault)
      pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.55,
          yx=0.10,
          xy=0.20,
          yy=0.65,
          x0=-1.25,
          y0=-0.75,
        ),
      )
      ctx.set_source_rgb(0.125, 0.125, 0.125)
      ctx.paint()
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    27 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let pattern = @cairoon.Pattern::for_surface(source)
      pattern.set_extend(@cairoon.ExtendNone)
      pattern.set_filter(@cairoon.Nearest)
      pattern.set_dither(@cairoon.DitherNone)
      pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.45,
          yx=-0.05,
          xy=0.12,
          yy=0.50,
          x0=-3.0,
          y0=-2.0,
        ),
      )
      ctx.set_source_rgba(0.08, 0.09, 0.10, 1.0)
      ctx.paint()
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    28 => {
      let pattern = @cairoon.Pattern::linear(2.0, 0.0, 12.0, 16.0)
      pattern.add_color_stop_rgba(0.0, 0.95, 0.20, 0.05, 1.0)
      pattern.add_color_stop_rgba(0.30, 0.20, 0.85, 0.25, 0.80)
      pattern.add_color_stop_rgba(0.75, 0.10, 0.20, 0.95, 0.65)
      pattern.add_color_stop_rgba(1.0, 0.98, 0.92, 0.25, 1.0)
      pattern.set_extend(@cairoon.Pad)
      pattern.set_filter(@cairoon.Bilinear)
      pattern.set_dither(@cairoon.DitherBest)
      pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.70,
          yx=-0.10,
          xy=0.15,
          yy=0.85,
          x0=-1.0,
          y0=2.0,
        ),
      )
      ctx.set_source_rgb(0.125, 0.125, 0.125)
      ctx.paint()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    29 => {
      let pattern = @cairoon.Pattern::radial(3.0, 3.0, 1.0, 9.0, 10.0, 5.0)
      pattern.add_color_stop_rgba(0.0, 0.95, 0.10, 0.10, 0.95)
      pattern.add_color_stop_rgba(0.35, 0.15, 0.85, 0.25, 0.70)
      pattern.add_color_stop_rgba(0.70, 0.10, 0.25, 0.95, 0.65)
      pattern.add_color_stop_rgba(1.0, 0.95, 0.95, 0.95, 0.90)
      pattern.set_extend(@cairoon.Repeat)
      pattern.set_filter(@cairoon.Bilinear)
      pattern.set_dither(@cairoon.DitherFast)
      pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.65,
          yx=0.18,
          xy=-0.12,
          yy=0.75,
          x0=-2.25,
          y0=0.40,
        ),
      )
      ctx.set_source_rgb(0.125, 0.125, 0.125)
      ctx.paint()
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    30 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let pattern = @cairoon.Pattern::for_surface(source)
      pattern.set_extend(@cairoon.Repeat)
      pattern.set_filter(@cairoon.Bilinear)
      pattern.set_dither(@cairoon.DitherGood)
      pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.70,
          yx=-0.18,
          xy=0.22,
          yy=0.58,
          x0=-0.80,
          y0=1.35,
        ),
      )
      ctx.set_source_rgba(0.05, 0.07, 0.09, 1.0)
      ctx.paint()
      ctx.rectangle(1.0, 0.0, 14.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    31 => {
      let pattern = @cairoon.Pattern::linear(-2.0, 1.0, 14.0, 11.0)
      pattern.add_color_stop_rgba(0.0, 0.05, 0.10, 0.20, 1.0)
      pattern.add_color_stop_rgba(0.45, 0.10, 0.90, 0.80, 0.60)
      pattern.add_color_stop_rgba(0.45, 0.95, 0.90, 0.20, 0.80)
      pattern.add_color_stop_rgba(1.0, 0.95, 0.10, 0.65, 0.95)
      pattern.set_extend(@cairoon.ExtendNone)
      pattern.set_filter(@cairoon.Good)
      pattern.set_dither(@cairoon.DitherNone)
      pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.85,
          yx=0.05,
          xy=-0.18,
          yy=0.72,
          x0=2.5,
          y0=-1.0,
        ),
      )
      ctx.set_source_rgb(0.12, 0.12, 0.14)
      ctx.paint()
      ctx.rectangle(0.0, 1.0, 16.0, 14.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    32 => {
      let pattern = @cairoon.Pattern::radial(2.0, 13.0, 0.5, 12.0, 4.0, 7.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 0.95, 0.25, 1.0)
      pattern.add_color_stop_rgba(0.25, 0.95, 0.30, 0.10, 0.75)
      pattern.add_color_stop_rgba(0.80, 0.10, 0.20, 0.95, 0.65)
      pattern.add_color_stop_rgba(1.0, 0.02, 0.03, 0.08, 1.0)
      pattern.set_extend(@cairoon.Pad)
      pattern.set_filter(@cairoon.Good)
      pattern.set_dither(@cairoon.DitherDefault)
      pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.78,
          yx=-0.08,
          xy=0.16,
          yy=0.92,
          x0=-0.60,
          y0=1.80,
        ),
      )
      ctx.set_source_rgb(0.04, 0.05, 0.08)
      ctx.paint()
      ctx.rectangle(2.0, 0.0, 14.0, 15.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    33 => {
      let pattern = @cairoon.Pattern::mesh()
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
        @cairoon.Matrix::new(
          xx=0.90,
          yx=0.10,
          xy=-0.08,
          yy=0.85,
          x0=0.50,
          y0=-0.50,
        ),
      )
      ctx.set_source_rgb(0.03, 0.04, 0.08)
      ctx.paint()
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    34 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(@cairoon.Repeat)
      surface_pattern.set_filter(@cairoon.Nearest)
      surface_pattern.set_dither(@cairoon.DitherGood)
      surface_pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.50,
          yx=0.18,
          xy=-0.16,
          yy=0.62,
          x0=-1.40,
          y0=0.90,
        ),
      )

      let linear = @cairoon.Pattern::linear(0.0, 0.0, 16.0, 16.0)
      linear.add_color_stop_rgba(0.0, 0.90, 0.12, 0.05, 0.95)
      linear.add_color_stop_rgba(0.40, 0.10, 0.80, 0.35, 0.70)
      linear.add_color_stop_rgba(1.0, 0.08, 0.18, 0.95, 0.85)
      linear.set_extend(@cairoon.Reflect)
      linear.set_filter(@cairoon.Bilinear)
      linear.set_dither(@cairoon.DitherBest)
      linear.set_matrix(
        @cairoon.Matrix::new(
          xx=0.82,
          yx=-0.12,
          xy=0.20,
          yy=0.74,
          x0=-0.60,
          y0=1.40,
        ),
      )

      let radial = @cairoon.Pattern::radial(4.0, 12.0, 0.75, 13.0, 3.0, 7.0)
      radial.add_color_stop_rgba(0.0, 1.0, 0.95, 0.20, 1.0)
      radial.add_color_stop_rgba(0.55, 0.90, 0.10, 0.60, 0.68)
      radial.add_color_stop_rgba(1.0, 0.02, 0.04, 0.12, 1.0)
      radial.set_extend(@cairoon.Pad)
      radial.set_filter(@cairoon.Good)
      radial.set_dither(@cairoon.DitherDefault)
      radial.set_matrix(
        @cairoon.Matrix::new(
          xx=0.76,
          yx=0.08,
          xy=-0.18,
          yy=0.88,
          x0=1.25,
          y0=-0.75,
        ),
      )

      let mask = @cairoon.Pattern::linear(0.0, 16.0, 16.0, 0.0)
      mask.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.0)
      mask.add_color_stop_rgba(0.45, 1.0, 1.0, 1.0, 0.45)
      mask.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.95)

      ctx.set_source_rgb(0.02, 0.03, 0.06)
      ctx.paint()

      ctx.save()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.clip()
      ctx.set_source(surface_pattern)
      ctx.paint()
      ctx.set_operator(@cairoon.OperatorAtop)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(linear)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.restore()

      ctx.save()
      ctx.rectangle(3.0, 2.0, 10.0, 12.0)
      ctx.clip()
      ctx.set_source(radial)
      ctx.paint()
      ctx.restore()

      ctx.save()
      ctx.rectangle(2.0, 3.0, 12.0, 10.0)
      ctx.clip()
      ctx.set_source_rgba(1.0, 0.65, 0.10, 0.85)
      ctx.mask(mask)
      ctx.restore()
    }
    35 => {
      let mesh = @cairoon.Pattern::mesh()
      mesh.mesh_begin_patch()
      mesh.mesh_move_to(1.0, 2.0)
      mesh.mesh_curve_to(4.0, -1.0, 13.0, 2.0, 15.0, 6.0)
      mesh.mesh_curve_to(13.0, 12.0, 7.0, 17.0, 2.0, 14.0)
      mesh.mesh_curve_to(-1.0, 9.0, -1.0, 5.0, 1.0, 2.0)
      mesh.mesh_set_corner_color_rgba(0, 0.95, 0.05, 0.10, 1.0)
      mesh.mesh_set_corner_color_rgba(1, 0.05, 0.85, 0.25, 0.90)
      mesh.mesh_set_corner_color_rgba(2, 0.10, 0.20, 0.95, 0.80)
      mesh.mesh_set_corner_color_rgba(3, 0.95, 0.85, 0.05, 0.95)
      mesh.mesh_end_patch()
      mesh.mesh_begin_patch()
      mesh.mesh_move_to(6.0, 3.0)
      mesh.mesh_line_to(15.0, 8.0)
      mesh.mesh_line_to(9.0, 15.0)
      mesh.mesh_line_to(3.0, 11.0)
      mesh.mesh_set_corner_color_rgba(0, 0.05, 0.05, 0.07, 0.70)
      mesh.mesh_set_corner_color_rgba(1, 1.00, 1.00, 1.00, 0.35)
      mesh.mesh_set_corner_color_rgba(2, 0.90, 0.20, 0.70, 0.65)
      mesh.mesh_set_corner_color_rgba(3, 0.15, 0.90, 0.95, 0.75)
      mesh.mesh_end_patch()
      mesh.set_filter(@cairoon.Good)
      mesh.set_dither(@cairoon.DitherBest)
      mesh.set_matrix(
        @cairoon.Matrix::new(
          xx=0.88,
          yx=-0.06,
          xy=0.14,
          yy=0.82,
          x0=-0.25,
          y0=0.75,
        ),
      )

      let linear = @cairoon.Pattern::linear(0.0, 16.0, 16.0, 0.0)
      linear.add_color_stop_rgba(0.0, 0.02, 0.04, 0.12, 0.30)
      linear.add_color_stop_rgba(0.35, 0.95, 0.25, 0.05, 0.55)
      linear.add_color_stop_rgba(0.70, 0.08, 0.85, 0.55, 0.70)
      linear.add_color_stop_rgba(1.0, 0.95, 0.95, 0.25, 0.45)
      linear.set_extend(@cairoon.Pad)
      linear.set_filter(@cairoon.Good)
      linear.set_dither(@cairoon.DitherFast)
      linear.set_matrix(
        @cairoon.Matrix::new(
          xx=0.92,
          yx=0.10,
          xy=-0.12,
          yy=0.78,
          x0=-0.80,
          y0=1.10,
        ),
      )

      let mask_surface = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      let mask_ctx = @cairoon.Context::new(mask_surface)
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 0.20)
      mask_ctx.rectangle(0.0, 0.0, 1.0, 1.0)
      mask_ctx.fill()
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 0.55)
      mask_ctx.rectangle(1.0, 0.0, 1.0, 1.0)
      mask_ctx.fill()
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 0.80)
      mask_ctx.rectangle(0.0, 1.0, 1.0, 1.0)
      mask_ctx.fill()
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.00)
      mask_ctx.rectangle(1.0, 1.0, 1.0, 1.0)
      mask_ctx.fill()
      let mask = @cairoon.Pattern::for_surface(mask_surface)
      mask.set_extend(@cairoon.Reflect)
      mask.set_filter(@cairoon.Nearest)
      mask.set_dither(@cairoon.DitherNone)
      mask.set_matrix(
        @cairoon.Matrix::new(
          xx=0.48,
          yx=0.08,
          xy=-0.10,
          yy=0.52,
          x0=-1.20,
          y0=-0.80,
        ),
      )

      ctx.set_source_rgb(0.015, 0.025, 0.050)
      ctx.paint()
      ctx.save()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.clip()
      ctx.push_group_with_content(@cairoon.ContentColorAlpha)
      ctx.set_source(mesh)
      ctx.paint()
      ctx.set_operator(@cairoon.OperatorAtop)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(linear)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    36 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)

      let repeat = @cairoon.Pattern::for_surface(source)
      repeat.set_extend(@cairoon.Repeat)
      repeat.set_filter(@cairoon.Nearest)
      repeat.set_dither(@cairoon.DitherGood)
      repeat.set_matrix(
        @cairoon.Matrix::new(
          xx=0.44,
          yx=0.06,
          xy=-0.08,
          yy=0.56,
          x0=-1.10,
          y0=0.40,
        ),
      )

      let mask = @cairoon.Pattern::radial(4.0, 12.0, 0.50, 11.52, 4.48, 9.00)
      mask.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.10)
      mask.add_color_stop_rgba(0.45, 1.0, 1.0, 1.0, 0.72)
      mask.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.95)
      mask.set_extend(@cairoon.Reflect)
      mask.set_filter(@cairoon.Good)
      mask.set_dither(@cairoon.DitherFast)
      mask.set_matrix(
        @cairoon.Matrix::new(
          xx=0.88,
          yx=-0.10,
          xy=0.12,
          yy=0.82,
          x0=0.30,
          y0=-0.60,
        ),
      )

      ctx.set_source_rgb(0.025, 0.020, 0.045)
      ctx.paint()
      ctx.save()
      ctx.rectangle(1.0, 2.0, 14.0, 12.0)
      ctx.clip()
      ctx.set_source_surface(source, x=-1.0, y=2.0)
      ctx.paint_with_alpha(0.65)
      ctx.push_group_with_content(@cairoon.ContentColorAlpha)
      ctx.set_source(repeat)
      ctx.paint()
      ctx.set_operator(@cairoon.OperatorMultiply)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source_rgba(0.90, 0.55, 0.10, 0.72)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn render_image_oracle_scene(scene : Int) -> Bytes raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 16, 16)
  let ctx = @cairoon.Context::new(surface)
  draw_image_oracle_scene(ctx, scene)
  surface.copy_data()
}

///|
fn render_buffered_image_oracle_scene(
  scene : Int,
) -> (Bytes, Bytes) raise @cairoon.CairoError {
  let width = 16
  let height = 16
  let stride = @cairoon.Format::stride_for_width(@cairoon.Argb32, width)
  let backing : FixedArray[Byte] = FixedArray::make(stride * height, b'\x00')
  let surface = @cairoon.Surface::image_for_data(
    backing,
    @cairoon.Argb32,
    width,
    height,
    stride~,
  )
  let ctx = @cairoon.Context::new(surface)
  draw_image_oracle_scene(ctx, scene)
  surface.flush()
  (Bytes::from_array(backing), surface.copy_data())
}

///|
test "image rendering scenes match direct cairo C oracle" {
  for scene in 0..<37 {
    let actual = render_image_oracle_scene(scene)
    let expected = test_argb32_scene_oracle_ffi(scene, 16, 16)
    inspect(expected.length(), content="1024")
    inspect(actual == expected, content="true")
  }
}

///|
test "buffer backed image rendering scenes match direct cairo C oracle" {
  for scene in 0..<37 {
    let (actual, copied) = render_buffered_image_oracle_scene(scene)
    let expected = test_argb32_scene_oracle_ffi(scene, 16, 16)
    inspect(expected.length(), content="1024")
    inspect(copied == actual, content="true")
    inspect(actual == expected, content="true")
  }
}
