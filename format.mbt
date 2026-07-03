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
pub fn Format::stride_for_width(self : Format, width : Int) -> Int {
  format_stride_for_width_ffi(self, width)
}
