///|
#borrow(font_face, options)
extern "C" fn scaled_font_create_ffi(
  font_face : FontFace,
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
  options : FontOptions,
) -> ScaledFont = "cairoon_scaled_font_create"

///|
#borrow(scaled_font)
extern "C" fn scaled_font_status_ffi(scaled_font : ScaledFont) -> Status = "cairoon_scaled_font_status"

///|
#borrow(scaled_font, other)
extern "C" fn scaled_font_equal_ffi(
  scaled_font : ScaledFont,
  other : ScaledFont,
) -> Bool = "cairoon_scaled_font_equal"

///|
#borrow(scaled_font)
extern "C" fn scaled_font_hash_ffi(scaled_font : ScaledFont) -> UInt64 = "cairoon_scaled_font_hash"

///|
#borrow(scaled_font, status)
extern "C" fn scaled_font_get_font_face_ffi(
  scaled_font : ScaledFont,
  status : Ref[Status],
) -> FontFace = "cairoon_scaled_font_get_font_face"

///|
#borrow(scaled_font, status)
extern "C" fn scaled_font_get_font_options_ffi(
  scaled_font : ScaledFont,
  status : Ref[Status],
) -> FontOptions = "cairoon_scaled_font_get_font_options"

///|
#borrow(scaled_font, xx, yx, xy, yy, x0, y0)
extern "C" fn scaled_font_get_font_matrix_ffi(
  scaled_font : ScaledFont,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_scaled_font_get_font_matrix"

///|
#borrow(scaled_font, xx, yx, xy, yy, x0, y0)
extern "C" fn scaled_font_get_ctm_ffi(
  scaled_font : ScaledFont,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_scaled_font_get_ctm"

///|
#borrow(scaled_font, xx, yx, xy, yy, x0, y0)
extern "C" fn scaled_font_get_scale_matrix_ffi(
  scaled_font : ScaledFont,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_scaled_font_get_scale_matrix"

///|
#borrow(scaled_font, ascent, descent, height, max_x_advance, max_y_advance)
extern "C" fn scaled_font_extents_ffi(
  scaled_font : ScaledFont,
  ascent : Ref[Double],
  descent : Ref[Double],
  height : Ref[Double],
  max_x_advance : Ref[Double],
  max_y_advance : Ref[Double],
) -> Status = "cairoon_scaled_font_extents"

///|
#borrow(scaled_font, text, x_bearing, y_bearing, width, height, x_advance, y_advance)
extern "C" fn scaled_font_text_extents_ffi(
  scaled_font : ScaledFont,
  text : Bytes,
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Status = "cairoon_scaled_font_text_extents"

///|
#borrow(scaled_font, indices, xs, ys, x_bearing, y_bearing, width, height, x_advance, y_advance)
extern "C" fn scaled_font_glyph_extents_ffi(
  scaled_font : ScaledFont,
  indices : FixedArray[UInt64],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Status = "cairoon_scaled_font_glyph_extents"

///|
#borrow(scaled_font, text)
extern "C" fn scaled_font_text_to_glyphs_ffi(
  scaled_font : ScaledFont,
  x : Double,
  y : Double,
  text : Bytes,
) -> TextToGlyphsNative = "cairoon_scaled_font_text_to_glyphs"
