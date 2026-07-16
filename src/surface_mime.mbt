///|
/// Attach or remove alternate encoded image data for a MIME type.
///
/// `Some(data)` copies every byte into Cairo-owned storage; later MoonBit
/// mutation cannot change it. `None` removes the entry. The MIME string is
/// UTF-8 encoded and embedded NUL raises
/// `CairoInvalidArgument(InvalidString, _)`. Replacement, allocation, and
/// finished-surface failures use the checked `CairoError` hierarchy.
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
/// Copy attached bytes for `mime_type`, or return `None` when absent.
///
/// Each successful result is newly MoonBit-owned and remains valid after the
/// surface changes or is destroyed. The MIME string must not contain embedded
/// NUL. Invalid strings and failed or finished surfaces raise checked
/// `CairoError`.
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
/// Return whether this surface backend can consume `mime_type` directly.
///
/// Support is backend-specific, for example PDF may embed JPEG data while an
/// image surface commonly reports no such output capability. The UTF-8 MIME
/// string must not contain NUL. Invalid strings and surface failures raise
/// checked `CairoError`.
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
