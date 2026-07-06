///|
#borrow(surface)
extern "C" fn test_raster_surface_owner_count_ffi(
  surface : @cairoon.Surface,
) -> Int = "cairoon_test_raster_surface_owner_count"
