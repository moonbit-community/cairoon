///|
test "pycairo solid pattern default state fixture" {
  let pattern = @cairoon.Pattern::solid_rgb(1.0, 2.0, 4.0)
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
test "pycairo surface pattern default state fixture" {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 3)
  let pattern = @cairoon.Pattern::for_surface(source)
  debug_inspect(pattern.get_extend(), content="ExtendNone")
  debug_inspect(pattern.get_filter(), content="Good")
  debug_inspect(pattern.get_dither(), content="DitherDefault")
  debug_inspect(
    pattern.get_matrix(),
    content="{ xx: 1, yx: 0, xy: 0, yy: 1, x0: 0, y0: 0 }",
  )
  let returned = pattern.get_surface()
  inspect(returned.get_width(), content="2")
  inspect(returned.get_height(), content="3")
}

///|
test "pycairo solid pattern setter round trip fixture" {
  let pattern = @cairoon.Pattern::solid_rgba(0.1, 0.2, 0.3, 0.4)
  debug_inspect(pattern.get_rgba(), content="(0.1, 0.2, 0.3, 0.4)")

  pattern.set_matrix(@cairoon.Matrix::new())
  pattern.set_extend(@cairoon.Repeat)
  pattern.set_filter(@cairoon.Nearest)
  pattern.set_dither(@cairoon.DitherBest)

  debug_inspect(
    pattern.get_matrix(),
    content="{ xx: 1, yx: 0, xy: 0, yy: 1, x0: 0, y0: 0 }",
  )
  debug_inspect(pattern.get_extend(), content="Repeat")
  debug_inspect(pattern.get_filter(), content="Nearest")
  debug_inspect(pattern.get_dither(), content="DitherBest")
}

///|
test "pycairo gradient pattern method fixture" {
  let linear = @cairoon.Pattern::linear(0.0, 0.0, 0.0, 1.0)
  debug_inspect(linear.get_linear_points(), content="(0, 0, 0, 1)")
  inspect(linear.get_color_stops_rgba().length(), content="0")

  linear.add_color_stop_rgb(0.125, 0.25, 0.5, 0.75)
  debug_inspect(
    linear.get_color_stops_rgba(),
    content="[(0.125, 0.25, 0.5, 0.75, 1)]",
  )

  linear.add_color_stop_rgba(1.0, 0.75, 0.5, 0.25, 0.125)
  debug_inspect(
    linear.get_color_stops_rgba(),
    content="[(0.125, 0.25, 0.5, 0.75, 1), (1, 0.75, 0.5, 0.25, 0.125)]",
  )

  let radial = @cairoon.Pattern::radial(1.0, 1.0, 1.0, 2.0, 2.0, 1.0)
  debug_inspect(radial.get_radial_circles(), content="(1, 1, 1, 2, 2, 1)")
}

///|
test "pycairo mesh pattern example fixture" {
  let pattern = @cairoon.Pattern::mesh()
  inspect(pattern.mesh_get_patch_count(), content="0")

  pattern.mesh_begin_patch()
  pattern.mesh_move_to(100.0, 100.0)
  pattern.mesh_line_to(130.0, 130.0)
  pattern.mesh_line_to(130.0, 70.0)
  pattern.mesh_set_corner_color_rgb(0, 1.0, 0.0, 0.0)
  pattern.mesh_set_corner_color_rgb(1, 0.0, 1.0, 0.0)
  pattern.mesh_set_corner_color_rgb(2, 0.0, 0.0, 1.0)
  pattern.mesh_end_patch()

  inspect(pattern.mesh_get_patch_count(), content="1")
  debug_inspect(
    pattern.mesh_get_corner_color_rgba(0, 0),
    content="(1, 0, 0, 1)",
  )
  debug_inspect(
    pattern.mesh_get_corner_color_rgba(0, 1),
    content="(0, 1, 0, 1)",
  )
  debug_inspect(
    pattern.mesh_get_corner_color_rgba(0, 2),
    content="(0, 0, 1, 1)",
  )
  let path = pattern.mesh_get_path(0)
  inspect(path.length(), content="5")
  inspect(
    path
    .to_string()
    .contains(
      "curve_to 110.000000 110.000000 120.000000 120.000000 130.000000 130.000000",
    ),
    content="true",
  )
}
