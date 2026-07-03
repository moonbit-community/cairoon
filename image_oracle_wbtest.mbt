///|
test "image paint bytes match direct cairo C oracle" {
  let surface = Surface::image(Argb32, 2, 2)
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  let actual = surface.copy_data()
  let expected = test_argb32_blue_paint_oracle_ffi(2, 2)
  inspect(expected.length(), content="16")
  inspect(actual == expected, content="true")
}
