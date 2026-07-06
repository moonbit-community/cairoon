///|
#borrow(status)
extern "C" fn get_level_count_raw_ffi(status : Ref[Int]) -> Int = "cairoon_ps_get_level_count"

///|
#borrow(status)
extern "C" fn get_level_raw_ffi(index : Int, status : Ref[Int]) -> Int = "cairoon_ps_get_level"

///|
#borrow(status)
extern "C" fn level_to_string_raw_ffi(level : Int, status : Ref[Int]) -> Bytes = "cairoon_ps_level_to_string"
