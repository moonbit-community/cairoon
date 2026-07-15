///|
/// Intersect the current clip with the fill area of the current path.
///
/// Cairo uses the current fill rule, clears the path afterward, and can only
/// make the clip smaller. The clip is graphics state, so pair `save()` and
/// `restore()` for temporary restrictions. An empty path produces an empty
/// clip. Raises the checked context status.
pub fn Context::clip(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.clip_raw(self.to_raw()))
}

///|
/// Intersect the current clip with the current path while preserving the path.
///
/// Fill-rule, narrowing, and graphics-state behavior match `clip()`, but the
/// path and current point remain available for later drawing or queries.
/// Raises the checked context status.
pub fn Context::clip_preserve(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.clip_preserve_raw(self.to_raw()))
}

///|
/// Replace the current clip with Cairo's original unrestricted target clip.
///
/// This can discard restrictions installed by callers. Reusable drawing code
/// should normally put temporary clips inside `save()`/`restore()` instead.
/// The current path is unchanged. Raises the checked context status.
pub fn Context::reset_clip(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.reset_clip_raw(self.to_raw()))
}

///|
/// Return a user-space bounding box for the area inside the current clip.
///
/// The tuple is `(x1, y1, x2, y2)` for the left, top, right, and bottom bounds;
/// it bounds the clip but does not describe non-rectangular clip geometry.
/// This query does not change the clip or path and raises the checked context
/// status.
pub fn Context::clip_extents(
  self : Context,
) -> (Double, Double, Double, Double) raise CairoError {
  context_extents_from_output((x1, y1, x2, y2) => {
    @context_impl.clip_extents_raw(self.to_raw(), x1, y1, x2, y2)
  })
}

///|
fn context_extents_from_output(
  f : (Ref[Double], Ref[Double], Ref[Double], Ref[Double]) -> Int,
) -> (Double, Double, Double, Double) raise CairoError {
  let x1 = Ref(0.0)
  let y1 = Ref(0.0)
  let x2 = Ref(0.0)
  let y2 = Ref(0.0)
  check_context_status_raw(f(x1, y1, x2, y2))
  (x1.val, y1.val, x2.val, y2.val)
}

///|
/// Test whether `(x, y)` lies in the current visible clip area.
///
/// Coordinates are in current user space. A true result means a full-surface
/// `paint()` could affect that point; it does not inspect the current path.
/// This query has no side effects and raises the checked context status.
pub fn Context::in_clip(
  self : Context,
  x : Double,
  y : Double,
) -> Bool raise CairoError {
  context_hit_test_from_output(result => {
    @context_impl.in_clip_raw(self.to_raw(), x, y, result)
  })
}

///|
/// Copy the current clip into independent user-space rectangles.
///
/// The returned array and `Rectangle` values are pure MoonBit data and retain
/// no Cairo object. An empty clip returns `[]`. If the clip cannot be expressed
/// exactly as user-space rectangles, raises
/// `CairoError(ClipNotRepresentable, _)`; other Cairo failures are checked too.
pub fn Context::copy_clip_rectangle_list(
  self : Context,
) -> Array[Rectangle] raise CairoError {
  let status = Ref(0)
  let values = @context_impl.copy_clip_rectangle_list_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  Array::makei(values.length() / 4, index => {
    let offset = index * 4
    Rectangle::new(
      values[offset],
      values[offset + 1],
      values[offset + 2],
      values[offset + 3],
    )
  })
}

///|
/// Return the fill-ink bounds of the current path in user space.
///
/// The tuple is `(x1, y1, x2, y2)`. Cairo applies the current fill rule, but
/// ignores the clip and target dimensions. An empty or non-inking path returns
/// `(0.0, 0.0, 0.0, 0.0)`. The path is preserved. Raises the checked context
/// status.
pub fn Context::fill_extents(
  self : Context,
) -> (Double, Double, Double, Double) raise CairoError {
  context_extents_from_output((x1, y1, x2, y2) => {
    @context_impl.fill_extents_raw(self.to_raw(), x1, y1, x2, y2)
  })
}

///|
/// Return the stroke-ink bounds of the current path in user space.
///
/// The tuple is `(x1, y1, x2, y2)`. Line width, joins, caps, dashes, and other
/// stroke state are applied, while clipping and target dimensions are ignored.
/// An empty path yields `(0.0, 0.0, 0.0, 0.0)`. The path is preserved. Raises
/// the checked context status.
pub fn Context::stroke_extents(
  self : Context,
) -> (Double, Double, Double, Double) raise CairoError {
  context_extents_from_output((x1, y1, x2, y2) => {
    @context_impl.stroke_extents_raw(self.to_raw(), x1, y1, x2, y2)
  })
}

///|
/// Return geometric bounds for points on the current path in user space.
///
/// Stroke state, fill rule, clipping, and target dimensions are ignored. An
/// empty path or lone `move_to` returns zero extents, while even a degenerate
/// line segment contributes. This is generally cheaper than precise fill or
/// stroke bounds and preserves the path. Raises the checked context status.
pub fn Context::path_extents(
  self : Context,
) -> (Double, Double, Double, Double) raise CairoError {
  context_extents_from_output((x1, y1, x2, y2) => {
    @context_impl.path_extents_raw(self.to_raw(), x1, y1, x2, y2)
  })
}

///|
fn context_hit_test_from_output(f : (Ref[Int]) -> Int) -> Bool raise CairoError {
  let result = Ref(0)
  check_context_status_raw(f(result))
  result.val != 0
}

///|
/// Test whether `(x, y)` lies in the current path's fill area.
///
/// Cairo applies the current fill rule but deliberately ignores the clip and
/// target dimensions. Coordinates are in user space. The path is preserved and
/// any existing context error is raised.
pub fn Context::in_fill(
  self : Context,
  x : Double,
  y : Double,
) -> Bool raise CairoError {
  context_hit_test_from_output(result => {
    @context_impl.in_fill_raw(self.to_raw(), x, y, result)
  })
}

///|
/// Test whether `(x, y)` lies in the current path's stroke area.
///
/// Cairo applies current line width, joins, caps, dashes, and related stroke
/// state, but ignores the clip and target dimensions. Coordinates are in user
/// space. The path is preserved and any existing context error is raised.
pub fn Context::in_stroke(
  self : Context,
  x : Double,
  y : Double,
) -> Bool raise CairoError {
  context_hit_test_from_output(result => {
    @context_impl.in_stroke_raw(self.to_raw(), x, y, result)
  })
}
