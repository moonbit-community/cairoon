///|
fn context_extents_surface() -> @cairoon.Surface raise @cairoon.CairoError {
  @cairoon.Surface::image(Argb32, 20, 20)
}

///|
fn assert_extents_close(actual : Double, expected : Double) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    @test.fail("expected close doubles")
  }
}

///|
fn assert_context_extents_close(
  actual : (Double, Double, Double, Double),
  expected : (Double, Double, Double, Double),
) -> Unit raise {
  let (actual_x1, actual_y1, actual_x2, actual_y2) = actual
  let (expected_x1, expected_y1, expected_x2, expected_y2) = expected
  assert_extents_close(actual_x1, expected_x1)
  assert_extents_close(actual_y1, expected_y1)
  assert_extents_close(actual_x2, expected_x2)
  assert_extents_close(actual_y2, expected_y2)
}

///|
test "context fill and path extents follow current path" {
  let ctx = @cairoon.Context::new(context_extents_surface())
  assert_context_extents_close(ctx.fill_extents(), (0.0, 0.0, 0.0, 0.0))
  assert_context_extents_close(ctx.path_extents(), (0.0, 0.0, 0.0, 0.0))

  ctx.rectangle(2.0, 3.0, 5.0, 7.0)
  assert_context_extents_close(ctx.fill_extents(), (2.0, 3.0, 7.0, 10.0))
  assert_context_extents_close(ctx.path_extents(), (2.0, 3.0, 7.0, 10.0))
}

///|
test "context fill extents match pycairo polygon path" {
  let ctx = @cairoon.Context::new(context_extents_surface())
  ctx.line_to(1.0, 1.0)
  ctx.line_to(1.0, 0.0)
  ctx.line_to(0.0, 0.0)
  ctx.line_to(0.0, 1.0)
  ctx.line_to(1.0, 1.0)
  assert_context_extents_close(ctx.fill_extents(), (0.0, 0.0, 1.0, 1.0))
}

///|
test "context stroke extents include stroke width" {
  let ctx = @cairoon.Context::new(context_extents_surface())
  assert_context_extents_close(ctx.stroke_extents(), (0.0, 0.0, 0.0, 0.0))

  ctx.set_line_width(2.0)
  ctx.rectangle(2.0, 3.0, 5.0, 7.0)
  assert_context_extents_close(ctx.stroke_extents(), (1.0, 2.0, 8.0, 11.0))
}

///|
test "context fill and stroke hit testing follows current path" {
  let ctx = @cairoon.Context::new(context_extents_surface())
  inspect(ctx.in_fill(3.0, 4.0), content="false")
  inspect(ctx.in_stroke(2.0, 3.0), content="false")

  ctx.rectangle(2.0, 3.0, 5.0, 7.0)
  inspect(ctx.in_fill(3.0, 4.0), content="true")
  inspect(ctx.in_fill(0.0, 0.0), content="false")
  inspect(ctx.in_stroke(2.0, 3.0), content="true")
  inspect(ctx.in_stroke(4.0, 6.0), content="false")

  let clipped_ctx = @cairoon.Context::new(context_extents_surface())
  clipped_ctx.rectangle(0.0, 0.0, 2.0, 2.0)
  clipped_ctx.clip()
  clipped_ctx.rectangle(10.0, 10.0, 4.0, 4.0)
  inspect(clipped_ctx.in_clip(11.0, 11.0), content="false")
  inspect(clipped_ctx.in_fill(11.0, 11.0), content="true")
  inspect(clipped_ctx.in_stroke(10.0, 12.0), content="true")
  assert_context_extents_close(
    clipped_ctx.fill_extents(),
    (10.0, 10.0, 14.0, 14.0),
  )
  inspect(clipped_ctx.copy_path().length() > 0, content="true")
}

///|
test "context hit testing and extents propagate cairo error" {
  let ctx = @cairoon.Context::new(context_extents_surface())
  let set_result = @cairoon.run_cairo(() => {
    ctx.set_matrix(@cairoon.Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(set_result is Err(_), content="true")

  let fill_result = @cairoon.run_cairo(() => ctx.fill_extents())
  inspect(fill_result is Err(_), content="true")
  match fill_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let hit_result = @cairoon.run_cairo(() => ctx.in_fill(0.0, 0.0))
  inspect(hit_result is Err(_), content="true")
  match hit_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}
