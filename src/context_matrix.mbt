///|
/// Scale the user-space X and Y axes by `sx` and `sy`.
///
/// The scale is added after the context's existing user-space transformation;
/// the CTM remains part of save/restore graphics state. A scale that makes the
/// CTM non-invertible raises `CairoInvalidArgument(InvalidMatrix, _)` and makes
/// that Cairo status sticky.
pub fn Context::scale(
  self : Context,
  sx : Double,
  sy : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.scale_raw(self.to_raw(), sx, sy))
}

///|
/// Translate the user-space origin by `(tx, ty)`.
///
/// The offset is interpreted through the CTM that existed before this call, so
/// translation is added after the existing user-space transformation. The CTM
/// is part of save/restore graphics state. Raises the checked context status.
pub fn Context::translate(
  self : Context,
  tx : Double,
  ty : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.translate_raw(self.to_raw(), tx, ty))
}

///|
/// Rotate the user-space axes by `radians`.
///
/// Positive angles rotate from positive X toward positive Y, which appears
/// clockwise with Cairo's default downward-pointing Y axis. Rotation is added
/// after the existing user-space transformation. Raises the checked context
/// status.
pub fn Context::rotate(
  self : Context,
  radians : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.rotate_raw(self.to_raw(), radians))
}

///|
/// Apply `matrix` as an additional transformation of user space.
///
/// Unlike `set_matrix()`, this composes with the current CTM; Cairo applies the
/// new transformation after the existing one. If the result is not invertible,
/// raises `CairoInvalidArgument(InvalidMatrix, _)` and makes that status sticky.
pub fn Context::transform(
  self : Context,
  matrix : Matrix,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.transform_raw(
      self.to_raw(),
      matrix.xx,
      matrix.yx,
      matrix.xy,
      matrix.yy,
      matrix.x0,
      matrix.y0,
    ),
  )
}

///|
/// Replace the current user-to-device transformation with `matrix`.
///
/// No composition with the previous CTM occurs. The value is copied, so later
/// use of the pure `Matrix` cannot change this context. A non-invertible matrix
/// raises `CairoInvalidArgument(InvalidMatrix, _)` and makes that status sticky.
pub fn Context::set_matrix(
  self : Context,
  matrix : Matrix,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_matrix_raw(
      self.to_raw(),
      matrix.xx,
      matrix.yx,
      matrix.xy,
      matrix.yy,
      matrix.x0,
      matrix.y0,
    ),
  )
}

///|
fn matrix_from_context_output(
  f : (
    Ref[Double],
    Ref[Double],
    Ref[Double],
    Ref[Double],
    Ref[Double],
    Ref[Double],
  ) -> Int,
) -> Matrix raise CairoError {
  let xx = Ref(0.0)
  let yx = Ref(0.0)
  let xy = Ref(0.0)
  let yy = Ref(0.0)
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  check_context_status_raw(f(xx, yx, xy, yy, x0, y0))
  Matrix::new(xx=xx.val, yx=yx.val, xy=xy.val, yy=yy.val, x0=x0.val, y0=y0.val)
}

///|
/// Return a pure snapshot of the current user-to-device matrix.
///
/// The returned `Matrix` shares no mutable state with this context. CTM changes
/// made after the call do not alter it. Raises any existing checked context
/// status.
pub fn Context::get_matrix(self : Context) -> Matrix raise CairoError {
  matrix_from_context_output((xx, yx, xy, yy, x0, y0) => {
    @context_impl.get_matrix_raw(self.to_raw(), xx, yx, xy, yy, x0, y0)
  })
}

///|
/// Reset the CTM so user space and device space coincide.
///
/// Afterward one user-space unit maps to one device-space unit and the origins
/// align. This CTM change can be undone by a matching `restore()` when made
/// inside saved graphics state. Raises the checked context status.
pub fn Context::identity_matrix(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.identity_matrix_raw(self.to_raw()))
}

///|
fn point_from_context_output(
  f : (Ref[Double], Ref[Double]) -> Int,
) -> (Double, Double) raise CairoError {
  let x = Ref(0.0)
  let y = Ref(0.0)
  check_context_status_raw(f(x, y))
  (x.val, y.val)
}

///|
/// Transform user-space point `(x, y)` into device-space coordinates.
///
/// The full CTM is applied, including translation. This query does not mutate
/// the input values or context and raises any existing checked context status.
pub fn Context::user_to_device(
  self : Context,
  x : Double,
  y : Double,
) -> (Double, Double) raise CairoError {
  point_from_context_output((out_x, out_y) => {
    @context_impl.user_to_device_raw(self.to_raw(), x, y, out_x, out_y)
  })
}

///|
/// Transform a user-space distance vector into device space.
///
/// Scale, rotation, and shear are applied, but CTM translation is deliberately
/// ignored. Use `user_to_device()` for positions. This query does not mutate
/// the context and raises any existing checked context status.
pub fn Context::user_to_device_distance(
  self : Context,
  dx : Double,
  dy : Double,
) -> (Double, Double) raise CairoError {
  point_from_context_output((out_dx, out_dy) => {
    @context_impl.user_to_device_distance_raw(
      self.to_raw(),
      dx,
      dy,
      out_dx,
      out_dy,
    )
  })
}

///|
/// Transform device-space point `(x, y)` into user-space coordinates.
///
/// Cairo applies the inverse CTM, including its translation. This query does
/// not mutate the context and raises any existing checked context status.
pub fn Context::device_to_user(
  self : Context,
  x : Double,
  y : Double,
) -> (Double, Double) raise CairoError {
  point_from_context_output((out_x, out_y) => {
    @context_impl.device_to_user_raw(self.to_raw(), x, y, out_x, out_y)
  })
}

///|
/// Transform a device-space distance vector into user space.
///
/// Cairo applies the inverse CTM's scale, rotation, and shear while ignoring
/// inverse translation. Use `device_to_user()` for positions. This query does
/// not mutate the context and raises any existing checked context status.
pub fn Context::device_to_user_distance(
  self : Context,
  dx : Double,
  dy : Double,
) -> (Double, Double) raise CairoError {
  point_from_context_output((out_dx, out_dy) => {
    @context_impl.device_to_user_distance_raw(
      self.to_raw(),
      dx,
      dy,
      out_dx,
      out_dy,
    )
  })
}
