///|
#borrow(status)
extern "C" fn get_version_count_raw_ffi(status : Ref[Int]) -> Int = "cairoon_pdf_get_version_count"

///|
#borrow(status)
extern "C" fn get_version_raw_ffi(index : Int, status : Ref[Int]) -> Int = "cairoon_pdf_get_version"

///|
#borrow(status)
extern "C" fn version_to_string_raw_ffi(
  version : Int,
  status : Ref[Int],
) -> Bytes = "cairoon_pdf_version_to_string"
