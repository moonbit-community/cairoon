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
pub fn Surface::image_for_data(
  data : FixedArray[Byte],
  format : Format,
  width : Int,
  height : Int,
  stride? : Int = Format::stride_for_width(format, width),
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = image_surface_create_for_data_ffi(
    data, format, width, height, stride, status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
fn checked_c_string_bytes(value : String) -> Bytes raise CairoError {
  let bytes = @utf8.encode(value)
  check_no_embedded_nul(bytes)
  bytes
}

///|
fn checked_path_bytes(path : String) -> Bytes raise CairoError {
  checked_c_string_bytes(path)
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
pub fn Surface::recording(
  content : Content,
  extents? : Rectangle? = None,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = match extents {
    None =>
      recording_surface_create_ffi(content, false, 0.0, 0.0, 0.0, 0.0, status)
    Some(rect) =>
      recording_surface_create_ffi(
        content,
        true,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        status,
      )
  }
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::create_similar(
  self : Surface,
  content : Content,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = surface_create_similar_ffi(self, content, width, height, status)
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::create_similar_image(
  self : Surface,
  format : Format,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = surface_create_similar_image_ffi(
    self, format, width, height, status,
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
pub fn Surface::get_content(self : Surface) -> Content raise CairoError {
  check_status(surface_status_ffi(self))
  surface_get_content_ffi(self)
}

///|
pub fn Surface::get_type(self : Surface) -> SurfaceType raise CairoError {
  check_status(surface_status_ffi(self))
  surface_get_type_ffi(self)
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
pub fn Surface::recording_ink_extents(
  self : Surface,
) -> Rectangle raise CairoError {
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  let width = Ref(0.0)
  let height = Ref(0.0)
  check_status(recording_surface_ink_extents_ffi(self, x0, y0, width, height))
  Rectangle::new(x0.val, y0.val, width.val, height.val)
}

///|
pub fn Surface::recording_get_extents(
  self : Surface,
) -> Rectangle? raise CairoError {
  let has_extents = Ref(0)
  let x = Ref(0.0)
  let y = Ref(0.0)
  let width = Ref(0.0)
  let height = Ref(0.0)
  check_status(
    recording_surface_get_extents_ffi(self, has_extents, x, y, width, height),
  )
  if has_extents.val == 0 {
    None
  } else {
    Some(Rectangle::new(x.val, y.val, width.val, height.val))
  }
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

///|
pub fn Surface::write_to_png(
  self : Surface,
  path : String,
) -> Unit raise CairoError {
  check_status(surface_write_to_png_ffi(self, checked_path_bytes(path)))
}

///|
pub fn Surface::set_mime_data(
  self : Surface,
  mime_type : String,
  data : Bytes?,
) -> Unit raise CairoError {
  let mime_type = checked_c_string_bytes(mime_type)
  match data {
    None => check_status(surface_clear_mime_data_ffi(self, mime_type))
    Some(bytes) =>
      check_status(surface_set_mime_data_ffi(self, mime_type, bytes))
  }
}

///|
pub fn Surface::get_mime_data(
  self : Surface,
  mime_type : String,
) -> Bytes? raise CairoError {
  let has_data = Ref(0)
  let status = Ref(Success)
  let bytes = surface_get_mime_data_ffi(
    self,
    checked_c_string_bytes(mime_type),
    has_data,
    status,
  )
  check_status(status.val)
  if has_data.val == 0 {
    None
  } else {
    Some(bytes)
  }
}

///|
pub fn Surface::supports_mime_type(
  self : Surface,
  mime_type : String,
) -> Bool raise CairoError {
  let status = Ref(Success)
  let supported = surface_supports_mime_type_ffi(
    self,
    checked_c_string_bytes(mime_type),
    status,
  )
  check_status(status.val)
  supported
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
