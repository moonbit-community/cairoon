///|
fn expect_mesh_error(result : Result[Unit, @cairoon.CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(InvalidMeshConstruction, _)) => ()
    _ => @test.fail("expected InvalidMeshConstruction")
  }
}

///|
fn expect_mesh_invalid_index(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}

///|
fn mesh_path_from_local_pattern() -> @cairoon.Path raise @cairoon.CairoError {
  let pattern = @cairoon.Pattern::mesh()
  pattern.mesh_begin_patch()
  pattern.mesh_move_to(0.0, 0.0)
  pattern.mesh_line_to(1.0, 0.0)
  pattern.mesh_line_to(0.0, 1.0)
  pattern.mesh_end_patch()
  pattern.mesh_get_path(0)
}

///|
test "mesh path survives source pattern scope" {
  let path = mesh_path_from_local_pattern()
  inspect(path.length(), content="5")
  inspect(path.to_string().contains("curve_to"), content="true")
}

///|
test "mesh pattern builds coons patch and exposes path color and points" {
  let pattern = @cairoon.Pattern::mesh()
  inspect(pattern.mesh_get_patch_count(), content="0")

  pattern.mesh_begin_patch()
  pattern.mesh_move_to(0.0, 0.0)
  pattern.mesh_curve_to(30.0, -30.0, 60.0, 30.0, 100.0, 0.0)
  pattern.mesh_curve_to(60.0, 30.0, 130.0, 60.0, 100.0, 100.0)
  pattern.mesh_curve_to(60.0, 70.0, 30.0, 130.0, 0.0, 100.0)
  pattern.mesh_curve_to(30.0, 70.0, -30.0, 30.0, 0.0, 0.0)
  pattern.mesh_set_corner_color_rgb(0, 1.0, 0.0, 0.0)
  pattern.mesh_set_corner_color_rgb(1, 0.0, 1.0, 0.0)
  pattern.mesh_set_corner_color_rgba(2, 0.0, 0.0, 1.0, 0.5)
  pattern.mesh_set_corner_color_rgb(3, 1.0, 1.0, 0.0)
  pattern.mesh_set_control_point(0, 10.0, 12.0)
  pattern.mesh_end_patch()

  inspect(pattern.mesh_get_patch_count(), content="1")
  debug_inspect(
    pattern.mesh_get_corner_color_rgba(0, 0),
    content="(1, 0, 0, 1)",
  )
  debug_inspect(
    pattern.mesh_get_corner_color_rgba(0, 2),
    content="(0, 0, 1, 0.5)",
  )
  debug_inspect(pattern.mesh_get_control_point(0, 0), content="(10, 12)")
  let path = pattern.mesh_get_path(0)
  inspect(path.length(), content="5")
  inspect(path.to_string().contains("curve_to"), content="true")
}

///|
test "mesh pattern builds triangle patch and paints" {
  let pattern = @cairoon.Pattern::mesh()
  pattern.mesh_begin_patch()
  pattern.mesh_move_to(0.0, 0.0)
  pattern.mesh_line_to(2.0, 0.0)
  pattern.mesh_line_to(0.0, 2.0)
  pattern.mesh_set_corner_color_rgba(0, 1.0, 0.0, 0.0, 1.0)
  pattern.mesh_set_corner_color_rgba(1, 1.0, 0.0, 0.0, 1.0)
  pattern.mesh_set_corner_color_rgba(2, 1.0, 0.0, 0.0, 1.0)
  pattern.mesh_end_patch()

  let surface = @cairoon.Surface::image(Argb32, 1, 1)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source(pattern)
  ctx.paint()
  let data = surface.copy_data()
  inspect(data[2].to_int() > 0, content="true")
  inspect(data[3].to_int() > 0, content="true")
}

///|
test "mesh pattern accepts curve command as first patch path segment" {
  let pattern = @cairoon.Pattern::mesh()
  pattern.mesh_begin_patch()
  pattern.mesh_curve_to(0.0, 1.0, 2.0, 3.0, 4.0, 5.0)
  pattern.mesh_set_corner_color_rgba(0, 0.125, 0.25, 0.5, 0.75)
  pattern.mesh_set_control_point(0, 10.0, 12.0)
  pattern.mesh_end_patch()

  inspect(pattern.mesh_get_patch_count(), content="1")
  debug_inspect(
    pattern.mesh_get_corner_color_rgba(0, 0),
    content="(0.125, 0.25, 0.5, 0.75)",
  )
  debug_inspect(pattern.mesh_get_control_point(0, 0), content="(10, 12)")
  inspect(
    pattern.mesh_get_path(0).to_string().contains("curve_to"),
    content="true",
  )
  expect_mesh_invalid_index(
    @cairoon.run_cairo(() => {
      let _ = pattern.mesh_get_control_point(1, 0)
      ()
    }),
  )
}

///|
test "mesh pattern invalid patch and point indexes map to invalid argument" {
  let pattern = @cairoon.Pattern::mesh()
  pattern.mesh_begin_patch()
  pattern.mesh_move_to(0.0, 0.0)
  pattern.mesh_line_to(1.0, 0.0)
  pattern.mesh_line_to(1.0, 1.0)
  pattern.mesh_end_patch()

  expect_mesh_invalid_index(
    @cairoon.run_cairo(() => {
      let _ = pattern.mesh_get_corner_color_rgba(1, 0)
      ()
    }),
  )
  expect_mesh_invalid_index(
    @cairoon.run_cairo(() => {
      let _ = pattern.mesh_get_corner_color_rgba(0, 9)
      ()
    }),
  )
  expect_mesh_invalid_index(
    @cairoon.run_cairo(() => {
      let _ = pattern.mesh_get_control_point(0, 9)
      ()
    }),
  )
  expect_mesh_invalid_index(
    @cairoon.run_cairo(() => {
      let _ = pattern.mesh_get_path(9)
      ()
    }),
  )
  expect_mesh_invalid_index(
    @cairoon.run_cairo(() => pattern.mesh_set_control_point(-1, 0.0, 0.0)),
  )
}

///|
test "mesh pattern lifecycle errors propagate cairo status" {
  let pattern = @cairoon.Pattern::mesh()
  pattern.mesh_begin_patch()
  expect_mesh_error(@cairoon.run_cairo(() => pattern.mesh_begin_patch()))

  expect_mesh_error(
    @cairoon.run_cairo(() => @cairoon.Pattern::mesh().mesh_end_patch()),
  )
  expect_mesh_error(
    @cairoon.run_cairo(() => {
      @cairoon.Pattern::mesh().mesh_curve_to(0.0, 1.0, 2.0, 3.0, 4.0, 5.0)
    }),
  )
  expect_mesh_error(
    @cairoon.run_cairo(() => @cairoon.Pattern::mesh().mesh_line_to(130.0, 130.0)),
  )
  expect_mesh_error(
    @cairoon.run_cairo(() => @cairoon.Pattern::mesh().mesh_move_to(0.0, 0.0)),
  )
  expect_mesh_error(
    @cairoon.run_cairo(() => {
      @cairoon.Pattern::mesh().mesh_set_corner_color_rgba(
        0, 0.125, 0.25, 0.5, 0.75,
      )
    }),
  )
  expect_mesh_error(
    @cairoon.run_cairo(() => {
      @cairoon.Pattern::mesh().mesh_set_corner_color_rgb(0, 0.125, 0.25, 0.5)
    }),
  )
}

///|
test "mesh methods reject non-mesh patterns" {
  let solid = @cairoon.Pattern::solid_rgb(0.0, 0.0, 0.0)
  let result = @cairoon.run_cairo(() => solid.mesh_begin_patch())
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(PatternTypeMismatch, _)) => ()
    _ => @test.fail("expected PatternTypeMismatch")
  }
}
