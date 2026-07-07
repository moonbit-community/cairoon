///|
fn context_path_surface() -> @cairoon.Surface raise @cairoon.CairoError {
  @cairoon.Surface::image(@cairoon.Argb32, 20, 20)
}

///|
fn assert_path_close(actual : Double, expected : Double) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    @test.fail("expected \{expected}, got \{actual}")
  }
}

///|
fn assert_path_point_close(
  actual : (Double, Double),
  expected : (Double, Double),
) -> Unit raise {
  let (actual_x, actual_y) = actual
  let (expected_x, expected_y) = expected
  assert_path_close(actual_x, expected_x)
  assert_path_close(actual_y, expected_y)
}

///|
fn assert_path_extents_close(
  actual : (Double, Double, Double, Double),
  expected : (Double, Double, Double, Double),
) -> Unit raise {
  let (actual_x1, actual_y1, actual_x2, actual_y2) = actual
  let (expected_x1, expected_y1, expected_x2, expected_y2) = expected
  assert_path_close(actual_x1, expected_x1)
  assert_path_close(actual_y1, expected_y1)
  assert_path_close(actual_x2, expected_x2)
  assert_path_close(actual_y2, expected_y2)
}

///|
test "context current point new_path and new_sub_path" {
  let ctx = @cairoon.Context::new(context_path_surface())
  inspect(ctx.has_current_point(), content="false")
  assert_path_point_close(ctx.get_current_point(), (0.0, 0.0))

  ctx.move_to(10.0, 11.0)
  inspect(ctx.has_current_point(), content="true")
  assert_path_point_close(ctx.get_current_point(), (10.0, 11.0))

  ctx.new_sub_path()
  inspect(ctx.has_current_point(), content="false")
  assert_path_extents_close(ctx.path_extents(), (0.0, 0.0, 0.0, 0.0))

  ctx.new_path()
  inspect(ctx.has_current_point(), content="false")
  assert_path_extents_close(ctx.path_extents(), (0.0, 0.0, 0.0, 0.0))
}

///|
test "context relative path operations update current point" {
  let ctx = @cairoon.Context::new(context_path_surface())
  ctx.move_to(1.0, 2.0)
  ctx.rel_move_to(3.0, 4.0)
  assert_path_point_close(ctx.get_current_point(), (4.0, 6.0))

  ctx.rel_line_to(5.0, -2.0)
  assert_path_point_close(ctx.get_current_point(), (9.0, 4.0))

  ctx.rel_curve_to(1.0, 1.0, 2.0, 2.0, 3.0, 3.0)
  assert_path_point_close(ctx.get_current_point(), (12.0, 7.0))
  assert_path_extents_close(ctx.path_extents(), (4.0, 4.0, 12.0, 7.0))
}

///|
test "context rectangle path extents match pycairo width and height" {
  let ctx = @cairoon.Context::new(context_path_surface())
  ctx.rectangle(1.0, 2.0, 4.0, 5.0)
  assert_path_extents_close(ctx.path_extents(), (1.0, 2.0, 5.0, 7.0))
}

///|
test "context close_path resets current point to subpath start" {
  let ctx = @cairoon.Context::new(context_path_surface())
  ctx.move_to(2.0, 3.0)
  ctx.line_to(7.0, 3.0)
  ctx.line_to(7.0, 9.0)
  ctx.close_path()
  assert_path_point_close(ctx.get_current_point(), (2.0, 3.0))
  assert_path_extents_close(ctx.path_extents(), (2.0, 3.0, 7.0, 9.0))
}

///|
test "context arc operations create current point" {
  let ctx = @cairoon.Context::new(context_path_surface())
  ctx.arc(5.0, 6.0, 2.0, 0.0, 0.0)
  inspect(ctx.has_current_point(), content="true")
  assert_path_point_close(ctx.get_current_point(), (7.0, 6.0))

  ctx.new_path()
  ctx.arc_negative(5.0, 6.0, 2.0, 0.0, 0.0)
  inspect(ctx.has_current_point(), content="true")
  assert_path_point_close(ctx.get_current_point(), (7.0, 6.0))
}

///|
test "context copy_path appends an independent path" {
  let source = @cairoon.Context::new(context_path_surface())
  source.rectangle(2.0, 3.0, 4.0, 5.0)
  let path = source.copy_path()
  source.new_path()
  assert_path_extents_close(source.path_extents(), (0.0, 0.0, 0.0, 0.0))

  let target = @cairoon.Context::new(context_path_surface())
  target.append_path(path)
  assert_path_extents_close(target.path_extents(), (2.0, 3.0, 6.0, 8.0))
}

///|
test "context append_path preserves pycairo path string" {
  let source = @cairoon.Context::new(context_path_surface())
  source.line_to(1.0, 2.0)
  let path = source.copy_path()
  source.new_path()

  let target = @cairoon.Context::new(context_path_surface())
  target.append_path(path)
  let source_string = path.to_string()
  let target_string = target.copy_path().to_string()
  inspect(source_string, content="move_to 1.000000 2.000000")
  inspect(target_string, content="move_to 1.000000 2.000000")
  inspect(target_string == source_string, content="true")
}

///|
test "context copy_path_flat appends a flattened path" {
  let source = @cairoon.Context::new(context_path_surface())
  source.move_to(1.0, 1.0)
  source.line_to(7.0, 1.0)
  source.line_to(7.0, 6.0)
  source.close_path()
  let path = source.copy_path_flat()

  let target = @cairoon.Context::new(context_path_surface())
  target.append_path(path)
  assert_path_extents_close(target.path_extents(), (1.0, 1.0, 7.0, 6.0))
}

///|
test "context path copy and append propagate cairo error" {
  let path_source = @cairoon.Context::new(context_path_surface())
  path_source.rectangle(1.0, 1.0, 2.0, 2.0)
  let path = path_source.copy_path()

  let ctx = @cairoon.Context::new(context_path_surface())
  let set_result = @cairoon.run_cairo(() => {
    ctx.set_matrix(@cairoon.Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(set_result is Err(_), content="true")

  let copy_result = @cairoon.run_cairo(() => {
    let _ = ctx.copy_path()
    ()
  })
  inspect(copy_result is Err(_), content="true")
  match copy_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let flat_result = @cairoon.run_cairo(() => {
    let _ = ctx.copy_path_flat()
    ()
  })
  inspect(flat_result is Err(_), content="true")
  match flat_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let append_result = @cairoon.run_cairo(() => ctx.append_path(path))
  inspect(append_result is Err(_), content="true")
  match append_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}

///|
test "context relative path without current point maps cairo error" {
  let ctx = @cairoon.Context::new(context_path_surface())
  let result = @cairoon.run_cairo(() => ctx.rel_line_to(1.0, 1.0))
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.NoCurrentPoint, _)) => ()
    _ => @test.fail("expected NoCurrentPoint")
  }
}

///|
test "context path getters propagate cairo error" {
  let ctx = @cairoon.Context::new(context_path_surface())
  let set_result = @cairoon.run_cairo(() => {
    ctx.set_matrix(@cairoon.Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(set_result is Err(_), content="true")

  let current_point_result = @cairoon.run_cairo(() => ctx.get_current_point())
  inspect(current_point_result is Err(_), content="true")
  match current_point_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let has_current_point_result = @cairoon.run_cairo(() => {
    ctx.has_current_point()
  })
  inspect(has_current_point_result is Err(_), content="true")
  match has_current_point_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}
