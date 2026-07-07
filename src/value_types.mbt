///|
pub struct Rectangle {
  x : Double
  y : Double
  width : Double
  height : Double
} derive(Eq, Hash, Debug)

///|
pub fn Rectangle::new(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Rectangle {
  { x, y, width, height }
}

///|
pub fn Rectangle::components(
  self : Rectangle,
) -> (Double, Double, Double, Double) {
  (self.x, self.y, self.width, self.height)
}

///|
pub fn Rectangle::component(
  self : Rectangle,
  index : Int,
) -> Double raise CairoError {
  match index {
    0 => self.x
    1 => self.y
    2 => self.width
    3 => self.height
    _ => raise CairoInvalidArgument(InvalidIndex, InvalidIndex.message())
  }
}

///|
pub struct RectangleInt {
  x : Int
  y : Int
  width : Int
  height : Int
} derive(Eq, Hash, Debug)

///|
pub fn RectangleInt::new(
  x? : Int = 0,
  y? : Int = 0,
  width? : Int = 0,
  height? : Int = 0,
) -> RectangleInt {
  { x, y, width, height }
}

///|
pub fn RectangleInt::components(self : RectangleInt) -> (Int, Int, Int, Int) {
  (self.x, self.y, self.width, self.height)
}

///|
pub fn RectangleInt::component(
  self : RectangleInt,
  index : Int,
) -> Int raise CairoError {
  match index {
    0 => self.x
    1 => self.y
    2 => self.width
    3 => self.height
    _ => raise CairoInvalidArgument(InvalidIndex, InvalidIndex.message())
  }
}

///|
pub type Glyph = @glyph.Glyph

///|
pub struct TextCluster {
  num_bytes : Int
  num_glyphs : Int
} derive(Eq, Hash, Debug)

///|
pub fn TextCluster::new(num_bytes : Int, num_glyphs : Int) -> TextCluster {
  { num_bytes, num_glyphs }
}

///|
pub fn TextCluster::components(self : TextCluster) -> (Int, Int) {
  (self.num_bytes, self.num_glyphs)
}

///|
fn text_cluster_field_arrays(
  clusters : ArrayView[TextCluster],
) -> (FixedArray[Int], FixedArray[Int]) {
  let count = clusters.length()
  (
    FixedArray::makei(count, index => clusters[index].num_bytes),
    FixedArray::makei(count, index => clusters[index].num_glyphs),
  )
}

///|
pub fn TextCluster::component(
  self : TextCluster,
  index : Int,
) -> Int raise CairoError {
  match index {
    0 => self.num_bytes
    1 => self.num_glyphs
    _ => raise CairoInvalidArgument(InvalidIndex, InvalidIndex.message())
  }
}

///|
pub struct TextExtents {
  x_bearing : Double
  y_bearing : Double
  width : Double
  height : Double
  x_advance : Double
  y_advance : Double
} derive(Eq, Hash, Debug)

///|
pub fn TextExtents::new(
  x_bearing : Double,
  y_bearing : Double,
  width : Double,
  height : Double,
  x_advance : Double,
  y_advance : Double,
) -> TextExtents {
  { x_bearing, y_bearing, width, height, x_advance, y_advance }
}

///|
pub fn TextExtents::components(
  self : TextExtents,
) -> (Double, Double, Double, Double, Double, Double) {
  (
    self.x_bearing,
    self.y_bearing,
    self.width,
    self.height,
    self.x_advance,
    self.y_advance,
  )
}

///|
pub fn TextExtents::component(
  self : TextExtents,
  index : Int,
) -> Double raise CairoError {
  match index {
    0 => self.x_bearing
    1 => self.y_bearing
    2 => self.width
    3 => self.height
    4 => self.x_advance
    5 => self.y_advance
    _ => raise CairoInvalidArgument(InvalidIndex, InvalidIndex.message())
  }
}

///|
pub struct TextGlyphRun {
  glyphs : Array[Glyph]
  clusters : Array[TextCluster]
  flags : TextClusterFlags
} derive(Eq, Debug)

///|
pub fn TextGlyphRun::new(
  glyphs : Array[Glyph],
  clusters : Array[TextCluster],
  flags : TextClusterFlags,
) -> TextGlyphRun {
  { glyphs, clusters, flags }
}

///|
pub fn TextGlyphRun::components(
  self : TextGlyphRun,
) -> (Array[Glyph], Array[TextCluster], TextClusterFlags) {
  (self.glyphs, self.clusters, self.flags)
}

///|
pub struct FontExtents {
  ascent : Double
  descent : Double
  height : Double
  max_x_advance : Double
  max_y_advance : Double
} derive(Eq, Hash, Debug)

///|
pub fn FontExtents::new(
  ascent : Double,
  descent : Double,
  height : Double,
  max_x_advance : Double,
  max_y_advance : Double,
) -> FontExtents {
  { ascent, descent, height, max_x_advance, max_y_advance }
}

///|
pub fn FontExtents::components(
  self : FontExtents,
) -> (Double, Double, Double, Double, Double) {
  (
    self.ascent,
    self.descent,
    self.height,
    self.max_x_advance,
    self.max_y_advance,
  )
}

///|
pub fn FontExtents::component(
  self : FontExtents,
  index : Int,
) -> Double raise CairoError {
  match index {
    0 => self.ascent
    1 => self.descent
    2 => self.height
    3 => self.max_x_advance
    4 => self.max_y_advance
    _ => raise CairoInvalidArgument(InvalidIndex, InvalidIndex.message())
  }
}
