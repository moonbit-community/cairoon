///|
/// Create an owning tee surface whose index-zero target is `primary`.
///
/// Drawing through the result is forwarded to the primary and every added
/// replica. The primary controls queried content, device, font options, and
/// extents. Cairoon retains the primary MoonBit wrapper until the tee is
/// collected. This requires `CAIRO_HAS_TEE_SURFACE` (Cairo 1.10 or newer); an
/// unavailable backend, a finished/error primary, or construction failure
/// raises a checked `CairoError`.
pub fn Surface::tee(primary : Surface) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.tee_create_raw(primary.to_raw(), status)
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Append a drawing target to this tee surface.
///
/// A successful call creates both Cairo's native target reference and a
/// retained MoonBit owner edge; each duplicate add is a distinct replica.
/// `tee_remove` releases one matching edge. Finished or wrong-type receivers
/// and erroneous targets raise checked errors. Adding the tee to itself raises
/// `CairoError(InvalidStatus, _)` to prevent a permanent ownership cycle.
pub fn Surface::tee_add(
  self : Surface,
  target : Surface,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.tee_add_raw(self.to_raw(), target.to_raw()),
  )
}

///|
/// Remove one matching added replica and release its retained wrapper edge.
///
/// The primary target at index zero cannot be removed. Removing the primary or
/// a target that is not present gives the tee a sticky `InvalidIndex` status
/// and raises `CairoInvalidArgument(InvalidIndex, _)`. Finished/wrong-type
/// receivers and self-removal raise their corresponding checked errors.
pub fn Surface::tee_remove(
  self : Surface,
  target : Surface,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.tee_remove_raw(self.to_raw(), target.to_raw()),
  )
}

///|
/// Return an independently referenced surface at `index`.
///
/// Index zero is the primary; added replicas follow in insertion order. The
/// result remains valid after a matching `tee_remove` or after the tee wrapper
/// leaves scope. Negative indexes raise `CairoInvalidArgument(InvalidIndex,
/// _)`. Cairo maps a positive out-of-range index through its error-surface
/// fallback to `CairoMemoryError(NoMemory, _)`; finished and wrong-type
/// receivers are checked before indexing.
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
