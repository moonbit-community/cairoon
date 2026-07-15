///|
pub fn set_source_rgb_raw(
  ctx : RawContext,
  red : Double,
  green : Double,
  blue : Double,
) -> Int {
  ensure_native()
  context_set_source_rgb_ffi(ctx, red, green, blue)
}

///|
pub fn set_source_rgba_raw(
  ctx : RawContext,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Int {
  ensure_native()
  context_set_source_rgba_ffi(ctx, red, green, blue, alpha)
}

///|
pub fn set_source_raw(
  ctx : RawContext,
  pattern : @pattern_impl.RawPattern,
) -> Int {
  ensure_native()
  context_set_source_ffi(ctx, pattern)
}

///|
pub fn paint_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_paint_ffi(ctx)
}

///|
pub fn paint_with_alpha_raw(ctx : RawContext, alpha : Double) -> Int {
  ensure_native()
  context_paint_with_alpha_ffi(ctx, alpha)
}

///|
pub fn mask_raw(ctx : RawContext, pattern : @pattern_impl.RawPattern) -> Int {
  ensure_native()
  context_mask_ffi(ctx, pattern)
}

///|
pub fn fill_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_fill_ffi(ctx)
}

///|
pub fn fill_preserve_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_fill_preserve_ffi(ctx)
}

///|
pub fn stroke_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_stroke_ffi(ctx)
}

///|
pub fn stroke_preserve_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_stroke_preserve_ffi(ctx)
}

///|
pub fn copy_page_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_copy_page_ffi(ctx)
}

///|
pub fn show_page_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_show_page_ffi(ctx)
}
