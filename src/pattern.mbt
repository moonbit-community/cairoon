///|
struct Pattern(@pattern_impl.RawPattern)

///|
fn Pattern::from_raw(raw : @pattern_impl.RawPattern) -> Pattern {
  Pattern(raw)
}

///|
fn Pattern::to_raw(self : Pattern) -> @pattern_impl.RawPattern {
  self.0
}

///|
fn pattern_status_from_raw(raw : Int) -> Status {
  status_from_raw(raw) catch {
    _ => InvalidStatus
  }
}

///|
fn check_pattern_status_raw(raw : Int) -> Unit raise CairoError {
  check_status(status_from_raw(raw))
}

///|
pub fn Pattern::solid_rgb(
  red : Double,
  green : Double,
  blue : Double,
) -> Pattern raise CairoError {
  let raw = @pattern_impl.create_rgb_raw(red, green, blue)
  check_pattern_status_raw(@pattern_impl.status_raw(raw))
  Pattern::from_raw(raw)
}

///|
pub fn Pattern::solid_rgba(
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Pattern raise CairoError {
  let raw = @pattern_impl.create_rgba_raw(red, green, blue, alpha)
  check_pattern_status_raw(@pattern_impl.status_raw(raw))
  Pattern::from_raw(raw)
}

///|
pub fn Pattern::for_surface(surface : Surface) -> Pattern raise CairoError {
  let raw = @pattern_impl.create_for_surface_raw(surface.to_raw())
  check_pattern_status_raw(@pattern_impl.status_raw(raw))
  Pattern::from_raw(raw)
}

///|
pub fn Pattern::get_surface(self : Pattern) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @pattern_impl.get_surface_raw(self.to_raw(), status)
  check_pattern_status_raw(status.val)
  Surface::from_raw(raw)
}

///|
pub fn Pattern::status(self : Pattern) -> Status {
  pattern_status_from_raw(@pattern_impl.status_raw(self.to_raw()))
}

///|
pub fn Pattern::equal(self : Pattern, other : Pattern) -> Bool {
  @pattern_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
pub fn Pattern::hash(self : Pattern) -> UInt64 {
  @pattern_impl.hash_raw(self.to_raw())
}

///|
pub impl Eq for Pattern with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for Pattern with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for Pattern with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
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
  check_status(pattern_set_extend_ffi(self.to_raw(), extend_mode))
}

///|
pub fn Pattern::get_extend_raw(self : Pattern) -> Int raise CairoError {
  check_pattern_status_raw(@pattern_impl.status_raw(self.to_raw()))
  @pattern_impl.get_extend_raw(self.to_raw())
}

///|
pub fn Pattern::set_extend_raw(
  self : Pattern,
  extend_mode : Int,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.set_extend_raw(self.to_raw(), extend_mode),
  )
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
  check_status(pattern_set_filter_ffi(self.to_raw(), filter))
}

///|
pub fn Pattern::get_filter_raw(self : Pattern) -> Int raise CairoError {
  check_pattern_status_raw(@pattern_impl.status_raw(self.to_raw()))
  @pattern_impl.get_filter_raw(self.to_raw())
}

///|
pub fn Pattern::set_filter_raw(
  self : Pattern,
  filter : Int,
) -> Unit raise CairoError {
  check_pattern_status_raw(@pattern_impl.set_filter_raw(self.to_raw(), filter))
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
  check_status(pattern_set_dither_ffi(self.to_raw(), dither))
}

///|
pub fn Pattern::get_dither_raw(self : Pattern) -> Int raise CairoError {
  let status = Ref(0)
  let dither = @pattern_impl.get_dither_raw(self.to_raw(), status)
  check_pattern_status_raw(status.val)
  dither
}

///|
pub fn Pattern::set_dither_raw(
  self : Pattern,
  dither : Int,
) -> Unit raise CairoError {
  check_pattern_status_raw(@pattern_impl.set_dither_raw(self.to_raw(), dither))
}

///|
pub fn Pattern::get_matrix(self : Pattern) -> Matrix raise CairoError {
  let xx = Ref(0.0)
  let yx = Ref(0.0)
  let xy = Ref(0.0)
  let yy = Ref(0.0)
  let x0 = Ref(0.0)
  let y0 = Ref(0.0)
  check_pattern_status_raw(
    @pattern_impl.get_matrix_raw(self.to_raw(), xx, yx, xy, yy, x0, y0),
  )
  Matrix::new(xx=xx.val, yx=yx.val, xy=xy.val, yy=yy.val, x0=x0.val, y0=y0.val)
}

///|
pub fn Pattern::set_matrix(
  self : Pattern,
  matrix : Matrix,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.set_matrix_raw(
      self.to_raw(),
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
  check_pattern_status_raw(
    @pattern_impl.get_rgba_raw(self.to_raw(), red, green, blue, alpha),
  )
  (red.val, green.val, blue.val, alpha.val)
}
