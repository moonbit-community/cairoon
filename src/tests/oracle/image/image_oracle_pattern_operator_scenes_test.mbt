///|
fn draw_image_oracle_pattern_operator_scene(
  ctx : @cairoon.Context,
  scene : Int,
) -> Unit raise @cairoon.CairoError {
  match scene {
    42 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      source.set_device_offset(0.25, -0.30)

      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(@cairoon.Reflect)
      surface_pattern.set_filter(@cairoon.Nearest)
      surface_pattern.set_dither(@cairoon.DitherFast)
      surface_pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.62,
          yx=0.18,
          xy=-0.14,
          yy=0.58,
          x0=-0.75,
          y0=0.20,
        ),
      )

      let radial = @cairoon.Pattern::radial(2.5, 2.0, 0.4, 12.5, 13.5, 7.5)
      radial.add_color_stop_rgba(0.0, 0.95, 0.95, 0.15, 0.88)
      radial.add_color_stop_rgba(0.45, 0.15, 0.90, 0.80, 0.70)
      radial.add_color_stop_rgba(1.0, 0.80, 0.10, 0.95, 0.82)
      radial.set_extend(@cairoon.Pad)
      radial.set_filter(@cairoon.Bilinear)
      radial.set_dither(@cairoon.DitherBest)
      radial.set_matrix(
        @cairoon.Matrix::new(
          xx=0.82,
          yx=-0.10,
          xy=0.18,
          yy=0.76,
          x0=-1.20,
          y0=0.80,
        ),
      )

      ctx.set_source_rgb(0.035, 0.030, 0.070)
      ctx.paint()
      ctx.save()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.clip()
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(surface_pattern)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorColorDodge)
      ctx.set_source(radial)
      ctx.arc(8.0, 8.8, 7.0, 0.0, 6.283185307179586)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.set_source_rgba(0.02, 0.03, 0.06, 0.35)
      ctx.rectangle(0.0, 0.0, 16.0, 3.0)
      ctx.fill()
      ctx.restore()
    }
    43 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      source.set_device_offset(-0.40, 0.35)

      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(@cairoon.Repeat)
      surface_pattern.set_filter(@cairoon.Good)
      surface_pattern.set_dither(@cairoon.DitherNone)
      surface_pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.72,
          yx=-0.16,
          xy=0.12,
          yy=0.68,
          x0=-1.00,
          y0=0.45,
        ),
      )

      let linear = @cairoon.Pattern::linear(0.0, 16.0, 16.0, 0.0)
      linear.add_color_stop_rgba(0.0, 0.95, 0.12, 0.08, 0.86)
      linear.add_color_stop_rgba(0.38, 0.10, 0.86, 0.42, 0.74)
      linear.add_color_stop_rgba(0.72, 0.10, 0.22, 0.92, 0.80)
      linear.add_color_stop_rgba(1.0, 0.92, 0.90, 0.18, 0.88)
      linear.set_extend(@cairoon.Reflect)
      linear.set_filter(@cairoon.Bilinear)
      linear.set_dither(@cairoon.DitherGood)
      linear.set_matrix(
        @cairoon.Matrix::new(
          xx=0.90,
          yx=0.12,
          xy=-0.18,
          yy=0.84,
          x0=1.20,
          y0=-0.60,
        ),
      )

      let mask = @cairoon.Pattern::radial(8.0, 8.0, 1.0, 8.0, 8.0, 8.5)
      mask.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.08)
      mask.add_color_stop_rgba(0.45, 1.0, 1.0, 1.0, 0.72)
      mask.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.96)
      mask.set_extend(@cairoon.Pad)
      mask.set_filter(@cairoon.Good)
      mask.set_dither(@cairoon.DitherDefault)
      mask.set_matrix(
        @cairoon.Matrix::new(
          xx=0.88,
          yx=-0.08,
          xy=0.10,
          yy=0.92,
          x0=-0.35,
          y0=0.25,
        ),
      )

      ctx.set_source_rgb(0.025, 0.025, 0.055)
      ctx.paint()
      ctx.save()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.clip()
      ctx.push_group()
      ctx.set_source(surface_pattern)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorHslHue)
      ctx.set_source(linear)
      ctx.move_to(1.0, 14.0)
      ctx.curve_to(4.8, 1.0, 11.2, 15.0, 15.0, 2.0)
      ctx.line_to(14.0, 14.0)
      ctx.close_path()
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.set_source_rgba(1.0, 1.0, 1.0, 0.16)
      ctx.rectangle(2.0, 2.0, 12.0, 3.0)
      ctx.fill()
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    44 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      source.set_device_offset(0.35, 0.15)

      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(@cairoon.Pad)
      surface_pattern.set_filter(@cairoon.Nearest)
      surface_pattern.set_dither(@cairoon.DitherGood)
      surface_pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.68,
          yx=0.14,
          xy=-0.10,
          yy=0.74,
          x0=-0.55,
          y0=-0.35,
        ),
      )

      let linear = @cairoon.Pattern::linear(0.0, 0.0, 16.0, 16.0)
      linear.add_color_stop_rgba(0.0, 0.92, 0.12, 0.84, 0.82)
      linear.add_color_stop_rgba(0.30, 0.12, 0.70, 0.95, 0.78)
      linear.add_color_stop_rgba(0.68, 0.90, 0.84, 0.12, 0.74)
      linear.add_color_stop_rgba(1.0, 0.18, 0.94, 0.26, 0.86)
      linear.set_extend(@cairoon.Repeat)
      linear.set_filter(@cairoon.Good)
      linear.set_dither(@cairoon.DitherFast)
      linear.set_matrix(
        @cairoon.Matrix::new(
          xx=0.78,
          yx=-0.14,
          xy=0.16,
          yy=0.86,
          x0=0.70,
          y0=-0.90,
        ),
      )

      let mask = @cairoon.Pattern::radial(8.0, 8.0, 1.25, 8.0, 8.0, 7.75)
      mask.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.18)
      mask.add_color_stop_rgba(0.42, 1.0, 1.0, 1.0, 0.78)
      mask.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.92)
      mask.set_extend(@cairoon.Pad)
      mask.set_filter(@cairoon.Bilinear)
      mask.set_dither(@cairoon.DitherDefault)
      mask.set_matrix(
        @cairoon.Matrix::new(
          xx=0.84,
          yx=0.06,
          xy=-0.12,
          yy=0.88,
          x0=0.25,
          y0=-0.15,
        ),
      )

      ctx.set_source_rgb(0.030, 0.028, 0.060)
      ctx.paint()
      ctx.save()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.clip()
      ctx.push_group_with_content(@cairoon.ContentColorAlpha)
      ctx.set_source(surface_pattern)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorHslSaturation)
      ctx.set_source(linear)
      ctx.arc(8.32, 7.52, 6.6, 0.0, 6.283185307179586)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.set_source_rgba(0.08, 0.08, 0.14, 0.30)
      ctx.rectangle(2.0, 10.0, 12.0, 3.0)
      ctx.fill()
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    45 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      source.set_device_offset(-0.25, -0.20)

      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(@cairoon.Reflect)
      surface_pattern.set_filter(@cairoon.Bilinear)
      surface_pattern.set_dither(@cairoon.DitherBest)
      surface_pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.64,
          yx=-0.12,
          xy=0.18,
          yy=0.72,
          x0=-0.80,
          y0=0.35,
        ),
      )

      let radial = @cairoon.Pattern::radial(3.0, 13.0, 0.5, 13.5, 2.5, 8.0)
      radial.add_color_stop_rgba(0.0, 0.10, 0.86, 0.94, 0.84)
      radial.add_color_stop_rgba(0.36, 0.95, 0.24, 0.18, 0.78)
      radial.add_color_stop_rgba(0.78, 0.24, 0.94, 0.28, 0.72)
      radial.add_color_stop_rgba(1.0, 0.88, 0.86, 0.16, 0.86)
      radial.set_extend(@cairoon.Repeat)
      radial.set_filter(@cairoon.Good)
      radial.set_dither(@cairoon.DitherFast)
      radial.set_matrix(
        @cairoon.Matrix::new(
          xx=0.86,
          yx=0.11,
          xy=-0.13,
          yy=0.80,
          x0=0.55,
          y0=-0.75,
        ),
      )

      let mask = @cairoon.Pattern::linear(0.0, 0.0, 16.0, 16.0)
      mask.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.12)
      mask.add_color_stop_rgba(0.52, 1.0, 1.0, 1.0, 0.76)
      mask.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.98)
      mask.set_extend(@cairoon.Pad)
      mask.set_filter(@cairoon.Bilinear)
      mask.set_dither(@cairoon.DitherDefault)
      mask.set_matrix(
        @cairoon.Matrix::new(
          xx=0.90,
          yx=-0.04,
          xy=0.08,
          yy=0.86,
          x0=-0.25,
          y0=0.30,
        ),
      )

      ctx.set_source_rgb(0.026, 0.030, 0.050)
      ctx.paint()
      ctx.save()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.clip()
      ctx.push_group_with_content(@cairoon.ContentColorAlpha)
      ctx.set_source(surface_pattern)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorHslColor)
      ctx.set_source(radial)
      ctx.move_to(2.0, 3.0)
      ctx.curve_to(5.5, 0.5, 12.5, 2.0, 14.0, 7.0)
      ctx.line_to(12.0, 14.0)
      ctx.curve_to(8.5, 12.5, 4.5, 14.5, 2.0, 11.0)
      ctx.close_path()
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.set_source_rgba(0.95, 0.95, 0.88, 0.12)
      ctx.rectangle(3.0, 11.0, 10.0, 2.5)
      ctx.fill()
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    46 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      source.set_device_offset(0.10, -0.45)

      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(@cairoon.Repeat)
      surface_pattern.set_filter(@cairoon.Bilinear)
      surface_pattern.set_dither(@cairoon.DitherDefault)
      surface_pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.58,
          yx=0.20,
          xy=-0.22,
          yy=0.66,
          x0=0.40,
          y0=-0.30,
        ),
      )

      let linear = @cairoon.Pattern::linear(0.0, 14.0, 16.0, 1.0)
      linear.add_color_stop_rgba(0.0, 0.94, 0.78, 0.12, 0.82)
      linear.add_color_stop_rgba(0.34, 0.18, 0.92, 0.86, 0.74)
      linear.add_color_stop_rgba(0.66, 0.92, 0.20, 0.34, 0.78)
      linear.add_color_stop_rgba(1.0, 0.24, 0.30, 0.96, 0.88)
      linear.set_extend(@cairoon.Reflect)
      linear.set_filter(@cairoon.Good)
      linear.set_dither(@cairoon.DitherBest)
      linear.set_matrix(
        @cairoon.Matrix::new(
          xx=0.74,
          yx=-0.18,
          xy=0.10,
          yy=0.82,
          x0=-0.70,
          y0=0.95,
        ),
      )

      let mask = @cairoon.Pattern::radial(5.0, 5.0, 0.75, 10.5, 9.5, 7.2)
      mask.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.16)
      mask.add_color_stop_rgba(0.48, 1.0, 1.0, 1.0, 0.84)
      mask.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.94)
      mask.set_extend(@cairoon.Pad)
      mask.set_filter(@cairoon.Bilinear)
      mask.set_dither(@cairoon.DitherFast)
      mask.set_matrix(
        @cairoon.Matrix::new(
          xx=0.92,
          yx=0.08,
          xy=-0.06,
          yy=0.88,
          x0=0.10,
          y0=-0.45,
        ),
      )

      ctx.set_source_rgb(0.018, 0.024, 0.046)
      ctx.paint()
      ctx.save()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.clip()
      ctx.push_group_with_content(@cairoon.ContentColorAlpha)
      ctx.set_source(surface_pattern)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorHslLuminosity)
      ctx.set_source(linear)
      ctx.move_to(1.5, 8.0)
      ctx.curve_to(4.0, 1.0, 10.5, 2.0, 14.5, 5.5)
      ctx.line_to(13.0, 13.5)
      ctx.curve_to(8.5, 15.0, 4.0, 13.0, 1.5, 8.0)
      ctx.close_path()
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.set_source_rgba(1.0, 0.96, 0.72, 0.14)
      ctx.set_line_width(1.25)
      ctx.move_to(3.0, 4.0)
      ctx.curve_to(6.0, 9.5, 10.0, 5.5, 13.0, 11.5)
      ctx.stroke()
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}
