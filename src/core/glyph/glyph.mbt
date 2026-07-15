///|
/// A glyph identifier and its independently positioned user-space origin.
///
/// `index` is interpreted by the active font backend. Glyph positions are not
/// cumulative: each `(x, y)` is relative to the overall drawing origin.
pub struct Glyph {
  index : UInt64
  x : Double
  y : Double
} derive(Eq, Hash, Debug)

///|
/// Construct a glyph from its unsigned font index and user-space origin.
pub fn Glyph::new(index : UInt64, x : Double, y : Double) -> Glyph {
  { index, x, y }
}

///|
/// Return `(index, x, y)` without narrowing the unsigned glyph index.
pub fn Glyph::components(self : Glyph) -> (UInt64, Double, Double) {
  (self.index, self.x, self.y)
}

///|
/// Split glyphs into newly allocated index, X, and Y arrays for native calls.
///
/// All three arrays preserve input order and have `glyphs.length()` elements.
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
