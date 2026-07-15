///|
#borrow(surface, status)
extern "C" fn surface_get_font_options_ffi(
  surface : RawSurface,
  status : Ref[Int],
) -> @font_options_impl.RawFontOptions = "cairoon_surface_get_font_options"
