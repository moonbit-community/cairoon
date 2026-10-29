///|
type RawFontOptions

///|
extern "C" fn font_options_create_ffi() -> RawFontOptions = "cairoon_font_options_create"

///|
#borrow(options)
extern "C" fn font_options_status_ffi(options : RawFontOptions) -> Int32 = "cairoon_font_options_status"

///|
#borrow(options, status)
extern "C" fn font_options_copy_ffi(
  options : RawFontOptions,
  status : Ref[Int32],
) -> RawFontOptions = "cairoon_font_options_copy"

///|
#borrow(options, other)
extern "C" fn font_options_merge_ffi(
  options : RawFontOptions,
  other : RawFontOptions,
) -> Int32 = "cairoon_font_options_merge"

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
) -> Int32 = "cairoon_font_options_get_antialias_raw"

///|
#borrow(options)
extern "C" fn font_options_set_antialias_ffi(
  options : RawFontOptions,
  antialias : Int32,
) -> Int32 = "cairoon_font_options_set_antialias"

///|
#borrow(options)
extern "C" fn font_options_set_antialias_raw_ffi(
  options : RawFontOptions,
  antialias : Int32,
) -> Int32 = "cairoon_font_options_set_antialias_raw"

///|
#borrow(options)
extern "C" fn font_options_get_subpixel_order_raw_ffi(
  options : RawFontOptions,
) -> Int32 = "cairoon_font_options_get_subpixel_order_raw"

///|
#borrow(options)
extern "C" fn font_options_set_subpixel_order_ffi(
  options : RawFontOptions,
  subpixel_order : Int32,
) -> Int32 = "cairoon_font_options_set_subpixel_order"

///|
#borrow(options)
extern "C" fn font_options_set_subpixel_order_raw_ffi(
  options : RawFontOptions,
  subpixel_order : Int32,
) -> Int32 = "cairoon_font_options_set_subpixel_order_raw"

///|
#borrow(options)
extern "C" fn font_options_get_hint_style_raw_ffi(
  options : RawFontOptions,
) -> Int32 = "cairoon_font_options_get_hint_style_raw"

///|
#borrow(options)
extern "C" fn font_options_set_hint_style_ffi(
  options : RawFontOptions,
  hint_style : Int32,
) -> Int32 = "cairoon_font_options_set_hint_style"

///|
#borrow(options)
extern "C" fn font_options_set_hint_style_raw_ffi(
  options : RawFontOptions,
  hint_style : Int32,
) -> Int32 = "cairoon_font_options_set_hint_style_raw"

///|
#borrow(options)
extern "C" fn font_options_get_hint_metrics_raw_ffi(
  options : RawFontOptions,
) -> Int32 = "cairoon_font_options_get_hint_metrics_raw"

///|
#borrow(options)
extern "C" fn font_options_set_hint_metrics_ffi(
  options : RawFontOptions,
  hint_metrics : Int32,
) -> Int32 = "cairoon_font_options_set_hint_metrics"

///|
#borrow(options)
extern "C" fn font_options_set_hint_metrics_raw_ffi(
  options : RawFontOptions,
  hint_metrics : Int32,
) -> Int32 = "cairoon_font_options_set_hint_metrics_raw"

///|
#borrow(options, has_variations, status)
extern "C" fn font_options_get_variations_ffi(
  options : RawFontOptions,
  has_variations : Ref[Int32],
  status : Ref[Int32],
) -> Bytes = "cairoon_font_options_get_variations"

///|
#borrow(options, variations)
extern "C" fn font_options_set_variations_ffi(
  options : RawFontOptions,
  variations : Bytes,
) -> Int32 = "cairoon_font_options_set_variations"

///|
#borrow(options)
extern "C" fn font_options_clear_variations_ffi(
  options : RawFontOptions,
) -> Int32 = "cairoon_font_options_clear_variations"

///|
#borrow(options, status)
extern "C" fn font_options_get_color_mode_raw_ffi(
  options : RawFontOptions,
  status : Ref[Int32],
) -> Int32 = "cairoon_font_options_get_color_mode_raw"

///|
#borrow(options)
extern "C" fn font_options_set_color_mode_ffi(
  options : RawFontOptions,
  color_mode : Int32,
) -> Int32 = "cairoon_font_options_set_color_mode"

///|
#borrow(options)
extern "C" fn font_options_set_color_mode_raw_ffi(
  options : RawFontOptions,
  color_mode : Int32,
) -> Int32 = "cairoon_font_options_set_color_mode_raw"

///|
#borrow(options, status)
extern "C" fn font_options_get_color_palette_ffi(
  options : RawFontOptions,
  status : Ref[Int32],
) -> UInt32 = "cairoon_font_options_get_color_palette"

///|
#borrow(options)
extern "C" fn font_options_set_color_palette_ffi(
  options : RawFontOptions,
  palette_index : UInt32,
) -> Int32 = "cairoon_font_options_set_color_palette"

///|
#borrow(options)
extern "C" fn font_options_set_custom_palette_color_ffi(
  options : RawFontOptions,
  index : UInt32,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Int32 = "cairoon_font_options_set_custom_palette_color"

///|
#borrow(options, red, green, blue, alpha)
extern "C" fn font_options_get_custom_palette_color_ffi(
  options : RawFontOptions,
  index : UInt32,
  red : Ref[Double],
  green : Ref[Double],
  blue : Ref[Double],
  alpha : Ref[Double],
) -> Int32 = "cairoon_font_options_get_custom_palette_color"
