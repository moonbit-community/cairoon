///|
pub fn Surface::set_mime_data(
  self : Surface,
  mime_type : String,
  data : Bytes?,
) -> Unit raise CairoError {
  let mime_type = checked_c_string_bytes(mime_type)
  match data {
    None => check_status(surface_clear_mime_data_ffi(self, mime_type))
    Some(bytes) =>
      check_status(surface_set_mime_data_ffi(self, mime_type, bytes))
  }
}

///|
pub fn Surface::get_mime_data(
  self : Surface,
  mime_type : String,
) -> Bytes? raise CairoError {
  let has_data = Ref(0)
  let status = Ref(Success)
  let bytes = surface_get_mime_data_ffi(
    self,
    checked_c_string_bytes(mime_type),
    has_data,
    status,
  )
  check_status(status.val)
  if has_data.val == 0 {
    None
  } else {
    Some(bytes)
  }
}

///|
pub fn Surface::supports_mime_type(
  self : Surface,
  mime_type : String,
) -> Bool raise CairoError {
  let status = Ref(Success)
  let supported = surface_supports_mime_type_ffi(
    self,
    checked_c_string_bytes(mime_type),
    status,
  )
  check_status(status.val)
  supported
}
