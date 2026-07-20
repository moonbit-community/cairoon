///|
fn draw_image_oracle_pattern_stack_scene_37_41(
  ctx : @cairoon.Context,
  scene : Int,
) -> Unit raise @cairoon.CairoError {
  match scene {
    37 => {
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.set_line_width(6.0)
      set_image_oracle_hairline_if_supported(ctx, true)
      ctx.move_to(1.5, 8.0)
      ctx.line_to(14.5, 8.0)
      ctx.stroke()
    }
    38 => {
      let mask_surface = @cairoon.Surface::image(Argb32, 2, 2)
      let mask_ctx = @cairoon.Context::new(mask_surface)
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 0.15)
      mask_ctx.rectangle(0.0, 0.0, 1.0, 1.0)
      mask_ctx.fill()
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 0.55)
      mask_ctx.rectangle(1.0, 0.0, 1.0, 1.0)
      mask_ctx.fill()
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 0.75)
      mask_ctx.rectangle(0.0, 1.0, 1.0, 1.0)
      mask_ctx.fill()
      mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
      mask_ctx.rectangle(1.0, 1.0, 1.0, 1.0)
      mask_ctx.fill()
      mask_surface.set_device_offset(0.5, -0.25)

      let mask = @cairoon.Pattern::for_surface(mask_surface)
      mask.set_extend(Reflect)
      mask.set_filter(Nearest)
      set_image_oracle_dither_if_supported(mask, DitherNone)
      mask.set_matrix(
        @cairoon.Matrix::new(
          xx=0.52,
          yx=0.11,
          xy=-0.09,
          yy=0.47,
          x0=-1.35,
          y0=0.55,
        ),
      )

      let linear = @cairoon.Pattern::linear(0.0, 0.0, 16.0, 0.0)
      linear.add_color_stop_rgba(0.0, 0.04, 0.08, 0.16, 0.85)
      linear.add_color_stop_rgba(0.35, 0.85, 0.25, 0.10, 0.65)
      linear.add_color_stop_rgba(0.70, 0.10, 0.80, 0.55, 0.75)
      linear.add_color_stop_rgba(1.0, 0.95, 0.95, 0.25, 0.90)
      linear.set_extend(Pad)
      linear.set_filter(Good)
      set_image_oracle_dither_if_supported(linear, DitherFast)
      linear.set_matrix(
        @cairoon.Matrix::new(
          xx=0.90,
          yx=-0.07,
          xy=0.13,
          yy=0.82,
          x0=-0.70,
          y0=1.20,
        ),
      )

      ctx.set_source_rgb(0.02, 0.025, 0.055)
      ctx.paint()
      ctx.save()
      ctx.rectangle(2.0, 1.0, 12.0, 14.0)
      ctx.clip()
      ctx.push_group_with_content(ContentColorAlpha)
      ctx.set_source(linear)
      ctx.paint()
      ctx.set_operator(OperatorScreen)
      ctx.rectangle(3.0, 3.0, 10.0, 10.0)
      ctx.set_source_rgba(0.15, 0.80, 0.95, 0.70)
      ctx.fill()
      ctx.set_operator(OperatorOver)
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    39 => {
      let source = @cairoon.Surface::image(Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(Reflect)
      surface_pattern.set_filter(Nearest)
      set_image_oracle_dither_if_supported(surface_pattern, DitherFast)
      surface_pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.58,
          yx=-0.09,
          xy=0.16,
          yy=0.53,
          x0=-1.80,
          y0=0.25,
        ),
      )

      let radial = @cairoon.Pattern::radial(4.0, 4.0, 0.75, 12.0, 11.0, 8.0)
      radial.add_color_stop_rgba(0.0, 0.98, 0.92, 0.18, 0.92)
      radial.add_color_stop_rgba(0.42, 0.10, 0.72, 0.85, 0.68)
      radial.add_color_stop_rgba(1.0, 0.04, 0.05, 0.12, 0.88)
      radial.set_extend(Repeat)
      radial.set_filter(Good)
      set_image_oracle_dither_if_supported(radial, DitherBest)
      radial.set_matrix(
        @cairoon.Matrix::new(
          xx=0.86,
          yx=0.12,
          xy=-0.14,
          yy=0.79,
          x0=0.75,
          y0=-1.10,
        ),
      )

      let mask = @cairoon.Pattern::linear(0.0, 16.0, 16.0, 0.0)
      mask.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.05)
      mask.add_color_stop_rgba(0.50, 1.0, 1.0, 1.0, 0.62)
      mask.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.98)
      mask.set_extend(Pad)
      mask.set_filter(Good)
      set_image_oracle_dither_if_supported(mask, DitherDefault)
      mask.set_matrix(
        @cairoon.Matrix::new(
          xx=0.93,
          yx=-0.08,
          xy=0.11,
          yy=0.84,
          x0=-0.35,
          y0=0.70,
        ),
      )

      ctx.set_source_rgb(0.018, 0.030, 0.055)
      ctx.paint()
      ctx.save()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.clip()
      ctx.push_group_with_content(ContentColorAlpha)
      ctx.set_source(surface_pattern)
      ctx.paint()
      ctx.set_operator(OperatorOverlay)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(radial)
      ctx.fill()
      ctx.set_operator(OperatorOver)
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    40 => {
      let source = @cairoon.Surface::image(Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)

      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(Pad)
      surface_pattern.set_filter(Bilinear)
      set_image_oracle_dither_if_supported(surface_pattern, DitherDefault)
      surface_pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.64,
          yx=0.09,
          xy=-0.12,
          yy=0.59,
          x0=-0.90,
          y0=0.65,
        ),
      )

      let mesh = @cairoon.Pattern::mesh()
      mesh.mesh_begin_patch()
      mesh.mesh_move_to(1.0, 1.0)
      mesh.mesh_curve_to(5.0, -1.0, 13.0, 2.0, 15.0, 7.0)
      mesh.mesh_curve_to(12.0, 14.0, 5.0, 16.0, 1.0, 11.0)
      mesh.mesh_curve_to(-1.0, 7.0, -1.0, 3.0, 1.0, 1.0)
      mesh.mesh_set_corner_color_rgba(0, 0.92, 0.08, 0.12, 0.95)
      mesh.mesh_set_corner_color_rgba(1, 0.08, 0.82, 0.32, 0.82)
      mesh.mesh_set_corner_color_rgba(2, 0.10, 0.24, 0.95, 0.78)
      mesh.mesh_set_corner_color_rgba(3, 0.95, 0.88, 0.10, 0.92)
      mesh.mesh_end_patch()
      mesh.set_filter(Good)
      set_image_oracle_dither_if_supported(mesh, DitherGood)
      mesh.set_matrix(
        @cairoon.Matrix::new(
          xx=0.87,
          yx=-0.10,
          xy=0.13,
          yy=0.81,
          x0=0.20,
          y0=0.50,
        ),
      )

      let linear = @cairoon.Pattern::linear(0.0, 3.0, 16.0, 13.0)
      linear.add_color_stop_rgba(0.0, 0.06, 0.08, 0.16, 0.88)
      linear.add_color_stop_rgba(0.33, 0.86, 0.24, 0.14, 0.65)
      linear.add_color_stop_rgba(0.66, 0.16, 0.84, 0.62, 0.72)
      linear.add_color_stop_rgba(1.0, 0.98, 0.92, 0.25, 0.82)
      linear.set_extend(Repeat)
      linear.set_filter(Bilinear)
      set_image_oracle_dither_if_supported(linear, DitherBest)
      linear.set_matrix(
        @cairoon.Matrix::new(
          xx=0.74,
          yx=0.05,
          xy=-0.16,
          yy=0.88,
          x0=-1.10,
          y0=1.50,
        ),
      )

      let mask = @cairoon.Pattern::radial(5.0, 12.0, 0.5, 11.0, 4.0, 9.0)
      mask.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.08)
      mask.add_color_stop_rgba(0.42, 1.0, 1.0, 1.0, 0.66)
      mask.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.96)
      mask.set_extend(Reflect)
      mask.set_filter(Good)
      set_image_oracle_dither_if_supported(mask, DitherFast)
      mask.set_matrix(
        @cairoon.Matrix::new(
          xx=0.91,
          yx=-0.06,
          xy=0.10,
          yy=0.83,
          x0=0.45,
          y0=-0.55,
        ),
      )

      ctx.set_source_rgb(0.016, 0.020, 0.046)
      ctx.paint()
      ctx.save()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.clip()
      ctx.push_group_with_content(ContentColorAlpha)
      ctx.set_source(mesh)
      ctx.paint()
      ctx.set_operator(OperatorSoftLight)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(surface_pattern)
      ctx.fill()
      ctx.set_operator(OperatorOver)
      ctx.set_source(linear)
      ctx.paint_with_alpha(0.72)
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    41 => {
      let source = @cairoon.Surface::image(Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      source.set_device_offset(-0.35, 0.40)

      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(Repeat)
      surface_pattern.set_filter(Bilinear)
      set_image_oracle_dither_if_supported(surface_pattern, DitherBest)
      surface_pattern.set_matrix(
        @cairoon.Matrix::new(
          xx=0.46,
          yx=0.12,
          xy=-0.10,
          yy=0.54,
          x0=-1.50,
          y0=0.35,
        ),
      )

      let linear = @cairoon.Pattern::linear(16.0, 0.0, 0.0, 16.0)
      linear.add_color_stop_rgba(0.0, 0.04, 0.07, 0.14, 0.94)
      linear.add_color_stop_rgba(0.38, 0.92, 0.32, 0.10, 0.72)
      linear.add_color_stop_rgba(0.72, 0.18, 0.78, 0.58, 0.68)
      linear.add_color_stop_rgba(1.0, 0.90, 0.92, 0.24, 0.86)
      linear.set_extend(Pad)
      linear.set_filter(Good)
      set_image_oracle_dither_if_supported(linear, DitherDefault)
      linear.set_matrix(
        @cairoon.Matrix::new(
          xx=0.88,
          yx=-0.09,
          xy=0.16,
          yy=0.82,
          x0=-0.45,
          y0=1.05,
        ),
      )

      let mask = @cairoon.Pattern::radial(3.0, 13.0, 0.5, 12.0, 4.0, 8.5)
      mask.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.04)
      mask.add_color_stop_rgba(0.48, 1.0, 1.0, 1.0, 0.64)
      mask.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.98)
      mask.set_extend(Reflect)
      mask.set_filter(Good)
      set_image_oracle_dither_if_supported(mask, DitherFast)
      mask.set_matrix(
        @cairoon.Matrix::new(
          xx=0.90,
          yx=0.07,
          xy=-0.12,
          yy=0.85,
          x0=0.30,
          y0=-0.65,
        ),
      )

      ctx.set_source_rgb(0.018, 0.022, 0.050)
      ctx.paint()
      ctx.save()
      ctx.rectangle(1.0, 1.0, 14.0, 14.0)
      ctx.clip()
      ctx.push_group_with_content(ContentColorAlpha)
      ctx.set_source(linear)
      ctx.paint()
      ctx.set_operator(OperatorDifference)
      ctx.set_line_width(3.0)
      ctx.set_line_join(LineJoinRound)
      ctx.set_line_cap(LineCapSquare)
      ctx.set_dash([3.0, 1.5], offset=0.75)
      ctx.set_source(surface_pattern)
      ctx.move_to(2.0, 4.0)
      ctx.curve_to(6.0, -1.0, 10.0, 17.0, 14.0, 11.0)
      ctx.stroke()
      ctx.set_operator(OperatorOver)
      ctx.rectangle(2.0, 2.0, 12.0, 12.0)
      ctx.set_source_rgba(0.90, 0.25, 0.55, 0.45)
      ctx.fill()
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}
