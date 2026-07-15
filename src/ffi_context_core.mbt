///|
#borrow(surface)
extern "C" fn context_create_ffi(surface : Surface) -> @context_impl.RawContext = "cairoon_context_create"

///|
#borrow(surface, status)
extern "C" fn context_create_for_mapped_image_ffi(
  surface : MappedImageSurface,
  status : Ref[Status],
) -> @context_impl.RawContext = "cairoon_context_create_for_mapped_image"

///|
#borrow(ctx, status)
extern "C" fn context_get_target_ffi(
  ctx : @context_impl.RawContext,
  status : Ref[Status],
) -> Surface = "cairoon_context_get_target"

///|
#borrow(ctx, status)
extern "C" fn context_get_group_target_ffi(
  ctx : @context_impl.RawContext,
  status : Ref[Status],
) -> Surface = "cairoon_context_get_group_target"

///|
#borrow(ctx)
extern "C" fn context_push_group_with_content_ffi(
  ctx : @context_impl.RawContext,
  content : Content,
) -> Status = "cairoon_context_push_group_with_content"
