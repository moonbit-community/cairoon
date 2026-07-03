///|
pub fn Surface::get_data(self : Surface) -> ImageData raise CairoError {
  let status = Ref(Success)
  let data = image_surface_get_data_ffi(self, status)
  check_status(status.val)
  check_status(image_data_status_ffi(data))
  data
}

///|
pub fn MappedImageSurface::get_data(
  self : MappedImageSurface,
) -> ImageData raise CairoError {
  let status = Ref(Success)
  let data = mapped_image_surface_get_data_ffi(self, status)
  check_status(status.val)
  check_status(image_data_status_ffi(data))
  data
}

///|
pub fn ImageData::status(self : ImageData) -> Status {
  image_data_status_ffi(self)
}

///|
pub fn ImageData::length(self : ImageData) -> Int raise CairoError {
  check_status(image_data_status_ffi(self))
  image_data_length_ffi(self)
}

///|
pub fn ImageData::get(self : ImageData, index : Int) -> Byte raise CairoError {
  let status = Ref(Success)
  let value = image_data_get_ffi(self, index, status)
  check_status(status.val)
  value
}

///|
pub fn ImageData::set(
  self : ImageData,
  index : Int,
  value : Byte,
) -> Unit raise CairoError {
  check_status(image_data_set_ffi(self, index, value))
}

///|
pub fn ImageData::copy(self : ImageData) -> Bytes raise CairoError {
  let status = Ref(Success)
  let bytes = image_data_copy_ffi(self, status)
  check_status(status.val)
  bytes
}
