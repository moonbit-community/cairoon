///|
pub fn get_level_count_raw(status : Ref[Int]) -> Int {
  ignore(@native.native_anchor())
  get_level_count_raw_ffi(status)
}

///|
pub fn get_level_raw(index : Int, status : Ref[Int]) -> Int {
  ignore(@native.native_anchor())
  get_level_raw_ffi(index, status)
}

///|
pub fn level_to_string_raw(level : Int, status : Ref[Int]) -> String {
  ignore(@native.native_anchor())
  @utf8.decode_lossy(level_to_string_raw_ffi(level, status))
}
