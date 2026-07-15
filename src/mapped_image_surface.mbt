///|
struct MappedImageSurface(@surface_impl.RawMappedImageSurface)

///|
fn MappedImageSurface::from_raw(
  raw : @surface_impl.RawMappedImageSurface,
) -> MappedImageSurface {
  MappedImageSurface(raw)
}

///|
fn MappedImageSurface::to_raw(
  self : MappedImageSurface,
) -> @surface_impl.RawMappedImageSurface {
  self.0
}

///|
pub fn Surface::map_to_image(
  self : Surface,
  extents? : RectangleInt? = None,
) -> MappedImageSurface raise CairoError {
  let status = Ref(0)
  let raw = match extents {
    None =>
      @surface_impl.map_to_image_raw(self.to_raw(), false, 0, 0, 0, 0, status)
    Some(rect) =>
      @surface_impl.map_to_image_raw(
        self.to_raw(),
        true,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        status,
      )
  }
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.mapped_status_raw(raw))
  MappedImageSurface::from_raw(raw)
}

///|
pub fn Surface::unmap_image(
  self : Surface,
  mapped : MappedImageSurface,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.unmap_image_raw(self.to_raw(), mapped.to_raw()),
  )
}

///|
pub fn MappedImageSurface::status(self : MappedImageSurface) -> Status {
  surface_status_from_raw(@surface_impl.mapped_status_raw(self.to_raw()))
}

///|
pub fn MappedImageSurface::unmap(
  self : MappedImageSurface,
) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.mapped_unmap_raw(self.to_raw()))
}

///|
pub fn[T] MappedImageSurface::with_unmapped(
  self : MappedImageSurface,
  f : () -> T raise CairoError,
) -> T raise CairoError {
  try f() catch {
    err => {
      self.unmap()
      raise err
    }
  } noraise {
    value => {
      self.unmap()
      value
    }
  }
}

///|
pub fn MappedImageSurface::flush(
  self : MappedImageSurface,
) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.mapped_flush_raw(self.to_raw()))
}

///|
pub fn MappedImageSurface::get_width(
  self : MappedImageSurface,
) -> Int raise CairoError {
  check_surface_status_raw(@surface_impl.mapped_status_raw(self.to_raw()))
  @surface_impl.mapped_get_width_raw(self.to_raw())
}

///|
pub fn MappedImageSurface::get_height(
  self : MappedImageSurface,
) -> Int raise CairoError {
  check_surface_status_raw(@surface_impl.mapped_status_raw(self.to_raw()))
  @surface_impl.mapped_get_height_raw(self.to_raw())
}

///|
pub fn MappedImageSurface::get_stride(
  self : MappedImageSurface,
) -> Int raise CairoError {
  check_surface_status_raw(@surface_impl.mapped_status_raw(self.to_raw()))
  @surface_impl.mapped_get_stride_raw(self.to_raw())
}

///|
pub fn MappedImageSurface::get_format(
  self : MappedImageSurface,
) -> Format raise CairoError {
  format_from_raw(self.get_format_raw())
}

///|
pub fn MappedImageSurface::get_format_raw(
  self : MappedImageSurface,
) -> Int raise CairoError {
  check_surface_status_raw(@surface_impl.mapped_status_raw(self.to_raw()))
  @surface_impl.mapped_get_format_raw(self.to_raw())
}

///|
pub fn MappedImageSurface::copy_data(
  self : MappedImageSurface,
) -> Bytes raise CairoError {
  self.flush()
  check_surface_status_raw(@surface_impl.mapped_status_raw(self.to_raw()))
  @surface_impl.mapped_copy_data_raw(self.to_raw())
}
