///|
pub fn Surface::map_to_image(
  self : Surface,
  extents? : RectangleInt? = None,
) -> MappedImageSurface raise CairoError {
  let status = Ref(Success)
  let mapped = match extents {
    None => surface_map_to_image_ffi(self, false, 0, 0, 0, 0, status)
    Some(rect) =>
      surface_map_to_image_ffi(
        self,
        true,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        status,
      )
  }
  check_status(status.val)
  check_status(mapped_image_surface_status_ffi(mapped))
  mapped
}

///|
pub fn Surface::unmap_image(
  self : Surface,
  mapped : MappedImageSurface,
) -> Unit raise CairoError {
  check_status(surface_unmap_image_ffi(self, mapped))
}

///|
pub fn MappedImageSurface::status(self : MappedImageSurface) -> Status {
  mapped_image_surface_status_ffi(self)
}

///|
pub fn MappedImageSurface::unmap(
  self : MappedImageSurface,
) -> Unit raise CairoError {
  check_status(mapped_image_surface_unmap_ffi(self))
}

///|
pub fn MappedImageSurface::flush(
  self : MappedImageSurface,
) -> Unit raise CairoError {
  check_status(mapped_image_surface_flush_ffi(self))
}

///|
pub fn MappedImageSurface::get_width(
  self : MappedImageSurface,
) -> Int raise CairoError {
  check_status(mapped_image_surface_status_ffi(self))
  mapped_image_surface_get_width_ffi(self)
}

///|
pub fn MappedImageSurface::get_height(
  self : MappedImageSurface,
) -> Int raise CairoError {
  check_status(mapped_image_surface_status_ffi(self))
  mapped_image_surface_get_height_ffi(self)
}

///|
pub fn MappedImageSurface::get_stride(
  self : MappedImageSurface,
) -> Int raise CairoError {
  check_status(mapped_image_surface_status_ffi(self))
  mapped_image_surface_get_stride_ffi(self)
}

///|
pub fn MappedImageSurface::get_format(
  self : MappedImageSurface,
) -> Format raise CairoError {
  check_status(mapped_image_surface_status_ffi(self))
  mapped_image_surface_get_format_ffi(self)
}

///|
pub fn MappedImageSurface::copy_data(
  self : MappedImageSurface,
) -> Bytes raise CairoError {
  self.flush()
  check_status(mapped_image_surface_status_ffi(self))
  mapped_image_surface_copy_data_ffi(self)
}
