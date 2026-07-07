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
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}
