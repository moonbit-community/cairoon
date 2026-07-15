///|
#borrow(ctx)
extern "C" fn context_move_to_ffi(
  ctx : RawContext,
  x : Double,
  y : Double,
) -> Int = "cairoon_context_move_to"

///|
#borrow(ctx)
extern "C" fn context_rel_move_to_ffi(
  ctx : RawContext,
  dx : Double,
  dy : Double,
) -> Int = "cairoon_context_rel_move_to"

///|
#borrow(ctx)
extern "C" fn context_line_to_ffi(
  ctx : RawContext,
  x : Double,
  y : Double,
) -> Int = "cairoon_context_line_to"

///|
#borrow(ctx)
extern "C" fn context_rel_line_to_ffi(
  ctx : RawContext,
  dx : Double,
  dy : Double,
) -> Int = "cairoon_context_rel_line_to"

///|
#borrow(ctx)
extern "C" fn context_curve_to_ffi(
  ctx : RawContext,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Int = "cairoon_context_curve_to"

///|
#borrow(ctx)
extern "C" fn context_rel_curve_to_ffi(
  ctx : RawContext,
  dx1 : Double,
  dy1 : Double,
  dx2 : Double,
  dy2 : Double,
  dx3 : Double,
  dy3 : Double,
) -> Int = "cairoon_context_rel_curve_to"

///|
#borrow(ctx)
extern "C" fn context_rectangle_ffi(
  ctx : RawContext,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Int = "cairoon_context_rectangle"

///|
#borrow(ctx)
extern "C" fn context_arc_ffi(
  ctx : RawContext,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Int = "cairoon_context_arc"

///|
#borrow(ctx)
extern "C" fn context_arc_negative_ffi(
  ctx : RawContext,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Int = "cairoon_context_arc_negative"

///|
#borrow(ctx)
extern "C" fn context_close_path_ffi(ctx : RawContext) -> Int = "cairoon_context_close_path"

///|
#borrow(ctx)
extern "C" fn context_new_path_ffi(ctx : RawContext) -> Int = "cairoon_context_new_path"

///|
#borrow(ctx)
extern "C" fn context_new_sub_path_ffi(ctx : RawContext) -> Int = "cairoon_context_new_sub_path"

///|
#borrow(ctx, x, y)
extern "C" fn context_get_current_point_ffi(
  ctx : RawContext,
  x : Ref[Double],
  y : Ref[Double],
) -> Int = "cairoon_context_get_current_point"

///|
#borrow(ctx, result)
extern "C" fn context_has_current_point_ffi(
  ctx : RawContext,
  result : Ref[Int],
) -> Int = "cairoon_context_has_current_point"

///|
#borrow(ctx, status)
extern "C" fn context_copy_path_ffi(
  ctx : RawContext,
  status : Ref[Int],
) -> @path_impl.RawPath = "cairoon_context_copy_path"

///|
#borrow(ctx, status)
extern "C" fn context_copy_path_flat_ffi(
  ctx : RawContext,
  status : Ref[Int],
) -> @path_impl.RawPath = "cairoon_context_copy_path_flat"

///|
#borrow(ctx, path)
extern "C" fn context_append_path_ffi(
  ctx : RawContext,
  path : @path_impl.RawPath,
) -> Int = "cairoon_context_append_path"
