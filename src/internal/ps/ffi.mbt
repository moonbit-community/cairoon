///|
#borrow(status)
extern "C" fn get_level_count_raw_ffi(status : Ref[Int32]) -> Int32 = "cairoon_ps_get_level_count"

///|
#borrow(status)
extern "C" fn get_level_raw_ffi(index : Int32, status : Ref[Int32]) -> Int32 = "cairoon_ps_get_level"

///|
#borrow(status)
extern "C" fn level_to_string_raw_ffi(
  level : Int32,
  status : Ref[Int32],
) -> Bytes = "cairoon_ps_level_to_string"
