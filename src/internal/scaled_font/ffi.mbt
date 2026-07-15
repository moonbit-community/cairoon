///|
type RawScaledFont

///|
#borrow(font_face, options)
extern "C" fn scaled_font_create_ffi(
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
) -> RawScaledFont = "cairoon_scaled_font_create"

///|
#borrow(scaled_font)
extern "C" fn scaled_font_status_ffi(scaled_font : RawScaledFont) -> Int = "cairoon_scaled_font_status"

///|
#borrow(scaled_font, other)
extern "C" fn scaled_font_equal_ffi(
  scaled_font : RawScaledFont,
  other : RawScaledFont,
) -> Bool = "cairoon_scaled_font_equal"

///|
#borrow(scaled_font)
extern "C" fn scaled_font_hash_ffi(scaled_font : RawScaledFont) -> UInt64 = "cairoon_scaled_font_hash"

///|
#borrow(scaled_font, status)
extern "C" fn scaled_font_get_font_face_ffi(
  scaled_font : RawScaledFont,
  status : Ref[Int],
) -> @font_face_impl.RawFontFace = "cairoon_scaled_font_get_font_face"

///|
#borrow(scaled_font, status)
extern "C" fn scaled_font_get_font_options_ffi(
  scaled_font : RawScaledFont,
  status : Ref[Int],
) -> @font_options_impl.RawFontOptions = "cairoon_scaled_font_get_font_options"

///|
#borrow(scaled_font, xx, yx, xy, yy, x0, y0)
extern "C" fn scaled_font_get_font_matrix_ffi(
  scaled_font : RawScaledFont,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Int = "cairoon_scaled_font_get_font_matrix"

///|
#borrow(scaled_font, xx, yx, xy, yy, x0, y0)
extern "C" fn scaled_font_get_ctm_ffi(
  scaled_font : RawScaledFont,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Int = "cairoon_scaled_font_get_ctm"

///|
#borrow(scaled_font, xx, yx, xy, yy, x0, y0)
extern "C" fn scaled_font_get_scale_matrix_ffi(
  scaled_font : RawScaledFont,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Int = "cairoon_scaled_font_get_scale_matrix"

///|
#borrow(scaled_font, ascent, descent, height, max_x_advance, max_y_advance)
extern "C" fn scaled_font_extents_ffi(
  scaled_font : RawScaledFont,
  ascent : Ref[Double],
  descent : Ref[Double],
  height : Ref[Double],
  max_x_advance : Ref[Double],
  max_y_advance : Ref[Double],
) -> Int = "cairoon_scaled_font_extents"

///|
#borrow(scaled_font, text, x_bearing, y_bearing, width, height, x_advance, y_advance)
extern "C" fn scaled_font_text_extents_ffi(
  scaled_font : RawScaledFont,
  text : Bytes,
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Int = "cairoon_scaled_font_text_extents"

///|
#borrow(scaled_font, indices, xs, ys, x_bearing, y_bearing, width, height, x_advance, y_advance)
extern "C" fn scaled_font_glyph_extents_ffi(
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
) -> Int = "cairoon_scaled_font_glyph_extents"
