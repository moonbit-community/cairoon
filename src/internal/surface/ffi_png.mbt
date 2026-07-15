///|
#borrow(filename, status)
extern "C" fn image_surface_create_from_png_ffi(
  filename : Bytes,
  status : Ref[Int],
) -> RawSurface = "cairoon_image_surface_create_from_png"

///|
#borrow(surface, filename)
extern "C" fn surface_write_to_png_ffi(
  surface : RawSurface,
  filename : Bytes,
) -> Int = "cairoon_surface_write_to_png"
