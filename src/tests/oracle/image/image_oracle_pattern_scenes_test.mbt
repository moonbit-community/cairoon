///|
fn draw_image_oracle_pattern_scene(
  ctx : @cairoon.Context,
  scene : Int,
) -> Unit raise @cairoon.CairoError {
  match scene {
    19 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let pattern = @cairoon.Pattern::for_surface(source)
      pattern.set_extend(@cairoon.Reflect)
      pattern.set_filter(@cairoon.Nearest)
      set_image_oracle_dither_if_supported(pattern, @cairoon.DitherBest)
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
      set_image_oracle_dither_if_supported(pattern, @cairoon.DitherFast)
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
      set_image_oracle_dither_if_supported(pattern, @cairoon.DitherGood)
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
      set_image_oracle_dither_if_supported(pattern, @cairoon.DitherDefault)
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
      set_image_oracle_dither_if_supported(pattern, @cairoon.DitherNone)
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
      set_image_oracle_dither_if_supported(pattern, @cairoon.DitherBest)
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
      set_image_oracle_dither_if_supported(pattern, @cairoon.DitherFast)
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
      set_image_oracle_dither_if_supported(pattern, @cairoon.DitherGood)
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
      set_image_oracle_dither_if_supported(pattern, @cairoon.DitherNone)
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
      set_image_oracle_dither_if_supported(pattern, @cairoon.DitherDefault)
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
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}
