///|
#borrow(surface)
extern "C" fn surface_flush_ffi(surface : RawSurface) -> Int = "cairoon_surface_flush"

///|
#borrow(surface)
extern "C" fn surface_mark_dirty_ffi(surface : RawSurface) -> Int = "cairoon_surface_mark_dirty"

///|
#borrow(surface)
extern "C" fn surface_mark_dirty_rectangle_ffi(
  surface : RawSurface,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Int = "cairoon_surface_mark_dirty_rectangle"

///|
#borrow(surface)
extern "C" fn surface_set_device_offset_ffi(
  surface : RawSurface,
  x_offset : Double,
  y_offset : Double,
) -> Int = "cairoon_surface_set_device_offset"

///|
#borrow(surface, x_offset, y_offset)
extern "C" fn surface_get_device_offset_ffi(
  surface : RawSurface,
  x_offset : Ref[Double],
  y_offset : Ref[Double],
) -> Int = "cairoon_surface_get_device_offset"

///|
#borrow(surface)
extern "C" fn surface_set_device_scale_ffi(
  surface : RawSurface,
  x_scale : Double,
  y_scale : Double,
) -> Int = "cairoon_surface_set_device_scale"

///|
#borrow(surface, x_scale, y_scale)
extern "C" fn surface_get_device_scale_ffi(
  surface : RawSurface,
  x_scale : Ref[Double],
  y_scale : Ref[Double],
) -> Int = "cairoon_surface_get_device_scale"

///|
#borrow(surface)
extern "C" fn surface_set_fallback_resolution_ffi(
  surface : RawSurface,
  x_pixels_per_inch : Double,
  y_pixels_per_inch : Double,
) -> Int = "cairoon_surface_set_fallback_resolution"

///|
#borrow(surface, x_pixels_per_inch, y_pixels_per_inch)
extern "C" fn surface_get_fallback_resolution_ffi(
  surface : RawSurface,
  x_pixels_per_inch : Ref[Double],
  y_pixels_per_inch : Ref[Double],
) -> Int = "cairoon_surface_get_fallback_resolution"

///|
#borrow(surface, status)
extern "C" fn surface_has_show_text_glyphs_ffi(
  surface : RawSurface,
  status : Ref[Int],
) -> Bool = "cairoon_surface_has_show_text_glyphs"

///|
#borrow(surface)
extern "C" fn surface_copy_page_ffi(surface : RawSurface) -> Int = "cairoon_surface_copy_page"

///|
#borrow(surface)
extern "C" fn surface_show_page_ffi(surface : RawSurface) -> Int = "cairoon_surface_show_page"
