///|
#borrow(status)
extern "C" fn recording_surface_create_ffi(
  content : Content,
  has_extents : Bool,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  status : Ref[Status],
) -> Surface = "cairoon_recording_surface_create"

///|
#borrow(surface, x0, y0, width, height)
extern "C" fn recording_surface_ink_extents_ffi(
  surface : Surface,
  x0 : Ref[Double],
  y0 : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
) -> Status = "cairoon_recording_surface_ink_extents"

///|
#borrow(surface, has_extents, x, y, width, height)
extern "C" fn recording_surface_get_extents_ffi(
  surface : Surface,
  has_extents : Ref[Int],
  x : Ref[Double],
  y : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
) -> Status = "cairoon_recording_surface_get_extents"
