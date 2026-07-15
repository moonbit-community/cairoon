///|
/// Owned, mutable Cairo drawing context.
///
/// Assigning this wrapper shares the same `cairo_t`; all aliases observe the
/// same path and graphics state. The context retains its target wrapper and
/// releases both the Cairo context and that retained owner when its final
/// MoonBit wrapper becomes unreachable. Equality and hashing use Cairo pointer
/// identity rather than drawing-state contents.
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
/// Create a fresh context that draws to `target`.
///
/// Cairo initializes the graphics state to its defaults. The new context
/// retains `target`, including any MoonBit buffers or stream callbacks owned by
/// it, so the original surface binding may leave scope first. Raises the
/// target or newly created context status, including allocation failures.
pub fn Context::new(target : Surface) -> Context raise CairoError {
  let raw = @context_impl.create_raw(target.to_raw())
  check_context_status_raw(@context_impl.status_raw(raw))
  Context::from_raw(raw)
}

///|
/// Create a context that draws into a currently mapped image view.
///
/// The context retains `target`, preventing implicit finalizer unmapping while
/// it is live. Finish all drawing before explicitly unmapping the view; using
/// this constructor inside `MappedImageSurface::with_unmapped` is the scoped
/// form. Raises `CairoError(SurfaceFinished, _)` if the view was already
/// unmapped, or the mapped surface/context status on other failures.
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
/// Return this context's sticky Cairo status without raising it.
///
/// Public operations normally check and raise their resulting status, but
/// backends can report some errors later, such as when a page is committed.
/// Once Cairo records an error, later checked operations report that error too.
pub fn Context::status(self : Context) -> Status {
  context_status_from_raw(@context_impl.status_raw(self.to_raw()))
}

///|
/// Return whether two wrappers refer to the same Cairo context.
///
/// Contexts created separately for the same target are not equal. This matches
/// the public `Eq` implementation and does not compare mutable drawing state.
pub fn Context::equal(self : Context, other : Context) -> Bool {
  @context_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
/// Return the pointer-identity hash of this Cairo context.
///
/// Equal contexts produce the same value, which remains stable for the
/// context's lifetime. This is the value used by the public `Hash` trait.
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
/// Push a copy of the current graphics state onto Cairo's save stack.
///
/// Saves can be nested and are paired with `restore()`. The current path is not
/// part of the graphics state and is therefore not copied. Raises the checked
/// context status.
pub fn Context::save(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.save_raw(self.to_raw()))
}

///|
/// Restore and remove the most recently saved graphics state.
///
/// The current path is unchanged. Calling this without a matching `save()`
/// raises `CairoError(InvalidRestore, _)` and leaves the context in Cairo's
/// sticky error state.
pub fn Context::restore(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.restore_raw(self.to_raw()))
}

///|
/// Begin a tagged drawing range for links or document structure.
///
/// `attributes` uses Cairo's `key=value` syntax; pass `""` when none are
/// needed. Close the range with `tag_end` using the same name. Both strings are
/// UTF-8 encoded, and embedded NUL bytes raise
/// `CairoInvalidArgument(InvalidString, _)` before FFI. Invalid attributes or
/// nesting can raise `CairoError(TagError, _)` immediately or on a later page
/// commit, depending on the Cairo backend and version.
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
/// End the innermost tagged range with matching `tag_name`.
///
/// The name is UTF-8 encoded; an embedded NUL raises
/// `CairoInvalidArgument(InvalidString, _)` before FFI. Invalid or mismatched
/// nesting can surface as `CairoError(TagError, _)` here or during a later page
/// commit.
pub fn Context::tag_end(
  self : Context,
  tag_name : String,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.tag_end_raw(self.to_raw(), checked_c_string_bytes(tag_name)),
  )
}

///|
/// Return an independently retained wrapper for the original target surface.
///
/// Group redirection does not change this result; use `get_group_target()` for
/// the current destination. The returned wrapper remains usable after the
/// original surface binding or this context leaves scope. Raises the checked
/// context or target status.
pub fn Context::get_target(self : Context) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.get_target_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  Surface::from_raw(raw)
}

///|
/// Return an owned wrapper around the current source pattern reference.
///
/// This is not a deep copy: it refers to the same Cairo pattern currently used
/// by the context. The wrapper remains usable after the context leaves scope or
/// a different source is installed. Raises the checked context/pattern status.
pub fn Context::get_source(self : Context) -> Pattern raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.get_source_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  Pattern::from_raw(raw)
}

///|
/// Return an independently retained wrapper for the current destination.
///
/// Inside a pushed group this is that group's intermediate surface; outside a
/// group it is the original target. The wrapper retains the context as its
/// owner and remains usable after the context binding leaves scope. Raises the
/// checked context or surface status.
pub fn Context::get_group_target(self : Context) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.get_group_target_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  Surface::from_raw(raw)
}

///|
/// Redirect subsequent drawing to a color-and-alpha intermediate group.
///
/// Groups may be nested. Cairo implicitly saves the graphics state here; a
/// matching `pop_group()` or `pop_group_to_source()` restores it and exposes
/// the rendered group as a pattern. Raises the checked context status.
pub fn Context::push_group(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.push_group_raw(self.to_raw()))
}

///|
/// Redirect drawing to an intermediate group with typed `content`.
///
/// This has the same nesting and implicit save/restore behavior as
/// `push_group()`, but controls whether the intermediate surface stores color,
/// alpha, or both. Raises the checked context status.
pub fn Context::push_group_with_content(
  self : Context,
  content : Content,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.push_group_with_content_raw(self.to_raw(), content.to_raw()),
  )
}

///|
/// Push a group using a Cairo C integer content value.
///
/// This pycairo compatibility entry point accepts exactly `0x1000` (color),
/// `0x2000` (alpha), or `0x3000` (color and alpha). Any other value raises
/// `CairoInvalidArgument(InvalidContent, _)` before entering Cairo.
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
/// Finish the current group and return its pixels as an owned surface pattern.
///
/// Cairo restores the graphics state saved by the matching push. This method
/// does not install the pattern as the source; use `set_source` or call
/// `pop_group_to_source()` instead. An unmatched pop raises
/// `CairoError(InvalidPopGroup, _)`.
pub fn Context::pop_group(self : Context) -> Pattern raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.pop_group_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  Pattern::from_raw(raw)
}

///|
/// Finish the current group and install its result as the current source.
///
/// This is equivalent to `pop_group()`, `set_source(pattern)`, and releasing
/// the temporary pattern. Cairo restores the state saved by the matching push
/// before installing that source. An unmatched pop raises
/// `CairoError(InvalidPopGroup, _)`.
pub fn Context::pop_group_to_source(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.pop_group_to_source_raw(self.to_raw()))
}
