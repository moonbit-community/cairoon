///|
#borrow(ctx)
extern "C" fn context_set_source_rgb_ffi(
  ctx : RawContext,
  red : Double,
  green : Double,
  blue : Double,
) -> Int = "cairoon_context_set_source_rgb"

///|
#borrow(ctx)
extern "C" fn context_set_source_rgba_ffi(
  ctx : RawContext,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Int = "cairoon_context_set_source_rgba"

///|
#borrow(ctx, pattern)
extern "C" fn context_set_source_ffi(
  ctx : RawContext,
  pattern : @pattern_impl.RawPattern,
) -> Int = "cairoon_context_set_source"

///|
#borrow(ctx)
extern "C" fn context_paint_ffi(ctx : RawContext) -> Int = "cairoon_context_paint"

///|
#borrow(ctx)
extern "C" fn context_paint_with_alpha_ffi(
  ctx : RawContext,
  alpha : Double,
) -> Int = "cairoon_context_paint_with_alpha"

///|
#borrow(ctx, pattern)
extern "C" fn context_mask_ffi(
  ctx : RawContext,
  pattern : @pattern_impl.RawPattern,
) -> Int = "cairoon_context_mask"

///|
#borrow(ctx)
extern "C" fn context_fill_ffi(ctx : RawContext) -> Int = "cairoon_context_fill"

///|
#borrow(ctx)
extern "C" fn context_fill_preserve_ffi(ctx : RawContext) -> Int = "cairoon_context_fill_preserve"

///|
#borrow(ctx)
extern "C" fn context_stroke_ffi(ctx : RawContext) -> Int = "cairoon_context_stroke"

///|
#borrow(ctx)
extern "C" fn context_stroke_preserve_ffi(ctx : RawContext) -> Int = "cairoon_context_stroke_preserve"

///|
#borrow(ctx)
extern "C" fn context_copy_page_ffi(ctx : RawContext) -> Int = "cairoon_context_copy_page"

///|
#borrow(ctx)
extern "C" fn context_show_page_ffi(ctx : RawContext) -> Int = "cairoon_context_show_page"
