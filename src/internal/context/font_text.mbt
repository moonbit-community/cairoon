///|
pub fn get_font_options_raw(
  ctx : RawContext,
  status : Ref[Int],
) -> @font_options_impl.RawFontOptions {
  ensure_native()
  context_get_font_options_ffi(ctx, status)
}

///|
pub fn set_font_options_raw(
  ctx : RawContext,
  options : @font_options_impl.RawFontOptions,
) -> Int {
  ensure_native()
  context_set_font_options_ffi(ctx, options)
}

///|
pub fn get_font_face_raw(
  ctx : RawContext,
  status : Ref[Int],
) -> @font_face_impl.RawFontFace {
  ensure_native()
  context_get_font_face_ffi(ctx, status)
}

///|
pub fn set_font_face_raw(
  ctx : RawContext,
  font_face : @font_face_impl.RawFontFace,
) -> Int {
  ensure_native()
  context_set_font_face_ffi(ctx, font_face)
}

///|
pub fn set_font_face_default_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_set_font_face_default_ffi(ctx)
}

///|
pub fn select_font_face_raw(
  ctx : RawContext,
  family : Bytes,
  slant : Int,
  weight : Int,
) -> Int {
  ensure_native()
  context_select_font_face_raw_ffi(ctx, family, slant, weight)
}

///|
pub fn set_font_matrix_raw(
  ctx : RawContext,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Int {
  ensure_native()
  context_set_font_matrix_ffi(ctx, xx, yx, xy, yy, x0, y0)
}

///|
pub fn get_font_matrix_raw(
  ctx : RawContext,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Int {
  ensure_native()
  context_get_font_matrix_ffi(ctx, xx, yx, xy, yy, x0, y0)
}

///|
pub fn set_font_size_raw(ctx : RawContext, size : Double) -> Int {
  ensure_native()
  context_set_font_size_ffi(ctx, size)
}

///|
pub fn font_extents_raw(
  ctx : RawContext,
  ascent : Ref[Double],
  descent : Ref[Double],
  height : Ref[Double],
  max_x_advance : Ref[Double],
  max_y_advance : Ref[Double],
) -> Int {
  ensure_native()
  context_font_extents_ffi(
    ctx, ascent, descent, height, max_x_advance, max_y_advance,
  )
}

///|
pub fn show_text_raw(ctx : RawContext, text : Bytes) -> Int {
  ensure_native()
  context_show_text_ffi(ctx, text)
}

///|
pub fn text_extents_raw(
  ctx : RawContext,
  text : Bytes,
  x_bearing : Ref[Double],
  y_bearing : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
  x_advance : Ref[Double],
  y_advance : Ref[Double],
) -> Int {
  ensure_native()
  context_text_extents_ffi(
    ctx, text, x_bearing, y_bearing, width, height, x_advance, y_advance,
  )
}

///|
pub fn text_path_raw(ctx : RawContext, text : Bytes) -> Int {
  ensure_native()
  context_text_path_ffi(ctx, text)
}

///|
pub fn glyph_extents_raw(
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
) -> Int {
  ensure_native()
  context_glyph_extents_ffi(
    ctx, indices, xs, ys, x_bearing, y_bearing, width, height, x_advance, y_advance,
  )
}

///|
pub fn glyph_path_raw(
  ctx : RawContext,
  indices : FixedArray[UInt64],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
) -> Int {
  ensure_native()
  context_glyph_path_ffi(ctx, indices, xs, ys)
}

///|
pub fn show_glyphs_raw(
  ctx : RawContext,
  indices : FixedArray[UInt64],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
) -> Int {
  ensure_native()
  context_show_glyphs_ffi(ctx, indices, xs, ys)
}

///|
pub fn get_scaled_font_raw(
  ctx : RawContext,
  status : Ref[Int],
) -> @scaled_font_impl.RawScaledFont {
  ensure_native()
  context_get_scaled_font_ffi(ctx, status)
}

///|
pub fn set_scaled_font_raw(
  ctx : RawContext,
  scaled_font : @scaled_font_impl.RawScaledFont,
) -> Int {
  ensure_native()
  context_set_scaled_font_ffi(ctx, scaled_font)
}
