///|
/// Set the diameter of the pen used by later stroke operations.
///
/// `width` is measured in user-space units and interpreted with the current
/// transformation at stroke time. It is part of the current graphics state,
/// so `save()` and `restore()` preserve it. Raises the checked context status.
pub fn Context::set_line_width(
  self : Context,
  width : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_line_width_raw(self.to_raw(), width),
  )
}

///|
/// Return the current stroke width in user-space units.
///
/// This is the stored value supplied to `set_line_width`; changing the current
/// transformation does not rescale the value returned here. Raises the checked
/// context status.
pub fn Context::get_line_width(self : Context) -> Double raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_line_width_raw(self.to_raw())
}

///|
/// Enable or disable Cairo hairline stroking.
///
/// A hairline uses the thinnest stroke the target can represent, including a
/// native hairline where a vector backend supports one. It is a graphics-state
/// setting distinct from choosing a small line width. Requires Cairo 1.18 or
/// newer; older versions raise `CairoError(InvalidStatus, _)`.
pub fn Context::set_hairline(
  self : Context,
  set_hairline : Bool,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_hairline_raw(self.to_raw(), set_hairline),
  )
}

///|
/// Return whether hairline stroking is enabled in the current graphics state.
///
/// Requires Cairo 1.18 or newer. Older versions, or an invalid context, raise
/// the corresponding checked `CairoError`.
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
fn line_cap_to_raw(cap : LineCap) -> Int {
  match cap {
    LineCapButt => 0
    LineCapRound => 1
    LineCapSquare => 2
  }
}

///|
/// Set the typed shape used at the ends of open subpaths when stroking.
///
/// Cairo reads this graphics-state value at stroke time, not while the path is
/// constructed. Raises the checked context status.
pub fn Context::set_line_cap(
  self : Context,
  cap : LineCap,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_line_cap_raw(self.to_raw(), line_cap_to_raw(cap)),
  )
}

///|
/// Return the current typed line-cap mode.
///
/// The Cairo default is `LineCapButt`. An unknown value installed through the
/// raw compatibility API raises `CairoInvalidArgument(InvalidStatus, _)`.
pub fn Context::get_line_cap(self : Context) -> LineCap raise CairoError {
  line_cap_from_raw(self.get_line_cap_raw())
}

///|
/// Set the line-cap mode from an unvalidated Cairo C integer.
///
/// This pycairo compatibility entry point preserves unknown values; a later
/// typed getter rejects them with `CairoInvalidArgument(InvalidStatus, _)`.
/// Raises the checked context status.
pub fn Context::set_line_cap_raw(
  self : Context,
  cap : Int,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.set_line_cap_raw(self.to_raw(), cap))
}

///|
/// Return the exact Cairo C integer stored for the line-cap mode.
///
/// Unlike `get_line_cap`, this preserves unknown values. Raises the checked
/// context status before reading the value.
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
fn line_join_to_raw(join : LineJoin) -> Int {
  match join {
    LineJoinMiter => 0
    LineJoinRound => 1
    LineJoinBevel => 2
  }
}

///|
/// Set the typed shape used to join connected stroke segments.
///
/// Cairo reads this graphics-state value at stroke time. Miter joins are also
/// constrained by `set_miter_limit`. Raises the checked context status.
pub fn Context::set_line_join(
  self : Context,
  join : LineJoin,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_line_join_raw(self.to_raw(), line_join_to_raw(join)),
  )
}

///|
/// Return the current typed line-join mode.
///
/// The Cairo default is `LineJoinMiter`. An unknown value installed through
/// the raw API raises `CairoInvalidArgument(InvalidStatus, _)`.
pub fn Context::get_line_join(self : Context) -> LineJoin raise CairoError {
  line_join_from_raw(self.get_line_join_raw())
}

///|
/// Set the line-join mode from an unvalidated Cairo C integer.
///
/// Unknown values remain observable through `get_line_join_raw`; the typed
/// getter rejects them with `CairoInvalidArgument(InvalidStatus, _)`. Raises
/// the checked context status.
pub fn Context::set_line_join_raw(
  self : Context,
  join : Int,
) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.set_line_join_raw(self.to_raw(), join))
}

///|
/// Return the exact Cairo C integer stored for the line-join mode.
///
/// Unlike `get_line_join`, this preserves unknown values. Raises the checked
/// context status before reading the value.
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
fn fill_rule_to_raw(fill_rule : FillRule) -> Int {
  match fill_rule {
    FillWinding => 0
    FillEvenOdd => 1
  }
}

///|
/// Set the typed rule used to determine which path regions are inside.
///
/// The rule affects both fill operations and clipping and is stored in the
/// current graphics state. Raises the checked context status.
pub fn Context::set_fill_rule(
  self : Context,
  fill_rule : FillRule,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_fill_rule_raw(self.to_raw(), fill_rule_to_raw(fill_rule)),
  )
}

///|
/// Return the current typed fill rule.
///
/// The Cairo default is `FillWinding`. An unknown value installed through the
/// raw API raises `CairoInvalidArgument(InvalidStatus, _)`.
pub fn Context::get_fill_rule(self : Context) -> FillRule raise CairoError {
  fill_rule_from_raw(self.get_fill_rule_raw())
}

///|
/// Set the fill rule from an unvalidated Cairo C integer.
///
/// Unknown values remain observable through `get_fill_rule_raw`; the typed
/// getter rejects them with `CairoInvalidArgument(InvalidStatus, _)`. Raises
/// the checked context status.
pub fn Context::set_fill_rule_raw(
  self : Context,
  fill_rule : Int,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_fill_rule_raw(self.to_raw(), fill_rule),
  )
}

///|
/// Return the exact Cairo C integer stored for the fill rule.
///
/// Unlike `get_fill_rule`, this preserves unknown values. Raises the checked
/// context status before reading the value.
pub fn Context::get_fill_rule_raw(self : Context) -> Int raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_fill_rule_raw(self.to_raw())
}

///|
/// Set the typed compositing operator used by subsequent drawing operations.
///
/// The operator controls how source and destination pixels are combined and is
/// part of the current graphics state. Raises the checked context status.
pub fn Context::set_operator(
  self : Context,
  operator : Operator,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_operator_raw(self.to_raw(), operator_to_raw(operator)),
  )
}

///|
fn operator_to_raw(operator : Operator) -> Int {
  match operator {
    OperatorClear => 0
    OperatorSource => 1
    OperatorOver => 2
    OperatorIn => 3
    OperatorOut => 4
    OperatorAtop => 5
    OperatorDest => 6
    OperatorDestOver => 7
    OperatorDestIn => 8
    OperatorDestOut => 9
    OperatorDestAtop => 10
    OperatorXor => 11
    OperatorAdd => 12
    OperatorSaturate => 13
    OperatorMultiply => 14
    OperatorScreen => 15
    OperatorOverlay => 16
    OperatorDarken => 17
    OperatorLighten => 18
    OperatorColorDodge => 19
    OperatorColorBurn => 20
    OperatorHardLight => 21
    OperatorSoftLight => 22
    OperatorDifference => 23
    OperatorExclusion => 24
    OperatorHslHue => 25
    OperatorHslSaturation => 26
    OperatorHslColor => 27
    OperatorHslLuminosity => 28
  }
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
/// Return the current typed compositing operator.
///
/// The Cairo default is `OperatorOver`. An unknown value installed through the
/// raw API raises `CairoInvalidArgument(InvalidStatus, _)`.
pub fn Context::get_operator(self : Context) -> Operator raise CairoError {
  operator_from_raw(self.get_operator_raw())
}

///|
/// Set the compositing operator from an unvalidated Cairo C integer.
///
/// Unknown values remain observable through `get_operator_raw`; the typed
/// getter rejects them with `CairoInvalidArgument(InvalidStatus, _)`. Raises
/// the checked context status.
pub fn Context::set_operator_raw(
  self : Context,
  operator : Int,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_operator_raw(self.to_raw(), operator),
  )
}

///|
/// Return the exact Cairo C integer stored for the compositing operator.
///
/// Unlike `get_operator`, this preserves unknown values. Raises the checked
/// context status before reading the value.
pub fn Context::get_operator_raw(self : Context) -> Int raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_operator_raw(self.to_raw())
}

///|
/// Set the typed antialiasing mode for shapes drawn by this context.
///
/// This does not configure text-specific antialiasing in `FontOptions`. The
/// mode is part of the current graphics state. Raises the checked context
/// status.
pub fn Context::set_antialias(
  self : Context,
  antialias : Antialias,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_antialias_raw(self.to_raw(), antialias_to_raw(antialias)),
  )
}

///|
/// Return the current typed shape-antialiasing mode.
///
/// An unknown value installed through the raw API raises
/// `CairoInvalidArgument(InvalidStatus, _)`.
pub fn Context::get_antialias(self : Context) -> Antialias raise CairoError {
  antialias_from_raw(self.get_antialias_raw())
}

///|
/// Set shape antialiasing from an unvalidated Cairo C integer.
///
/// Unknown values remain observable through `get_antialias_raw`; the typed
/// getter rejects them with `CairoInvalidArgument(InvalidStatus, _)`. Raises
/// the checked context status.
pub fn Context::set_antialias_raw(
  self : Context,
  antialias : Int,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_antialias_raw(self.to_raw(), antialias),
  )
}

///|
/// Return the exact Cairo C integer stored for shape antialiasing.
///
/// Unlike `get_antialias`, this preserves unknown values. Raises the checked
/// context status before reading the value.
pub fn Context::get_antialias_raw(self : Context) -> Int raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_antialias_raw(self.to_raw())
}

///|
/// Set Cairo's curve-flattening tolerance in device-space units.
///
/// The tolerance bounds the permitted error when curves are approximated for
/// rendering: larger values can be faster and less accurate, while smaller
/// values can be slower and more accurate. Raises the checked context status.
pub fn Context::set_tolerance(
  self : Context,
  tolerance : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_tolerance_raw(self.to_raw(), tolerance),
  )
}

///|
/// Return the current curve-flattening tolerance in device-space units.
///
/// Cairo's default is `0.1`. Raises the checked context status.
pub fn Context::get_tolerance(self : Context) -> Double raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_tolerance_raw(self.to_raw())
}

///|
/// Set the maximum miter-length to line-width ratio for miter joins.
///
/// When the ratio needed by a join exceeds `limit`, Cairo uses a bevel join
/// instead. This setting matters only with `LineJoinMiter` and is stored in the
/// current graphics state. Raises the checked context status.
pub fn Context::set_miter_limit(
  self : Context,
  limit : Double,
) -> Unit raise CairoError {
  check_context_status_raw(
    @context_impl.set_miter_limit_raw(self.to_raw(), limit),
  )
}

///|
/// Return the current miter-length to line-width ratio limit.
///
/// Cairo's default is `10.0`. Raises the checked context status.
pub fn Context::get_miter_limit(self : Context) -> Double raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_miter_limit_raw(self.to_raw())
}

///|
/// Set the alternating on/off pattern used by later stroke operations.
///
/// Cairo copies `dashes`; it does not retain the MoonBit view. Lengths are
/// user-space values interpreted at stroke time. An empty view disables
/// dashing, and one value produces equal on/off lengths. In a non-empty
/// pattern, values must be non-negative with at least one positive value;
/// otherwise this raises `CairoInvalidArgument(InvalidDash, _)`. Cairo
/// normalizes `offset`.
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
/// Return the number of entries in the current dash pattern.
///
/// Returns zero when dashing is disabled. Raises the checked context status.
pub fn Context::get_dash_count(self : Context) -> Int raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  @context_impl.get_dash_count_raw(self.to_raw())
}

///|
/// Return a copy of the current dash pattern and Cairo's normalized offset.
///
/// Mutating the returned array does not change the context. The array is empty
/// when dashing is disabled. Raises the checked context status.
pub fn Context::get_dash(
  self : Context,
) -> (Array[Double], Double) raise CairoError {
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  let offset = Ref(0.0)
  let dashes = @context_impl.get_dash_raw(self.to_raw(), offset)
  check_context_status_raw(@context_impl.status_raw(self.to_raw()))
  (dashes.iter().collect(), offset.val)
}
