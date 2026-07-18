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
fn set_image_oracle_dither_if_supported(
  pattern : @cairoon.Pattern,
  dither : @cairoon.Dither,
) -> Unit raise @cairoon.CairoError {
  if @cairoon.CAIRO_VERSION >= 11800 {
    pattern.set_dither(dither)
  }
}

///|
fn set_image_oracle_hairline_if_supported(
  ctx : @cairoon.Context,
  enabled : Bool,
) -> Unit raise @cairoon.CairoError {
  if @cairoon.CAIRO_VERSION >= 11800 {
    ctx.set_hairline(enabled)
  }
}

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
  if scene < 19 {
    draw_image_oracle_basic_scene(ctx, scene)
  } else if scene < 34 {
    draw_image_oracle_pattern_scene(ctx, scene)
  } else if scene < 42 {
    draw_image_oracle_pattern_stack_scene(ctx, scene)
  } else {
    draw_image_oracle_pattern_operator_scene(ctx, scene)
  }
}

///|
fn render_image_oracle_scene(scene : Int) -> Bytes raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(Argb32, 16, 16)
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
  let stride = @cairoon.Format::stride_for_width(Argb32, width)
  let backing : FixedArray[Byte] = FixedArray::make(stride * height, b'\x00')
  let surface = @cairoon.Surface::image_for_data(
    backing,
    Argb32,
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
  for scene in 0..<47 {
    let actual = render_image_oracle_scene(scene)
    let expected = test_argb32_scene_oracle_ffi(scene, 16, 16)
    inspect(expected.length(), content="1024")
    inspect(actual == expected, content="true")
  }
}

///|
test "buffer backed image rendering scenes match direct cairo C oracle" {
  for scene in 0..<47 {
    let (actual, copied) = render_buffered_image_oracle_scene(scene)
    let expected = test_argb32_scene_oracle_ffi(scene, 16, 16)
    inspect(expected.length(), content="1024")
    inspect(copied == actual, content="true")
    inspect(actual == expected, content="true")
  }
}
