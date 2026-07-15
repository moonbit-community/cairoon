///|
fn ensure_native() -> Unit {
  ignore(@native.native_anchor())
}

///|
pub fn create_raw() -> RawFontOptions {
  ensure_native()
  font_options_create_ffi()
}

///|
pub fn status_raw(options : RawFontOptions) -> Int {
  ensure_native()
  font_options_status_ffi(options)
}

///|
pub fn copy_raw(options : RawFontOptions, status : Ref[Int]) -> RawFontOptions {
  ensure_native()
  font_options_copy_ffi(options, status)
}

///|
pub fn merge_raw(options : RawFontOptions, other : RawFontOptions) -> Int {
  ensure_native()
  font_options_merge_ffi(options, other)
}

///|
pub fn equal_raw(options : RawFontOptions, other : RawFontOptions) -> Bool {
  ensure_native()
  font_options_equal_ffi(options, other)
}

///|
pub fn hash_raw(options : RawFontOptions) -> UInt64 {
  ensure_native()
  font_options_hash_ffi(options)
}

///|
pub fn get_antialias_raw(options : RawFontOptions) -> Int {
  ensure_native()
  font_options_get_antialias_raw_ffi(options)
}

///|
pub fn set_antialias_value_raw(
  options : RawFontOptions,
  antialias : Int,
) -> Int {
  ensure_native()
  font_options_set_antialias_ffi(options, antialias)
}

///|
pub fn set_antialias_raw(options : RawFontOptions, antialias : Int) -> Int {
  ensure_native()
  font_options_set_antialias_raw_ffi(options, antialias)
}

///|
pub fn get_subpixel_order_raw(options : RawFontOptions) -> Int {
  ensure_native()
  font_options_get_subpixel_order_raw_ffi(options)
}

///|
pub fn set_subpixel_order_value_raw(
  options : RawFontOptions,
  subpixel_order : Int,
) -> Int {
  ensure_native()
  font_options_set_subpixel_order_ffi(options, subpixel_order)
}

///|
pub fn set_subpixel_order_raw(
  options : RawFontOptions,
  subpixel_order : Int,
) -> Int {
  ensure_native()
  font_options_set_subpixel_order_raw_ffi(options, subpixel_order)
}

///|
pub fn get_hint_style_raw(options : RawFontOptions) -> Int {
  ensure_native()
  font_options_get_hint_style_raw_ffi(options)
}

///|
pub fn set_hint_style_value_raw(
  options : RawFontOptions,
  hint_style : Int,
) -> Int {
  ensure_native()
  font_options_set_hint_style_ffi(options, hint_style)
}

///|
pub fn set_hint_style_raw(options : RawFontOptions, hint_style : Int) -> Int {
  ensure_native()
  font_options_set_hint_style_raw_ffi(options, hint_style)
}

///|
pub fn get_hint_metrics_raw(options : RawFontOptions) -> Int {
  ensure_native()
  font_options_get_hint_metrics_raw_ffi(options)
}

///|
pub fn set_hint_metrics_value_raw(
  options : RawFontOptions,
  hint_metrics : Int,
) -> Int {
  ensure_native()
  font_options_set_hint_metrics_ffi(options, hint_metrics)
}

///|
pub fn set_hint_metrics_raw(
  options : RawFontOptions,
  hint_metrics : Int,
) -> Int {
  ensure_native()
  font_options_set_hint_metrics_raw_ffi(options, hint_metrics)
}

///|
pub fn get_variations_raw(
  options : RawFontOptions,
  has_variations : Ref[Int],
  status : Ref[Int],
) -> Bytes {
  ensure_native()
  font_options_get_variations_ffi(options, has_variations, status)
}

///|
pub fn set_variations_raw(options : RawFontOptions, variations : Bytes) -> Int {
  ensure_native()
  font_options_set_variations_ffi(options, variations)
}

///|
pub fn clear_variations_raw(options : RawFontOptions) -> Int {
  ensure_native()
  font_options_clear_variations_ffi(options)
}

///|
pub fn get_color_mode_raw(options : RawFontOptions, status : Ref[Int]) -> Int {
  ensure_native()
  font_options_get_color_mode_raw_ffi(options, status)
}

///|
pub fn set_color_mode_value_raw(
  options : RawFontOptions,
  color_mode : Int,
) -> Int {
  ensure_native()
  font_options_set_color_mode_ffi(options, color_mode)
}

///|
pub fn set_color_mode_raw(options : RawFontOptions, color_mode : Int) -> Int {
  ensure_native()
  font_options_set_color_mode_raw_ffi(options, color_mode)
}

///|
pub fn get_color_palette_raw(
  options : RawFontOptions,
  status : Ref[Int],
) -> UInt {
  ensure_native()
  font_options_get_color_palette_ffi(options, status)
}

///|
pub fn set_color_palette_raw(
  options : RawFontOptions,
  palette_index : UInt,
) -> Int {
  ensure_native()
  font_options_set_color_palette_ffi(options, palette_index)
}

///|
pub fn set_custom_palette_color_raw(
  options : RawFontOptions,
  index : UInt,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Int {
  ensure_native()
  font_options_set_custom_palette_color_ffi(
    options, index, red, green, blue, alpha,
  )
}

///|
pub fn get_custom_palette_color_raw(
  options : RawFontOptions,
  index : UInt,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Int {
  ensure_native()
  font_options_get_custom_palette_color_ffi(
    options, index, red, green, blue, alpha,
  )
}
