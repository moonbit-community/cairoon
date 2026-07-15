///|
/// A pure affine transformation in Cairo component order.
///
/// Points are transformed as `x' = xx*x + xy*y + x0` and
/// `y' = yx*x + yy*y + y0`. All transformation methods return new values;
/// they never mutate the receiver as pycairo's corresponding methods do.
pub struct Matrix {
  xx : Double
  yx : Double
  xy : Double
  yy : Double
  x0 : Double
  y0 : Double
} derive(Eq, Debug)

///|
/// Construct a matrix from `(xx, yx, xy, yy, x0, y0)` components.
///
/// Omitted components produce the identity matrix.
pub fn Matrix::new(
  xx? : Double = 1.0,
  yx? : Double = 0.0,
  xy? : Double = 0.0,
  yy? : Double = 1.0,
  x0? : Double = 0.0,
  y0? : Double = 0.0,
) -> Matrix {
  { xx, yx, xy, yy, x0, y0 }
}

///|
/// Construct a rotation by `radians` around the origin.
///
/// Positive angles rotate from the positive X axis toward positive Y, which
/// appears clockwise with Cairo's default downward-pointing Y axis.
pub fn Matrix::init_rotate(radians : Double) -> Matrix {
  let s = @math.sin(radians)
  let c = @math.cos(radians)
  { xx: c, yx: s, xy: -s, yy: c, x0: 0.0, y0: 0.0 }
}

///|
/// Return `(xx, yx, xy, yy, x0, y0)`.
pub fn Matrix::components(
  self : Matrix,
) -> (Double, Double, Double, Double, Double, Double) {
  (self.xx, self.yx, self.xy, self.yy, self.x0, self.y0)
}

///|
/// Return the component at index `0..5` in Cairo/pycairo order.
///
/// Raises `CairoInvalidArgument(InvalidIndex, _)` for any other index.
pub fn Matrix::component(self : Matrix, index : Int) -> Double raise CairoError {
  match index {
    0 => self.xx
    1 => self.yx
    2 => self.xy
    3 => self.yy
    4 => self.x0
    5 => self.y0
    _ => raise CairoInvalidArgument(InvalidIndex, InvalidIndex.message())
  }
}

///|
/// Index the `(xx, yx, xy, yy, x0, y0)` component sequence.
///
/// Raises `CairoInvalidArgument(InvalidIndex, _)` outside `0..5`.
#alias("_[_]")
pub fn Matrix::at(self : Matrix, index : Int) -> Double raise CairoError {
  self.component(index)
}

///|
/// Return a transform that first translates by `(tx, ty)`, then applies `self`.
///
/// The receiver is unchanged.
pub fn Matrix::translate(self : Matrix, tx : Double, ty : Double) -> Matrix {
  {
    xx: self.xx,
    yx: self.yx,
    xy: self.xy,
    yy: self.yy,
    x0: self.x0 + tx * self.xx + ty * self.xy,
    y0: self.y0 + tx * self.yx + ty * self.yy,
  }
}

///|
/// Return a transform that first rotates by `radians`, then applies `self`.
///
/// The receiver is unchanged.
pub fn Matrix::rotate(self : Matrix, radians : Double) -> Matrix {
  Matrix::init_rotate(radians).multiply(self)
}

///|
/// Return a transform that first scales by `(sx, sy)`, then applies `self`.
///
/// The receiver is unchanged.
pub fn Matrix::scale(self : Matrix, sx : Double, sy : Double) -> Matrix {
  {
    xx: self.xx * sx,
    yx: self.yx * sx,
    xy: self.xy * sy,
    yy: self.yy * sy,
    x0: self.x0,
    y0: self.y0,
  }
}

///|
/// Return the inverse affine transformation without changing `self`.
///
/// Raises `CairoInvalidArgument(InvalidMatrix, _)` when the matrix is
/// degenerate and has no inverse.
pub fn Matrix::invert(self : Matrix) -> Matrix raise CairoError {
  let det = self.xx * self.yy - self.yx * self.xy
  if det == 0.0 {
    check_status(InvalidMatrix)
  }
  {
    xx: self.yy / det,
    yx: -self.yx / det,
    xy: -self.xy / det,
    yy: self.xx / det,
    x0: (self.xy * self.y0 - self.yy * self.x0) / det,
    y0: (self.yx * self.x0 - self.xx * self.y0) / det,
  }
}

///|
/// Compose `self` with `other`, applying `self` to coordinates first.
///
/// The `*` operator delegates to this method. Neither operand is mutated.
pub fn Matrix::multiply(self : Matrix, other : Matrix) -> Matrix {
  {
    xx: self.xx * other.xx + self.yx * other.xy,
    yx: self.xx * other.yx + self.yx * other.yy,
    xy: self.xy * other.xx + self.yy * other.xy,
    yy: self.xy * other.yx + self.yy * other.yy,
    x0: self.x0 * other.xx + self.y0 * other.xy + other.x0,
    y0: self.x0 * other.yx + self.y0 * other.yy + other.y0,
  }
}

///|
pub impl Mul for Matrix with fn mul(self, other) {
  self.multiply(other)
}

///|
/// Transform a point, including the matrix's translation components.
pub fn Matrix::transform_point(
  self : Matrix,
  x : Double,
  y : Double,
) -> (Double, Double) {
  (self.xx * x + self.xy * y + self.x0, self.yx * x + self.yy * y + self.y0)
}

///|
/// Transform a distance vector while ignoring translation.
pub fn Matrix::transform_distance(
  self : Matrix,
  dx : Double,
  dy : Double,
) -> (Double, Double) {
  (self.xx * dx + self.xy * dy, self.yx * dx + self.yy * dy)
}
