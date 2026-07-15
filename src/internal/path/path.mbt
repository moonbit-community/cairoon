///|
fn ensure_native() -> Unit {
  ignore(@native.native_anchor())
}

///|
pub fn status_raw(path : RawPath) -> Int {
  ensure_native()
  path_status_ffi(path)
}

///|
pub fn equal_raw(path : RawPath, other : RawPath) -> Bool {
  ensure_native()
  path_equal_ffi(path, other)
}

///|
pub fn hash_raw(path : RawPath) -> UInt64 {
  ensure_native()
  path_hash_ffi(path)
}

///|
pub fn num_data_raw(path : RawPath, status : Ref[Int]) -> Int {
  ensure_native()
  path_num_data_ffi(path, status)
}

///|
pub fn num_segments_raw(path : RawPath, status : Ref[Int]) -> Int {
  ensure_native()
  path_num_segments_ffi(path, status)
}

///|
pub fn get_data_raw(
  path : RawPath,
  data_index : Int,
  type_ : Ref[Int],
  length : Ref[Int],
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
  x3 : Ref[Double],
  y3 : Ref[Double],
) -> Int {
  ensure_native()
  path_get_data_ffi(path, data_index, type_, length, x1, y1, x2, y2, x3, y3)
}

///|
pub fn to_string_raw(path : RawPath, status : Ref[Int]) -> Bytes {
  ensure_native()
  path_to_string_ffi(path, status)
}
