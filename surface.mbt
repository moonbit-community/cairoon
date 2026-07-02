///|
pub fn Surface::image(
  format : Format,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let surface = image_surface_create_ffi(format, width, height)
  check_status(surface_status_ffi(surface))
  surface
}

///|
fn checked_path_bytes(path : String) -> Bytes raise CairoError {
  let bytes = @utf8.encode(path)
  check_no_embedded_nul(bytes)
  bytes
}

///|
pub fn Surface::image_from_png(path : String) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = image_surface_create_from_png_ffi(
    checked_path_bytes(path),
    status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::status(self : Surface) -> Status {
  surface_status_ffi(self)
}

///|
pub fn Surface::finish(self : Surface) -> Unit raise CairoError {
  check_status(surface_finish_ffi(self))
}

///|
pub fn Surface::flush(self : Surface) -> Unit raise CairoError {
  check_status(surface_flush_ffi(self))
}

///|
pub fn Surface::copy_page(self : Surface) -> Unit raise CairoError {
  check_status(surface_copy_page_ffi(self))
}

///|
pub fn Surface::show_page(self : Surface) -> Unit raise CairoError {
  check_status(surface_show_page_ffi(self))
}

///|
pub fn Surface::write_to_png(
  self : Surface,
  path : String,
) -> Unit raise CairoError {
  check_status(surface_write_to_png_ffi(self, checked_path_bytes(path)))
}

///|
pub fn Surface::get_width(self : Surface) -> Int {
  image_surface_get_width_ffi(self)
}

///|
pub fn Surface::get_height(self : Surface) -> Int {
  image_surface_get_height_ffi(self)
}

///|
pub fn Surface::get_stride(self : Surface) -> Int {
  image_surface_get_stride_ffi(self)
}

///|
pub fn Surface::get_format(self : Surface) -> Format {
  image_surface_get_format_ffi(self)
}

///|
pub fn Surface::copy_data(self : Surface) -> Bytes raise CairoError {
  self.flush()
  check_status(surface_status_ffi(self))
  image_surface_copy_data_ffi(self)
}

///|
pub fn Surface::get_font_options(
  self : Surface,
) -> FontOptions raise CairoError {
  let status = Ref(Success)
  let options = surface_get_font_options_ffi(self, status)
  check_status(status.val)
  options
}
