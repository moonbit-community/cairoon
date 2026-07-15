///|
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
pub fn Pattern::get_color_stop_count(self : Pattern) -> Int raise CairoError {
  let count = Ref(0)
  check_pattern_status_raw(
    @pattern_impl.get_color_stop_count_raw(self.to_raw(), count),
  )
  count.val
}

///|
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
