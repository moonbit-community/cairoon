///|
extern "C" fn image_surface_create_ffi(
  format : Format,
  width : Int,
  height : Int,
) -> Surface = "cairoon_image_surface_create"

///|
extern "C" fn image_surface_create_raw_ffi(
  format : Int,
  width : Int,
  height : Int,
) -> Surface = "cairoon_image_surface_create"

///|
#owned(data)
#borrow(status)
extern "C" fn image_surface_create_for_data_ffi(
  data : FixedArray[Byte],
  format : Format,
  width : Int,
  height : Int,
  stride : Int,
  status : Ref[Status],
) -> Surface = "cairoon_image_surface_create_for_data"

///|
#owned(data)
#borrow(status)
extern "C" fn image_surface_create_for_data_raw_ffi(
  data : FixedArray[Byte],
  format : Int,
  width : Int,
  height : Int,
  stride : Int,
  status : Ref[Status],
) -> Surface = "cairoon_image_surface_create_for_data"

///|
#borrow(surface, status)
extern "C" fn image_surface_get_width_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Int = "cairoon_image_surface_get_width"

///|
#borrow(surface, status)
extern "C" fn image_surface_get_height_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Int = "cairoon_image_surface_get_height"

///|
#borrow(surface, status)
extern "C" fn image_surface_get_stride_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Int = "cairoon_image_surface_get_stride"

///|
#borrow(surface, status)
extern "C" fn image_surface_get_format_raw_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Int = "cairoon_image_surface_get_format"

///|
#borrow(surface, status)
extern "C" fn image_surface_copy_data_ffi(
  surface : Surface,
  status : Ref[Status],
) -> Bytes = "cairoon_image_surface_copy_data"
