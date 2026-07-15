///|
struct ImageData(@surface_impl.RawImageData)

///|
fn ImageData::from_raw(raw : @surface_impl.RawImageData) -> ImageData {
  ImageData(raw)
}

///|
fn ImageData::to_raw(self : ImageData) -> @surface_impl.RawImageData {
  self.0
}

///|
pub fn Surface::get_data(self : Surface) -> ImageData raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.image_get_data_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.data_status_raw(raw))
  ImageData::from_raw(raw)
}

///|
pub fn MappedImageSurface::get_data(
  self : MappedImageSurface,
) -> ImageData raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.mapped_get_data_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.data_status_raw(raw))
  ImageData::from_raw(raw)
}

///|
pub fn ImageData::status(self : ImageData) -> Status {
  surface_status_from_raw(@surface_impl.data_status_raw(self.to_raw()))
}

///|
pub fn ImageData::length(self : ImageData) -> Int raise CairoError {
  check_surface_status_raw(@surface_impl.data_status_raw(self.to_raw()))
  @surface_impl.data_length_raw(self.to_raw())
}

///|
pub fn ImageData::get(self : ImageData, index : Int) -> Byte raise CairoError {
  let status = Ref(0)
  let value = @surface_impl.data_get_raw(self.to_raw(), index, status)
  check_surface_status_raw(status.val)
  value
}

///|
pub fn ImageData::set(
  self : ImageData,
  index : Int,
  value : Byte,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.data_set_raw(self.to_raw(), index, value),
  )
}

///|
pub fn ImageData::copy(self : ImageData) -> Bytes raise CairoError {
  let status = Ref(0)
  let bytes = @surface_impl.data_copy_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  bytes
}
