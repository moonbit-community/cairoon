///|
extern "C" fn font_options_create_ffi() -> FontOptions = "cairoon_font_options_create"

///|
#borrow(options)
extern "C" fn font_options_status_ffi(options : FontOptions) -> Status = "cairoon_font_options_status"

///|
#borrow(options, status)
extern "C" fn font_options_copy_ffi(
  options : FontOptions,
  status : Ref[Status],
) -> FontOptions = "cairoon_font_options_copy"

///|
#borrow(options, other)
extern "C" fn font_options_merge_ffi(
  options : FontOptions,
  other : FontOptions,
) -> Status = "cairoon_font_options_merge"

///|
#borrow(options, other)
extern "C" fn font_options_equal_ffi(
  options : FontOptions,
  other : FontOptions,
) -> Bool = "cairoon_font_options_equal"

///|
#borrow(options)
extern "C" fn font_options_hash_ffi(options : FontOptions) -> UInt64 = "cairoon_font_options_hash"

///|
#borrow(options)
extern "C" fn font_options_get_antialias_ffi(
  options : FontOptions,
) -> Antialias = "cairoon_font_options_get_antialias"

///|
#borrow(options)
extern "C" fn font_options_set_antialias_ffi(
  options : FontOptions,
  antialias : Antialias,
) -> Status = "cairoon_font_options_set_antialias"

///|
#borrow(options)
extern "C" fn font_options_get_subpixel_order_ffi(
  options : FontOptions,
) -> SubpixelOrder = "cairoon_font_options_get_subpixel_order"

///|
#borrow(options)
extern "C" fn font_options_set_subpixel_order_ffi(
  options : FontOptions,
  subpixel_order : SubpixelOrder,
) -> Status = "cairoon_font_options_set_subpixel_order"

///|
#borrow(options)
extern "C" fn font_options_get_hint_style_ffi(
  options : FontOptions,
) -> HintStyle = "cairoon_font_options_get_hint_style"

///|
#borrow(options)
extern "C" fn font_options_set_hint_style_ffi(
  options : FontOptions,
  hint_style : HintStyle,
) -> Status = "cairoon_font_options_set_hint_style"

///|
#borrow(options)
extern "C" fn font_options_get_hint_metrics_ffi(
  options : FontOptions,
) -> HintMetrics = "cairoon_font_options_get_hint_metrics"

///|
#borrow(options)
extern "C" fn font_options_set_hint_metrics_ffi(
  options : FontOptions,
  hint_metrics : HintMetrics,
) -> Status = "cairoon_font_options_set_hint_metrics"

///|
#borrow(options, has_variations)
extern "C" fn font_options_get_variations_ffi(
  options : FontOptions,
  has_variations : Ref[Int],
) -> Bytes = "cairoon_font_options_get_variations"

///|
#borrow(options, variations)
extern "C" fn font_options_set_variations_ffi(
  options : FontOptions,
  variations : Bytes,
) -> Status = "cairoon_font_options_set_variations"

///|
#borrow(options)
extern "C" fn font_options_clear_variations_ffi(
  options : FontOptions,
) -> Status = "cairoon_font_options_clear_variations"

///|
#borrow(options)
extern "C" fn font_options_get_color_mode_ffi(
  options : FontOptions,
) -> ColorMode = "cairoon_font_options_get_color_mode"

///|
#borrow(options)
extern "C" fn font_options_set_color_mode_ffi(
  options : FontOptions,
  color_mode : ColorMode,
) -> Status = "cairoon_font_options_set_color_mode"

///|
#borrow(options)
extern "C" fn font_options_get_color_palette_ffi(options : FontOptions) -> UInt = "cairoon_font_options_get_color_palette"

///|
#borrow(options)
extern "C" fn font_options_set_color_palette_ffi(
  options : FontOptions,
  palette_index : UInt,
) -> Status = "cairoon_font_options_set_color_palette"

///|
#borrow(options)
extern "C" fn font_options_set_custom_palette_color_ffi(
  options : FontOptions,
  index : UInt,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Status = "cairoon_font_options_set_custom_palette_color"

///|
#borrow(options, red, green, blue, alpha)
extern "C" fn font_options_get_custom_palette_color_ffi(
  options : FontOptions,
  index : UInt,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Status = "cairoon_font_options_get_custom_palette_color"

///|
#borrow(family)
extern "C" fn toy_font_face_create_ffi(
  family : Bytes,
  slant : FontSlant,
  weight : FontWeight,
) -> FontFace = "cairoon_toy_font_face_create"

///|
#borrow(font_face)
extern "C" fn font_face_status_ffi(font_face : FontFace) -> Status = "cairoon_font_face_status"

///|
#borrow(font_face, other)
extern "C" fn font_face_equal_ffi(
  font_face : FontFace,
  other : FontFace,
) -> Bool = "cairoon_font_face_equal"

///|
#borrow(font_face)
extern "C" fn font_face_hash_ffi(font_face : FontFace) -> UInt64 = "cairoon_font_face_hash"

///|
#borrow(font_face, status)
extern "C" fn toy_font_face_get_family_ffi(
  font_face : FontFace,
  status : Ref[Status],
) -> Bytes = "cairoon_toy_font_face_get_family"

///|
#borrow(font_face, status)
extern "C" fn toy_font_face_get_slant_ffi(
  font_face : FontFace,
  status : Ref[Status],
) -> FontSlant = "cairoon_toy_font_face_get_slant"

///|
#borrow(font_face, status)
extern "C" fn toy_font_face_get_weight_ffi(
  font_face : FontFace,
  status : Ref[Status],
) -> FontWeight = "cairoon_toy_font_face_get_weight"

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

///|
#borrow(result)
extern "C" fn text_to_glyphs_status_ffi(result : TextToGlyphsNative) -> Status = "cairoon_text_to_glyphs_status"

///|
#borrow(result)
extern "C" fn text_to_glyphs_indices_ffi(
  result : TextToGlyphsNative,
) -> FixedArray[UInt64] = "cairoon_text_to_glyphs_indices"

///|
#borrow(result)
extern "C" fn text_to_glyphs_positions_ffi(
  result : TextToGlyphsNative,
) -> FixedArray[Double] = "cairoon_text_to_glyphs_positions"

///|
#borrow(result)
extern "C" fn text_to_glyphs_clusters_ffi(
  result : TextToGlyphsNative,
) -> FixedArray[Int] = "cairoon_text_to_glyphs_clusters"

///|
#borrow(result)
extern "C" fn text_to_glyphs_flags_ffi(
  result : TextToGlyphsNative,
) -> TextClusterFlags = "cairoon_text_to_glyphs_flags"
