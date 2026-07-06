///|
pub struct Glyph {
  index : UInt64
  x : Double
  y : Double
} derive(Eq, Debug)

///|
pub fn Glyph::new(index : UInt64, x : Double, y : Double) -> Glyph {
  { index, x, y }
}

///|
pub fn Glyph::components(self : Glyph) -> (UInt64, Double, Double) {
  (self.index, self.x, self.y)
}
