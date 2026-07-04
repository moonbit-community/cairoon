///|
#borrow(surface, mime_type, data)
extern "C" fn surface_set_mime_data_ffi(
  surface : Surface,
  mime_type : Bytes,
  data : Bytes,
) -> Status = "cairoon_surface_set_mime_data"

///|
#borrow(surface, mime_type)
extern "C" fn surface_clear_mime_data_ffi(
  surface : Surface,
  mime_type : Bytes,
) -> Status = "cairoon_surface_clear_mime_data"

///|
#borrow(surface, mime_type, has_data, status)
extern "C" fn surface_get_mime_data_ffi(
  surface : Surface,
  mime_type : Bytes,
  has_data : Ref[Int],
  status : Ref[Status],
) -> Bytes = "cairoon_surface_get_mime_data"

///|
#borrow(surface, mime_type, status)
extern "C" fn surface_supports_mime_type_ffi(
  surface : Surface,
  mime_type : Bytes,
  status : Ref[Status],
) -> Bool = "cairoon_surface_supports_mime_type"
