///|
pub fn recording_create_raw(
  content : Int32,
  has_extents : Bool,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
  status : Ref[Int32],
) -> RawSurface {
  ensure_native()
  recording_surface_create_raw_ffi(
    content, has_extents, x, y, width, height, status,
  )
}

///|
pub fn recording_ink_extents_raw(
  surface : RawSurface,
  x0 : Ref[Double],
  y0 : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
) -> Int32 {
  ensure_native()
  recording_surface_ink_extents_ffi(surface, x0, y0, width, height)
}

///|
pub fn recording_get_extents_raw(
  surface : RawSurface,
  has_extents : Ref[Int32],
  x : Ref[Double],
  y : Ref[Double],
  width : Ref[Double],
  height : Ref[Double],
) -> Int32 {
  ensure_native()
  recording_surface_get_extents_ffi(surface, has_extents, x, y, width, height)
}
