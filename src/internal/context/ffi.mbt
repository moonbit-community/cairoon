///|
type RawContext

///|
#borrow(ctx)
extern "C" fn context_status_ffi(ctx : RawContext) -> Int = "cairoon_context_status"

///|
#borrow(ctx, other)
extern "C" fn context_equal_ffi(ctx : RawContext, other : RawContext) -> Bool = "cairoon_context_equal"

///|
#borrow(ctx)
extern "C" fn context_hash_ffi(ctx : RawContext) -> UInt64 = "cairoon_context_hash"

///|
#borrow(ctx)
extern "C" fn context_save_ffi(ctx : RawContext) -> Int = "cairoon_context_save"

///|
#borrow(ctx)
extern "C" fn context_restore_ffi(ctx : RawContext) -> Int = "cairoon_context_restore"

///|
#borrow(ctx, tag_name, attributes)
extern "C" fn context_tag_begin_ffi(
  ctx : RawContext,
  tag_name : Bytes,
  attributes : Bytes,
) -> Int = "cairoon_context_tag_begin"

///|
#borrow(ctx, tag_name)
extern "C" fn context_tag_end_ffi(ctx : RawContext, tag_name : Bytes) -> Int = "cairoon_context_tag_end"

///|
#borrow(ctx, status)
extern "C" fn context_get_source_ffi(
  ctx : RawContext,
  status : Ref[Int],
) -> @pattern_impl.RawPattern = "cairoon_context_get_source"

///|
#borrow(ctx)
extern "C" fn context_push_group_ffi(ctx : RawContext) -> Int = "cairoon_context_push_group"

///|
#borrow(ctx)
extern "C" fn context_push_group_with_content_raw_ffi(
  ctx : RawContext,
  content : Int,
) -> Int = "cairoon_context_push_group_with_content"

///|
#borrow(ctx, status)
extern "C" fn context_pop_group_ffi(
  ctx : RawContext,
  status : Ref[Int],
) -> @pattern_impl.RawPattern = "cairoon_context_pop_group"

///|
#borrow(ctx)
extern "C" fn context_pop_group_to_source_ffi(ctx : RawContext) -> Int = "cairoon_context_pop_group_to_source"
