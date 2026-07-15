///|
pub fn get_font_options_raw(
  surface : RawSurface,
  status : Ref[Int],
) -> @font_options_impl.RawFontOptions {
  ensure_native()
  surface_get_font_options_ffi(surface, status)
}
