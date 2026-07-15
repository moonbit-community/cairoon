///|
pub fn Surface::image(
  format : Format,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let raw = @surface_impl.image_create_raw(format.to_raw(), width, height)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::image_raw(
  format : Int,
  width : Int,
  height : Int,
) -> Surface raise CairoError {
  let raw = @surface_impl.image_create_raw(format, width, height)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::image_for_data(
  data : FixedArray[Byte],
  format : Format,
  width : Int,
  height : Int,
  stride? : Int = Format::stride_for_width(format, width),
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.image_create_for_data_raw(
    data,
    format.to_raw(),
    width,
    height,
    stride,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::image_for_data_raw(
  data : FixedArray[Byte],
  format : Int,
  width : Int,
  height : Int,
  stride? : Int,
) -> Surface raise CairoError {
  let actual_stride = match stride {
    Some(stride) => stride
    None => {
      let calculated = Format::stride_for_width_raw(format, width)
      if calculated < 0 {
        raise CairoInvalidArgument(InvalidFormat, InvalidFormat.message())
      }
      calculated
    }
  }
  let status = Ref(0)
  let raw = @surface_impl.image_create_for_data_raw(
    data, format, width, height, actual_stride, status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::get_width(self : Surface) -> Int raise CairoError {
  let status = Ref(0)
  let width = @surface_impl.image_get_width_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  width
}

///|
pub fn Surface::get_height(self : Surface) -> Int raise CairoError {
  let status = Ref(0)
  let height = @surface_impl.image_get_height_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  height
}

///|
pub fn Surface::get_stride(self : Surface) -> Int raise CairoError {
  let status = Ref(0)
  let stride = @surface_impl.image_get_stride_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  stride
}

///|
pub fn Surface::get_format(self : Surface) -> Format raise CairoError {
  format_from_raw(self.get_format_raw())
}

///|
pub fn Surface::get_format_raw(self : Surface) -> Int raise CairoError {
  let status = Ref(0)
  let format = @surface_impl.image_get_format_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  format
}

///|
pub fn Surface::copy_data(self : Surface) -> Bytes raise CairoError {
  let status = Ref(0)
  let bytes = @surface_impl.image_copy_data_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  bytes
}
