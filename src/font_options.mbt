///|
pub fn FontOptions::new() -> FontOptions raise CairoError {
  let options = font_options_create_ffi()
  check_status(font_options_status_ffi(options))
  options
}

///|
pub fn FontOptions::status(self : FontOptions) -> Status {
  font_options_status_ffi(self)
}

///|
pub fn FontOptions::copy(self : FontOptions) -> FontOptions raise CairoError {
  let status = Ref(Success)
  let options = font_options_copy_ffi(self, status)
  check_status(status.val)
  options
}

///|
pub fn FontOptions::merge(
  self : FontOptions,
  other : FontOptions,
) -> Unit raise CairoError {
  check_status(font_options_merge_ffi(self, other))
}

///|
pub fn FontOptions::equal(self : FontOptions, other : FontOptions) -> Bool {
  font_options_equal_ffi(self, other)
}

///|
pub fn FontOptions::hash(self : FontOptions) -> UInt64 {
  font_options_hash_ffi(self)
}

///|
pub fn FontOptions::get_antialias(
  self : FontOptions,
) -> Antialias raise CairoError {
  antialias_from_raw(self.get_antialias_raw())
}

///|
pub fn FontOptions::get_antialias_raw(
  self : FontOptions,
) -> Int raise CairoError {
  check_status(font_options_status_ffi(self))
  font_options_get_antialias_raw_ffi(self)
}

///|
pub fn FontOptions::set_antialias(
  self : FontOptions,
  antialias : Antialias,
) -> Unit raise CairoError {
  check_status(font_options_set_antialias_ffi(self, antialias))
}

///|
pub fn FontOptions::set_antialias_raw(
  self : FontOptions,
  antialias : Int,
) -> Unit raise CairoError {
  check_status(font_options_set_antialias_raw_ffi(self, antialias))
}

///|
fn subpixel_order_from_raw(raw : Int) -> SubpixelOrder raise CairoError {
  match raw {
    0 => SubpixelDefault
    1 => SubpixelRgb
    2 => SubpixelBgr
    3 => SubpixelVrgb
    4 => SubpixelVbgr
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo subpixel order: \{raw}",
      )
  }
}

///|
pub fn FontOptions::get_subpixel_order(
  self : FontOptions,
) -> SubpixelOrder raise CairoError {
  subpixel_order_from_raw(self.get_subpixel_order_raw())
}

///|
pub fn FontOptions::get_subpixel_order_raw(
  self : FontOptions,
) -> Int raise CairoError {
  check_status(font_options_status_ffi(self))
  font_options_get_subpixel_order_raw_ffi(self)
}

///|
pub fn FontOptions::set_subpixel_order(
  self : FontOptions,
  subpixel_order : SubpixelOrder,
) -> Unit raise CairoError {
  check_status(font_options_set_subpixel_order_ffi(self, subpixel_order))
}

///|
pub fn FontOptions::set_subpixel_order_raw(
  self : FontOptions,
  subpixel_order : Int,
) -> Unit raise CairoError {
  check_status(font_options_set_subpixel_order_raw_ffi(self, subpixel_order))
}

///|
fn hint_style_from_raw(raw : Int) -> HintStyle raise CairoError {
  match raw {
    0 => HintStyleDefault
    1 => HintStyleNone
    2 => HintStyleSlight
    3 => HintStyleMedium
    4 => HintStyleFull
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo hint style: \{raw}",
      )
  }
}

///|
pub fn FontOptions::get_hint_style(
  self : FontOptions,
) -> HintStyle raise CairoError {
  hint_style_from_raw(self.get_hint_style_raw())
}

///|
pub fn FontOptions::get_hint_style_raw(
  self : FontOptions,
) -> Int raise CairoError {
  check_status(font_options_status_ffi(self))
  font_options_get_hint_style_raw_ffi(self)
}

///|
pub fn FontOptions::set_hint_style(
  self : FontOptions,
  hint_style : HintStyle,
) -> Unit raise CairoError {
  check_status(font_options_set_hint_style_ffi(self, hint_style))
}

///|
pub fn FontOptions::set_hint_style_raw(
  self : FontOptions,
  hint_style : Int,
) -> Unit raise CairoError {
  check_status(font_options_set_hint_style_raw_ffi(self, hint_style))
}

///|
fn hint_metrics_from_raw(raw : Int) -> HintMetrics raise CairoError {
  match raw {
    0 => HintMetricsDefault
    1 => HintMetricsOff
    2 => HintMetricsOn
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo hint metrics: \{raw}",
      )
  }
}

///|
pub fn FontOptions::get_hint_metrics(
  self : FontOptions,
) -> HintMetrics raise CairoError {
  hint_metrics_from_raw(self.get_hint_metrics_raw())
}

///|
pub fn FontOptions::get_hint_metrics_raw(
  self : FontOptions,
) -> Int raise CairoError {
  check_status(font_options_status_ffi(self))
  font_options_get_hint_metrics_raw_ffi(self)
}

///|
pub fn FontOptions::set_hint_metrics(
  self : FontOptions,
  hint_metrics : HintMetrics,
) -> Unit raise CairoError {
  check_status(font_options_set_hint_metrics_ffi(self, hint_metrics))
}

///|
pub fn FontOptions::set_hint_metrics_raw(
  self : FontOptions,
  hint_metrics : Int,
) -> Unit raise CairoError {
  check_status(font_options_set_hint_metrics_raw_ffi(self, hint_metrics))
}

///|
fn check_no_embedded_nul(bytes : Bytes) -> Unit raise CairoError {
  if @cstring_impl.has_embedded_nul(bytes) {
    raise CairoInvalidArgument(InvalidString, InvalidString.message())
  }
}

///|
pub fn FontOptions::get_variations(
  self : FontOptions,
) -> String? raise CairoError {
  check_status(font_options_status_ffi(self))
  let has_variations = Ref(0)
  let bytes = font_options_get_variations_ffi(self, has_variations)
  if has_variations.val == 0 {
    None
  } else {
    Some(@utf8.decode_lossy(bytes))
  }
}

///|
pub fn FontOptions::set_variations(
  self : FontOptions,
  variations : String?,
) -> Unit raise CairoError {
  match variations {
    None => check_status(font_options_clear_variations_ffi(self))
    Some(value) => {
      let bytes = @utf8.encode(value)
      check_no_embedded_nul(bytes)
      check_status(font_options_set_variations_ffi(self, bytes))
    }
  }
}

///|
pub fn FontOptions::get_color_mode(
  self : FontOptions,
) -> ColorMode raise CairoError {
  color_mode_from_raw(self.get_color_mode_raw())
}

///|
fn color_mode_from_raw(raw : Int) -> ColorMode raise CairoError {
  match raw {
    0 => ColorModeDefault
    1 => ColorModeNoColor
    2 => ColorModeColor
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo color mode: \{raw}",
      )
  }
}

///|
pub fn FontOptions::get_color_mode_raw(
  self : FontOptions,
) -> Int raise CairoError {
  check_status(font_options_status_ffi(self))
  font_options_get_color_mode_raw_ffi(self)
}

///|
pub fn FontOptions::set_color_mode(
  self : FontOptions,
  color_mode : ColorMode,
) -> Unit raise CairoError {
  check_status(font_options_set_color_mode_ffi(self, color_mode))
}

///|
pub fn FontOptions::set_color_mode_raw(
  self : FontOptions,
  color_mode : Int,
) -> Unit raise CairoError {
  check_status(font_options_set_color_mode_raw_ffi(self, color_mode))
}

///|
pub fn FontOptions::get_color_palette(
  self : FontOptions,
) -> UInt raise CairoError {
  check_status(font_options_status_ffi(self))
  font_options_get_color_palette_ffi(self)
}

///|
pub fn FontOptions::set_color_palette(
  self : FontOptions,
  palette_index : UInt,
) -> Unit raise CairoError {
  check_status(font_options_set_color_palette_ffi(self, palette_index))
}

///|
pub fn FontOptions::set_custom_palette_color(
  self : FontOptions,
  index : UInt,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Unit raise CairoError {
  check_status(
    font_options_set_custom_palette_color_ffi(
      self, index, red, green, blue, alpha,
    ),
  )
}

///|
pub fn FontOptions::get_custom_palette_color(
  self : FontOptions,
  index : UInt,
) -> (Double, Double, Double, Double) raise CairoError {
  let red = Ref(0.0)
  let green = Ref(0.0)
  let blue = Ref(0.0)
  let alpha = Ref(0.0)
  check_status(
    font_options_get_custom_palette_color_ffi(
      self, index, red, green, blue, alpha,
    ),
  )
  (red.val, green.val, blue.val, alpha.val)
}
