///|
fn draw_image_oracle_pattern_stack_scene(
  ctx : @cairoon.Context,
  scene : Int,
) -> Unit raise @cairoon.CairoError {
  match scene {
    34 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(@cairoon.Repeat)
      surface_pattern.set_filter(@cairoon.Nearest)
      set_image_oracle_dither_if_supported(surface_pattern, @cairoon.DitherGood)
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
      set_image_oracle_dither_if_supported(linear, @cairoon.DitherBest)
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
      set_image_oracle_dither_if_supported(radial, @cairoon.DitherDefault)
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
      set_image_oracle_dither_if_supported(mesh, @cairoon.DitherBest)
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
      set_image_oracle_dither_if_supported(linear, @cairoon.DitherFast)
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
      set_image_oracle_dither_if_supported(mask, @cairoon.DitherNone)
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
      set_image_oracle_dither_if_supported(repeat, @cairoon.DitherGood)
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
      set_image_oracle_dither_if_supported(mask, @cairoon.DitherFast)
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
    37 => {
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.set_line_width(6.0)
      set_image_oracle_hairline_if_supported(ctx, true)
      ctx.move_to(1.5, 8.0)
      ctx.line_to(14.5, 8.0)
      ctx.stroke()
    }
    38 => {
      let mask_surface = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
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
      mask.set_extend(@cairoon.Reflect)
      mask.set_filter(@cairoon.Nearest)
      set_image_oracle_dither_if_supported(mask, @cairoon.DitherNone)
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
      linear.set_extend(@cairoon.Pad)
      linear.set_filter(@cairoon.Good)
      set_image_oracle_dither_if_supported(linear, @cairoon.DitherFast)
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
      ctx.push_group_with_content(@cairoon.ContentColorAlpha)
      ctx.set_source(linear)
      ctx.paint()
      ctx.set_operator(@cairoon.OperatorScreen)
      ctx.rectangle(3.0, 3.0, 10.0, 10.0)
      ctx.set_source_rgba(0.15, 0.80, 0.95, 0.70)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    39 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(@cairoon.Reflect)
      surface_pattern.set_filter(@cairoon.Nearest)
      set_image_oracle_dither_if_supported(surface_pattern, @cairoon.DitherFast)
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
      radial.set_extend(@cairoon.Repeat)
      radial.set_filter(@cairoon.Good)
      set_image_oracle_dither_if_supported(radial, @cairoon.DitherBest)
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
      mask.set_extend(@cairoon.Pad)
      mask.set_filter(@cairoon.Good)
      set_image_oracle_dither_if_supported(mask, @cairoon.DitherDefault)
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
      ctx.push_group_with_content(@cairoon.ContentColorAlpha)
      ctx.set_source(surface_pattern)
      ctx.paint()
      ctx.set_operator(@cairoon.OperatorOverlay)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(radial)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    40 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)

      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(@cairoon.Pad)
      surface_pattern.set_filter(@cairoon.Bilinear)
      set_image_oracle_dither_if_supported(
        surface_pattern,
        @cairoon.DitherDefault,
      )
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
      mesh.set_filter(@cairoon.Good)
      set_image_oracle_dither_if_supported(mesh, @cairoon.DitherGood)
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
      linear.set_extend(@cairoon.Repeat)
      linear.set_filter(@cairoon.Bilinear)
      set_image_oracle_dither_if_supported(linear, @cairoon.DitherBest)
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
      mask.set_extend(@cairoon.Reflect)
      mask.set_filter(@cairoon.Good)
      set_image_oracle_dither_if_supported(mask, @cairoon.DitherFast)
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
      ctx.push_group_with_content(@cairoon.ContentColorAlpha)
      ctx.set_source(mesh)
      ctx.paint()
      ctx.set_operator(@cairoon.OperatorSoftLight)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(surface_pattern)
      ctx.fill()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.set_source(linear)
      ctx.paint_with_alpha(0.72)
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    41 => {
      let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      source.set_device_offset(-0.35, 0.40)

      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(@cairoon.Repeat)
      surface_pattern.set_filter(@cairoon.Bilinear)
      set_image_oracle_dither_if_supported(surface_pattern, @cairoon.DitherBest)
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
      linear.set_extend(@cairoon.Pad)
      linear.set_filter(@cairoon.Good)
      set_image_oracle_dither_if_supported(linear, @cairoon.DitherDefault)
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
      mask.set_extend(@cairoon.Reflect)
      mask.set_filter(@cairoon.Good)
      set_image_oracle_dither_if_supported(mask, @cairoon.DitherFast)
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
      ctx.push_group_with_content(@cairoon.ContentColorAlpha)
      ctx.set_source(linear)
      ctx.paint()
      ctx.set_operator(@cairoon.OperatorDifference)
      ctx.set_line_width(3.0)
      ctx.set_line_join(@cairoon.LineJoinRound)
      ctx.set_line_cap(@cairoon.LineCapSquare)
      ctx.set_dash([3.0, 1.5], offset=0.75)
      ctx.set_source(surface_pattern)
      ctx.move_to(2.0, 4.0)
      ctx.curve_to(6.0, -1.0, 10.0, 17.0, 14.0, 11.0)
      ctx.stroke()
      ctx.set_operator(@cairoon.OperatorOver)
      ctx.rectangle(2.0, 2.0, 12.0, 12.0)
      ctx.set_source_rgba(0.90, 0.25, 0.55, 0.45)
      ctx.fill()
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}
