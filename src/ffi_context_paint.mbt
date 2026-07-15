///|
#borrow(ctx)
extern "C" fn context_set_source_rgb_ffi(
  ctx : Context,
  red : Double,
  green : Double,
  blue : Double,
) -> Status = "cairoon_context_set_source_rgb"

///|
#borrow(ctx)
extern "C" fn context_set_source_rgba_ffi(
  ctx : Context,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Status = "cairoon_context_set_source_rgba"

///|
#borrow(ctx, pattern)
extern "C" fn context_set_source_ffi(
  ctx : Context,
  pattern : @pattern_impl.RawPattern,
) -> Status = "cairoon_context_set_source"

///|
#borrow(ctx, surface)
extern "C" fn context_set_source_surface_ffi(
  ctx : Context,
  surface : Surface,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_set_source_surface"

///|
#borrow(ctx)
extern "C" fn context_paint_ffi(ctx : Context) -> Status = "cairoon_context_paint"

///|
#borrow(ctx)
extern "C" fn context_paint_with_alpha_ffi(
  ctx : Context,
  alpha : Double,
) -> Status = "cairoon_context_paint_with_alpha"

///|
#borrow(ctx, pattern)
extern "C" fn context_mask_ffi(
  ctx : Context,
  pattern : @pattern_impl.RawPattern,
) -> Status = "cairoon_context_mask"

///|
#borrow(ctx, surface)
extern "C" fn context_mask_surface_ffi(
  ctx : Context,
  surface : Surface,
  x : Double,
  y : Double,
) -> Status = "cairoon_context_mask_surface"

///|
#borrow(ctx)
extern "C" fn context_fill_ffi(ctx : Context) -> Status = "cairoon_context_fill"

///|
#borrow(ctx)
extern "C" fn context_fill_preserve_ffi(ctx : Context) -> Status = "cairoon_context_fill_preserve"

///|
#borrow(ctx)
extern "C" fn context_stroke_ffi(ctx : Context) -> Status = "cairoon_context_stroke"

///|
#borrow(ctx)
extern "C" fn context_stroke_preserve_ffi(ctx : Context) -> Status = "cairoon_context_stroke_preserve"

///|
#borrow(ctx)
extern "C" fn context_copy_page_ffi(ctx : Context) -> Status = "cairoon_context_copy_page"

///|
#borrow(ctx)
extern "C" fn context_show_page_ffi(ctx : Context) -> Status = "cairoon_context_show_page"
