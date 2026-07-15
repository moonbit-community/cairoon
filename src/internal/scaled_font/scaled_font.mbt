///|
fn ensure_native() -> Unit {
  ignore(@native.native_anchor())
}

///|
pub fn create_raw(
  font_face : @font_face_impl.RawFontFace,
  font_xx : Double,
  font_yx : Double,
  font_xy : Double,
  font_yy : Double,
  font_x0 : Double,
  font_y0 : Double,
  ctm_xx : Double,
  ctm_yx : Double,
  ctm_xy : Double,
  ctm_yy : Double,
  ctm_x0 : Double,
  ctm_y0 : Double,
  options : @font_options_impl.RawFontOptions,
) -> RawScaledFont {
  ensure_native()
  scaled_font_create_ffi(
    font_face, font_xx, font_yx, font_xy, font_yy, font_x0, font_y0, ctm_xx, ctm_yx,
    ctm_xy, ctm_yy, ctm_x0, ctm_y0, options,
  )
}

///|
pub fn status_raw(scaled_font : RawScaledFont) -> Int {
  ensure_native()
  scaled_font_status_ffi(scaled_font)
}

///|
pub fn equal_raw(scaled_font : RawScaledFont, other : RawScaledFont) -> Bool {
  ensure_native()
  scaled_font_equal_ffi(scaled_font, other)
}

///|
pub fn hash_raw(scaled_font : RawScaledFont) -> UInt64 {
  ensure_native()
  scaled_font_hash_ffi(scaled_font)
}

///|
pub fn get_font_face_raw(
  scaled_font : RawScaledFont,
  status : Ref[Int],
) -> @font_face_impl.RawFontFace {
  ensure_native()
  scaled_font_get_font_face_ffi(scaled_font, status)
}

///|
pub fn get_font_options_raw(
  scaled_font : RawScaledFont,
  status : Ref[Int],
) -> @font_options_impl.RawFontOptions {
  ensure_native()
  scaled_font_get_font_options_ffi(scaled_font, status)
}

///|
pub fn get_font_matrix_raw(
  scaled_font : RawScaledFont,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Int {
  ensure_native()
  scaled_font_get_font_matrix_ffi(scaled_font, xx, yx, xy, yy, x0, y0)
}

///|
pub fn get_ctm_raw(
  scaled_font : RawScaledFont,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Int {
  ensure_native()
  scaled_font_get_ctm_ffi(scaled_font, xx, yx, xy, yy, x0, y0)
}

///|
pub fn get_scale_matrix_raw(
  scaled_font : RawScaledFont,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Int {
  ensure_native()
  scaled_font_get_scale_matrix_ffi(scaled_font, xx, yx, xy, yy, x0, y0)
}

///|
pub fn extents_raw(
  scaled_font : RawScaledFont,
  ascent : Ref[Double],
  descent : Ref[Double],
  height : Ref[Double],
  max_x_advance : Ref[Double],
  max_y_advance : Ref[Double],
) -> Int {
  ensure_native()
  scaled_font_extents_ffi(
    scaled_font, ascent, descent, height, max_x_advance, max_y_advance,
  )
}

///|
pub fn text_extents_raw(
  scaled_font : RawScaledFont,
  text : Bytes,
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Int {
  ensure_native()
  scaled_font_text_extents_ffi(
    scaled_font, text, x_bearing, y_bearing, width, height, x_advance, y_advance,
  )
}

///|
pub fn glyph_extents_raw(
  scaled_font : RawScaledFont,
  indices : FixedArray[UInt64],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Int {
  ensure_native()
  scaled_font_glyph_extents_ffi(
    scaled_font, indices, xs, ys, x_bearing, y_bearing, width, height, x_advance,
    y_advance,
  )
}
