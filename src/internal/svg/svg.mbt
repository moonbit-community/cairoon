///|
pub fn get_version_count_raw(status : Ref[Int]) -> Int {
  ignore(@native.native_anchor())
  get_version_count_raw_ffi(status)
}

///|
pub fn get_version_raw(index : Int, status : Ref[Int]) -> Int {
  ignore(@native.native_anchor())
  get_version_raw_ffi(index, status)
}

///|
pub fn version_to_string_raw(version : Int, status : Ref[Int]) -> String {
  ignore(@native.native_anchor())
  @utf8.decode_lossy(version_to_string_raw_ffi(version, status))
}
