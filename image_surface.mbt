///|
pub fn Surface::image(
  format : Format,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let surface = image_surface_create_ffi(format, width, height)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::image_for_data(
  data : FixedArray[Byte],
  format : Format,
  width : Int,
  height : Int,
  stride? : Int = Format::stride_for_width(format, width),
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = image_surface_create_for_data_ffi(
    data, format, width, height, stride, status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::get_width(self : Surface) -> Int raise CairoError {
  let status = Ref(Success)
  let width = image_surface_get_width_ffi(self, status)
  check_status(status.val)
  width
}

///|
pub fn Surface::get_height(self : Surface) -> Int raise CairoError {
  let status = Ref(Success)
  let height = image_surface_get_height_ffi(self, status)
  check_status(status.val)
  height
}

///|
pub fn Surface::get_stride(self : Surface) -> Int raise CairoError {
  let status = Ref(Success)
  let stride = image_surface_get_stride_ffi(self, status)
  check_status(status.val)
  stride
}

///|
pub fn Surface::get_format(self : Surface) -> Format raise CairoError {
  let status = Ref(Success)
  let format = image_surface_get_format_ffi(self, status)
  check_status(status.val)
  format
}

///|
pub fn Surface::copy_data(self : Surface) -> Bytes raise CairoError {
  let status = Ref(Success)
  let bytes = image_surface_copy_data_ffi(self, status)
  check_status(status.val)
  bytes
}
