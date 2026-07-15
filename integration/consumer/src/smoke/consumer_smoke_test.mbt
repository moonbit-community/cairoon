///|
test "consumer imports, links, and renders through cairoon" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.flush()

  let pixels = surface.copy_data()
  inspect(pixels.length(), content="16")
  inspect(
    pixels[0].to_int() +
    pixels[1].to_int() +
    pixels[2].to_int() +
    pixels[3].to_int(),
    content="510",
  )
  inspect(surface.status() == @cairoon.Success, content="true")
}
