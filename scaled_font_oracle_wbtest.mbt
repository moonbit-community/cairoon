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
fn scaled_font_oracle_expect_glyph(
  actual : Glyph,
  expected : Glyph,
) -> Unit raise {
  let (actual_index, actual_x, actual_y) = actual.components()
  let (expected_index, expected_x, expected_y) = expected.components()
  if actual_index != expected_index {
    fail("scaled-font oracle glyph index mismatch")
  }
  scaled_font_oracle_assert_close(actual_x, expected_x)
  scaled_font_oracle_assert_close(actual_y, expected_y)
}

///|
fn scaled_font_oracle_expect_cluster(
  actual : TextCluster,
  expected : TextCluster,
) -> Unit raise {
  let (actual_bytes, actual_glyphs) = actual.components()
  let (expected_bytes, expected_glyphs) = expected.components()
  if actual_bytes != expected_bytes || actual_glyphs != expected_glyphs {
    fail("scaled-font oracle text-cluster mismatch")
  }
}

///|
fn scaled_font_oracle_expect_run(
  actual : TextGlyphRun,
  expected : TextGlyphRun,
) -> Unit raise {
  let (actual_glyphs, actual_clusters, actual_flags) = actual.components()
  let (expected_glyphs, expected_clusters, expected_flags) = expected.components()
  if actual_glyphs.length() != expected_glyphs.length() {
    fail("scaled-font oracle glyph count mismatch")
  }
  for index in 0..<actual_glyphs.length() {
    scaled_font_oracle_expect_glyph(
      actual_glyphs[index],
      expected_glyphs[index],
    )
  }
  if actual_clusters.length() != expected_clusters.length() {
    fail("scaled-font oracle text-cluster count mismatch")
  }
  for index in 0..<actual_clusters.length() {
    scaled_font_oracle_expect_cluster(
      actual_clusters[index],
      expected_clusters[index],
    )
  }
  if actual_flags != expected_flags {
    fail("scaled-font oracle text-cluster flags mismatch")
  }
}

///|
fn scaled_font_oracle_expect_text_to_glyphs(
  scaled_font : ScaledFont,
  x : Double,
  y : Double,
  text : String,
) -> Unit raise {
  scaled_font_oracle_expect_run(
    scaled_font.text_to_glyphs(x, y, text),
    text_glyph_run_from_native(
      test_scaled_font_text_to_glyphs_oracle_ffi(x, y, @utf8.encode(text)),
    ),
  )
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
    scaled_font.text_extents("e\u{0301}"),
    test_scaled_font_extents_oracle_ffi(1, @utf8.encode("e\u{0301}")),
  )
  scaled_font_oracle_expect_text_extents(
    scaled_font.text_extents("\u{0645}\u{0631}\u{062d}\u{0628}\u{0627}"),
    test_scaled_font_extents_oracle_ffi(
      1,
      @utf8.encode("\u{0645}\u{0631}\u{062d}\u{0628}\u{0627}"),
    ),
  )
  scaled_font_oracle_expect_text_extents(
    scaled_font.glyph_extents([
      Glyph::new(0UL, 1.5, 2.5),
      Glyph::new(1UL, 10.0, 2.5),
    ]),
    test_scaled_font_extents_oracle_ffi(2, b""),
  )
}

///|
test "scaled font text_to_glyphs matches direct cairo C oracle" {
  let scaled_font = scaled_font_oracle_make_font()
  scaled_font_oracle_expect_text_to_glyphs(scaled_font, 0.0, 0.0, "")
  scaled_font_oracle_expect_text_to_glyphs(scaled_font, 2.0, 12.0, "a")
  scaled_font_oracle_expect_text_to_glyphs(scaled_font, 0.0, 0.0, "a b")
  scaled_font_oracle_expect_text_to_glyphs(scaled_font, 2.0, 11.0, "affinity")
  scaled_font_oracle_expect_text_to_glyphs(scaled_font, -3.5, 4.25, "\u{00e9}")
  scaled_font_oracle_expect_text_to_glyphs(scaled_font, 1.25, -2.5, "e\u{0301}")
  scaled_font_oracle_expect_text_to_glyphs(
    scaled_font, 5.0, -6.0, "\u{4e2d}\u{6587}",
  )
  scaled_font_oracle_expect_text_to_glyphs(
    scaled_font, -8.0, 3.0, "\u{0645}\u{0631}\u{062d}\u{0628}\u{0627}",
  )
  scaled_font_oracle_expect_text_to_glyphs(scaled_font, 7.0, 2.0, "\u{1f642}")
}
