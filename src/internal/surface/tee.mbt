///|
pub fn tee_create_raw(primary : RawSurface, status : Ref[Int]) -> RawSurface {
  ensure_native()
  tee_surface_create_ffi(primary, status)
}

///|
pub fn tee_add_raw(surface : RawSurface, target : RawSurface) -> Int {
  ensure_native()
  tee_surface_add_ffi(surface, target)
}

///|
pub fn tee_remove_raw(surface : RawSurface, target : RawSurface) -> Int {
  ensure_native()
  tee_surface_remove_ffi(surface, target)
}

///|
pub fn tee_index_raw(
  surface : RawSurface,
  index : Int,
  status : Ref[Int],
) -> RawSurface {
  ensure_native()
  tee_surface_index_ffi(surface, index, status)
}
