///|
struct Context(@context_impl.RawContext)

///|
fn Context::from_raw(raw : @context_impl.RawContext) -> Context {
  Context(raw)
}

///|
fn Context::to_raw(self : Context) -> @context_impl.RawContext {
  self.0
}

///|
fn context_status_from_raw(raw : Int) -> Status {
  status_from_raw(raw) catch {
    _ => InvalidStatus
  }
}

///|
fn check_context_status_raw(raw : Int) -> Unit raise CairoError {
  check_status(status_from_raw(raw))
}

///|
pub fn Context::new(target : Surface) -> Context raise CairoError {
  let raw = @context_impl.create_raw(target.to_raw())
  check_context_status_raw(@context_impl.status_raw(raw))
  Context::from_raw(raw)
}

///|
pub fn Context::new_for_mapped_image(
  target : MappedImageSurface,
) -> Context raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.create_for_mapped_image_raw(target.to_raw(), status)
  check_context_status_raw(status.val)
  check_context_status_raw(@context_impl.status_raw(raw))
  Context::from_raw(raw)
}

///|
pub fn Context::status(self : Context) -> Status {
  context_status_from_raw(@context_impl.status_raw(self.to_raw()))
}

///|
pub fn Context::equal(self : Context, other : Context) -> Bool {
  @context_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
pub fn Context::hash(self : Context) -> UInt64 {
  @context_impl.hash_raw(self.to_raw())
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
  check_context_status_raw(@context_impl.save_raw(self.to_raw()))
}

///|
pub fn Context::restore(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.restore_raw(self.to_raw()))
}

///|
pub fn Context::tag_begin(
  self : Context,
  tag_name : String,
  attributes : String,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.tag_begin_raw(
      self.to_raw(),
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
  check_context_status_raw(
    @context_impl.tag_end_raw(self.to_raw(), checked_c_string_bytes(tag_name)),
  )
}

///|
pub fn Context::get_target(self : Context) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.get_target_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  Surface::from_raw(raw)
}

///|
pub fn Context::get_source(self : Context) -> Pattern raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.get_source_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  Pattern::from_raw(raw)
}

///|
pub fn Context::get_group_target(self : Context) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.get_group_target_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  Surface::from_raw(raw)
}

///|
pub fn Context::push_group(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.push_group_raw(self.to_raw()))
}

///|
pub fn Context::push_group_with_content(
  self : Context,
  content : Content,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.push_group_with_content_raw(self.to_raw(), content.to_raw()),
  )
}

///|
pub fn Context::push_group_with_content_raw(
  self : Context,
  content : Int,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.push_group_with_content_raw(
      self.to_raw(),
      checked_content_raw(content),
    ),
  )
}

///|
pub fn Context::pop_group(self : Context) -> Pattern raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.pop_group_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  Pattern::from_raw(raw)
}

///|
pub fn Context::pop_group_to_source(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.pop_group_to_source_raw(self.to_raw()))
}
