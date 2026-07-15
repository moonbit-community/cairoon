///|
#borrow(ctx)
extern "C" fn context_set_line_width_ffi(
  ctx : RawContext,
  width : Double,
) -> Int = "cairoon_context_set_line_width"

///|
#borrow(ctx)
extern "C" fn context_get_line_width_ffi(ctx : RawContext) -> Double = "cairoon_context_get_line_width"

///|
#borrow(ctx)
extern "C" fn context_set_hairline_ffi(
  ctx : RawContext,
  set_hairline : Bool,
) -> Int = "cairoon_context_set_hairline"

///|
#borrow(ctx, status)
extern "C" fn context_get_hairline_ffi(
  ctx : RawContext,
  status : Ref[Int],
) -> Bool = "cairoon_context_get_hairline"

///|
#borrow(ctx)
extern "C" fn context_set_line_cap_raw_ffi(ctx : RawContext, cap : Int) -> Int = "cairoon_context_set_line_cap_raw"

///|
#borrow(ctx)
extern "C" fn context_get_line_cap_raw_ffi(ctx : RawContext) -> Int = "cairoon_context_get_line_cap_raw"

///|
#borrow(ctx)
extern "C" fn context_set_line_join_raw_ffi(
  ctx : RawContext,
  join : Int,
) -> Int = "cairoon_context_set_line_join_raw"

///|
#borrow(ctx)
extern "C" fn context_get_line_join_raw_ffi(ctx : RawContext) -> Int = "cairoon_context_get_line_join_raw"

///|
#borrow(ctx)
extern "C" fn context_set_fill_rule_raw_ffi(
  ctx : RawContext,
  fill_rule : Int,
) -> Int = "cairoon_context_set_fill_rule_raw"

///|
#borrow(ctx)
extern "C" fn context_get_fill_rule_raw_ffi(ctx : RawContext) -> Int = "cairoon_context_get_fill_rule_raw"

///|
#borrow(ctx)
extern "C" fn context_set_operator_raw_ffi(
  ctx : RawContext,
  operator : Int,
) -> Int = "cairoon_context_set_operator_raw"

///|
#borrow(ctx)
extern "C" fn context_get_operator_raw_ffi(ctx : RawContext) -> Int = "cairoon_context_get_operator_raw"

///|
#borrow(ctx)
extern "C" fn context_set_antialias_raw_ffi(
  ctx : RawContext,
  antialias : Int,
) -> Int = "cairoon_context_set_antialias_raw"

///|
#borrow(ctx)
extern "C" fn context_get_antialias_raw_ffi(ctx : RawContext) -> Int = "cairoon_context_get_antialias_raw"

///|
#borrow(ctx)
extern "C" fn context_set_tolerance_ffi(
  ctx : RawContext,
  tolerance : Double,
) -> Int = "cairoon_context_set_tolerance"

///|
#borrow(ctx)
extern "C" fn context_get_tolerance_ffi(ctx : RawContext) -> Double = "cairoon_context_get_tolerance"

///|
#borrow(ctx)
extern "C" fn context_set_miter_limit_ffi(
  ctx : RawContext,
  limit : Double,
) -> Int = "cairoon_context_set_miter_limit"

///|
#borrow(ctx)
extern "C" fn context_get_miter_limit_ffi(ctx : RawContext) -> Double = "cairoon_context_get_miter_limit"

///|
#borrow(ctx, dashes)
extern "C" fn context_set_dash_ffi(
  ctx : RawContext,
  dashes : FixedArray[Double],
  offset : Double,
) -> Int = "cairoon_context_set_dash"

///|
#borrow(ctx)
extern "C" fn context_get_dash_count_ffi(ctx : RawContext) -> Int = "cairoon_context_get_dash_count"

///|
#borrow(ctx, offset)
extern "C" fn context_get_dash_ffi(
  ctx : RawContext,
  offset : Ref[Double],
) -> FixedArray[Double] = "cairoon_context_get_dash"
