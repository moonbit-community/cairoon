///|
pub fn move_to_raw(ctx : RawContext, x : Double, y : Double) -> Int {
  ensure_native()
  context_move_to_ffi(ctx, x, y)
}

///|
pub fn rel_move_to_raw(ctx : RawContext, dx : Double, dy : Double) -> Int {
  ensure_native()
  context_rel_move_to_ffi(ctx, dx, dy)
}

///|
pub fn line_to_raw(ctx : RawContext, x : Double, y : Double) -> Int {
  ensure_native()
  context_line_to_ffi(ctx, x, y)
}

///|
pub fn rel_line_to_raw(ctx : RawContext, dx : Double, dy : Double) -> Int {
  ensure_native()
  context_rel_line_to_ffi(ctx, dx, dy)
}

///|
pub fn curve_to_raw(
  ctx : RawContext,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Int {
  ensure_native()
  context_curve_to_ffi(ctx, x1, y1, x2, y2, x3, y3)
}

///|
pub fn rel_curve_to_raw(
  ctx : RawContext,
  dx1 : Double,
  dy1 : Double,
  dx2 : Double,
  dy2 : Double,
  dx3 : Double,
  dy3 : Double,
) -> Int {
  ensure_native()
  context_rel_curve_to_ffi(ctx, dx1, dy1, dx2, dy2, dx3, dy3)
}

///|
pub fn rectangle_raw(
  ctx : RawContext,
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Int {
  ensure_native()
  context_rectangle_ffi(ctx, x, y, width, height)
}

///|
pub fn arc_raw(
  ctx : RawContext,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Int {
  ensure_native()
  context_arc_ffi(ctx, xc, yc, radius, angle1, angle2)
}

///|
pub fn arc_negative_raw(
  ctx : RawContext,
  xc : Double,
  yc : Double,
  radius : Double,
  angle1 : Double,
  angle2 : Double,
) -> Int {
  ensure_native()
  context_arc_negative_ffi(ctx, xc, yc, radius, angle1, angle2)
}

///|
pub fn close_path_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_close_path_ffi(ctx)
}

///|
pub fn new_path_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_new_path_ffi(ctx)
}

///|
pub fn new_sub_path_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_new_sub_path_ffi(ctx)
}

///|
pub fn get_current_point_raw(
  ctx : RawContext,
  x : Ref[Double],
  y : Ref[Double],
) -> Int {
  ensure_native()
  context_get_current_point_ffi(ctx, x, y)
}

///|
pub fn has_current_point_raw(ctx : RawContext, result : Ref[Int]) -> Int {
  ensure_native()
  context_has_current_point_ffi(ctx, result)
}

///|
pub fn copy_path_raw(ctx : RawContext, status : Ref[Int]) -> @path_impl.RawPath {
  ensure_native()
  context_copy_path_ffi(ctx, status)
}

///|
pub fn copy_path_flat_raw(
  ctx : RawContext,
  status : Ref[Int],
) -> @path_impl.RawPath {
  ensure_native()
  context_copy_path_flat_ffi(ctx, status)
}

///|
pub fn append_path_raw(ctx : RawContext, path : @path_impl.RawPath) -> Int {
  ensure_native()
  context_append_path_ffi(ctx, path)
}
