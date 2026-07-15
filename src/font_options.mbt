///|
/// Owned, mutable options that control how Cairo renders fonts.
///
/// Assigning this wrapper shares the same option object; use `copy()` for an
/// independently mutable snapshot. MoonBit destroys the underlying Cairo
/// object when its final wrapper becomes unreachable. Equality and `hash()`
/// are content-based, but no generic `Hash` implementation is provided because
/// setters and `merge()` can change that content.
struct FontOptions(@font_options_impl.RawFontOptions)

///|
fn FontOptions::from_raw(
  raw : @font_options_impl.RawFontOptions,
) -> FontOptions {
  FontOptions(raw)
}

///|
fn FontOptions::to_raw(self : FontOptions) -> @font_options_impl.RawFontOptions {
  self.0
}

///|
fn font_options_status_from_raw(raw : Int) -> Status {
  status_from_raw(raw) catch {
    _ => InvalidStatus
  }
}

///|
fn check_font_options_status_raw(raw : Int) -> Unit raise CairoError {
  check_status(status_from_raw(raw))
}

///|
/// Create an owned options object with every setting at its Cairo default.
///
/// Raises `CairoMemoryError(NoMemory, _)` if Cairo cannot allocate it.
pub fn FontOptions::new() -> FontOptions raise CairoError {
  let raw = @font_options_impl.create_raw()
  check_font_options_status_raw(@font_options_impl.status_raw(raw))
  FontOptions::from_raw(raw)
}

///|
/// Return the status stored in this options object without raising it.
///
/// Public constructors and mutators check their status before returning, so
/// `Success` is expected for values obtained through the public API.
pub fn FontOptions::status(self : FontOptions) -> Status {
  font_options_status_from_raw(@font_options_impl.status_raw(self.to_raw()))
}

///|
/// Copy every current option into a new, independently mutable object.
///
/// Later mutations of either object do not affect the other. Raises the
/// source status or `CairoMemoryError(NoMemory, _)` if copying fails.
pub fn FontOptions::copy(self : FontOptions) -> FontOptions raise CairoError {
  let status = Ref(0)
  let raw = @font_options_impl.copy_raw(self.to_raw(), status)
  check_font_options_status_raw(status.val)
  check_font_options_status_raw(@font_options_impl.status_raw(raw))
  FontOptions::from_raw(raw)
}

///|
/// Merge non-default fields from `other` into this object in place.
///
/// A non-default value in `other` replaces this object's value; default fields
/// leave the corresponding destination fields unchanged. `other` is neither
/// retained nor mutated. Raises the checked status of either object or of the
/// resulting destination.
pub fn FontOptions::merge(
  self : FontOptions,
  other : FontOptions,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.merge_raw(self.to_raw(), other.to_raw()),
  )
}

///|
/// Return whether every option field in two objects has the same value.
///
/// This is content equality rather than allocation identity. Cairo reports
/// unequal if either object is in an error state.
pub fn FontOptions::equal(self : FontOptions, other : FontOptions) -> Bool {
  @font_options_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
/// Return Cairo's content hash for the current option fields.
///
/// Equal options produce matching hashes. Any setter or `merge()` may change
/// this value, so do not persist it or use a mutable object as a hash-table key.
pub fn FontOptions::hash(self : FontOptions) -> UInt64 {
  @font_options_impl.hash_raw(self.to_raw())
}

///|
pub impl Eq for FontOptions with fn equal(self, other) {
  self.equal(other)
}

///|
fn antialias_to_raw(antialias : Antialias) -> Int {
  match antialias {
    AntialiasDefault => 0
    AntialiasNone => 1
    AntialiasGray => 2
    AntialiasSubpixel => 3
    AntialiasFast => 4
    AntialiasGood => 5
    AntialiasBest => 6
  }
}

///|
/// Return the typed antialiasing mode used for text rendering.
///
/// Raises the object's checked status, or
/// `CairoInvalidArgument(InvalidStatus, _)` for an unknown raw enum value.
pub fn FontOptions::get_antialias(
  self : FontOptions,
) -> Antialias raise CairoError {
  antialias_from_raw(self.get_antialias_raw())
}

///|
/// Return the exact Cairo C integer for the antialiasing mode.
///
/// Unknown values remain observable for pycairo C-int compatibility. Raises
/// the object's checked `CairoError` status before reading the value.
pub fn FontOptions::get_antialias_raw(
  self : FontOptions,
) -> Int raise CairoError {
  check_font_options_status_raw(@font_options_impl.status_raw(self.to_raw()))
  @font_options_impl.get_antialias_raw(self.to_raw())
}

///|
/// Set the typed antialiasing mode used when Cairo renders text.
///
/// Mutates this object and raises its checked `CairoError` status on failure.
pub fn FontOptions::set_antialias(
  self : FontOptions,
  antialias : Antialias,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.set_antialias_value_raw(
      self.to_raw(),
      antialias_to_raw(antialias),
    ),
  )
}

///|
/// Set the antialiasing mode from an unvalidated Cairo C integer.
///
/// This pycairo compatibility entry point preserves unknown values; a later
/// typed getter rejects them with `CairoInvalidArgument(InvalidStatus, _)`.
/// Raises the object's checked status on failure.
pub fn FontOptions::set_antialias_raw(
  self : FontOptions,
  antialias : Int,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.set_antialias_raw(self.to_raw(), antialias),
  )
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
fn subpixel_order_to_raw(subpixel_order : SubpixelOrder) -> Int {
  match subpixel_order {
    SubpixelDefault => 0
    SubpixelRgb => 1
    SubpixelBgr => 2
    SubpixelVrgb => 3
    SubpixelVbgr => 4
  }
}

///|
/// Return the typed color-element order used for subpixel antialiasing.
///
/// Raises the object's checked status, or
/// `CairoInvalidArgument(InvalidStatus, _)` for an unknown raw enum value.
pub fn FontOptions::get_subpixel_order(
  self : FontOptions,
) -> SubpixelOrder raise CairoError {
  subpixel_order_from_raw(self.get_subpixel_order_raw())
}

///|
/// Return the exact Cairo C integer for the subpixel order.
///
/// Unknown values remain observable for pycairo C-int compatibility. Raises
/// the object's checked `CairoError` status before reading the value.
pub fn FontOptions::get_subpixel_order_raw(
  self : FontOptions,
) -> Int raise CairoError {
  check_font_options_status_raw(@font_options_impl.status_raw(self.to_raw()))
  @font_options_impl.get_subpixel_order_raw(self.to_raw())
}

///|
/// Set the typed color-element order used with `AntialiasSubpixel`.
///
/// Mutates this object and raises its checked `CairoError` status on failure.
pub fn FontOptions::set_subpixel_order(
  self : FontOptions,
  subpixel_order : SubpixelOrder,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.set_subpixel_order_value_raw(
      self.to_raw(),
      subpixel_order_to_raw(subpixel_order),
    ),
  )
}

///|
/// Set the subpixel order from an unvalidated Cairo C integer.
///
/// This pycairo compatibility entry point preserves unknown values; a later
/// typed getter rejects them with `CairoInvalidArgument(InvalidStatus, _)`.
/// Raises the object's checked status on failure.
pub fn FontOptions::set_subpixel_order_raw(
  self : FontOptions,
  subpixel_order : Int,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.set_subpixel_order_raw(self.to_raw(), subpixel_order),
  )
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
fn hint_style_to_raw(hint_style : HintStyle) -> Int {
  match hint_style {
    HintStyleDefault => 0
    HintStyleNone => 1
    HintStyleSlight => 2
    HintStyleMedium => 3
    HintStyleFull => 4
  }
}

///|
/// Return the typed strength of font-outline pixel-grid fitting.
///
/// Raises the object's checked status, or
/// `CairoInvalidArgument(InvalidStatus, _)` for an unknown raw enum value.
pub fn FontOptions::get_hint_style(
  self : FontOptions,
) -> HintStyle raise CairoError {
  hint_style_from_raw(self.get_hint_style_raw())
}

///|
/// Return the exact Cairo C integer for the outline hint style.
///
/// Unknown values remain observable for pycairo C-int compatibility. Raises
/// the object's checked `CairoError` status before reading the value.
pub fn FontOptions::get_hint_style_raw(
  self : FontOptions,
) -> Int raise CairoError {
  check_font_options_status_raw(@font_options_impl.status_raw(self.to_raw()))
  @font_options_impl.get_hint_style_raw(self.to_raw())
}

///|
/// Set how strongly Cairo fits font outlines to the device pixel grid.
///
/// Mutates this object and raises its checked `CairoError` status on failure.
pub fn FontOptions::set_hint_style(
  self : FontOptions,
  hint_style : HintStyle,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.set_hint_style_value_raw(
      self.to_raw(),
      hint_style_to_raw(hint_style),
    ),
  )
}

///|
/// Set the outline hint style from an unvalidated Cairo C integer.
///
/// This pycairo compatibility entry point preserves unknown values; a later
/// typed getter rejects them with `CairoInvalidArgument(InvalidStatus, _)`.
/// Raises the object's checked status on failure.
pub fn FontOptions::set_hint_style_raw(
  self : FontOptions,
  hint_style : Int,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.set_hint_style_raw(self.to_raw(), hint_style),
  )
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
fn hint_metrics_to_raw(hint_metrics : HintMetrics) -> Int {
  match hint_metrics {
    HintMetricsDefault => 0
    HintMetricsOff => 1
    HintMetricsOn => 2
  }
}

///|
/// Return the typed font-metrics hinting mode.
///
/// Raises the object's checked status, or
/// `CairoInvalidArgument(InvalidStatus, _)` for an unknown raw enum value.
pub fn FontOptions::get_hint_metrics(
  self : FontOptions,
) -> HintMetrics raise CairoError {
  hint_metrics_from_raw(self.get_hint_metrics_raw())
}

///|
/// Return the exact Cairo C integer for the metrics hinting mode.
///
/// Unknown values remain observable for pycairo C-int compatibility. Raises
/// the object's checked `CairoError` status before reading the value.
pub fn FontOptions::get_hint_metrics_raw(
  self : FontOptions,
) -> Int raise CairoError {
  check_font_options_status_raw(@font_options_impl.status_raw(self.to_raw()))
  @font_options_impl.get_hint_metrics_raw(self.to_raw())
}

///|
/// Set whether Cairo quantizes font metrics to integer device units.
///
/// Mutates this object and raises its checked `CairoError` status on failure.
pub fn FontOptions::set_hint_metrics(
  self : FontOptions,
  hint_metrics : HintMetrics,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.set_hint_metrics_value_raw(
      self.to_raw(),
      hint_metrics_to_raw(hint_metrics),
    ),
  )
}

///|
/// Set the metrics hinting mode from an unvalidated Cairo C integer.
///
/// This pycairo compatibility entry point preserves unknown values; a later
/// typed getter rejects them with `CairoInvalidArgument(InvalidStatus, _)`.
/// Raises the object's checked status on failure.
pub fn FontOptions::set_hint_metrics_raw(
  self : FontOptions,
  hint_metrics : Int,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.set_hint_metrics_raw(self.to_raw(), hint_metrics),
  )
}

///|
fn check_no_embedded_nul(bytes : Bytes) -> Unit raise CairoError {
  if @cstring_impl.has_embedded_nul(bytes) {
    raise CairoInvalidArgument(InvalidString, InvalidString.message())
  }
}

///|
/// Return a MoonBit copy of the OpenType variation settings, or `None`.
///
/// Requires Cairo 1.16 or newer; older versions raise
/// `CairoError(InvalidStatus, _)`. The returned string is independent of the
/// options object's internal storage.
pub fn FontOptions::get_variations(
  self : FontOptions,
) -> String? raise CairoError {
  let has_variations = Ref(0)
  let status = Ref(0)
  let bytes = @font_options_impl.get_variations_raw(
    self.to_raw(),
    has_variations,
    status,
  )
  check_font_options_status_raw(status.val)
  if has_variations.val == 0 {
    None
  } else {
    Some(@utf8.decode_lossy(bytes))
  }
}

///|
/// Set or clear OpenType variation-axis assignments.
///
/// `Some` accepts a comma-separated CSS-like string such as
/// `"wght=200,wdth=140.5"`; `None` clears all assignments. Embedded NUL bytes
/// raise `CairoInvalidArgument(InvalidString, _)` without mutation. Requires
/// Cairo 1.16 or newer; older versions raise `CairoError(InvalidStatus, _)`.
pub fn FontOptions::set_variations(
  self : FontOptions,
  variations : String?,
) -> Unit raise CairoError {
  match variations {
    None =>
      check_font_options_status_raw(
        @font_options_impl.clear_variations_raw(self.to_raw()),
      )
    Some(value) => {
      let bytes = @utf8.encode(value)
      check_no_embedded_nul(bytes)
      check_font_options_status_raw(
        @font_options_impl.set_variations_raw(self.to_raw(), bytes),
      )
    }
  }
}

///|
/// Return the typed policy for rendering color-font glyphs.
///
/// Requires Cairo 1.18 or newer; older versions raise
/// `CairoError(InvalidStatus, _)`. An unknown raw value raises
/// `CairoInvalidArgument(InvalidStatus, _)`.
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
fn color_mode_to_raw(color_mode : ColorMode) -> Int {
  match color_mode {
    ColorModeDefault => 0
    ColorModeNoColor => 1
    ColorModeColor => 2
  }
}

///|
/// Return the exact Cairo C integer for the color-font mode.
///
/// Unknown values remain observable for pycairo C-int compatibility. Requires
/// Cairo 1.18 or newer; older versions raise `CairoError(InvalidStatus, _)`.
pub fn FontOptions::get_color_mode_raw(
  self : FontOptions,
) -> Int raise CairoError {
  let status = Ref(0)
  let color_mode = @font_options_impl.get_color_mode_raw(self.to_raw(), status)
  check_font_options_status_raw(status.val)
  color_mode
}

///|
/// Set the typed policy for rendering color glyphs or outline glyphs.
///
/// Requires Cairo 1.18 or newer; older versions raise
/// `CairoError(InvalidStatus, _)` without mutating this object.
pub fn FontOptions::set_color_mode(
  self : FontOptions,
  color_mode : ColorMode,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.set_color_mode_value_raw(
      self.to_raw(),
      color_mode_to_raw(color_mode),
    ),
  )
}

///|
/// Set the color-font mode from an unvalidated Cairo C integer.
///
/// On Cairo 1.18 or newer, unknown values remain visible through the raw
/// getter and are rejected by the typed getter. Older versions raise
/// `CairoError(InvalidStatus, _)` without mutating this object.
pub fn FontOptions::set_color_mode_raw(
  self : FontOptions,
  color_mode : Int,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.set_color_mode_raw(self.to_raw(), color_mode),
  )
}

///|
/// Return the selected unsigned OpenType CPAL palette index.
///
/// New objects return `COLOR_PALETTE_DEFAULT`. Requires Cairo 1.18 or newer;
/// older versions raise `CairoError(InvalidStatus, _)`.
pub fn FontOptions::get_color_palette(
  self : FontOptions,
) -> UInt raise CairoError {
  let status = Ref(0)
  let palette = @font_options_impl.get_color_palette_raw(self.to_raw(), status)
  check_font_options_status_raw(status.val)
  palette
}

///|
/// Select an unsigned OpenType CPAL palette index.
///
/// Cairo falls back to the default palette when the selected index is invalid;
/// custom color overrides remain in effect across palette changes. Requires
/// Cairo 1.18 or newer, otherwise raises `CairoError(InvalidStatus, _)`.
pub fn FontOptions::set_color_palette(
  self : FontOptions,
  palette_index : UInt,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.set_color_palette_raw(self.to_raw(), palette_index),
  )
}

///|
/// Configure an RGBA override for OpenType palette entry `index`.
///
/// Components are passed directly to Cairo. The override is independent of
/// the selected palette and survives later `set_color_palette` calls. Requires
/// Cairo 1.18 or newer, otherwise raises `CairoError(InvalidStatus, _)`.
pub fn FontOptions::set_custom_palette_color(
  self : FontOptions,
  index : UInt,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Unit raise CairoError {
  check_font_options_status_raw(
    @font_options_impl.set_custom_palette_color_raw(
      self.to_raw(),
      index,
      red,
      green,
      blue,
      alpha,
    ),
  )
}

///|
/// Return the configured custom RGBA override for palette entry `index`.
///
/// This reads only explicit overrides, not a font's underlying palette.
/// Raises `CairoInvalidArgument(InvalidIndex, _)` when no override exists.
/// Requires Cairo 1.18 or newer; older versions instead raise
/// `CairoError(InvalidStatus, _)`.
pub fn FontOptions::get_custom_palette_color(
  self : FontOptions,
  index : UInt,
) -> (Double, Double, Double, Double) raise CairoError {
  let red = Ref(0.0)
  let green = Ref(0.0)
  let blue = Ref(0.0)
  let alpha = Ref(0.0)
  check_font_options_status_raw(
    @font_options_impl.get_custom_palette_color_raw(
      self.to_raw(),
      index,
      red,
      green,
      blue,
      alpha,
    ),
  )
  (red.val, green.val, blue.val, alpha.val)
}
