///|
#borrow(surface)
extern "C" fn context_create_ffi(surface : Surface) -> Context = "cairoon_context_create"

///|
#borrow(surface, status)
extern "C" fn context_create_for_mapped_image_ffi(
  surface : MappedImageSurface,
  status : Ref[Status],
) -> Context = "cairoon_context_create_for_mapped_image"

///|
#borrow(ctx)
extern "C" fn context_status_ffi(ctx : Context) -> Status = "cairoon_context_status"

///|
#borrow(ctx, other)
extern "C" fn context_equal_ffi(ctx : Context, other : Context) -> Bool = "cairoon_context_equal"

///|
#borrow(ctx)
extern "C" fn context_hash_ffi(ctx : Context) -> UInt64 = "cairoon_context_hash"

///|
#borrow(ctx)
extern "C" fn context_save_ffi(ctx : Context) -> Status = "cairoon_context_save"

///|
#borrow(ctx)
extern "C" fn context_restore_ffi(ctx : Context) -> Status = "cairoon_context_restore"

///|
#borrow(ctx, status)
extern "C" fn context_get_target_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Surface = "cairoon_context_get_target"

///|
#borrow(ctx, tag_name, attributes)
extern "C" fn context_tag_begin_ffi(
  ctx : Context,
  tag_name : Bytes,
  attributes : Bytes,
) -> Status = "cairoon_context_tag_begin"

///|
#borrow(ctx, tag_name)
extern "C" fn context_tag_end_ffi(ctx : Context, tag_name : Bytes) -> Status = "cairoon_context_tag_end"

///|
#borrow(ctx, status)
extern "C" fn context_get_source_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Pattern = "cairoon_context_get_source"

///|
#borrow(ctx, status)
extern "C" fn context_get_group_target_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Surface = "cairoon_context_get_group_target"

///|
#borrow(ctx)
extern "C" fn context_push_group_ffi(ctx : Context) -> Status = "cairoon_context_push_group"

///|
#borrow(ctx)
extern "C" fn context_push_group_with_content_ffi(
  ctx : Context,
  content : Content,
) -> Status = "cairoon_context_push_group_with_content"

///|
#borrow(ctx, status)
extern "C" fn context_pop_group_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Pattern = "cairoon_context_pop_group"

///|
#borrow(ctx)
extern "C" fn context_pop_group_to_source_ffi(ctx : Context) -> Status = "cairoon_context_pop_group_to_source"
