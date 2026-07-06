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

///|
pub fn field_arrays(
  glyphs : ArrayView[Glyph],
) -> (FixedArray[UInt64], FixedArray[Double], FixedArray[Double]) {
  let count = glyphs.length()
  (
    FixedArray::makei(count, index => glyphs[index].index),
    FixedArray::makei(count, index => glyphs[index].x),
    FixedArray::makei(count, index => glyphs[index].y),
  )
}
