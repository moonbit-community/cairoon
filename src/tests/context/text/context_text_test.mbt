///|
fn assert_text_close(actual : Double, expected : Double) -> Unit raise {
  let delta = actual - expected
  let diff = if delta < 0.0 { -delta } else { delta }
  if diff > 0.000001 {
    @test.fail("expected \{expected}, got \{actual}")
  }
}

///|
fn assert_text_point_close(
  actual : (Double, Double),
  expected : (Double, Double),
) -> Unit raise {
  let (actual_x, actual_y) = actual
  let (expected_x, expected_y) = expected
  assert_text_close(actual_x, expected_x)
  assert_text_close(actual_y, expected_y)
}

///|
fn expect_text_invalid_string(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }
}

///|
fn expect_text_invalid_matrix(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}

///|
test "context font_extents matches current scaled font" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 32, 32),
  )
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  let context_extents = ctx.font_extents()
  let scaled_extents = ctx.get_scaled_font().extents()
  inspect(context_extents == scaled_extents, content="true")
  inspect(context_extents.height > 0.0, content="true")
  inspect(context_extents.ascent >= 0.0, content="true")
}

///|
test "context text_extents matches current scaled font" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 32, 32),
  )
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  let context_extents = ctx.text_extents("foo")
  let scaled_extents = ctx.get_scaled_font().text_extents("foo")
  inspect(context_extents == scaled_extents, content="true")
  inspect(context_extents.x_advance > 0.0, content="true")
  inspect(context_extents.height > 0.0, content="true")

  let empty = ctx.text_extents("")
  inspect(empty.width, content="0")
  inspect(empty.height, content="0")
  inspect(empty.x_advance, content="0")
}

///|
test "context show_text advances current point" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 32, 32),
  )
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.move_to(2.0, 7.0)
  let extents = ctx.text_extents("foo")
  ctx.show_text("foo")
  assert_text_point_close(
    ctx.get_current_point(),
    (2.0 + extents.x_advance, 7.0),
  )
}

///|
test "context text_path creates fillable text path" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 48, 24)
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(16.0)
  ctx.move_to(2.0, 18.0)
  ctx.text_path("foo")
  let (x1, y1, x2, y2) = ctx.path_extents()
  inspect(x2 > x1, content="true")
  inspect(y2 > y1, content="true")
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.fill()
  inspect(surface.copy_data().length() > 0, content="true")
}

///|
test "context text methods validate embedded nul strings" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 8, 8),
  )
  expect_text_invalid_string(
    @cairoon.run_cairo(() => ctx.show_text("bad\u{0}text")),
  )
  expect_text_invalid_string(
    @cairoon.run_cairo(() => {
      let _ = ctx.text_extents("bad\u{0}text")
      ()
    }),
  )
  expect_text_invalid_string(
    @cairoon.run_cairo(() => ctx.text_path("bad\u{0}text")),
  )
}

///|
test "context text methods propagate existing context errors" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 8, 8),
  )
  let invalid_matrix = @cairoon.run_cairo(() => {
    ctx.set_matrix(@cairoon.Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(invalid_matrix is Err(_), content="true")
  expect_text_invalid_matrix(@cairoon.run_cairo(() => ctx.show_text("foo")))
  expect_text_invalid_matrix(
    @cairoon.run_cairo(() => {
      let _ = ctx.text_extents("foo")
      ()
    }),
  )
  expect_text_invalid_matrix(@cairoon.run_cairo(() => ctx.text_path("foo")))
}
