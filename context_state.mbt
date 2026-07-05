///|
pub fn Context::set_line_width(
  self : Context,
  width : Double,
) -> Unit raise CairoError {
  check_status(context_set_line_width_ffi(self, width))
}

///|
pub fn Context::get_line_width(self : Context) -> Double raise CairoError {
  check_status(context_status_ffi(self))
  context_get_line_width_ffi(self)
}

///|
pub fn Context::set_hairline(
  self : Context,
  set_hairline : Bool,
) -> Unit raise CairoError {
  check_status(context_set_hairline_ffi(self, set_hairline))
}

///|
pub fn Context::get_hairline(self : Context) -> Bool raise CairoError {
  check_status(context_status_ffi(self))
  context_get_hairline_ffi(self)
}

///|
pub fn Context::set_line_cap(
  self : Context,
  cap : LineCap,
) -> Unit raise CairoError {
  check_status(context_set_line_cap_ffi(self, cap))
}

///|
pub fn Context::get_line_cap(self : Context) -> LineCap raise CairoError {
  check_status(context_status_ffi(self))
  context_get_line_cap_ffi(self)
}

///|
pub fn Context::set_line_join(
  self : Context,
  join : LineJoin,
) -> Unit raise CairoError {
  check_status(context_set_line_join_ffi(self, join))
}

///|
pub fn Context::get_line_join(self : Context) -> LineJoin raise CairoError {
  check_status(context_status_ffi(self))
  context_get_line_join_ffi(self)
}

///|
pub fn Context::set_fill_rule(
  self : Context,
  fill_rule : FillRule,
) -> Unit raise CairoError {
  check_status(context_set_fill_rule_ffi(self, fill_rule))
}

///|
pub fn Context::get_fill_rule(self : Context) -> FillRule raise CairoError {
  check_status(context_status_ffi(self))
  context_get_fill_rule_ffi(self)
}

///|
pub fn Context::set_operator(
  self : Context,
  operator : Operator,
) -> Unit raise CairoError {
  check_status(context_set_operator_ffi(self, operator))
}

///|
fn operator_from_raw(raw : Int) -> Operator raise CairoError {
  match raw {
    0 => OperatorClear
    1 => OperatorSource
    2 => OperatorOver
    3 => OperatorIn
    4 => OperatorOut
    5 => OperatorAtop
    6 => OperatorDest
    7 => OperatorDestOver
    8 => OperatorDestIn
    9 => OperatorDestOut
    10 => OperatorDestAtop
    11 => OperatorXor
    12 => OperatorAdd
    13 => OperatorSaturate
    14 => OperatorMultiply
    15 => OperatorScreen
    16 => OperatorOverlay
    17 => OperatorDarken
    18 => OperatorLighten
    19 => OperatorColorDodge
    20 => OperatorColorBurn
    21 => OperatorHardLight
    22 => OperatorSoftLight
    23 => OperatorDifference
    24 => OperatorExclusion
    25 => OperatorHslHue
    26 => OperatorHslSaturation
    27 => OperatorHslColor
    28 => OperatorHslLuminosity
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo operator: \{raw}",
      )
  }
}

///|
pub fn Context::get_operator(self : Context) -> Operator raise CairoError {
  operator_from_raw(self.get_operator_raw())
}

///|
pub fn Context::set_operator_raw(
  self : Context,
  operator : Int,
) -> Unit raise CairoError {
  check_status(context_set_operator_raw_ffi(self, operator))
}

///|
pub fn Context::get_operator_raw(self : Context) -> Int raise CairoError {
  check_status(context_status_ffi(self))
  context_get_operator_raw_ffi(self)
}

///|
pub fn Context::set_antialias(
  self : Context,
  antialias : Antialias,
) -> Unit raise CairoError {
  check_status(context_set_antialias_ffi(self, antialias))
}

///|
pub fn Context::get_antialias(self : Context) -> Antialias raise CairoError {
  check_status(context_status_ffi(self))
  context_get_antialias_ffi(self)
}

///|
pub fn Context::set_tolerance(
  self : Context,
  tolerance : Double,
) -> Unit raise CairoError {
  check_status(context_set_tolerance_ffi(self, tolerance))
}

///|
pub fn Context::get_tolerance(self : Context) -> Double raise CairoError {
  check_status(context_status_ffi(self))
  context_get_tolerance_ffi(self)
}

///|
pub fn Context::set_miter_limit(
  self : Context,
  limit : Double,
) -> Unit raise CairoError {
  check_status(context_set_miter_limit_ffi(self, limit))
}

///|
pub fn Context::get_miter_limit(self : Context) -> Double raise CairoError {
  check_status(context_status_ffi(self))
  context_get_miter_limit_ffi(self)
}

///|
pub fn Context::set_dash(
  self : Context,
  dashes : ArrayView[Double],
  offset? : Double = 0.0,
) -> Unit raise CairoError {
  check_status(
    context_set_dash_ffi(self, FixedArray::from_array(dashes), offset),
  )
}

///|
pub fn Context::get_dash_count(self : Context) -> Int raise CairoError {
  check_status(context_status_ffi(self))
  context_get_dash_count_ffi(self)
}

///|
pub fn Context::get_dash(
  self : Context,
) -> (Array[Double], Double) raise CairoError {
  check_status(context_status_ffi(self))
  let offset = Ref(0.0)
  let dashes = context_get_dash_ffi(self, offset)
  check_status(context_status_ffi(self))
  (dashes.iter().collect(), offset.val)
}

///|
