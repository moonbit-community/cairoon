///|
fn ensure_native() -> Unit {
  ignore(@native.native_anchor())
}

///|
pub fn status_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_status_ffi(ctx)
}

///|
pub fn equal_raw(ctx : RawContext, other : RawContext) -> Bool {
  ensure_native()
  context_equal_ffi(ctx, other)
}

///|
pub fn hash_raw(ctx : RawContext) -> UInt64 {
  ensure_native()
  context_hash_ffi(ctx)
}

///|
pub fn save_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_save_ffi(ctx)
}

///|
pub fn restore_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_restore_ffi(ctx)
}

///|
pub fn tag_begin_raw(
  ctx : RawContext,
  tag_name : Bytes,
  attributes : Bytes,
) -> Int {
  ensure_native()
  context_tag_begin_ffi(ctx, tag_name, attributes)
}

///|
pub fn tag_end_raw(ctx : RawContext, tag_name : Bytes) -> Int {
  ensure_native()
  context_tag_end_ffi(ctx, tag_name)
}

///|
pub fn get_source_raw(
  ctx : RawContext,
  status : Ref[Int],
) -> @pattern_impl.RawPattern {
  ensure_native()
  context_get_source_ffi(ctx, status)
}

///|
pub fn push_group_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_push_group_ffi(ctx)
}

///|
pub fn push_group_with_content_raw(ctx : RawContext, content : Int) -> Int {
  ensure_native()
  context_push_group_with_content_raw_ffi(ctx, content)
}

///|
pub fn pop_group_raw(
  ctx : RawContext,
  status : Ref[Int],
) -> @pattern_impl.RawPattern {
  ensure_native()
  context_pop_group_ffi(ctx, status)
}

///|
pub fn pop_group_to_source_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_pop_group_to_source_ffi(ctx)
}
