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
extern "C" fn font_options_get_antialias_raw_ffi(options : FontOptions) -> Int = "cairoon_font_options_get_antialias_raw"

///|
#borrow(options)
extern "C" fn font_options_set_antialias_ffi(
  options : FontOptions,
  antialias : Antialias,
) -> Status = "cairoon_font_options_set_antialias"

///|
#borrow(options)
extern "C" fn font_options_set_antialias_raw_ffi(
  options : FontOptions,
  antialias : Int,
) -> Status = "cairoon_font_options_set_antialias_raw"

///|
#borrow(options)
extern "C" fn font_options_get_subpixel_order_raw_ffi(
  options : FontOptions,
) -> Int = "cairoon_font_options_get_subpixel_order_raw"

///|
#borrow(options)
extern "C" fn font_options_set_subpixel_order_ffi(
  options : FontOptions,
  subpixel_order : SubpixelOrder,
) -> Status = "cairoon_font_options_set_subpixel_order"

///|
#borrow(options)
extern "C" fn font_options_set_subpixel_order_raw_ffi(
  options : FontOptions,
  subpixel_order : Int,
) -> Status = "cairoon_font_options_set_subpixel_order_raw"

///|
#borrow(options)
extern "C" fn font_options_get_hint_style_raw_ffi(options : FontOptions) -> Int = "cairoon_font_options_get_hint_style_raw"

///|
#borrow(options)
extern "C" fn font_options_set_hint_style_ffi(
  options : FontOptions,
  hint_style : HintStyle,
) -> Status = "cairoon_font_options_set_hint_style"

///|
#borrow(options)
extern "C" fn font_options_set_hint_style_raw_ffi(
  options : FontOptions,
  hint_style : Int,
) -> Status = "cairoon_font_options_set_hint_style_raw"

///|
#borrow(options)
extern "C" fn font_options_get_hint_metrics_raw_ffi(
  options : FontOptions,
) -> Int = "cairoon_font_options_get_hint_metrics_raw"

///|
#borrow(options)
extern "C" fn font_options_set_hint_metrics_ffi(
  options : FontOptions,
  hint_metrics : HintMetrics,
) -> Status = "cairoon_font_options_set_hint_metrics"

///|
#borrow(options)
extern "C" fn font_options_set_hint_metrics_raw_ffi(
  options : FontOptions,
  hint_metrics : Int,
) -> Status = "cairoon_font_options_set_hint_metrics_raw"

///|
#borrow(options, has_variations, status)
extern "C" fn font_options_get_variations_ffi(
  options : FontOptions,
  has_variations : Ref[Int],
  status : Ref[Status],
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
#borrow(options, status)
extern "C" fn font_options_get_color_mode_raw_ffi(
  options : FontOptions,
  status : Ref[Status],
) -> Int = "cairoon_font_options_get_color_mode_raw"

///|
#borrow(options)
extern "C" fn font_options_set_color_mode_ffi(
  options : FontOptions,
  color_mode : ColorMode,
) -> Status = "cairoon_font_options_set_color_mode"

///|
#borrow(options)
extern "C" fn font_options_set_color_mode_raw_ffi(
  options : FontOptions,
  color_mode : Int,
) -> Status = "cairoon_font_options_set_color_mode_raw"

///|
#borrow(options, status)
extern "C" fn font_options_get_color_palette_ffi(
  options : FontOptions,
  status : Ref[Status],
) -> UInt = "cairoon_font_options_get_color_palette"

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
