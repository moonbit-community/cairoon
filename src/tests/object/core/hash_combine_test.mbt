///|
fn[T : Hash] expect_hash_combine_matches_hash(value : T) -> Unit raise {
  let hasher = Hasher()
  Hash::hash_combine(value, hasher)
  inspect(hasher.finalize() == Hash::hash(value), content="true")
}

///|
test "external object hash_combine agrees with hash" {
  let surface = @cairoon.Surface::image(Argb32, 4, 4)
  let ctx = @cairoon.Context::new(surface)
  let pattern = @cairoon.Pattern::solid_rgb(0.25, 0.5, 0.75)
  let device = @cairoon.Device::script_stream(_bytes => Success)
  ctx.select_font_face("serif")
  let font_face = ctx.get_font_face()
  let scaled_font = ctx.get_scaled_font()
  ctx.line_to(1.0, 2.0)
  let path = ctx.copy_path()

  expect_hash_combine_matches_hash(surface)
  expect_hash_combine_matches_hash(ctx)
  expect_hash_combine_matches_hash(pattern)
  expect_hash_combine_matches_hash(device)
  expect_hash_combine_matches_hash(font_face)
  expect_hash_combine_matches_hash(scaled_font)
  expect_hash_combine_matches_hash(path)
}
