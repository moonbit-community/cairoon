///|
fn has_nonzero_byte(bytes : Bytes) -> Bool {
  for index in 0..<bytes.length() {
    if bytes[index].to_int() != 0 {
      return true
    }
  }
  false
}

///|
fn paint_unicode_text_surface(text : String) -> @cairoon.Surface raise {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 300, 300)
  let ctx = @cairoon.Context::new(surface)
  ctx.scale(300.0, 300.0)
  ctx.set_line_width(0.04)
  ctx.select_font_face(
    "Sans",
    slant=@cairoon.FontSlantNormal,
    weight=@cairoon.FontWeightNormal,
  )
  ctx.set_font_size(0.20)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.move_to(0.05, 0.5)
  let extents = ctx.text_extents(text)
  inspect(extents.x_advance > 0.0, content="true")
  ctx.show_text(text)
  surface
}

///|
test "pycairo unicode show_text smoke fixture" {
  let surface = paint_unicode_text_surface("ēxāmple.")
  inspect(has_nonzero_byte(surface.copy_data()), content="true")
}

///|
test "pycairo unicode png filename roundtrip fixture" {
  let path = "/tmp/cairoon_pycairo_unicode_ēxāmple.png"
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 10, 10)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgba(0.0, 0.25, 1.0, 1.0)
  ctx.paint()
  surface.write_to_png(path)

  let loaded = @cairoon.Surface::image_from_png(path)
  inspect(loaded.get_width(), content="10")
  inspect(loaded.get_height(), content="10")
  inspect(loaded.copy_data() == surface.copy_data(), content="true")
}
