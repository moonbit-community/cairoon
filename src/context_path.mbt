///|
/// Begin a new subpath at `(x, y)` in the current user space.
///
/// No segment connects the previous current point to this one. On success the
/// new point is available from `get_current_point()`. Raises the checked
/// context status.
pub fn Context::move_to(
  self : Context,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.move_to_raw(self.to_raw(), x, y))
}

///|
/// Begin a new subpath at an offset from the current point.
///
/// Given current point `(x, y)`, this is `move_to(x + dx, y + dy)` in user
/// space. If no current point exists, raises `CairoError(NoCurrentPoint, _)`
/// and puts the context into Cairo's sticky error state.
pub fn Context::rel_move_to(
  self : Context,
  dx : Double,
  dy : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.rel_move_to_raw(self.to_raw(), dx, dy))
}

///|
/// Add a straight segment from the current point to `(x, y)`.
///
/// Coordinates are in the current user space and the endpoint becomes current.
/// If no current point exists, Cairo treats this as `move_to(x, y)`. Raises the
/// checked context status.
pub fn Context::line_to(
  self : Context,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.line_to_raw(self.to_raw(), x, y))
}

///|
/// Add a straight segment ending at an offset from the current point.
///
/// Given current point `(x, y)`, the endpoint is `(x + dx, y + dy)` in user
/// space. If no current point exists, raises
/// `CairoError(NoCurrentPoint, _)` and makes that status sticky.
pub fn Context::rel_line_to(
  self : Context,
  dx : Double,
  dy : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.rel_line_to_raw(self.to_raw(), dx, dy))
}

///|
/// Add a cubic Bezier segment in absolute user-space coordinates.
///
/// `(x1, y1)` and `(x2, y2)` are control points; `(x3, y3)` is the endpoint
/// and becomes current. With no current point, Cairo first behaves as though
/// `move_to(x1, y1)` had been called. Raises the checked context status.
pub fn Context::curve_to(
  self : Context,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.curve_to_raw(self.to_raw(), x1, y1, x2, y2, x3, y3),
  )
}

///|
/// Add a cubic Bezier segment using offsets from the current point.
///
/// The two control points and endpoint are respectively offset by
/// `(dx1, dy1)`, `(dx2, dy2)`, and `(dx3, dy3)`. If no current point exists,
/// raises `CairoError(NoCurrentPoint, _)` and makes that status sticky.
pub fn Context::rel_curve_to(
  self : Context,
  dx1 : Double,
  dy1 : Double,
  dx2 : Double,
  dy2 : Double,
  dx3 : Double,
  dy3 : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.rel_curve_to_raw(self.to_raw(), dx1, dy1, dx2, dy2, dx3, dy3),
  )
}

///|
/// Add a closed rectangular subpath in user-space coordinates.
///
/// Its opposite corners are `(x, y)` and `(x + width, y + height)`; signed
/// widths and heights therefore select direction as well as size. Cairo closes
/// the subpath and leaves `(x, y)` as the current point. Raises the checked
/// context status.
pub fn Context::rectangle(
  self : Context,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.rectangle_raw(self.to_raw(), x, y, width, height),
  )
}

///|
/// Add a circular arc in the direction of increasing angles.
///
/// Angles are radians in user space: zero points along positive X and, under
/// the default transform, increasing angles run clockwise. When `angle2` is
/// below `angle1`, Cairo adds whole turns until it is above it. An existing
/// current point is joined to the arc start by a line; call `new_sub_path()`
/// first to avoid that join. Raises the checked context status.
pub fn Context::arc(
  self : Context,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.arc_raw(self.to_raw(), xc, yc, radius, angle1, angle2),
  )
}

///|
/// Add a circular arc in the direction of decreasing angles.
///
/// This follows the same user-space and current-point rules as `arc()`, but
/// subtracts whole turns from `angle2` when needed and traverses toward smaller
/// angles. Call `new_sub_path()` first when the arc must not connect to the
/// current point. Raises the checked context status.
pub fn Context::arc_negative(
  self : Context,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.arc_negative_raw(
      self.to_raw(),
      xc,
      yc,
      radius,
      angle1,
      angle2,
    ),
  )
}

///|
/// Close the current subpath with a line back to its starting point.
///
/// The resulting stroke uses a line join rather than two end caps, and the
/// start becomes current. Cairo also exposes an explicit move segment after
/// the close in copied paths. If no current point exists, this is a no-op.
/// Raises the checked context status.
pub fn Context::close_path(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.close_path_raw(self.to_raw()))
}

///|
/// Clear every subpath and unset the current point.
///
/// This does not draw anything. It is also unnecessary after non-preserving
/// `fill()` or `stroke()`, which clear the path themselves. Raises the checked
/// context status.
pub fn Context::new_path(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.new_path_raw(self.to_raw()))
}

///|
/// End the current subpath without clearing existing path geometry.
///
/// The current point becomes undefined, so the next absolute path operation
/// starts a disconnected subpath. This is especially useful before `arc()` or
/// `arc_negative()` when no connecting line is wanted. Raises the checked
/// context status.
pub fn Context::new_sub_path(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.new_sub_path_raw(self.to_raw()))
}

///|
/// Return the current point in user-space coordinates.
///
/// This is the final point reached by the current path. It returns `(0.0, 0.0)`
/// when no point is defined; use `has_current_point()` to distinguish that case
/// from a real origin. Unlike Cairo's raw C getter, this wrapper raises any
/// existing checked context error instead of returning fallback zeros.
pub fn Context::get_current_point(
  self : Context,
) -> (Double, Double) raise CairoError {
  point_from_context_output((x, y) => {
    @context_impl.get_current_point_raw(self.to_raw(), x, y)
  })
}

///|
/// Return whether the current path has a defined current point.
///
/// `new_path()` and `new_sub_path()` make this false; most path construction
/// methods define a new point. Raises any existing checked context status.
pub fn Context::has_current_point(self : Context) -> Bool raise CairoError {
  let result = Ref(0)
  check_context_status_raw(
    @context_impl.has_current_point_raw(self.to_raw(), result),
  )
  result.val != 0
}

///|
/// Copy the current path into an independently owned `Path` snapshot.
///
/// Cubic curves remain curve segments and an empty context yields a valid empty
/// path. The result neither retains nor aliases this context and remains usable
/// after the context leaves scope or its path changes. Raises the context or
/// returned path status, including allocation failure.
pub fn Context::copy_path(self : Context) -> Path raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.copy_path_raw(self.to_raw(), status)
  check_path_status_raw(status.val)
  Path::from_raw(raw)
}

///|
/// Copy a line-segment approximation of the current path.
///
/// Cairo replaces every cubic curve with line segments accurate to the current
/// tolerance; the owned result contains no curve segments. It remains usable
/// independently of this context. Raises the context or returned path status,
/// including allocation failure.
pub fn Context::copy_path_flat(self : Context) -> Path raise CairoError {
  let status = Ref(0)
  let raw = @context_impl.copy_path_flat_raw(self.to_raw(), status)
  check_path_status_raw(status.val)
  Path::from_raw(raw)
}

///|
/// Append every segment of `path` to this context's current path.
///
/// The supplied owned snapshot is borrowed for the call: it is neither
/// consumed nor mutated and may be reused after this method returns. The
/// appended data updates the current point according to its final segment.
/// Raises either the path's status or the checked context status.
pub fn Context::append_path(
  self : Context,
  path : Path,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.append_path_raw(self.to_raw(), path.to_raw()),
  )
}
