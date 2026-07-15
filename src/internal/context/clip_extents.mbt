///|
pub fn clip_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_clip_ffi(ctx)
}

///|
pub fn clip_preserve_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_clip_preserve_ffi(ctx)
}

///|
pub fn reset_clip_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_reset_clip_ffi(ctx)
}

///|
pub fn clip_extents_raw(
  ctx : RawContext,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Int {
  ensure_native()
  context_clip_extents_ffi(ctx, x1, y1, x2, y2)
}

///|
pub fn in_clip_raw(
  ctx : RawContext,
  x : Double,
  y : Double,
  result : Ref[Int],
) -> Int {
  ensure_native()
  context_in_clip_ffi(ctx, x, y, result)
}

///|
pub fn copy_clip_rectangle_list_raw(
  ctx : RawContext,
  status : Ref[Int],
) -> FixedArray[Double] {
  ensure_native()
  context_copy_clip_rectangle_list_ffi(ctx, status)
}

///|
pub fn fill_extents_raw(
  ctx : RawContext,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Int {
  ensure_native()
  context_fill_extents_ffi(ctx, x1, y1, x2, y2)
}

///|
pub fn stroke_extents_raw(
  ctx : RawContext,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Int {
  ensure_native()
  context_stroke_extents_ffi(ctx, x1, y1, x2, y2)
}

///|
pub fn path_extents_raw(
  ctx : RawContext,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Int {
  ensure_native()
  context_path_extents_ffi(ctx, x1, y1, x2, y2)
}

///|
pub fn in_fill_raw(
  ctx : RawContext,
  x : Double,
  y : Double,
  result : Ref[Int],
) -> Int {
  ensure_native()
  context_in_fill_ffi(ctx, x, y, result)
}

///|
pub fn in_stroke_raw(
  ctx : RawContext,
  x : Double,
  y : Double,
  result : Ref[Int],
) -> Int {
  ensure_native()
  context_in_stroke_ffi(ctx, x, y, result)
}
