///|
#borrow(ctx)
extern "C" fn context_set_line_cap_ffi(
  ctx : @context_impl.RawContext,
  cap : LineCap,
) -> Status = "cairoon_context_set_line_cap"

///|
#borrow(ctx)
extern "C" fn context_set_line_join_ffi(
  ctx : @context_impl.RawContext,
  join : LineJoin,
) -> Status = "cairoon_context_set_line_join"

///|
#borrow(ctx)
extern "C" fn context_set_fill_rule_ffi(
  ctx : @context_impl.RawContext,
  fill_rule : FillRule,
) -> Status = "cairoon_context_set_fill_rule"

///|
#borrow(ctx)
extern "C" fn context_set_operator_ffi(
  ctx : @context_impl.RawContext,
  operator : Operator,
) -> Status = "cairoon_context_set_operator"

///|
#borrow(ctx)
extern "C" fn context_set_antialias_ffi(
  ctx : @context_impl.RawContext,
  antialias : Antialias,
) -> Status = "cairoon_context_set_antialias"
