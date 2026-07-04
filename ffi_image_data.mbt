///|
#borrow(surface, status)
extern "C" fn image_surface_get_data_ffi(
  surface : Surface,
  status : Ref[Status],
) -> ImageData = "cairoon_image_surface_get_data"

///|
#borrow(surface, status)
extern "C" fn mapped_image_surface_get_data_ffi(
  surface : MappedImageSurface,
  status : Ref[Status],
) -> ImageData = "cairoon_mapped_image_surface_get_data"

///|
#borrow(data)
extern "C" fn image_data_status_ffi(data : ImageData) -> Status = "cairoon_image_data_status"

///|
#borrow(data)
extern "C" fn image_data_length_ffi(data : ImageData) -> Int = "cairoon_image_data_length"

///|
#borrow(data, status)
extern "C" fn image_data_get_ffi(
  data : ImageData,
  index : Int,
  status : Ref[Status],
) -> Byte = "cairoon_image_data_get"

///|
#borrow(data)
extern "C" fn image_data_set_ffi(
  data : ImageData,
  index : Int,
  value : Byte,
) -> Status = "cairoon_image_data_set"

///|
#borrow(data, status)
extern "C" fn image_data_copy_ffi(
  data : ImageData,
  status : Ref[Status],
) -> Bytes = "cairoon_image_data_copy"
