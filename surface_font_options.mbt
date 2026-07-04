///|
pub fn Surface::get_font_options(
  self : Surface,
) -> FontOptions raise CairoError {
  let status = Ref(Success)
  let options = surface_get_font_options_ffi(self, status)
  check_status(status.val)
  options
}
