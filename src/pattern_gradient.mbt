///|
/// Create a linear gradient from `(x0, y0)` to `(x1, y1)`.
///
/// Coordinates are in pattern space, which initially equals user space and can
/// be changed with `set_matrix()`. Add at least one color stop before drawing.
/// The returned value owns its native pattern and raises its creation status.
pub fn Pattern::linear(
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
) -> Pattern raise CairoError {
  let raw = @pattern_impl.create_linear_raw(x0, y0, x1, y1)
  check_pattern_status_raw(@pattern_impl.status_raw(raw))
  Pattern::from_raw(raw)
}

///|
/// Create a radial gradient between two circles.
///
/// Centers and radii are in pattern space; Cairo stores each radius as its
/// absolute value. The result owns its native pattern and raises the checked
/// creation status. Add color stops before drawing.
pub fn Pattern::radial(
  cx0 : Double,
  cy0 : Double,
  radius0 : Double,
  cx1 : Double,
  cy1 : Double,
  radius1 : Double,
) -> Pattern raise CairoError {
  let raw = @pattern_impl.create_radial_raw(
    cx0, cy0, radius0, cx1, cy1, radius1,
  )
  check_pattern_status_raw(@pattern_impl.status_raw(raw))
  Pattern::from_raw(raw)
}

///|
/// Add an opaque color stop to a linear or radial gradient.
///
/// `offset` and RGB components are clamped to `[0.0, 1.0]`. Stops with equal
/// offsets preserve insertion order, allowing sharp transitions. Raises
/// `PatternTypeMismatch` on a non-gradient and makes the error sticky.
pub fn Pattern::add_color_stop_rgb(
  self : Pattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.add_color_stop_rgb_raw(
      self.to_raw(),
      offset,
      red,
      green,
      blue,
    ),
  )
}

///|
/// Add a color stop with alpha to a linear or radial gradient.
///
/// `offset` and all RGBA components are clamped to `[0.0, 1.0]`. Equal-offset
/// stops preserve insertion order. Raises `PatternTypeMismatch` on any other
/// pattern subtype and propagates a sticky pattern error.
pub fn Pattern::add_color_stop_rgba(
  self : Pattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.add_color_stop_rgba_raw(
      self.to_raw(),
      offset,
      red,
      green,
      blue,
      alpha,
    ),
  )
}

///|
/// Return the number of stops in a linear or radial gradient.
///
/// Raises `PatternTypeMismatch` for non-gradient patterns and propagates an
/// existing sticky pattern error.
pub fn Pattern::get_color_stop_count(self : Pattern) -> Int raise CairoError {
  let count = Ref(0)
  check_pattern_status_raw(
    @pattern_impl.get_color_stop_count_raw(self.to_raw(), count),
  )
  count.val
}

///|
/// Return one gradient stop as `(offset, red, green, blue, alpha)`.
///
/// Colors are unpremultiplied and all values are in `[0.0, 1.0]`. Stop order
/// follows offset and stable insertion order for ties. Raises `InvalidIndex`
/// outside `0..<get_color_stop_count()` or `PatternTypeMismatch` otherwise.
pub fn Pattern::get_color_stop_rgba(
  self : Pattern,
  index : Int,
) -> (Double, Double, Double, Double, Double) raise CairoError {
  let offset = Ref(0.0)
  let red = Ref(0.0)
  let green = Ref(0.0)
  let blue = Ref(0.0)
  let alpha = Ref(0.0)
  check_pattern_status_raw(
    @pattern_impl.get_color_stop_rgba_raw(
      self.to_raw(),
      index,
      offset,
      red,
      green,
      blue,
      alpha,
    ),
  )
  (offset.val, red.val, green.val, blue.val, alpha.val)
}

///|
/// Copy every gradient stop into a new ordered array.
///
/// The returned tuples are independent value snapshots with unpremultiplied
/// RGBA components. Raises the same `PatternTypeMismatch`, `InvalidIndex`, or
/// sticky status as the underlying count and indexed getters.
pub fn Pattern::get_color_stops_rgba(
  self : Pattern,
) -> Array[(Double, Double, Double, Double, Double)] raise CairoError {
  let stops = []
  for index in 0..<self.get_color_stop_count() {
    stops.push(self.get_color_stop_rgba(index))
  }
  stops
}

///|
/// Return a linear gradient's endpoints `(x0, y0, x1, y1)`.
///
/// Values are the original pattern-space coordinates and are not transformed
/// by the current pattern matrix. Raises `PatternTypeMismatch` for any other
/// subtype and propagates a sticky pattern error.
pub fn Pattern::get_linear_points(
  self : Pattern,
) -> (Double, Double, Double, Double) raise CairoError {
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  let x1 = Ref(0.0)
  let y1 = Ref(0.0)
  check_pattern_status_raw(
    @pattern_impl.get_linear_points_raw(self.to_raw(), x0, y0, x1, y1),
  )
  (x0.val, y0.val, x1.val, y1.val)
}

///|
/// Return a radial gradient's two circles.
///
/// The tuple is `(cx0, cy0, radius0, cx1, cy1, radius1)` in the original
/// pattern space. Raises `PatternTypeMismatch` for any other subtype and
/// propagates a sticky pattern error.
pub fn Pattern::get_radial_circles(
  self : Pattern,
) -> (Double, Double, Double, Double, Double, Double) raise CairoError {
  let cx0 = Ref(0.0)
  let cy0 = Ref(0.0)
  let radius0 = Ref(0.0)
  let cx1 = Ref(0.0)
  let cy1 = Ref(0.0)
  let radius1 = Ref(0.0)
  check_pattern_status_raw(
    @pattern_impl.get_radial_circles_raw(
      self.to_raw(),
      cx0,
      cy0,
      radius0,
      cx1,
      cy1,
      radius1,
    ),
  )
  (cx0.val, cy0.val, radius0.val, cx1.val, cy1.val, radius1.val)
}
