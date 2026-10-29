///|
pub fn stride_for_width_raw(format : Int32, width : Int32) -> Int32 {
  ignore(@native.native_anchor())
  format_stride_for_width_raw_ffi(format, width)
}
