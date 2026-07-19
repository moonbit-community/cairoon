///|
test "consumer maps and unmaps image data with scoped ownership" {
  let surface = @cairoon.Surface::image(@cairoon.Rgb24, 1, 1)
  let mapped = surface.map_to_image()
  mapped.with_unmapped(() => {
    let ctx = @cairoon.Context::new_for_mapped_image(mapped)
    ctx.set_source_rgb(1.0, 1.0, 1.0)
    ctx.paint()
  })
  surface.flush()

  let pixels = surface.copy_data()
  inspect(pixels.length(), content="4")
  inspect(pixels[0].to_int(), content="255")
  inspect(pixels[1].to_int(), content="255")
  inspect(pixels[2].to_int(), content="255")
  inspect(pixels[3].to_int(), content="255")
  inspect(
    @cairoon.run_cairo(() => {
      let _ = mapped.copy_data()
      ()
    })
    is Err(_),
    content="true",
  )
}
