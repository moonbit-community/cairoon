///|
#borrow(ctx)
extern "C" fn context_clip_ffi(ctx : Context) -> Status = "cairoon_context_clip"

///|
#borrow(ctx)
extern "C" fn context_clip_preserve_ffi(ctx : Context) -> Status = "cairoon_context_clip_preserve"

///|
#borrow(ctx)
extern "C" fn context_reset_clip_ffi(ctx : Context) -> Status = "cairoon_context_reset_clip"

///|
#borrow(ctx, x1, y1, x2, y2)
extern "C" fn context_clip_extents_ffi(
  ctx : Context,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Status = "cairoon_context_clip_extents"

///|
#borrow(ctx, result)
extern "C" fn context_in_clip_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  result : Ref[Int],
) -> Status = "cairoon_context_in_clip"

///|
#borrow(ctx, status)
extern "C" fn context_copy_clip_rectangle_list_ffi(
  ctx : Context,
  status : Ref[Status],
) -> FixedArray[Double] = "cairoon_context_copy_clip_rectangle_list"

///|
#borrow(ctx, x1, y1, x2, y2)
extern "C" fn context_fill_extents_ffi(
  ctx : Context,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Status = "cairoon_context_fill_extents"

///|
#borrow(ctx, x1, y1, x2, y2)
extern "C" fn context_stroke_extents_ffi(
  ctx : Context,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Status = "cairoon_context_stroke_extents"

///|
#borrow(ctx, x1, y1, x2, y2)
extern "C" fn context_path_extents_ffi(
  ctx : Context,
  x1 : Ref[Double],
  y1 : Ref[Double],
  x2 : Ref[Double],
  y2 : Ref[Double],
) -> Status = "cairoon_context_path_extents"

///|
#borrow(ctx, result)
extern "C" fn context_in_fill_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  result : Ref[Int],
) -> Status = "cairoon_context_in_fill"

///|
#borrow(ctx, result)
extern "C" fn context_in_stroke_ffi(
  ctx : Context,
  x : Double,
  y : Double,
  result : Ref[Int],
) -> Status = "cairoon_context_in_stroke"
