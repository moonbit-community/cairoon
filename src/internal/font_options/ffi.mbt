///|
type RawFontOptions

///|
extern "C" fn font_options_create_ffi() -> RawFontOptions = "cairoon_font_options_create"

///|
#borrow(options)
extern "C" fn font_options_status_ffi(options : RawFontOptions) -> Int = "cairoon_font_options_status"

///|
#borrow(options, status)
extern "C" fn font_options_copy_ffi(
  options : RawFontOptions,
  status : Ref[Int],
) -> RawFontOptions = "cairoon_font_options_copy"

///|
#borrow(options, other)
extern "C" fn font_options_merge_ffi(
  options : RawFontOptions,
  other : RawFontOptions,
) -> Int = "cairoon_font_options_merge"

///|
#borrow(options, other)
extern "C" fn font_options_equal_ffi(
  options : RawFontOptions,
  other : RawFontOptions,
) -> Bool = "cairoon_font_options_equal"

///|
#borrow(options)
extern "C" fn font_options_hash_ffi(options : RawFontOptions) -> UInt64 = "cairoon_font_options_hash"

///|
#borrow(options)
extern "C" fn font_options_get_antialias_raw_ffi(
  options : RawFontOptions,
) -> Int = "cairoon_font_options_get_antialias_raw"

///|
#borrow(options)
extern "C" fn font_options_set_antialias_ffi(
  options : RawFontOptions,
  antialias : Int,
) -> Int = "cairoon_font_options_set_antialias"

///|
#borrow(options)
extern "C" fn font_options_set_antialias_raw_ffi(
  options : RawFontOptions,
  antialias : Int,
) -> Int = "cairoon_font_options_set_antialias_raw"

///|
#borrow(options)
extern "C" fn font_options_get_subpixel_order_raw_ffi(
  options : RawFontOptions,
) -> Int = "cairoon_font_options_get_subpixel_order_raw"

///|
#borrow(options)
extern "C" fn font_options_set_subpixel_order_ffi(
  options : RawFontOptions,
  subpixel_order : Int,
) -> Int = "cairoon_font_options_set_subpixel_order"

///|
#borrow(options)
extern "C" fn font_options_set_subpixel_order_raw_ffi(
  options : RawFontOptions,
  subpixel_order : Int,
) -> Int = "cairoon_font_options_set_subpixel_order_raw"

///|
#borrow(options)
extern "C" fn font_options_get_hint_style_raw_ffi(
  options : RawFontOptions,
) -> Int = "cairoon_font_options_get_hint_style_raw"

///|
#borrow(options)
extern "C" fn font_options_set_hint_style_ffi(
  options : RawFontOptions,
  hint_style : Int,
) -> Int = "cairoon_font_options_set_hint_style"

///|
#borrow(options)
extern "C" fn font_options_set_hint_style_raw_ffi(
  options : RawFontOptions,
  hint_style : Int,
) -> Int = "cairoon_font_options_set_hint_style_raw"

///|
#borrow(options)
extern "C" fn font_options_get_hint_metrics_raw_ffi(
  options : RawFontOptions,
) -> Int = "cairoon_font_options_get_hint_metrics_raw"

///|
#borrow(options)
extern "C" fn font_options_set_hint_metrics_ffi(
  options : RawFontOptions,
  hint_metrics : Int,
) -> Int = "cairoon_font_options_set_hint_metrics"

///|
#borrow(options)
extern "C" fn font_options_set_hint_metrics_raw_ffi(
  options : RawFontOptions,
  hint_metrics : Int,
) -> Int = "cairoon_font_options_set_hint_metrics_raw"

///|
#borrow(options, has_variations, status)
extern "C" fn font_options_get_variations_ffi(
  options : RawFontOptions,
  has_variations : Ref[Int],
  status : Ref[Int],
) -> Bytes = "cairoon_font_options_get_variations"

///|
#borrow(options, variations)
extern "C" fn font_options_set_variations_ffi(
  options : RawFontOptions,
  variations : Bytes,
) -> Int = "cairoon_font_options_set_variations"

///|
#borrow(options)
extern "C" fn font_options_clear_variations_ffi(
  options : RawFontOptions,
) -> Int = "cairoon_font_options_clear_variations"

///|
#borrow(options, status)
extern "C" fn font_options_get_color_mode_raw_ffi(
  options : RawFontOptions,
  status : Ref[Int],
) -> Int = "cairoon_font_options_get_color_mode_raw"

///|
#borrow(options)
extern "C" fn font_options_set_color_mode_ffi(
  options : RawFontOptions,
  color_mode : Int,
) -> Int = "cairoon_font_options_set_color_mode"

///|
#borrow(options)
extern "C" fn font_options_set_color_mode_raw_ffi(
  options : RawFontOptions,
  color_mode : Int,
) -> Int = "cairoon_font_options_set_color_mode_raw"

///|
#borrow(options, status)
extern "C" fn font_options_get_color_palette_ffi(
  options : RawFontOptions,
  status : Ref[Int],
) -> UInt = "cairoon_font_options_get_color_palette"

///|
#borrow(options)
extern "C" fn font_options_set_color_palette_ffi(
  options : RawFontOptions,
  palette_index : UInt,
) -> Int = "cairoon_font_options_set_color_palette"

///|
#borrow(options)
extern "C" fn font_options_set_custom_palette_color_ffi(
  options : RawFontOptions,
  index : UInt,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Int = "cairoon_font_options_set_custom_palette_color"

///|
#borrow(options, red, green, blue, alpha)
extern "C" fn font_options_get_custom_palette_color_ffi(
  options : RawFontOptions,
  index : UInt,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Int = "cairoon_font_options_get_custom_palette_color"
