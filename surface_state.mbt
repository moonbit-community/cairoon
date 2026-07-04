///|
pub fn Surface::flush(self : Surface) -> Unit raise CairoError {
  check_status(surface_flush_ffi(self))
}

///|
pub fn Surface::mark_dirty(self : Surface) -> Unit raise CairoError {
  check_status(surface_mark_dirty_ffi(self))
}

///|
pub fn Surface::mark_dirty_rectangle(
  self : Surface,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit raise CairoError {
  check_status(surface_mark_dirty_rectangle_ffi(self, x, y, width, height))
}

///|
pub fn Surface::set_device_offset(
  self : Surface,
  x_offset : Double,
  y_offset : Double,
) -> Unit raise CairoError {
  check_status(surface_set_device_offset_ffi(self, x_offset, y_offset))
}

///|
pub fn Surface::get_device_offset(
  self : Surface,
) -> (Double, Double) raise CairoError {
  let x_offset = Ref(0.0)
  let y_offset = Ref(0.0)
  check_status(surface_get_device_offset_ffi(self, x_offset, y_offset))
  (x_offset.val, y_offset.val)
}

///|
pub fn Surface::set_device_scale(
  self : Surface,
  x_scale : Double,
  y_scale : Double,
) -> Unit raise CairoError {
  check_status(surface_set_device_scale_ffi(self, x_scale, y_scale))
}

///|
pub fn Surface::get_device_scale(
  self : Surface,
) -> (Double, Double) raise CairoError {
  let x_scale = Ref(0.0)
  let y_scale = Ref(0.0)
  check_status(surface_get_device_scale_ffi(self, x_scale, y_scale))
  (x_scale.val, y_scale.val)
}

///|
pub fn Surface::set_fallback_resolution(
  self : Surface,
  x_pixels_per_inch : Double,
  y_pixels_per_inch : Double,
) -> Unit raise CairoError {
  check_status(
    surface_set_fallback_resolution_ffi(
      self, x_pixels_per_inch, y_pixels_per_inch,
    ),
  )
}

///|
pub fn Surface::get_fallback_resolution(
  self : Surface,
) -> (Double, Double) raise CairoError {
  let x_pixels_per_inch = Ref(0.0)
  let y_pixels_per_inch = Ref(0.0)
  check_status(
    surface_get_fallback_resolution_ffi(
      self, x_pixels_per_inch, y_pixels_per_inch,
    ),
  )
  (x_pixels_per_inch.val, y_pixels_per_inch.val)
}

///|
pub fn Surface::has_show_text_glyphs(self : Surface) -> Bool raise CairoError {
  let status = Ref(Success)
  let has = surface_has_show_text_glyphs_ffi(self, status)
  check_status(status.val)
  has
}

///|
pub fn Surface::copy_page(self : Surface) -> Unit raise CairoError {
  check_status(surface_copy_page_ffi(self))
}

///|
pub fn Surface::show_page(self : Surface) -> Unit raise CairoError {
  check_status(surface_show_page_ffi(self))
}
