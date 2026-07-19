///|
fn make_finalizer_fallback_scaled_font(
  slant : Int,
) -> @scaled_font_impl.RawScaledFont {
  let face = @font_face_impl.toy_create_raw(b"serif", slant, 0)
  let options = @font_options_impl.create_raw()
  @scaled_font_impl.create_raw(
    face, 12.0, 0.0, 0.0, 12.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, options,
  )
}

///|
fn lifetime_stress_text_to_glyphs_finalizer(
  valid : @scaled_font_impl.RawScaledFont,
  invalid : @scaled_font_impl.RawScaledFont,
  index : Int,
) -> Unit raise {
  let mode = index % 3
  let scaled_font = if mode == 2 { invalid } else { valid }
  let with_clusters = mode != 1
  let result = @scaled_font_impl.text_to_glyphs_raw(
    scaled_font,
    index.to_double() / 10.0,
    2.0,
    b"finalizer fallback",
    with_clusters,
  )
  let status = @scaled_font_impl.text_to_glyphs_status_raw(result)
  let indices = @scaled_font_impl.text_to_glyphs_indices_raw(result)
  let positions = @scaled_font_impl.text_to_glyphs_positions_raw(result)
  let clusters = @scaled_font_impl.text_to_glyphs_clusters_raw(result)
  if mode == 2 {
    if status != 30 ||
      indices.length() != 0 ||
      positions.length() != 0 ||
      clusters.length() != 0 {
      @test.fail("invalid scaled font returned an unexpected raw text result")
    }
  } else {
    if status != 0 ||
      indices.length() == 0 ||
      positions.length() != indices.length() * 2 {
      @test.fail("valid scaled font returned an unexpected raw text result")
    }
    if with_clusters == (clusters.length() == 0) {
      @test.fail("raw text result did not honor cluster allocation mode")
    }
  }
}

///|
test "raw text-to-glyph results rely on finalizer fallback stress" {
  let valid = make_finalizer_fallback_scaled_font(0)
  let invalid = make_finalizer_fallback_scaled_font(42)
  inspect(@scaled_font_impl.status_raw(valid), content="0")
  inspect(@scaled_font_impl.status_raw(invalid), content="30")
  let mode_counts : FixedArray[Int] = FixedArray::make(3, 0)
  for index in 0..<1000 {
    let mode = index % 3
    mode_counts[mode] = mode_counts[mode] + 1
    lifetime_stress_text_to_glyphs_finalizer(valid, invalid, index)
  }
  inspect(mode_counts[0], content="334")
  inspect(mode_counts[1], content="333")
  inspect(mode_counts[2], content="333")
}
