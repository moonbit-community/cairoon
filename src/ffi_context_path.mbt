///|
#borrow(ctx)
extern "C" fn context_move_to_ffi(
  ctx : Context,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_move_to"

///|
#borrow(ctx)
extern "C" fn context_rel_move_to_ffi(
  ctx : Context,
  dx : Double,
  dy : Double,
) -> Status = "cairoon_context_rel_move_to"

///|
#borrow(ctx)
extern "C" fn context_line_to_ffi(
  ctx : Context,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_line_to"

///|
#borrow(ctx)
extern "C" fn context_rel_line_to_ffi(
  ctx : Context,
  dx : Double,
  dy : Double,
) -> Status = "cairoon_context_rel_line_to"

///|
#borrow(ctx)
extern "C" fn context_curve_to_ffi(
  ctx : Context,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Status = "cairoon_context_curve_to"

///|
#borrow(ctx)
extern "C" fn context_rel_curve_to_ffi(
  ctx : Context,
  dx1 : Double,
  dy1 : Double,
  dx2 : Double,
  dy2 : Double,
  dx3 : Double,
  dy3 : Double,
) -> Status = "cairoon_context_rel_curve_to"

///|
#borrow(ctx)
extern "C" fn context_rectangle_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Status = "cairoon_context_rectangle"

///|
#borrow(ctx)
extern "C" fn context_arc_ffi(
  ctx : Context,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Status = "cairoon_context_arc"

///|
#borrow(ctx)
extern "C" fn context_arc_negative_ffi(
  ctx : Context,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Status = "cairoon_context_arc_negative"

///|
#borrow(ctx)
extern "C" fn context_close_path_ffi(ctx : Context) -> Status = "cairoon_context_close_path"

///|
#borrow(ctx)
extern "C" fn context_new_path_ffi(ctx : Context) -> Status = "cairoon_context_new_path"

///|
#borrow(ctx)
extern "C" fn context_new_sub_path_ffi(ctx : Context) -> Status = "cairoon_context_new_sub_path"

///|
#borrow(ctx, x, y)
extern "C" fn context_get_current_point_ffi(
  ctx : Context,
  x : Ref[Double],
  y : Ref[Double],
) -> Status = "cairoon_context_get_current_point"

///|
#borrow(ctx, result)
extern "C" fn context_has_current_point_ffi(
  ctx : Context,
  result : Ref[Int],
) -> Status = "cairoon_context_has_current_point"

///|
#borrow(ctx, status)
extern "C" fn context_copy_path_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Path = "cairoon_context_copy_path"

///|
#borrow(ctx, status)
extern "C" fn context_copy_path_flat_ffi(
  ctx : Context,
  status : Ref[Status],
) -> Path = "cairoon_context_copy_path_flat"

///|
#borrow(ctx, path)
extern "C" fn context_append_path_ffi(ctx : Context, path : Path) -> Status = "cairoon_context_append_path"
