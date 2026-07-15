///|
#borrow(status)
extern "C" fn recording_surface_create_raw_ffi(
  content : Int,
  has_extents : Bool,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  status : Ref[Int],
) -> RawSurface = "cairoon_recording_surface_create"

///|
#borrow(surface, x0, y0, width, height)
extern "C" fn recording_surface_ink_extents_ffi(
  surface : RawSurface,
  x0 : Ref[Double],
  y0 : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
) -> Int = "cairoon_recording_surface_ink_extents"

///|
#borrow(surface, has_extents, x, y, width, height)
extern "C" fn recording_surface_get_extents_ffi(
  surface : RawSurface,
  has_extents : Ref[Int],
  x : Ref[Double],
  y : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
) -> Int = "cairoon_recording_surface_get_extents"
