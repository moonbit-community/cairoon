///|
pub fn stride_for_width_raw(format : Int, width : Int) -> Int {
  ignore(@native.native_anchor())
  format_stride_for_width_raw_ffi(format, width)
}
