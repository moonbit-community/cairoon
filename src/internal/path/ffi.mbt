///|
type RawPath

///|
#borrow(path)
extern "C" fn path_status_ffi(path : RawPath) -> Int32 = "cairoon_path_status"

///|
#borrow(path, other)
extern "C" fn path_equal_ffi(path : RawPath, other : RawPath) -> Bool = "cairoon_path_equal"

///|
#borrow(path)
extern "C" fn path_hash_ffi(path : RawPath) -> UInt64 = "cairoon_path_hash"

///|
#borrow(path, status)
extern "C" fn path_num_data_ffi(path : RawPath, status : Ref[Int32]) -> Int32 = "cairoon_path_num_data"

///|
#borrow(path, status)
extern "C" fn path_num_segments_ffi(
  path : RawPath,
  status : Ref[Int32],
) -> Int32 = "cairoon_path_num_segments"

///|
#borrow(path, type_, length, x1, y1, x2, y2, x3, y3)
extern "C" fn path_get_data_ffi(
  path : RawPath,
  data_index : Int32,
  type_ : Ref[Int32],
  length : Ref[Int32],
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
  x3 : Ref[Double],
  y3 : Ref[Double],
) -> Int32 = "cairoon_path_get_data"

///|
#borrow(path, status)
extern "C" fn path_to_string_ffi(path : RawPath, status : Ref[Int32]) -> Bytes = "cairoon_path_to_string"
