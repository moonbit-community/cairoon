///|
#borrow(surface, status)
extern "C" fn surface_get_font_options_ffi(
  surface : Surface,
  status : Ref[Status],
) -> @font_options_impl.RawFontOptions = "cairoon_surface_get_font_options"
