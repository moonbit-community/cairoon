///|
pub fn Surface::flush(self : Surface) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.flush_raw(self.to_raw()))
}

///|
pub fn Surface::mark_dirty(self : Surface) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.mark_dirty_raw(self.to_raw()))
}

///|
pub fn Surface::mark_dirty_rectangle(
  self : Surface,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.mark_dirty_rectangle_raw(self.to_raw(), x, y, width, height),
  )
}

///|
pub fn Surface::set_device_offset(
  self : Surface,
  x_offset : Double,
  y_offset : Double,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.set_device_offset_raw(self.to_raw(), x_offset, y_offset),
  )
}

///|
pub fn Surface::get_device_offset(
  self : Surface,
) -> (Double, Double) raise CairoError {
  let x_offset = Ref(0.0)
  let y_offset = Ref(0.0)
  check_surface_status_raw(
    @surface_impl.get_device_offset_raw(self.to_raw(), x_offset, y_offset),
  )
  (x_offset.val, y_offset.val)
}

///|
pub fn Surface::set_device_scale(
  self : Surface,
  x_scale : Double,
  y_scale : Double,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.set_device_scale_raw(self.to_raw(), x_scale, y_scale),
  )
}

///|
pub fn Surface::get_device_scale(
  self : Surface,
) -> (Double, Double) raise CairoError {
  let x_scale = Ref(0.0)
  let y_scale = Ref(0.0)
  check_surface_status_raw(
    @surface_impl.get_device_scale_raw(self.to_raw(), x_scale, y_scale),
  )
  (x_scale.val, y_scale.val)
}

///|
pub fn Surface::set_fallback_resolution(
  self : Surface,
  x_pixels_per_inch : Double,
  y_pixels_per_inch : Double,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.set_fallback_resolution_raw(
      self.to_raw(),
      x_pixels_per_inch,
      y_pixels_per_inch,
    ),
  )
}

///|
pub fn Surface::get_fallback_resolution(
  self : Surface,
) -> (Double, Double) raise CairoError {
  let x_pixels_per_inch = Ref(0.0)
  let y_pixels_per_inch = Ref(0.0)
  check_surface_status_raw(
    @surface_impl.get_fallback_resolution_raw(
      self.to_raw(),
      x_pixels_per_inch,
      y_pixels_per_inch,
    ),
  )
  (x_pixels_per_inch.val, y_pixels_per_inch.val)
}

///|
pub fn Surface::has_show_text_glyphs(self : Surface) -> Bool raise CairoError {
  let status = Ref(0)
  let has = @surface_impl.has_show_text_glyphs_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  has
}

///|
pub fn Surface::copy_page(self : Surface) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.copy_page_raw(self.to_raw()))
}

///|
pub fn Surface::show_page(self : Surface) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.show_page_raw(self.to_raw()))
}
