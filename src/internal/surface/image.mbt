///|
pub fn image_create_raw(format : Int, width : Int, height : Int) -> RawSurface {
  ensure_native()
  image_surface_create_raw_ffi(format, width, height)
}

///|
pub fn image_create_for_data_raw(
  data : FixedArray[Byte],
  format : Int,
  width : Int,
  height : Int,
  stride : Int,
  status : Ref[Int],
) -> RawSurface {
  ensure_native()
  image_surface_create_for_data_raw_ffi(
    data, format, width, height, stride, status,
  )
}

///|
pub fn image_get_width_raw(surface : RawSurface, status : Ref[Int]) -> Int {
  ensure_native()
  image_surface_get_width_ffi(surface, status)
}

///|
pub fn image_get_height_raw(surface : RawSurface, status : Ref[Int]) -> Int {
  ensure_native()
  image_surface_get_height_ffi(surface, status)
}

///|
pub fn image_get_stride_raw(surface : RawSurface, status : Ref[Int]) -> Int {
  ensure_native()
  image_surface_get_stride_ffi(surface, status)
}

///|
pub fn image_get_format_raw(surface : RawSurface, status : Ref[Int]) -> Int {
  ensure_native()
  image_surface_get_format_ffi(surface, status)
}

///|
pub fn image_copy_data_raw(surface : RawSurface, status : Ref[Int]) -> Bytes {
  ensure_native()
  image_surface_copy_data_ffi(surface, status)
}
