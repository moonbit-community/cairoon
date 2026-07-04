///|
#borrow(primary, status)
extern "C" fn tee_surface_create_ffi(
  primary : Surface,
  status : Ref[Status],
) -> Surface = "cairoon_tee_surface_create"

///|
#borrow(surface, target)
extern "C" fn tee_surface_add_ffi(
  surface : Surface,
  target : Surface,
) -> Status = "cairoon_tee_surface_add"

///|
#borrow(surface, target)
extern "C" fn tee_surface_remove_ffi(
  surface : Surface,
  target : Surface,
) -> Status = "cairoon_tee_surface_remove"

///|
#borrow(surface, status)
extern "C" fn tee_surface_index_ffi(
  surface : Surface,
  index : Int,
  status : Ref[Status],
) -> Surface = "cairoon_tee_surface_index"
