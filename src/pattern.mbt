///|
pub fn Pattern::solid_rgb(
  red : Double,
  green : Double,
  blue : Double,
) -> Pattern raise CairoError {
  let pattern = pattern_create_rgb_ffi(red, green, blue)
  check_status(pattern_status_ffi(pattern))
  pattern
}

///|
pub fn Pattern::solid_rgba(
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Pattern raise CairoError {
  let pattern = pattern_create_rgba_ffi(red, green, blue, alpha)
  check_status(pattern_status_ffi(pattern))
  pattern
}

///|
pub fn Pattern::for_surface(surface : Surface) -> Pattern raise CairoError {
  let pattern = pattern_create_for_surface_ffi(surface)
  check_status(pattern_status_ffi(pattern))
  pattern
}

///|
pub fn Pattern::get_surface(self : Pattern) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = pattern_get_surface_ffi(self, status)
  check_status(status.val)
  surface
}

///|
pub fn Pattern::status(self : Pattern) -> Status {
  pattern_status_ffi(self)
}

///|
pub fn Pattern::equal(self : Pattern, other : Pattern) -> Bool {
  pattern_equal_ffi(self, other)
}

///|
pub fn Pattern::hash(self : Pattern) -> UInt64 {
  pattern_hash_ffi(self)
}

///|
fn extend_from_raw(raw : Int) -> Extend raise CairoError {
  match raw {
    0 => ExtendNone
    1 => Repeat
    2 => Reflect
    3 => Pad
    _ =>
      raise CairoInvalidArgument(InvalidStatus, "unknown cairo extend: \{raw}")
  }
}

///|
fn filter_from_raw(raw : Int) -> Filter raise CairoError {
  match raw {
    0 => Fast
    1 => Good
    2 => Best
    3 => Nearest
    4 => Bilinear
    5 => Gaussian
    _ =>
      raise CairoInvalidArgument(InvalidStatus, "unknown cairo filter: \{raw}")
  }
}

///|
fn dither_from_raw(raw : Int) -> Dither raise CairoError {
  match raw {
    0 => DitherNone
    1 => DitherDefault
    2 => DitherFast
    3 => DitherGood
    4 => DitherBest
    _ =>
      raise CairoInvalidArgument(InvalidStatus, "unknown cairo dither: \{raw}")
  }
}

///|
pub fn Pattern::get_extend(self : Pattern) -> Extend raise CairoError {
  extend_from_raw(self.get_extend_raw())
}

///|
pub fn Pattern::set_extend(
  self : Pattern,
  extend_mode : Extend,
) -> Unit raise CairoError {
  check_status(pattern_set_extend_ffi(self, extend_mode))
}

///|
pub fn Pattern::get_extend_raw(self : Pattern) -> Int raise CairoError {
  check_status(pattern_status_ffi(self))
  pattern_get_extend_raw_ffi(self)
}

///|
pub fn Pattern::set_extend_raw(
  self : Pattern,
  extend_mode : Int,
) -> Unit raise CairoError {
  check_status(pattern_set_extend_raw_ffi(self, extend_mode))
}

///|
pub fn Pattern::get_filter(self : Pattern) -> Filter raise CairoError {
  filter_from_raw(self.get_filter_raw())
}

///|
pub fn Pattern::set_filter(
  self : Pattern,
  filter : Filter,
) -> Unit raise CairoError {
  check_status(pattern_set_filter_ffi(self, filter))
}

///|
pub fn Pattern::get_filter_raw(self : Pattern) -> Int raise CairoError {
  check_status(pattern_status_ffi(self))
  pattern_get_filter_raw_ffi(self)
}

///|
pub fn Pattern::set_filter_raw(
  self : Pattern,
  filter : Int,
) -> Unit raise CairoError {
  check_status(pattern_set_filter_raw_ffi(self, filter))
}

///|
pub fn Pattern::get_dither(self : Pattern) -> Dither raise CairoError {
  dither_from_raw(self.get_dither_raw())
}

///|
pub fn Pattern::set_dither(
  self : Pattern,
  dither : Dither,
) -> Unit raise CairoError {
  check_status(pattern_set_dither_ffi(self, dither))
}

///|
pub fn Pattern::get_dither_raw(self : Pattern) -> Int raise CairoError {
  check_status(pattern_status_ffi(self))
  pattern_get_dither_raw_ffi(self)
}

///|
pub fn Pattern::set_dither_raw(
  self : Pattern,
  dither : Int,
) -> Unit raise CairoError {
  check_status(pattern_set_dither_raw_ffi(self, dither))
}

///|
pub fn Pattern::get_matrix(self : Pattern) -> Matrix raise CairoError {
  let xx = Ref(0.0)
  let yx = Ref(0.0)
  let xy = Ref(0.0)
  let yy = Ref(0.0)
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  check_status(pattern_get_matrix_ffi(self, xx, yx, xy, yy, x0, y0))
  Matrix::new(xx=xx.val, yx=yx.val, xy=xy.val, yy=yy.val, x0=x0.val, y0=y0.val)
}

///|
pub fn Pattern::set_matrix(
  self : Pattern,
  matrix : Matrix,
) -> Unit raise CairoError {
  check_status(
    pattern_set_matrix_ffi(
      self,
      matrix.xx,
      matrix.yx,
      matrix.xy,
      matrix.yy,
      matrix.x0,
      matrix.y0,
    ),
  )
}

///|
pub fn Pattern::get_rgba(
  self : Pattern,
) -> (Double, Double, Double, Double) raise CairoError {
  let red = Ref(0.0)
  let green = Ref(0.0)
  let blue = Ref(0.0)
  let alpha = Ref(0.0)
  check_status(pattern_get_rgba_ffi(self, red, green, blue, alpha))
  (red.val, green.val, blue.val, alpha.val)
}
