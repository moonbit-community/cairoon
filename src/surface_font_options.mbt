///|
pub fn Surface::get_font_options(
  self : Surface,
) -> FontOptions raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.get_font_options_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  FontOptions::from_raw(raw)
}
