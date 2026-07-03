///|
fn scaled_font_oracle_make_font() -> ScaledFont raise CairoError {
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
fn scaled_font_oracle_assert_close(
  actual : Double,
  expected : Double,
) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    fail("scaled-font oracle mismatch")
  }
}

///|
fn scaled_font_oracle_expect_font_extents(
  actual : FontExtents,
  expected : FixedArray[Double],
) -> Unit raise {
  inspect(expected.length(), content="5")
  let (ascent, descent, height, max_x_advance, max_y_advance) = actual.components()
  scaled_font_oracle_assert_close(ascent, expected[0])
  scaled_font_oracle_assert_close(descent, expected[1])
  scaled_font_oracle_assert_close(height, expected[2])
  scaled_font_oracle_assert_close(max_x_advance, expected[3])
  scaled_font_oracle_assert_close(max_y_advance, expected[4])
}

///|
fn scaled_font_oracle_expect_text_extents(
  actual : TextExtents,
  expected : FixedArray[Double],
) -> Unit raise {
  inspect(expected.length(), content="6")
  let (x_bearing, y_bearing, width, height, x_advance, y_advance) = actual.components()
  scaled_font_oracle_assert_close(x_bearing, expected[0])
  scaled_font_oracle_assert_close(y_bearing, expected[1])
  scaled_font_oracle_assert_close(width, expected[2])
  scaled_font_oracle_assert_close(height, expected[3])
  scaled_font_oracle_assert_close(x_advance, expected[4])
  scaled_font_oracle_assert_close(y_advance, expected[5])
}

///|
test "scaled font extents match direct cairo C oracle" {
  let scaled_font = scaled_font_oracle_make_font()
  scaled_font_oracle_expect_font_extents(
    scaled_font.extents(),
    test_scaled_font_extents_oracle_ffi(0, b""),
  )
  scaled_font_oracle_expect_text_extents(
    scaled_font.text_extents("foo"),
    test_scaled_font_extents_oracle_ffi(1, @utf8.encode("foo")),
  )
  scaled_font_oracle_expect_text_extents(
    scaled_font.glyph_extents([
      Glyph::new(0U, 1.5, 2.5),
      Glyph::new(1U, 10.0, 2.5),
    ]),
    test_scaled_font_extents_oracle_ffi(2, b""),
  )
}
