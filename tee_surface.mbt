///|
pub fn Surface::tee(primary : Surface) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = tee_surface_create_ffi(primary, status)
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::tee_add(
  self : Surface,
  target : Surface,
) -> Unit raise CairoError {
  check_status(tee_surface_add_ffi(self, target))
}

///|
pub fn Surface::tee_remove(
  self : Surface,
  target : Surface,
) -> Unit raise CairoError {
  check_status(tee_surface_remove_ffi(self, target))
}

///|
pub fn Surface::tee_index(
  self : Surface,
  index : Int,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = tee_surface_index_ffi(self, index, status)
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}
