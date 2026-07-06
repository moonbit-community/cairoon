///|
test "pycairo solid pattern default state fixture" {
  let pattern = Pattern::solid_rgb(1.0, 2.0, 4.0)
  debug_inspect(pattern.get_extend(), content="Pad")
  debug_inspect(pattern.get_filter(), content="Good")
  debug_inspect(pattern.get_dither(), content="DitherDefault")
  debug_inspect(
    pattern.get_matrix(),
    content="{ xx: 1, yx: 0, xy: 0, yy: 1, x0: 0, y0: 0 }",
  )
  debug_inspect(pattern.get_rgba(), content="(1, 1, 1, 1)")
}

///|
test "pycairo solid pattern setter round trip fixture" {
  let pattern = Pattern::solid_rgba(0.1, 0.2, 0.3, 0.4)
  debug_inspect(pattern.get_rgba(), content="(0.1, 0.2, 0.3, 0.4)")

  pattern.set_matrix(Matrix::new())
  pattern.set_extend(Repeat)
  pattern.set_filter(Nearest)
  pattern.set_dither(DitherBest)

  debug_inspect(
    pattern.get_matrix(),
    content="{ xx: 1, yx: 0, xy: 0, yy: 1, x0: 0, y0: 0 }",
  )
  debug_inspect(pattern.get_extend(), content="Repeat")
  debug_inspect(pattern.get_filter(), content="Nearest")
  debug_inspect(pattern.get_dither(), content="DitherBest")
}
