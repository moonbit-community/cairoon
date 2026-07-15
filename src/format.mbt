///|
/// Cairo's raw sentinel for an invalid image format.
pub const FORMAT_INVALID : Int = -1

///|
/// The memory layout of pixels in an image surface.
///
/// Float formats require a Cairo build that supports them. Use
/// `stride_for_width` to obtain Cairo's required row stride.
pub(all) enum Format {
  Argb32 = 0
  Rgb24 = 1
  A8 = 2
  A1 = 3
  Rgb16_565 = 4
  Rgb30 = 5
  Rgb96F = 6
  Rgba128F = 7
} derive(Eq, Debug)

///|
fn format_from_raw(raw : Int) -> Format raise CairoError {
  match raw {
    0 => Argb32
    1 => Rgb24
    2 => A8
    3 => A1
    4 => Rgb16_565
    5 => Rgb30
    6 => Rgb96F
    7 => Rgba128F
    _ =>
      raise CairoInvalidArgument(InvalidStatus, "unknown cairo format: \{raw}")
  }
}

///|
fn Format::to_raw(self : Format) -> Int {
  match self {
    Argb32 => 0
    Rgb24 => 1
    A8 => 2
    A1 => 3
    Rgb16_565 => 4
    Rgb30 => 5
    Rgb96F => 6
    Rgba128F => 7
  }
}

///|
/// Return Cairo's required byte stride for rows of this format and width.
///
/// Cairo returns `-1` when the format or width cannot produce a valid stride.
pub fn Format::stride_for_width(self : Format, width : Int) -> Int {
  @format_impl.stride_for_width_raw(self.to_raw(), width)
}

///|
/// Return Cairo's required row stride for a raw `cairo_format_t` integer.
///
/// This compatibility entry point preserves pycairo's C-integer boundary and
/// returns `-1` for invalid input.
pub fn Format::stride_for_width_raw(format : Int, width : Int) -> Int {
  @format_impl.stride_for_width_raw(format, width)
}
