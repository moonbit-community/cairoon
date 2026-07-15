///|
pub fn Surface::tee(primary : Surface) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.tee_create_raw(primary.to_raw(), status)
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
pub fn Surface::tee_add(
  self : Surface,
  target : Surface,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.tee_add_raw(self.to_raw(), target.to_raw()),
  )
}

///|
pub fn Surface::tee_remove(
  self : Surface,
  target : Surface,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.tee_remove_raw(self.to_raw(), target.to_raw()),
  )
}

///|
pub fn Surface::tee_index(
  self : Surface,
  index : Int,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.tee_index_raw(self.to_raw(), index, status)
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}
