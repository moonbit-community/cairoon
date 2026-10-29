///|
#borrow(primary, status)
extern "C" fn tee_surface_create_ffi(
  primary : RawSurface,
  status : Ref[Int32],
) -> RawSurface = "cairoon_tee_surface_create"

///|
#borrow(surface, target)
extern "C" fn tee_surface_add_ffi(
  surface : RawSurface,
  target : RawSurface,
) -> Int32 = "cairoon_tee_surface_add"

///|
#borrow(surface, target)
extern "C" fn tee_surface_remove_ffi(
  surface : RawSurface,
  target : RawSurface,
) -> Int32 = "cairoon_tee_surface_remove"

///|
#borrow(surface, status)
extern "C" fn tee_surface_index_ffi(
  surface : RawSurface,
  index : Int32,
  status : Ref[Int32],
) -> RawSurface = "cairoon_tee_surface_index"
