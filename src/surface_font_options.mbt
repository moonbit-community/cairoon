///|
/// Return an independent copy of this surface's default font options.
///
/// Display backends can report subpixel order while print backends can adjust
/// hinting. The returned `FontOptions` owns its own Cairo options object and
/// may be mutated without changing the surface. Failed or finished surfaces
/// raise checked `CairoError`.
pub fn Surface::get_font_options(
  self : Surface,
) -> FontOptions raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.get_font_options_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  FontOptions::from_raw(raw)
}
