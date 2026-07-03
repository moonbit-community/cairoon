///|
fn assert_scaled_close(actual : Double, expected : Double) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    @test.fail("expected close doubles")
  }
}

///|
fn assert_scaled_matrix_close(actual : Matrix, expected : Matrix) -> Unit raise {
  assert_scaled_close(actual.xx, expected.xx)
  assert_scaled_close(actual.yx, expected.yx)
  assert_scaled_close(actual.xy, expected.xy)
  assert_scaled_close(actual.yy, expected.yy)
  assert_scaled_close(actual.x0, expected.x0)
  assert_scaled_close(actual.y0, expected.y0)
}

///|
fn expect_scaled_font_invalid_string(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }
}

///|
fn make_scaled_font() -> ScaledFont raise CairoError {
  let face = FontFace::toy("serif", weight=FontWeightBold)
  let options = FontOptions::new()
  options.set_antialias(AntialiasGray)
  ScaledFont::new(
    face,
    Matrix::new(xx=12.0, yy=12.0),
    Matrix::new(xx=2.0, yy=3.0, x0=5.0, y0=7.0),
    options,
  )
}

///|
test "scaled font construction exposes font face options and matrices" {
  let scaled_font = make_scaled_font()
  inspect(scaled_font.status().is_success(), content="true")

  let returned_face = scaled_font.get_font_face()
  inspect(returned_face.get_family(), content="serif")
  debug_inspect(returned_face.get_weight(), content="FontWeightBold")

  let returned_options = scaled_font.get_font_options()
  debug_inspect(returned_options.get_antialias(), content="AntialiasGray")

  assert_scaled_matrix_close(
    scaled_font.get_font_matrix(),
    Matrix::new(xx=12.0, yy=12.0),
  )
  assert_scaled_matrix_close(scaled_font.get_ctm(), Matrix::new(xx=2.0, yy=3.0))
  assert_scaled_matrix_close(
    scaled_font.get_scale_matrix(),
    Matrix::new(xx=24.0, yy=36.0),
  )
}

///|
test "scaled font scale matrix combines sheared font and ctm matrices" {
  let face = FontFace::toy("serif")
  let options = FontOptions::new()
  let font_matrix = Matrix::new(xx=10.0, yx=1.0, xy=2.0, yy=12.0)
  let ctm = Matrix::new(xx=1.5, yx=0.25, xy=0.5, yy=2.0, x0=31.0, y0=-8.0)
  let scaled_font = ScaledFont::new(face, font_matrix, ctm, options)
  let returned_font_matrix = scaled_font.get_font_matrix()
  let returned_ctm = scaled_font.get_ctm()
  assert_scaled_matrix_close(returned_font_matrix, font_matrix)
  assert_scaled_matrix_close(
    returned_ctm,
    Matrix::new(xx=1.5, yx=0.25, xy=0.5, yy=2.0),
  )
  assert_scaled_matrix_close(
    scaled_font.get_scale_matrix(),
    returned_font_matrix.multiply(returned_ctm),
  )
}

///|
test "scaled font metrics and text extents are checked values" {
  let scaled_font = make_scaled_font()
  let extents = scaled_font.extents()
  inspect(extents.height > 0.0, content="true")
  inspect(extents.ascent >= 0.0, content="true")

  let text = scaled_font.text_extents("foo")
  inspect(text.x_advance > 0.0, content="true")
  inspect(text.y_advance, content="0")

  let empty = scaled_font.text_extents("")
  inspect(empty.x_advance, content="0")
  inspect(empty.y_advance, content="0")
}

///|
test "scaled font text_extents validates embedded nul strings" {
  let scaled_font = make_scaled_font()
  expect_scaled_font_invalid_string(
    run_cairo(() => {
      let _ = scaled_font.text_extents("bad\u{0}text")
      ()
    }),
  )
}

///|
test "scaled font equality and hash follow cairo pointer identity" {
  let surface = Surface::image(Rgb24, 4, 4)
  let ctx = Context::new(surface)
  ctx.set_font_size(14.0)
  let first = ctx.get_scaled_font()
  let second = ctx.get_scaled_font()
  inspect(first.equal(second), content="true")
  inspect(first.hash() == second.hash(), content="true")
}

///|
test "context font matrix size extents and scaled font round trip" {
  let surface = Surface::image(Rgb24, 8, 8)
  let ctx = Context::new(surface)
  ctx.set_font_size(42.0)
  assert_scaled_matrix_close(
    ctx.get_font_matrix(),
    Matrix::new(xx=42.0, yy=42.0),
  )

  let font_matrix = Matrix::new(xx=9.0, yx=1.0, xy=2.0, yy=11.0, x0=3.0, y0=4.0)
  ctx.set_font_matrix(font_matrix)
  assert_scaled_matrix_close(ctx.get_font_matrix(), font_matrix)

  let extents = ctx.font_extents()
  inspect(extents.height > 0.0, content="true")

  let scaled_font = make_scaled_font()
  ctx.set_scaled_font(scaled_font)
  let returned = ctx.get_scaled_font()
  assert_scaled_matrix_close(
    ctx.get_font_matrix(),
    scaled_font.get_font_matrix(),
  )
  assert_scaled_matrix_close(
    returned.get_font_matrix(),
    scaled_font.get_font_matrix(),
  )
  inspect(returned.get_font_face().status().is_success(), content="true")
  debug_inspect(
    returned.get_font_options().get_antialias(),
    content="AntialiasGray",
  )
}

///|
test "context scaled font methods propagate cairo error" {
  let ctx = Context::new(Surface::image(Argb32, 1, 1))
  let scaled_font = make_scaled_font()
  let set_matrix_result = run_cairo(() => {
    ctx.set_matrix(Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(set_matrix_result is Err(_), content="true")

  let get_matrix_result = run_cairo(() => {
    let _ = ctx.get_font_matrix()
    ()
  })
  inspect(get_matrix_result is Err(_), content="true")
  match get_matrix_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let set_size_result = run_cairo(() => ctx.set_font_size(12.0))
  inspect(set_size_result is Err(_), content="true")
  match set_size_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let extents_result = run_cairo(() => {
    let _ = ctx.font_extents()
    ()
  })
  inspect(extents_result is Err(_), content="true")
  match extents_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let get_scaled_result = run_cairo(() => {
    let _ = ctx.get_scaled_font()
    ()
  })
  inspect(get_scaled_result is Err(_), content="true")
  match get_scaled_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let set_scaled_result = run_cairo(() => ctx.set_scaled_font(scaled_font))
  inspect(set_scaled_result is Err(_), content="true")
  match set_scaled_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}
