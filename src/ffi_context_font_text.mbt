///|
#borrow(ctx, status)
extern "C" fn context_get_font_options_ffi(
  ctx : Context,
  status : Ref[Status],
) -> @font_options_impl.RawFontOptions = "cairoon_context_get_font_options"

///|
#borrow(ctx, options)
extern "C" fn context_set_font_options_ffi(
  ctx : Context,
  options : @font_options_impl.RawFontOptions,
) -> Status = "cairoon_context_set_font_options"

///|
#borrow(ctx, status)
extern "C" fn context_get_font_face_ffi(
  ctx : Context,
  status : Ref[Status],
) -> @font_face_impl.RawFontFace = "cairoon_context_get_font_face"

///|
#borrow(ctx, font_face)
extern "C" fn context_set_font_face_ffi(
  ctx : Context,
  font_face : @font_face_impl.RawFontFace,
) -> Status = "cairoon_context_set_font_face"

///|
#borrow(ctx)
extern "C" fn context_set_font_face_default_ffi(ctx : Context) -> Status = "cairoon_context_set_font_face_default"

///|
#borrow(ctx, family)
extern "C" fn context_select_font_face_ffi(
  ctx : Context,
  family : Bytes,
  slant : FontSlant,
  weight : FontWeight,
) -> Status = "cairoon_context_select_font_face"

///|
#borrow(ctx, family)
extern "C" fn context_select_font_face_raw_ffi(
  ctx : Context,
  family : Bytes,
  slant : Int,
  weight : Int,
) -> Status = "cairoon_context_select_font_face_raw"

///|
#borrow(ctx)
extern "C" fn context_set_font_matrix_ffi(
  ctx : Context,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Status = "cairoon_context_set_font_matrix"

///|
#borrow(ctx, xx, yx, xy, yy, x0, y0)
extern "C" fn context_get_font_matrix_ffi(
  ctx : Context,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_context_get_font_matrix"

///|
#borrow(ctx)
extern "C" fn context_set_font_size_ffi(ctx : Context, size : Double) -> Status = "cairoon_context_set_font_size"

///|
#borrow(ctx, ascent, descent, height, max_x_advance, max_y_advance)
extern "C" fn context_font_extents_ffi(
  ctx : Context,
  ascent : Ref[Double],
  descent : Ref[Double],
  height : Ref[Double],
  max_x_advance : Ref[Double],
  max_y_advance : Ref[Double],
) -> Status = "cairoon_context_font_extents"

///|
#borrow(ctx, text)
extern "C" fn context_show_text_ffi(ctx : Context, text : Bytes) -> Status = "cairoon_context_show_text"

///|
#borrow(ctx, text, x_bearing, y_bearing, width, height, x_advance, y_advance)
extern "C" fn context_text_extents_ffi(
  ctx : Context,
  text : Bytes,
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Status = "cairoon_context_text_extents"

///|
#borrow(ctx, text)
extern "C" fn context_text_path_ffi(ctx : Context, text : Bytes) -> Status = "cairoon_context_text_path"

///|
#borrow(ctx, indices, xs, ys, x_bearing, y_bearing, width, height, x_advance, y_advance)
extern "C" fn context_glyph_extents_ffi(
  ctx : Context,
  indices : FixedArray[UInt64],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Status = "cairoon_context_glyph_extents"

///|
#borrow(ctx, indices, xs, ys)
extern "C" fn context_glyph_path_ffi(
  ctx : Context,
  indices : FixedArray[UInt64],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
) -> Status = "cairoon_context_glyph_path"

///|
#borrow(ctx, indices, xs, ys)
extern "C" fn context_show_glyphs_ffi(
  ctx : Context,
  indices : FixedArray[UInt64],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
) -> Status = "cairoon_context_show_glyphs"

///|
#borrow(ctx, text, indices, xs, ys, cluster_num_bytes, cluster_num_glyphs)
extern "C" fn context_show_text_glyphs_ffi(
  ctx : Context,
  text : Bytes,
  indices : FixedArray[UInt64],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
  cluster_num_bytes : FixedArray[Int],
  cluster_num_glyphs : FixedArray[Int],
  flags : TextClusterFlags,
) -> Status = "cairoon_context_show_text_glyphs"

///|
#borrow(ctx, status)
extern "C" fn context_get_scaled_font_ffi(
  ctx : Context,
  status : Ref[Status],
) -> ScaledFont = "cairoon_context_get_scaled_font"

///|
#borrow(ctx, scaled_font)
extern "C" fn context_set_scaled_font_ffi(
  ctx : Context,
  scaled_font : ScaledFont,
) -> Status = "cairoon_context_set_scaled_font"
