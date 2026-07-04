///|
pub fn Pattern::linear(
  x0 : Double,
  y0 : Double,
  x1 : Double,
  y1 : Double,
) -> Pattern raise CairoError {
  let pattern = pattern_create_linear_ffi(x0, y0, x1, y1)
  check_status(pattern_status_ffi(pattern))
  pattern
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
  let pattern = pattern_create_radial_ffi(cx0, cy0, radius0, cx1, cy1, radius1)
  check_status(pattern_status_ffi(pattern))
  pattern
}

///|
pub fn Pattern::add_color_stop_rgb(
  self : Pattern,
  offset : Double,
  red : Double,
  green : Double,
  blue : Double,
) -> Unit raise CairoError {
  check_status(pattern_add_color_stop_rgb_ffi(self, offset, red, green, blue))
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
  check_status(
    pattern_add_color_stop_rgba_ffi(self, offset, red, green, blue, alpha),
  )
}

///|
pub fn Pattern::get_color_stop_count(self : Pattern) -> Int raise CairoError {
  let count = Ref(0)
  check_status(pattern_get_color_stop_count_ffi(self, count))
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
  check_status(
    pattern_get_color_stop_rgba_ffi(
      self, index, offset, red, green, blue, alpha,
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
  check_status(pattern_get_linear_points_ffi(self, x0, y0, x1, y1))
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
  check_status(
    pattern_get_radial_circles_ffi(self, cx0, cy0, radius0, cx1, cy1, radius1),
  )
  (cx0.val, cy0.val, radius0.val, cx1.val, cy1.val, radius1.val)
}
