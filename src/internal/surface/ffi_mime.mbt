///|
#borrow(surface, mime_type, data)
extern "C" fn surface_set_mime_data_ffi(
  surface : RawSurface,
  mime_type : Bytes,
  data : Bytes,
) -> Int = "cairoon_surface_set_mime_data"

///|
#borrow(surface, mime_type)
extern "C" fn surface_clear_mime_data_ffi(
  surface : RawSurface,
  mime_type : Bytes,
) -> Int = "cairoon_surface_clear_mime_data"

///|
#borrow(surface, mime_type, has_data, status)
extern "C" fn surface_get_mime_data_ffi(
  surface : RawSurface,
  mime_type : Bytes,
  has_data : Ref[Int],
  status : Ref[Int],
) -> Bytes = "cairoon_surface_get_mime_data"

///|
#borrow(surface, mime_type, status)
extern "C" fn surface_supports_mime_type_ffi(
  surface : RawSurface,
  mime_type : Bytes,
  status : Ref[Int],
) -> Bool = "cairoon_surface_supports_mime_type"
