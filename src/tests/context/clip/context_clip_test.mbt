///|
fn context_clip_surface() -> @cairoon.Surface raise @cairoon.CairoError {
  @cairoon.Surface::image(Argb32, 20, 20)
}

///|
fn assert_clip_close(actual : Double, expected : Double) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    @test.fail("expected close doubles")
  }
}

///|
fn assert_clip_extents_close(
  actual : (Double, Double, Double, Double),
  expected : (Double, Double, Double, Double),
) -> Unit raise {
  let (actual_x1, actual_y1, actual_x2, actual_y2) = actual
  let (expected_x1, expected_y1, expected_x2, expected_y2) = expected
  assert_clip_close(actual_x1, expected_x1)
  assert_clip_close(actual_y1, expected_y1)
  assert_clip_close(actual_x2, expected_x2)
  assert_clip_close(actual_y2, expected_y2)
}

///|
test "context clip extents in_clip and reset_clip" {
  let ctx = @cairoon.Context::new(context_clip_surface())
  assert_clip_extents_close(ctx.clip_extents(), (0.0, 0.0, 20.0, 20.0))
  inspect(ctx.in_clip(10.0, 10.0), content="true")

  ctx.rectangle(2.0, 3.0, 5.0, 7.0)
  ctx.clip()
  assert_clip_extents_close(ctx.clip_extents(), (2.0, 3.0, 7.0, 10.0))
  inspect(ctx.in_clip(3.0, 4.0), content="true")
  inspect(ctx.in_clip(0.0, 0.0), content="false")

  ctx.save()
  ctx.rectangle(3.0, 4.0, 2.0, 3.0)
  ctx.clip()
  assert_clip_extents_close(ctx.clip_extents(), (3.0, 4.0, 5.0, 7.0))
  ctx.restore()
  assert_clip_extents_close(ctx.clip_extents(), (2.0, 3.0, 7.0, 10.0))

  ctx.reset_clip()
  assert_clip_extents_close(ctx.clip_extents(), (0.0, 0.0, 20.0, 20.0))
  inspect(ctx.in_clip(10.0, 10.0), content="true")
}

///|
test "context empty path clip matches pycairo in_clip behavior" {
  let ctx = @cairoon.Context::new(@cairoon.Surface::image(Argb32, 100, 100))
  inspect(ctx.in_clip(50.0, 50.0), content="true")
  ctx.clip()
  inspect(ctx.in_clip(50.0, 50.0), content="false")
  inspect(ctx.copy_clip_rectangle_list().length(), content="0")
  ctx.reset_clip()
  inspect(ctx.in_clip(50.0, 50.0), content="true")
}

///|
test "context clip clears path and clip_preserve keeps path" {
  let clear_ctx = @cairoon.Context::new(context_clip_surface())
  clear_ctx.rectangle(2.0, 3.0, 5.0, 7.0)
  inspect(clear_ctx.copy_path().length() > 0, content="true")
  clear_ctx.clip()
  inspect(clear_ctx.copy_path().length(), content="0")
  assert_clip_extents_close(clear_ctx.path_extents(), (0.0, 0.0, 0.0, 0.0))
  assert_clip_extents_close(clear_ctx.clip_extents(), (2.0, 3.0, 7.0, 10.0))

  let preserve_ctx = @cairoon.Context::new(context_clip_surface())
  preserve_ctx.rectangle(2.0, 3.0, 5.0, 7.0)
  preserve_ctx.clip_preserve()
  inspect(preserve_ctx.copy_path().length() > 0, content="true")
  assert_clip_extents_close(preserve_ctx.path_extents(), (2.0, 3.0, 7.0, 10.0))
  assert_clip_extents_close(preserve_ctx.clip_extents(), (2.0, 3.0, 7.0, 10.0))
}

///|
test "context clip_preserve keeps current path drawable" {
  let surface = @cairoon.Surface::image(Argb32, 4, 4)
  let ctx = @cairoon.Context::new(surface)
  ctx.rectangle(1.0, 1.0, 2.0, 2.0)
  ctx.clip_preserve()
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.fill()

  let data = surface.copy_data()
  let stride = surface.get_stride()
  let inside = stride + 4
  inspect(data[inside].to_int(), content="0")
  inspect(data[inside + 1].to_int(), content="0")
  inspect(data[inside + 2].to_int(), content="255")
  inspect(data[inside + 3].to_int(), content="255")
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="0")
}

///|
test "context copy_clip_rectangle_list returns pure rectangles" {
  let ctx = @cairoon.Context::new(context_clip_surface())
  let default_rects = ctx.copy_clip_rectangle_list()
  inspect(default_rects.length(), content="1")
  debug_inspect(default_rects[0].components(), content="(0, 0, 20, 20)")

  ctx.rectangle(2.0, 3.0, 5.0, 7.0)
  ctx.clip()
  let clipped_rects = ctx.copy_clip_rectangle_list()
  inspect(clipped_rects.length(), content="1")
  debug_inspect(clipped_rects[0].components(), content="(2, 3, 5, 7)")
}

///|
test "context copy_clip_rectangle_list maps non-rectangular clip status" {
  let ctx = @cairoon.Context::new(context_clip_surface())
  ctx.move_to(1.0, 1.0)
  ctx.curve_to(5.0, 1.0, 5.0, 9.0, 9.0, 9.0)
  ctx.line_to(1.0, 9.0)
  ctx.clip()
  let result = @cairoon.run_cairo(() => ctx.copy_clip_rectangle_list())
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(ClipNotRepresentable, _)) => ()
    _ => @test.fail("expected ClipNotRepresentable")
  }
}

///|
test "context clip getters propagate cairo error" {
  let ctx = @cairoon.Context::new(context_clip_surface())
  let set_result = @cairoon.run_cairo(() => {
    ctx.set_matrix(@cairoon.Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(set_result is Err(_), content="true")
  let extents_result = @cairoon.run_cairo(() => ctx.clip_extents())
  inspect(extents_result is Err(_), content="true")
  match extents_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let in_clip_result = @cairoon.run_cairo(() => ctx.in_clip(0.0, 0.0))
  inspect(in_clip_result is Err(_), content="true")
  match in_clip_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}
