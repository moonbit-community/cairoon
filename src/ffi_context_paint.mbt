///|
#borrow(ctx, surface)
extern "C" fn context_set_source_surface_ffi(
  ctx : @context_impl.RawContext,
  surface : Surface,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_set_source_surface"

///|
#borrow(ctx, surface)
extern "C" fn context_mask_surface_ffi(
  ctx : @context_impl.RawContext,
  surface : Surface,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_mask_surface"
