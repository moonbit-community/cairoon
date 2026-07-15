///|
pub fn scale_raw(ctx : RawContext, sx : Double, sy : Double) -> Int {
  ensure_native()
  context_scale_ffi(ctx, sx, sy)
}

///|
pub fn translate_raw(ctx : RawContext, tx : Double, ty : Double) -> Int {
  ensure_native()
  context_translate_ffi(ctx, tx, ty)
}

///|
pub fn rotate_raw(ctx : RawContext, radians : Double) -> Int {
  ensure_native()
  context_rotate_ffi(ctx, radians)
}

///|
pub fn transform_raw(
  ctx : RawContext,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Int {
  ensure_native()
  context_transform_ffi(ctx, xx, yx, xy, yy, x0, y0)
}

///|
pub fn set_matrix_raw(
  ctx : RawContext,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Int {
  ensure_native()
  context_set_matrix_ffi(ctx, xx, yx, xy, yy, x0, y0)
}

///|
pub fn get_matrix_raw(
  ctx : RawContext,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Int {
  ensure_native()
  context_get_matrix_ffi(ctx, xx, yx, xy, yy, x0, y0)
}

///|
pub fn identity_matrix_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_identity_matrix_ffi(ctx)
}

///|
pub fn user_to_device_raw(
  ctx : RawContext,
  x : Double,
  y : Double,
  out_x : Ref[Double],
  out_y : Ref[Double],
) -> Int {
  ensure_native()
  context_user_to_device_ffi(ctx, x, y, out_x, out_y)
}

///|
pub fn user_to_device_distance_raw(
  ctx : RawContext,
  dx : Double,
  dy : Double,
  out_dx : Ref[Double],
  out_dy : Ref[Double],
) -> Int {
  ensure_native()
  context_user_to_device_distance_ffi(ctx, dx, dy, out_dx, out_dy)
}

///|
pub fn device_to_user_raw(
  ctx : RawContext,
  x : Double,
  y : Double,
  out_x : Ref[Double],
  out_y : Ref[Double],
) -> Int {
  ensure_native()
  context_device_to_user_ffi(ctx, x, y, out_x, out_y)
}

///|
pub fn device_to_user_distance_raw(
  ctx : RawContext,
  dx : Double,
  dy : Double,
  out_dx : Ref[Double],
  out_dy : Ref[Double],
) -> Int {
  ensure_native()
  context_device_to_user_distance_ffi(ctx, dx, dy, out_dx, out_dy)
}
