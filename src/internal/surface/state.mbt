///|
pub fn flush_raw(surface : RawSurface) -> Int {
  ensure_native()
  surface_flush_ffi(surface)
}

///|
pub fn mark_dirty_raw(surface : RawSurface) -> Int {
  ensure_native()
  surface_mark_dirty_ffi(surface)
}

///|
pub fn mark_dirty_rectangle_raw(
  surface : RawSurface,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Int {
  ensure_native()
  surface_mark_dirty_rectangle_ffi(surface, x, y, width, height)
}

///|
pub fn set_device_offset_raw(
  surface : RawSurface,
  x_offset : Double,
  y_offset : Double,
) -> Int {
  ensure_native()
  surface_set_device_offset_ffi(surface, x_offset, y_offset)
}

///|
pub fn get_device_offset_raw(
  surface : RawSurface,
  x_offset : Ref[Double],
  y_offset : Ref[Double],
) -> Int {
  ensure_native()
  surface_get_device_offset_ffi(surface, x_offset, y_offset)
}

///|
pub fn set_device_scale_raw(
  surface : RawSurface,
  x_scale : Double,
  y_scale : Double,
) -> Int {
  ensure_native()
  surface_set_device_scale_ffi(surface, x_scale, y_scale)
}

///|
pub fn get_device_scale_raw(
  surface : RawSurface,
  x_scale : Ref[Double],
  y_scale : Ref[Double],
) -> Int {
  ensure_native()
  surface_get_device_scale_ffi(surface, x_scale, y_scale)
}

///|
pub fn set_fallback_resolution_raw(
  surface : RawSurface,
  x_pixels_per_inch : Double,
  y_pixels_per_inch : Double,
) -> Int {
  ensure_native()
  surface_set_fallback_resolution_ffi(
    surface, x_pixels_per_inch, y_pixels_per_inch,
  )
}

///|
pub fn get_fallback_resolution_raw(
  surface : RawSurface,
  x_pixels_per_inch : Ref[Double],
  y_pixels_per_inch : Ref[Double],
) -> Int {
  ensure_native()
  surface_get_fallback_resolution_ffi(
    surface, x_pixels_per_inch, y_pixels_per_inch,
  )
}

///|
pub fn has_show_text_glyphs_raw(
  surface : RawSurface,
  status : Ref[Int],
) -> Bool {
  ensure_native()
  surface_has_show_text_glyphs_ffi(surface, status)
}

///|
pub fn copy_page_raw(surface : RawSurface) -> Int {
  ensure_native()
  surface_copy_page_ffi(surface)
}

///|
pub fn show_page_raw(surface : RawSurface) -> Int {
  ensure_native()
  surface_show_page_ffi(surface)
}
