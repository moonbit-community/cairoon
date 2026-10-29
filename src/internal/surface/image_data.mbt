///|
pub fn image_get_data_raw(
  surface : RawSurface,
  status : Ref[Int32],
) -> RawImageData {
  ensure_native()
  image_surface_get_data_ffi(surface, status)
}

///|
pub fn mapped_get_data_raw(
  surface : RawMappedImageSurface,
  status : Ref[Int32],
) -> RawImageData {
  ensure_native()
  mapped_image_surface_get_data_ffi(surface, status)
}

///|
pub fn data_status_raw(data : RawImageData) -> Int32 {
  ensure_native()
  image_data_status_ffi(data)
}

///|
pub fn data_length_raw(data : RawImageData) -> Int32 {
  ensure_native()
  image_data_length_ffi(data)
}

///|
pub fn data_get_raw(
  data : RawImageData,
  index : Int32,
  status : Ref[Int32],
) -> Byte {
  ensure_native()
  image_data_get_ffi(data, index, status)
}

///|
pub fn data_set_raw(data : RawImageData, index : Int32, value : Byte) -> Int32 {
  ensure_native()
  image_data_set_ffi(data, index, value)
}

///|
pub fn data_copy_raw(data : RawImageData, status : Ref[Int32]) -> Bytes {
  ensure_native()
  image_data_copy_ffi(data, status)
}
