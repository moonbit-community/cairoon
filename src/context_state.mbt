///|
pub fn Context::set_line_width(
  self : Context,
  width : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_line_width_raw(self.to_raw(), width),
  )
}

///|
pub fn Context::get_line_width(self : Context) -> Double raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_line_width_raw(self.to_raw())
}

///|
pub fn Context::set_hairline(
  self : Context,
  set_hairline : Bool,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_hairline_raw(self.to_raw(), set_hairline),
  )
}

///|
pub fn Context::get_hairline(self : Context) -> Bool raise CairoError {
  let status = Ref(0)
  let hairline = @context_impl.get_hairline_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  hairline
}

///|
fn line_cap_from_raw(raw : Int) -> LineCap raise CairoError {
  match raw {
    0 => LineCapButt
    1 => LineCapRound
    2 => LineCapSquare
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo line cap: \{raw}",
      )
  }
}

///|
pub fn Context::set_line_cap(
  self : Context,
  cap : LineCap,
) -> Unit raise CairoError {
  check_status(context_set_line_cap_ffi(self.to_raw(), cap))
}

///|
pub fn Context::get_line_cap(self : Context) -> LineCap raise CairoError {
  line_cap_from_raw(self.get_line_cap_raw())
}

///|
pub fn Context::set_line_cap_raw(
  self : Context,
  cap : Int,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.set_line_cap_raw(self.to_raw(), cap))
}

///|
pub fn Context::get_line_cap_raw(self : Context) -> Int raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_line_cap_raw(self.to_raw())
}

///|
fn line_join_from_raw(raw : Int) -> LineJoin raise CairoError {
  match raw {
    0 => LineJoinMiter
    1 => LineJoinRound
    2 => LineJoinBevel
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo line join: \{raw}",
      )
  }
}

///|
pub fn Context::set_line_join(
  self : Context,
  join : LineJoin,
) -> Unit raise CairoError {
  check_status(context_set_line_join_ffi(self.to_raw(), join))
}

///|
pub fn Context::get_line_join(self : Context) -> LineJoin raise CairoError {
  line_join_from_raw(self.get_line_join_raw())
}

///|
pub fn Context::set_line_join_raw(
  self : Context,
  join : Int,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.set_line_join_raw(self.to_raw(), join))
}

///|
pub fn Context::get_line_join_raw(self : Context) -> Int raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_line_join_raw(self.to_raw())
}

///|
fn fill_rule_from_raw(raw : Int) -> FillRule raise CairoError {
  match raw {
    0 => FillWinding
    1 => FillEvenOdd
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo fill rule: \{raw}",
      )
  }
}

///|
pub fn Context::set_fill_rule(
  self : Context,
  fill_rule : FillRule,
) -> Unit raise CairoError {
  check_status(context_set_fill_rule_ffi(self.to_raw(), fill_rule))
}

///|
pub fn Context::get_fill_rule(self : Context) -> FillRule raise CairoError {
  fill_rule_from_raw(self.get_fill_rule_raw())
}

///|
pub fn Context::set_fill_rule_raw(
  self : Context,
  fill_rule : Int,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_fill_rule_raw(self.to_raw(), fill_rule),
  )
}

///|
pub fn Context::get_fill_rule_raw(self : Context) -> Int raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_fill_rule_raw(self.to_raw())
}

///|
pub fn Context::set_operator(
  self : Context,
  operator : Operator,
) -> Unit raise CairoError {
  check_status(context_set_operator_ffi(self.to_raw(), operator))
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
  check_context_status_raw(
    @context_impl.set_operator_raw(self.to_raw(), operator),
  )
}

///|
pub fn Context::get_operator_raw(self : Context) -> Int raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_operator_raw(self.to_raw())
}

///|
pub fn Context::set_antialias(
  self : Context,
  antialias : Antialias,
) -> Unit raise CairoError {
  check_status(context_set_antialias_ffi(self.to_raw(), antialias))
}

///|
fn antialias_from_raw(raw : Int) -> Antialias raise CairoError {
  match raw {
    0 => AntialiasDefault
    1 => AntialiasNone
    2 => AntialiasGray
    3 => AntialiasSubpixel
    4 => AntialiasFast
    5 => AntialiasGood
    6 => AntialiasBest
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo antialias: \{raw}",
      )
  }
}

///|
pub fn Context::get_antialias(self : Context) -> Antialias raise CairoError {
  antialias_from_raw(self.get_antialias_raw())
}

///|
pub fn Context::set_antialias_raw(
  self : Context,
  antialias : Int,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_antialias_raw(self.to_raw(), antialias),
  )
}

///|
pub fn Context::get_antialias_raw(self : Context) -> Int raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_antialias_raw(self.to_raw())
}

///|
pub fn Context::set_tolerance(
  self : Context,
  tolerance : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_tolerance_raw(self.to_raw(), tolerance),
  )
}

///|
pub fn Context::get_tolerance(self : Context) -> Double raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_tolerance_raw(self.to_raw())
}

///|
pub fn Context::set_miter_limit(
  self : Context,
  limit : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_miter_limit_raw(self.to_raw(), limit),
  )
}

///|
pub fn Context::get_miter_limit(self : Context) -> Double raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_miter_limit_raw(self.to_raw())
}

///|
pub fn Context::set_dash(
  self : Context,
  dashes : ArrayView[Double],
  offset? : Double = 0.0,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_dash_raw(
      self.to_raw(),
      FixedArray::from_array(dashes),
      offset,
    ),
  )
}

///|
pub fn Context::get_dash_count(self : Context) -> Int raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_dash_count_raw(self.to_raw())
}

///|
pub fn Context::get_dash(
  self : Context,
) -> (Array[Double], Double) raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  let offset = Ref(0.0)
  let dashes = @context_impl.get_dash_raw(self.to_raw(), offset)
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  (dashes.iter().collect(), offset.val)
}
