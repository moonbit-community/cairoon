///|
test "raw pattern preserves identity, state, and matrix" {
  let pattern = create_rgba_raw(0.125, 0.25, 0.5, 0.75)
  inspect(status_raw(pattern), content="0")
  inspect(equal_raw(pattern, pattern), content="true")
  inspect(hash_raw(pattern) != 0, content="true")

  let red = Ref(0.0)
  let green = Ref(0.0)
  let blue = Ref(0.0)
  let alpha = Ref(0.0)
  inspect(get_rgba_raw(pattern, red, green, blue, alpha), content="0")
  inspect(red.val, content="0.125")
  inspect(green.val, content="0.25")
  inspect(blue.val, content="0.5")
  inspect(alpha.val, content="0.75")

  inspect(set_extend_raw(pattern, 2), content="0")
  inspect(get_extend_raw(pattern), content="2")
  inspect(set_filter_raw(pattern, 4), content="0")
  inspect(get_filter_raw(pattern), content="4")
  inspect(set_matrix_raw(pattern, 2.0, 0.5, 0.25, 3.0, 4.0, 5.0), content="0")
  let xx = Ref(0.0)
  let yx = Ref(0.0)
  let xy = Ref(0.0)
  let yy = Ref(0.0)
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  inspect(get_matrix_raw(pattern, xx, yx, xy, yy, x0, y0), content="0")
  inspect(xx.val, content="2")
  inspect(yx.val, content="0.5")
  inspect(xy.val, content="0.25")
  inspect(yy.val, content="3")
  inspect(x0.val, content="4")
  inspect(y0.val, content="5")
}

///|
test "raw surface and raster patterns cross the package boundary" {
  let surface = @surface_impl.image_create_raw(0, 2, 2)
  let pattern = create_for_surface_raw(surface)
  inspect(status_raw(pattern), content="0")
  let status = Ref(-1)
  let returned = get_surface_raw(pattern, status)
  inspect(status.val, content="0")
  inspect(@surface_impl.equal_raw(returned, surface), content="true")

  let raster = create_raster_source_raw(0x3000, 2, 3)
  inspect(status_raw(raster), content="0")
}

///|
test "raw gradient pattern exposes stops and geometry" {
  let linear = create_linear_raw(1.0, 2.0, 4.0, 5.0)
  inspect(status_raw(linear), content="0")
  inspect(add_color_stop_rgb_raw(linear, 0.0, 1.0, 0.0, 0.0), content="0")
  inspect(
    add_color_stop_rgba_raw(linear, 1.0, 0.0, 0.25, 1.0, 0.5),
    content="0",
  )
  let count = Ref(0)
  inspect(get_color_stop_count_raw(linear, count), content="0")
  inspect(count.val, content="2")

  let offset = Ref(0.0)
  let red = Ref(0.0)
  let green = Ref(0.0)
  let blue = Ref(0.0)
  let alpha = Ref(0.0)
  inspect(
    get_color_stop_rgba_raw(linear, 1, offset, red, green, blue, alpha),
    content="0",
  )
  inspect(offset.val, content="1")
  inspect(green.val, content="0.25")
  inspect(blue.val, content="1")
  inspect(alpha.val, content="0.5")

  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  let x1 = Ref(0.0)
  let y1 = Ref(0.0)
  inspect(get_linear_points_raw(linear, x0, y0, x1, y1), content="0")
  inspect(x0.val, content="1")
  inspect(y0.val, content="2")
  inspect(x1.val, content="4")
  inspect(y1.val, content="5")

  let radial = create_radial_raw(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
  let radius0 = Ref(0.0)
  let radius1 = Ref(0.0)
  inspect(
    get_radial_circles_raw(radial, x0, y0, radius0, x1, y1, radius1),
    content="0",
  )
  inspect(radius0.val, content="3")
  inspect(radius1.val, content="6")
  inspect(get_linear_points_raw(radial, x0, y0, x1, y1) != 0, content="true")
}

///|
test "raw mesh pattern preserves paths, colors, and control points" {
  let pattern = create_mesh_raw()
  inspect(status_raw(pattern), content="0")
  inspect(mesh_begin_patch_raw(pattern), content="0")
  inspect(mesh_move_to_raw(pattern, 0.0, 0.0), content="0")
  inspect(
    mesh_curve_to_raw(pattern, 30.0, -30.0, 60.0, 30.0, 100.0, 0.0),
    content="0",
  )
  inspect(
    mesh_curve_to_raw(pattern, 60.0, 30.0, 130.0, 60.0, 100.0, 100.0),
    content="0",
  )
  inspect(
    mesh_curve_to_raw(pattern, 60.0, 70.0, 30.0, 130.0, 0.0, 100.0),
    content="0",
  )
  inspect(
    mesh_curve_to_raw(pattern, 30.0, 70.0, -30.0, 30.0, 0.0, 0.0),
    content="0",
  )
  inspect(mesh_set_corner_color_rgb_raw(pattern, 0, 1.0, 0.0, 0.0), content="0")
  inspect(
    mesh_set_corner_color_rgba_raw(pattern, 2, 0.0, 0.0, 1.0, 0.5),
    content="0",
  )
  inspect(mesh_set_control_point_raw(pattern, 0, 10.0, 12.0), content="0")
  inspect(mesh_end_patch_raw(pattern), content="0")

  let count = Ref(0)
  inspect(mesh_get_patch_count_raw(pattern, count), content="0")
  inspect(count.val, content="1")
  let x = Ref(0.0)
  let y = Ref(0.0)
  inspect(mesh_get_control_point_raw(pattern, 0, 0, x, y), content="0")
  inspect(x.val, content="10")
  inspect(y.val, content="12")
  let red = Ref(0.0)
  let green = Ref(0.0)
  let blue = Ref(0.0)
  let alpha = Ref(0.0)
  inspect(
    mesh_get_corner_color_rgba_raw(pattern, 0, 2, red, green, blue, alpha),
    content="0",
  )
  inspect(blue.val, content="1")
  inspect(alpha.val, content="0.5")

  let status = Ref(-1)
  let path = mesh_get_path_raw(pattern, 0, status)
  inspect(status.val, content="0")
  inspect(@path_impl.status_raw(path), content="0")
  inspect(@path_impl.num_segments_raw(path, status), content="5")
  inspect(status.val, content="0")
}
