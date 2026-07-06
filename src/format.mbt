///|
pub const FORMAT_INVALID : Int = -1

///|
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
pub fn Format::stride_for_width(self : Format, width : Int) -> Int {
  format_stride_for_width_ffi(self, width)
}

///|
pub fn Format::stride_for_width_raw(format : Int, width : Int) -> Int {
  format_stride_for_width_raw_ffi(format, width)
}
