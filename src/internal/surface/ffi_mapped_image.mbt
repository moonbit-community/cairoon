///|
type RawMappedImageSurface

///|
#borrow(surface, status)
extern "C" fn surface_map_to_image_ffi(
  surface : RawSurface,
  has_extents : Bool,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  status : Ref[Int],
) -> RawMappedImageSurface = "cairoon_surface_map_to_image"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_status_ffi(
  surface : RawMappedImageSurface,
) -> Int = "cairoon_mapped_image_surface_status"

///|
#borrow(surface, mapped)
extern "C" fn surface_unmap_image_ffi(
  surface : RawSurface,
  mapped : RawMappedImageSurface,
) -> Int = "cairoon_surface_unmap_image"

///|
#borrow(mapped)
extern "C" fn mapped_image_surface_unmap_ffi(
  mapped : RawMappedImageSurface,
) -> Int = "cairoon_mapped_image_surface_unmap"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_flush_ffi(
  surface : RawMappedImageSurface,
) -> Int = "cairoon_mapped_image_surface_flush"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_get_width_ffi(
  surface : RawMappedImageSurface,
) -> Int = "cairoon_mapped_image_surface_get_width"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_get_height_ffi(
  surface : RawMappedImageSurface,
) -> Int = "cairoon_mapped_image_surface_get_height"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_get_stride_ffi(
  surface : RawMappedImageSurface,
) -> Int = "cairoon_mapped_image_surface_get_stride"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_get_format_ffi(
  surface : RawMappedImageSurface,
) -> Int = "cairoon_mapped_image_surface_get_format"

///|
#borrow(surface)
extern "C" fn mapped_image_surface_copy_data_ffi(
  surface : RawMappedImageSurface,
) -> Bytes = "cairoon_mapped_image_surface_copy_data"
