///|
test "consumer renders paths and patterns" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 4, 2)
  let ctx = @cairoon.Context::new(surface)

  ctx.set_source(@cairoon.Pattern::solid_rgb(1.0, 0.0, 0.0))
  ctx.rectangle(0.0, 0.0, 2.0, 2.0)
  let path = ctx.copy_path()
  inspect(path.length() > 0, content="true")
  ctx.fill()

  ctx.set_source(@cairoon.Pattern::solid_rgb(0.0, 0.0, 1.0))
  ctx.rectangle(2.0, 0.0, 2.0, 2.0)
  ctx.fill()
  surface.flush()

  let pixels = surface.copy_data()
  inspect(pixels.length(), content="32")
  inspect(pixels[0].to_int(), content="0")
  inspect(pixels[2].to_int(), content="255")
  inspect(pixels[8].to_int(), content="255")
  inspect(pixels[10].to_int(), content="0")
  inspect(surface.status() == @cairoon.Success, content="true")
}
