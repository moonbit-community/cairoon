///|
test "alpha-only similar surfaces preserve typed content" {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
  let alpha = source.create_similar(@cairoon.ContentAlpha, 2, 2)
  debug_inspect(alpha.get_content(), content="ContentAlpha")
}

///|
test "a8 image surfaces preserve typed format" {
  let surface = @cairoon.Surface::image(@cairoon.A8, 2, 2)
  debug_inspect(surface.get_format(), content="A8")
  inspect(surface.get_format_raw(), content="2")
}

///|
test "a1 image surfaces preserve typed format" {
  let surface = @cairoon.Surface::image(@cairoon.A1, 8, 2)
  debug_inspect(surface.get_format(), content="A1")
  inspect(surface.get_format_raw(), content="3")
}

///|
test "rgb16 565 image surfaces preserve typed format" {
  let surface = @cairoon.Surface::image(@cairoon.Rgb16_565, 2, 2)
  debug_inspect(surface.get_format(), content="Rgb16_565")
  inspect(surface.get_format_raw(), content="4")
}
