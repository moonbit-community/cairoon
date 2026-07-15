///|
pub fn Context::scale(
  self : Context,
  sx : Double,
  sy : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.scale_raw(self.to_raw(), sx, sy))
}

///|
pub fn Context::translate(
  self : Context,
  tx : Double,
  ty : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.translate_raw(self.to_raw(), tx, ty))
}

///|
pub fn Context::rotate(
  self : Context,
  radians : Double,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.rotate_raw(self.to_raw(), radians))
}

///|
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
pub fn Context::get_matrix(self : Context) -> Matrix raise CairoError {
  matrix_from_context_output((xx, yx, xy, yy, x0, y0) => {
    @context_impl.get_matrix_raw(self.to_raw(), xx, yx, xy, yy, x0, y0)
  })
}

///|
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
