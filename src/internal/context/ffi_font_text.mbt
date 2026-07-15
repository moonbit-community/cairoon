///|
#borrow(ctx, status)
extern "C" fn context_get_font_options_ffi(
  ctx : RawContext,
  status : Ref[Int],
) -> @font_options_impl.RawFontOptions = "cairoon_context_get_font_options"

///|
#borrow(ctx, options)
extern "C" fn context_set_font_options_ffi(
  ctx : RawContext,
  options : @font_options_impl.RawFontOptions,
) -> Int = "cairoon_context_set_font_options"

///|
#borrow(ctx, status)
extern "C" fn context_get_font_face_ffi(
  ctx : RawContext,
  status : Ref[Int],
) -> @font_face_impl.RawFontFace = "cairoon_context_get_font_face"

///|
#borrow(ctx, font_face)
extern "C" fn context_set_font_face_ffi(
  ctx : RawContext,
  font_face : @font_face_impl.RawFontFace,
) -> Int = "cairoon_context_set_font_face"

///|
#borrow(ctx)
extern "C" fn context_set_font_face_default_ffi(ctx : RawContext) -> Int = "cairoon_context_set_font_face_default"

///|
#borrow(ctx, family)
extern "C" fn context_select_font_face_raw_ffi(
  ctx : RawContext,
  family : Bytes,
  slant : Int,
  weight : Int,
) -> Int = "cairoon_context_select_font_face_raw"

///|
#borrow(ctx)
extern "C" fn context_set_font_matrix_ffi(
  ctx : RawContext,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Int = "cairoon_context_set_font_matrix"

///|
#borrow(ctx, xx, yx, xy, yy, x0, y0)
extern "C" fn context_get_font_matrix_ffi(
  ctx : RawContext,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Int = "cairoon_context_get_font_matrix"

///|
#borrow(ctx)
extern "C" fn context_set_font_size_ffi(ctx : RawContext, size : Double) -> Int = "cairoon_context_set_font_size"

///|
#borrow(ctx, ascent, descent, height, max_x_advance, max_y_advance)
extern "C" fn context_font_extents_ffi(
  ctx : RawContext,
  ascent : Ref[Double],
  descent : Ref[Double],
  height : Ref[Double],
  max_x_advance : Ref[Double],
  max_y_advance : Ref[Double],
) -> Int = "cairoon_context_font_extents"

///|
#borrow(ctx, text)
extern "C" fn context_show_text_ffi(ctx : RawContext, text : Bytes) -> Int = "cairoon_context_show_text"

///|
#borrow(ctx, text, x_bearing, y_bearing, width, height, x_advance, y_advance)
extern "C" fn context_text_extents_ffi(
  ctx : RawContext,
  text : Bytes,
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Int = "cairoon_context_text_extents"

///|
#borrow(ctx, text)
extern "C" fn context_text_path_ffi(ctx : RawContext, text : Bytes) -> Int = "cairoon_context_text_path"

///|
#borrow(ctx, indices, xs, ys, x_bearing, y_bearing, width, height, x_advance, y_advance)
extern "C" fn context_glyph_extents_ffi(
  ctx : RawContext,
  indices : FixedArray[UInt64],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Int = "cairoon_context_glyph_extents"

///|
#borrow(ctx, indices, xs, ys)
extern "C" fn context_glyph_path_ffi(
  ctx : RawContext,
  indices : FixedArray[UInt64],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
) -> Int = "cairoon_context_glyph_path"

///|
#borrow(ctx, indices, xs, ys)
extern "C" fn context_show_glyphs_ffi(
  ctx : RawContext,
  indices : FixedArray[UInt64],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
) -> Int = "cairoon_context_show_glyphs"

///|
#borrow(ctx, status)
extern "C" fn context_get_scaled_font_ffi(
  ctx : RawContext,
  status : Ref[Int],
) -> @scaled_font_impl.RawScaledFont = "cairoon_context_get_scaled_font"

///|
#borrow(ctx, scaled_font)
extern "C" fn context_set_scaled_font_ffi(
  ctx : RawContext,
  scaled_font : @scaled_font_impl.RawScaledFont,
) -> Int = "cairoon_context_set_scaled_font"
