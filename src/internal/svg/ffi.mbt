///|
#borrow(status)
extern "C" fn get_version_count_raw_ffi(status : Ref[Int32]) -> Int32 = "cairoon_svg_get_version_count"

///|
#borrow(status)
extern "C" fn get_version_raw_ffi(index : Int32, status : Ref[Int32]) -> Int32 = "cairoon_svg_get_version"

///|
#borrow(status)
extern "C" fn version_to_string_raw_ffi(
  version : Int32,
  status : Ref[Int32],
) -> Bytes = "cairoon_svg_version_to_string"
