///|
pub fn text_to_glyphs_raw(
  scaled_font : RawScaledFont,
  x : Double,
  y : Double,
  text : Bytes,
  with_clusters : Bool,
) -> RawTextToGlyphs {
  ensure_native()
  scaled_font_text_to_glyphs_ffi(scaled_font, x, y, text, with_clusters)
}

///|
pub fn text_to_glyphs_status_raw(result : RawTextToGlyphs) -> Int {
  ensure_native()
  text_to_glyphs_status_ffi(result)
}

///|
pub fn text_to_glyphs_indices_raw(
  result : RawTextToGlyphs,
) -> FixedArray[UInt64] {
  ensure_native()
  text_to_glyphs_indices_ffi(result)
}

///|
pub fn text_to_glyphs_positions_raw(
  result : RawTextToGlyphs,
) -> FixedArray[Double] {
  ensure_native()
  text_to_glyphs_positions_ffi(result)
}

///|
pub fn text_to_glyphs_clusters_raw(result : RawTextToGlyphs) -> FixedArray[Int] {
  ensure_native()
  text_to_glyphs_clusters_ffi(result)
}

///|
pub fn text_to_glyphs_flags_raw(result : RawTextToGlyphs) -> Int {
  ensure_native()
  text_to_glyphs_flags_ffi(result)
}

///|
pub fn text_to_glyphs_release_raw(result : RawTextToGlyphs) -> Unit {
  ensure_native()
  text_to_glyphs_release_ffi(result)
}
