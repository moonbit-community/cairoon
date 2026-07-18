///|
fn paint_quad_source_surface(
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
fn apply_vector_surface_pattern(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  let source = @cairoon.Surface::image(Argb32, 2, 2)
  paint_quad_source_surface(source)
  let pattern = @cairoon.Pattern::for_surface(source)
  pattern.set_extend(Repeat)
  pattern.set_filter(Nearest)
  ctx.rectangle(0.0, 0.0, 10.0, 10.0)
  ctx.set_source(pattern)
  ctx.fill()
}

///|
fn apply_vector_mask_surface(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  let mask = @cairoon.Surface::image(Argb32, 2, 2)
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
  ctx.mask_surface(mask, x=4.0, y=4.0)
}

///|
fn apply_vector_mesh_pattern(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
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
