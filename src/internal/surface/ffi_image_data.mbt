///|
type RawImageData

///|
#borrow(surface, status)
extern "C" fn image_surface_get_data_ffi(
  surface : RawSurface,
  status : Ref[Int32],
) -> RawImageData = "cairoon_image_surface_get_data"

///|
#borrow(surface, status)
extern "C" fn mapped_image_surface_get_data_ffi(
  surface : RawMappedImageSurface,
  status : Ref[Int32],
) -> RawImageData = "cairoon_mapped_image_surface_get_data"

///|
#borrow(data)
extern "C" fn image_data_status_ffi(data : RawImageData) -> Int32 = "cairoon_image_data_status"

///|
#borrow(data)
extern "C" fn image_data_length_ffi(data : RawImageData) -> Int32 = "cairoon_image_data_length"

///|
#borrow(data, status)
extern "C" fn image_data_get_ffi(
  data : RawImageData,
  index : Int32,
  status : Ref[Int32],
) -> Byte = "cairoon_image_data_get"

///|
#borrow(data)
extern "C" fn image_data_set_ffi(
  data : RawImageData,
  index : Int32,
  value : Byte,
) -> Int32 = "cairoon_image_data_set"

///|
#borrow(data, status)
extern "C" fn image_data_copy_ffi(
  data : RawImageData,
  status : Ref[Int32],
) -> Bytes = "cairoon_image_data_copy"
