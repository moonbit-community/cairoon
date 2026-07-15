///|
pub fn set_mime_data_raw(
  surface : RawSurface,
  mime_type : Bytes,
  data : Bytes,
) -> Int {
  ensure_native()
  surface_set_mime_data_ffi(surface, mime_type, data)
}

///|
pub fn clear_mime_data_raw(surface : RawSurface, mime_type : Bytes) -> Int {
  ensure_native()
  surface_clear_mime_data_ffi(surface, mime_type)
}

///|
pub fn get_mime_data_raw(
  surface : RawSurface,
  mime_type : Bytes,
  has_data : Ref[Int],
  status : Ref[Int],
) -> Bytes {
  ensure_native()
  surface_get_mime_data_ffi(surface, mime_type, has_data, status)
}

///|
pub fn supports_mime_type_raw(
  surface : RawSurface,
  mime_type : Bytes,
  status : Ref[Int],
) -> Bool {
  ensure_native()
  surface_supports_mime_type_ffi(surface, mime_type, status)
}
