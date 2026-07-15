///|
pub fn map_to_image_raw(
  surface : RawSurface,
  has_extents : Bool,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  status : Ref[Int],
) -> RawMappedImageSurface {
  ensure_native()
  surface_map_to_image_ffi(surface, has_extents, x, y, width, height, status)
}

///|
pub fn mapped_status_raw(surface : RawMappedImageSurface) -> Int {
  ensure_native()
  mapped_image_surface_status_ffi(surface)
}

///|
pub fn unmap_image_raw(
  surface : RawSurface,
  mapped : RawMappedImageSurface,
) -> Int {
  ensure_native()
  surface_unmap_image_ffi(surface, mapped)
}

///|
pub fn mapped_unmap_raw(mapped : RawMappedImageSurface) -> Int {
  ensure_native()
  mapped_image_surface_unmap_ffi(mapped)
}

///|
pub fn mapped_flush_raw(surface : RawMappedImageSurface) -> Int {
  ensure_native()
  mapped_image_surface_flush_ffi(surface)
}

///|
pub fn mapped_get_width_raw(surface : RawMappedImageSurface) -> Int {
  ensure_native()
  mapped_image_surface_get_width_ffi(surface)
}

///|
pub fn mapped_get_height_raw(surface : RawMappedImageSurface) -> Int {
  ensure_native()
  mapped_image_surface_get_height_ffi(surface)
}

///|
pub fn mapped_get_stride_raw(surface : RawMappedImageSurface) -> Int {
  ensure_native()
  mapped_image_surface_get_stride_ffi(surface)
}

///|
pub fn mapped_get_format_raw(surface : RawMappedImageSurface) -> Int {
  ensure_native()
  mapped_image_surface_get_format_ffi(surface)
}

///|
pub fn mapped_copy_data_raw(surface : RawMappedImageSurface) -> Bytes {
  ensure_native()
  mapped_image_surface_copy_data_ffi(surface)
}
