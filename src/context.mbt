///|
pub fn Context::new(target : Surface) -> Context raise CairoError {
  let ctx = context_create_ffi(target)
  check_status(context_status_ffi(ctx))
  ctx
}

///|
pub fn Context::new_for_mapped_image(
  target : MappedImageSurface,
) -> Context raise CairoError {
  let status = Ref(Success)
  let ctx = context_create_for_mapped_image_ffi(target, status)
  check_status(status.val)
  check_status(context_status_ffi(ctx))
  ctx
}

///|
pub fn Context::status(self : Context) -> Status {
  context_status_ffi(self)
}

///|
pub fn Context::equal(self : Context, other : Context) -> Bool {
  context_equal_ffi(self, other)
}

///|
pub fn Context::hash(self : Context) -> UInt64 {
  context_hash_ffi(self)
}

///|
pub impl Eq for Context with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for Context with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for Context with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
pub fn Context::save(self : Context) -> Unit raise CairoError {
  check_status(context_save_ffi(self))
}

///|
pub fn Context::restore(self : Context) -> Unit raise CairoError {
  check_status(context_restore_ffi(self))
}

///|
pub fn Context::tag_begin(
  self : Context,
  tag_name : String,
  attributes : String,
) -> Unit raise CairoError {
  check_status(
    context_tag_begin_ffi(
      self,
      checked_c_string_bytes(tag_name),
      checked_c_string_bytes(attributes),
    ),
  )
}

///|
pub fn Context::tag_end(
  self : Context,
  tag_name : String,
) -> Unit raise CairoError {
  check_status(context_tag_end_ffi(self, checked_c_string_bytes(tag_name)))
}

///|
pub fn Context::get_target(self : Context) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = context_get_target_ffi(self, status)
  check_status(status.val)
  surface
}

///|
pub fn Context::get_source(self : Context) -> Pattern raise CairoError {
  let status = Ref(Success)
  let pattern = context_get_source_ffi(self, status)
  check_status(status.val)
  pattern
}

///|
pub fn Context::get_group_target(self : Context) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = context_get_group_target_ffi(self, status)
  check_status(status.val)
  surface
}

///|
pub fn Context::push_group(self : Context) -> Unit raise CairoError {
  check_status(context_push_group_ffi(self))
}

///|
pub fn Context::push_group_with_content(
  self : Context,
  content : Content,
) -> Unit raise CairoError {
  check_status(context_push_group_with_content_ffi(self, content))
}

///|
pub fn Context::push_group_with_content_raw(
  self : Context,
  content : Int,
) -> Unit raise CairoError {
  check_status(
    context_push_group_with_content_raw_ffi(self, checked_content_raw(content)),
  )
}

///|
pub fn Context::pop_group(self : Context) -> Pattern raise CairoError {
  let status = Ref(Success)
  let pattern = context_pop_group_ffi(self, status)
  check_status(status.val)
  pattern
}

///|
pub fn Context::pop_group_to_source(self : Context) -> Unit raise CairoError {
  check_status(context_pop_group_to_source_ffi(self))
}

///|
