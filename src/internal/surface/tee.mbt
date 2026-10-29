///|
pub fn tee_create_raw(primary : RawSurface, status : Ref[Int32]) -> RawSurface {
  ensure_native()
  tee_surface_create_ffi(primary, status)
}

///|
pub fn tee_add_raw(surface : RawSurface, target : RawSurface) -> Int32 {
  ensure_native()
  tee_surface_add_ffi(surface, target)
}

///|
pub fn tee_remove_raw(surface : RawSurface, target : RawSurface) -> Int32 {
  ensure_native()
  tee_surface_remove_ffi(surface, target)
}

///|
pub fn tee_index_raw(
  surface : RawSurface,
  index : Int32,
  status : Ref[Int32],
) -> RawSurface {
  ensure_native()
  tee_surface_index_ffi(surface, index, status)
}
