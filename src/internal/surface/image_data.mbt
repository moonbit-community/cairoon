///|
pub fn image_get_data_raw(
  surface : RawSurface,
  status : Ref[Int],
) -> RawImageData {
  ensure_native()
  image_surface_get_data_ffi(surface, status)
}

///|
pub fn mapped_get_data_raw(
  surface : RawMappedImageSurface,
  status : Ref[Int],
) -> RawImageData {
  ensure_native()
  mapped_image_surface_get_data_ffi(surface, status)
}

///|
pub fn data_status_raw(data : RawImageData) -> Int {
  ensure_native()
  image_data_status_ffi(data)
}

///|
pub fn data_length_raw(data : RawImageData) -> Int {
  ensure_native()
  image_data_length_ffi(data)
}

///|
pub fn data_get_raw(
  data : RawImageData,
  index : Int,
  status : Ref[Int],
) -> Byte {
  ensure_native()
  image_data_get_ffi(data, index, status)
}

///|
pub fn data_set_raw(data : RawImageData, index : Int, value : Byte) -> Int {
  ensure_native()
  image_data_set_ffi(data, index, value)
}

///|
pub fn data_copy_raw(data : RawImageData, status : Ref[Int]) -> Bytes {
  ensure_native()
  image_data_copy_ffi(data, status)
}
