///|
#borrow(ctx)
extern "C" fn context_set_line_width_ffi(
  ctx : Context,
  width : Double,
) -> Status = "cairoon_context_set_line_width"

///|
#borrow(ctx)
extern "C" fn context_get_line_width_ffi(ctx : Context) -> Double = "cairoon_context_get_line_width"

///|
#borrow(ctx)
extern "C" fn context_set_hairline_ffi(
  ctx : Context,
  set_hairline : Bool,
) -> Status = "cairoon_context_set_hairline"

///|
#borrow(ctx)
extern "C" fn context_get_hairline_ffi(ctx : Context) -> Bool = "cairoon_context_get_hairline"

///|
#borrow(ctx)
extern "C" fn context_set_line_cap_ffi(ctx : Context, cap : LineCap) -> Status = "cairoon_context_set_line_cap"

///|
#borrow(ctx)
extern "C" fn context_set_line_cap_raw_ffi(ctx : Context, cap : Int) -> Status = "cairoon_context_set_line_cap_raw"

///|
#borrow(ctx)
extern "C" fn context_get_line_cap_raw_ffi(ctx : Context) -> Int = "cairoon_context_get_line_cap_raw"

///|
#borrow(ctx)
extern "C" fn context_set_line_join_ffi(
  ctx : Context,
  join : LineJoin,
) -> Status = "cairoon_context_set_line_join"

///|
#borrow(ctx)
extern "C" fn context_set_line_join_raw_ffi(
  ctx : Context,
  join : Int,
) -> Status = "cairoon_context_set_line_join_raw"

///|
#borrow(ctx)
extern "C" fn context_get_line_join_raw_ffi(ctx : Context) -> Int = "cairoon_context_get_line_join_raw"

///|
#borrow(ctx)
extern "C" fn context_set_fill_rule_ffi(
  ctx : Context,
  fill_rule : FillRule,
) -> Status = "cairoon_context_set_fill_rule"

///|
#borrow(ctx)
extern "C" fn context_set_fill_rule_raw_ffi(
  ctx : Context,
  fill_rule : Int,
) -> Status = "cairoon_context_set_fill_rule_raw"

///|
#borrow(ctx)
extern "C" fn context_get_fill_rule_raw_ffi(ctx : Context) -> Int = "cairoon_context_get_fill_rule_raw"

///|
#borrow(ctx)
extern "C" fn context_set_operator_ffi(
  ctx : Context,
  operator : Operator,
) -> Status = "cairoon_context_set_operator"

///|
#borrow(ctx)
extern "C" fn context_set_operator_raw_ffi(
  ctx : Context,
  operator : Int,
) -> Status = "cairoon_context_set_operator_raw"

///|
#borrow(ctx)
extern "C" fn context_get_operator_raw_ffi(ctx : Context) -> Int = "cairoon_context_get_operator_raw"

///|
#borrow(ctx)
extern "C" fn context_set_antialias_ffi(
  ctx : Context,
  antialias : Antialias,
) -> Status = "cairoon_context_set_antialias"

///|
#borrow(ctx)
extern "C" fn context_set_antialias_raw_ffi(
  ctx : Context,
  antialias : Int,
) -> Status = "cairoon_context_set_antialias_raw"

///|
#borrow(ctx)
extern "C" fn context_get_antialias_raw_ffi(ctx : Context) -> Int = "cairoon_context_get_antialias_raw"

///|
#borrow(ctx)
extern "C" fn context_set_tolerance_ffi(
  ctx : Context,
  tolerance : Double,
) -> Status = "cairoon_context_set_tolerance"

///|
#borrow(ctx)
extern "C" fn context_get_tolerance_ffi(ctx : Context) -> Double = "cairoon_context_get_tolerance"

///|
#borrow(ctx)
extern "C" fn context_set_miter_limit_ffi(
  ctx : Context,
  limit : Double,
) -> Status = "cairoon_context_set_miter_limit"

///|
#borrow(ctx)
extern "C" fn context_get_miter_limit_ffi(ctx : Context) -> Double = "cairoon_context_get_miter_limit"

///|
#borrow(ctx, dashes)
extern "C" fn context_set_dash_ffi(
  ctx : Context,
  dashes : FixedArray[Double],
  offset : Double,
) -> Status = "cairoon_context_set_dash"

///|
#borrow(ctx)
extern "C" fn context_get_dash_count_ffi(ctx : Context) -> Int = "cairoon_context_get_dash_count"

///|
#borrow(ctx, offset)
extern "C" fn context_get_dash_ffi(
  ctx : Context,
  offset : Ref[Double],
) -> FixedArray[Double] = "cairoon_context_get_dash"
