///|
fn draw_image_oracle_pattern_stack_scene(
  ctx : @cairoon.Context,
  scene : Int,
) -> Unit raise @cairoon.CairoError {
  if scene <= 36 {
    draw_image_oracle_pattern_stack_scene_34_36(ctx, scene)
  } else {
    draw_image_oracle_pattern_stack_scene_37_41(ctx, scene)
  }
}
