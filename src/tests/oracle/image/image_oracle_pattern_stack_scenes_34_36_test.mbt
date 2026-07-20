///|
fn draw_image_oracle_pattern_stack_scene_34_36(
  ctx : @cairoon.Context,
  scene : Int,
) -> Unit raise @cairoon.CairoError {
  match scene {
    34 => {
      let source = @cairoon.Surface::image(Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)
      let surface_pattern = @cairoon.Pattern::for_surface(source)
      surface_pattern.set_extend(Repeat)
      surface_pattern.set_filter(Nearest)
      set_image_oracle_dither_if_supported(surface_pattern, DitherGood)
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
      linear.set_extend(Reflect)
      linear.set_filter(Bilinear)
      set_image_oracle_dither_if_supported(linear, DitherBest)
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
      radial.set_extend(Pad)
      radial.set_filter(Good)
      set_image_oracle_dither_if_supported(radial, DitherDefault)
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
      ctx.set_operator(OperatorAtop)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(linear)
      ctx.fill()
      ctx.set_operator(OperatorOver)
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
      mesh.set_filter(Good)
      set_image_oracle_dither_if_supported(mesh, DitherBest)
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
      linear.set_extend(Pad)
      linear.set_filter(Good)
      set_image_oracle_dither_if_supported(linear, DitherFast)
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

      let mask_surface = @cairoon.Surface::image(Argb32, 2, 2)
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
      mask.set_extend(Reflect)
      mask.set_filter(Nearest)
      set_image_oracle_dither_if_supported(mask, DitherNone)
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
      ctx.push_group_with_content(ContentColorAlpha)
      ctx.set_source(mesh)
      ctx.paint()
      ctx.set_operator(OperatorAtop)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source(linear)
      ctx.fill()
      ctx.set_operator(OperatorOver)
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    36 => {
      let source = @cairoon.Surface::image(Argb32, 2, 2)
      paint_image_oracle_quad_surface(source)

      let repeat = @cairoon.Pattern::for_surface(source)
      repeat.set_extend(Repeat)
      repeat.set_filter(Nearest)
      set_image_oracle_dither_if_supported(repeat, DitherGood)
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
      mask.set_extend(Reflect)
      mask.set_filter(Good)
      set_image_oracle_dither_if_supported(mask, DitherFast)
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
      ctx.push_group_with_content(ContentColorAlpha)
      ctx.set_source(repeat)
      ctx.paint()
      ctx.set_operator(OperatorMultiply)
      ctx.rectangle(0.0, 0.0, 16.0, 16.0)
      ctx.set_source_rgba(0.90, 0.55, 0.10, 0.72)
      ctx.fill()
      ctx.set_operator(OperatorOver)
      ctx.pop_group_to_source()
      ctx.mask(mask)
      ctx.restore()
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}
