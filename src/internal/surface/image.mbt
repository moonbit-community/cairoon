///|
pub fn image_create_raw(
  format : Int32,
  width : Int32,
  height : Int32,
) -> RawSurface {
  ensure_native()
  image_surface_create_raw_ffi(format, width, height)
}

///|
pub fn image_create_for_data_raw(
  data : FixedArray[Byte],
  format : Int32,
  width : Int32,
  height : Int32,
  stride : Int32,
  status : Ref[Int32],
) -> RawSurface {
  ensure_native()
  image_surface_create_for_data_raw_ffi(
    data, format, width, height, stride, status,
  )
}

///|
pub fn image_get_width_raw(surface : RawSurface, status : Ref[Int32]) -> Int32 {
  ensure_native()
  image_surface_get_width_ffi(surface, status)
}

///|
pub fn image_get_height_raw(surface : RawSurface, status : Ref[Int32]) -> Int32 {
  ensure_native()
  image_surface_get_height_ffi(surface, status)
}

///|
pub fn image_get_stride_raw(surface : RawSurface, status : Ref[Int32]) -> Int32 {
  ensure_native()
  image_surface_get_stride_ffi(surface, status)
}

///|
pub fn image_get_format_raw(surface : RawSurface, status : Ref[Int32]) -> Int32 {
  ensure_native()
  image_surface_get_format_ffi(surface, status)
}

///|
pub fn image_copy_data_raw(surface : RawSurface, status : Ref[Int32]) -> Bytes {
  ensure_native()
  image_surface_copy_data_ffi(surface, status)
}
