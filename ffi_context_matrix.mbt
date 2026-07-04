///|
#borrow(ctx)
extern "C" fn context_scale_ffi(
  ctx : Context,
  sx : Double,
  sy : Double,
) -> Status = "cairoon_context_scale"

///|
#borrow(ctx)
extern "C" fn context_translate_ffi(
  ctx : Context,
  tx : Double,
  ty : Double,
) -> Status = "cairoon_context_translate"

///|
#borrow(ctx)
extern "C" fn context_rotate_ffi(ctx : Context, radians : Double) -> Status = "cairoon_context_rotate"

///|
#borrow(ctx)
extern "C" fn context_transform_ffi(
  ctx : Context,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Status = "cairoon_context_transform"

///|
#borrow(ctx)
extern "C" fn context_set_matrix_ffi(
  ctx : Context,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
  x0 : Double,
  y0 : Double,
) -> Status = "cairoon_context_set_matrix"

///|
#borrow(ctx, xx, yx, xy, yy, x0, y0)
extern "C" fn context_get_matrix_ffi(
  ctx : Context,
  xx : Ref[Double],
  yx : Ref[Double],
  xy : Ref[Double],
  yy : Ref[Double],
  x0 : Ref[Double],
  y0 : Ref[Double],
) -> Status = "cairoon_context_get_matrix"

///|
#borrow(ctx)
extern "C" fn context_identity_matrix_ffi(ctx : Context) -> Status = "cairoon_context_identity_matrix"

///|
#borrow(ctx, out_x, out_y)
extern "C" fn context_user_to_device_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  out_x : Ref[Double],
  out_y : Ref[Double],
) -> Status = "cairoon_context_user_to_device"

///|
#borrow(ctx, out_dx, out_dy)
extern "C" fn context_user_to_device_distance_ffi(
  ctx : Context,
  dx : Double,
  dy : Double,
  out_dx : Ref[Double],
  out_dy : Ref[Double],
) -> Status = "cairoon_context_user_to_device_distance"

///|
#borrow(ctx, out_x, out_y)
extern "C" fn context_device_to_user_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  out_x : Ref[Double],
  out_y : Ref[Double],
) -> Status = "cairoon_context_device_to_user"

///|
#borrow(ctx, out_dx, out_dy)
extern "C" fn context_device_to_user_distance_ffi(
  ctx : Context,
  dx : Double,
  dy : Double,
  out_dx : Ref[Double],
  out_dy : Ref[Double],
) -> Status = "cairoon_context_device_to_user_distance"
