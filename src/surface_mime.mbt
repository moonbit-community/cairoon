///|
pub fn Surface::set_mime_data(
  self : Surface,
  mime_type : String,
  data : Bytes?,
) -> Unit raise CairoError {
  let mime_type = checked_c_string_bytes(mime_type)
  match data {
    None =>
      check_surface_status_raw(
        @surface_impl.clear_mime_data_raw(self.to_raw(), mime_type),
      )
    Some(bytes) =>
      check_surface_status_raw(
        @surface_impl.set_mime_data_raw(self.to_raw(), mime_type, bytes),
      )
  }
}

///|
pub fn Surface::get_mime_data(
  self : Surface,
  mime_type : String,
) -> Bytes? raise CairoError {
  let has_data = Ref(0)
  let status = Ref(0)
  let bytes = @surface_impl.get_mime_data_raw(
    self.to_raw(),
    checked_c_string_bytes(mime_type),
    has_data,
    status,
  )
  check_surface_status_raw(status.val)
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
  let status = Ref(0)
  let supported = @surface_impl.supports_mime_type_raw(
    self.to_raw(),
    checked_c_string_bytes(mime_type),
    status,
  )
  check_surface_status_raw(status.val)
  supported
}
