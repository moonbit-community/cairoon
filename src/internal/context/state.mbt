///|
pub fn set_line_width_raw(ctx : RawContext, width : Double) -> Int {
  ensure_native()
  context_set_line_width_ffi(ctx, width)
}

///|
pub fn get_line_width_raw(ctx : RawContext) -> Double {
  ensure_native()
  context_get_line_width_ffi(ctx)
}

///|
pub fn set_hairline_raw(ctx : RawContext, set_hairline : Bool) -> Int {
  ensure_native()
  context_set_hairline_ffi(ctx, set_hairline)
}

///|
pub fn get_hairline_raw(ctx : RawContext, status : Ref[Int]) -> Bool {
  ensure_native()
  context_get_hairline_ffi(ctx, status)
}

///|
pub fn set_line_cap_raw(ctx : RawContext, cap : Int) -> Int {
  ensure_native()
  context_set_line_cap_raw_ffi(ctx, cap)
}

///|
pub fn get_line_cap_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_get_line_cap_raw_ffi(ctx)
}

///|
pub fn set_line_join_raw(ctx : RawContext, join : Int) -> Int {
  ensure_native()
  context_set_line_join_raw_ffi(ctx, join)
}

///|
pub fn get_line_join_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_get_line_join_raw_ffi(ctx)
}

///|
pub fn set_fill_rule_raw(ctx : RawContext, fill_rule : Int) -> Int {
  ensure_native()
  context_set_fill_rule_raw_ffi(ctx, fill_rule)
}

///|
pub fn get_fill_rule_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_get_fill_rule_raw_ffi(ctx)
}

///|
pub fn set_operator_raw(ctx : RawContext, operator : Int) -> Int {
  ensure_native()
  context_set_operator_raw_ffi(ctx, operator)
}

///|
pub fn get_operator_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_get_operator_raw_ffi(ctx)
}

///|
pub fn set_antialias_raw(ctx : RawContext, antialias : Int) -> Int {
  ensure_native()
  context_set_antialias_raw_ffi(ctx, antialias)
}

///|
pub fn get_antialias_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_get_antialias_raw_ffi(ctx)
}

///|
pub fn set_tolerance_raw(ctx : RawContext, tolerance : Double) -> Int {
  ensure_native()
  context_set_tolerance_ffi(ctx, tolerance)
}

///|
pub fn get_tolerance_raw(ctx : RawContext) -> Double {
  ensure_native()
  context_get_tolerance_ffi(ctx)
}

///|
pub fn set_miter_limit_raw(ctx : RawContext, limit : Double) -> Int {
  ensure_native()
  context_set_miter_limit_ffi(ctx, limit)
}

///|
pub fn get_miter_limit_raw(ctx : RawContext) -> Double {
  ensure_native()
  context_get_miter_limit_ffi(ctx)
}

///|
pub fn set_dash_raw(
  ctx : RawContext,
  dashes : FixedArray[Double],
  offset : Double,
) -> Int {
  ensure_native()
  context_set_dash_ffi(ctx, dashes, offset)
}

///|
pub fn get_dash_count_raw(ctx : RawContext) -> Int {
  ensure_native()
  context_get_dash_count_ffi(ctx)
}

///|
pub fn get_dash_raw(
  ctx : RawContext,
  offset : Ref[Double],
) -> FixedArray[Double] {
  ensure_native()
  context_get_dash_ffi(ctx, offset)
}
