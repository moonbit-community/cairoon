///|
#borrow(surface, status)
extern "C" fn surface_get_font_options_ffi(
  surface : Surface,
  status : Ref[Status],
) -> FontOptions = "cairoon_surface_get_font_options"
