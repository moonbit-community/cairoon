///|
pub fn image_create_from_png_raw(
  filename : Bytes,
  status : Ref[Int],
) -> RawSurface {
  ensure_native()
  image_surface_create_from_png_ffi(filename, status)
}

///|
pub fn write_to_png_raw(surface : RawSurface, filename : Bytes) -> Int {
  ensure_native()
  surface_write_to_png_ffi(surface, filename)
}
