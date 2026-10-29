///|
fn init {
  ignore(@native.oracle_native_anchor())
}

///|
#borrow(surface)
extern "C" fn test_raster_surface_owner_count_ffi(
  surface : @cairoon.Surface,
) -> Int32 = "cairoon_test_raster_surface_owner_count"

///|
#borrow(surface)
extern "C" fn test_surface_reference_count_ffi(
  surface : @cairoon.Surface,
) -> Int32 = "cairoon_test_surface_reference_count"
