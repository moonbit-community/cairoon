///|
/// A floating-point Cairo rectangle.
///
/// `x` and `y` locate the left and top edges; `width` and `height` give its
/// size. The coordinate space is defined by the API that produces or consumes
/// the rectangle.
pub struct Rectangle {
  x : Double
  y : Double
  width : Double
  height : Double
} derive(Eq, Hash, Debug)

///|
/// Construct a rectangle without validating its dimensions.
pub fn Rectangle::new(
  x : Double,
  y : Double,
  width : Double,
  height : Double,
) -> Rectangle {
  { x, y, width, height }
}

///|
/// Return `(x, y, width, height)` in pycairo tuple order.
pub fn Rectangle::components(
  self : Rectangle,
) -> (Double, Double, Double, Double) {
  (self.x, self.y, self.width, self.height)
}

///|
/// Return component `0..3` from `(x, y, width, height)`.
///
/// Raises `CairoInvalidArgument(InvalidIndex, _)` for any other index.
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
/// Index the `(x, y, width, height)` component sequence.
///
/// Raises `CairoInvalidArgument(InvalidIndex, _)` outside `0..3`.
#alias("_[_]")
pub fn Rectangle::at(self : Rectangle, index : Int) -> Double raise CairoError {
  self.component(index)
}

///|
/// An integer Cairo rectangle, commonly used by regions and image mappings.
///
/// `x` and `y` locate the left and top edges; `width` and `height` give its
/// size in the coordinate space of the consuming API.
pub struct RectangleInt {
  x : Int
  y : Int
  width : Int
  height : Int
} derive(Eq, Debug)

///|
/// Construct an integer rectangle; omitted components default to zero.
///
/// Construction does not validate dimensions.
pub fn RectangleInt::new(
  x? : Int = 0,
  y? : Int = 0,
  width? : Int = 0,
  height? : Int = 0,
) -> RectangleInt {
  { x, y, width, height }
}

///|
/// Return `(x, y, width, height)`.
pub fn RectangleInt::components(self : RectangleInt) -> (Int, Int, Int, Int) {
  (self.x, self.y, self.width, self.height)
}

///|
/// Return component `0..3` from `(x, y, width, height)`.
///
/// Raises `CairoInvalidArgument(InvalidIndex, _)` for any other index.
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
/// The canonical Cairo glyph value re-exported from its owning package.
///
/// This alias is the same type used by Context and ScaledFont glyph APIs.
pub type Glyph = @glyph.Glyph

///|
/// A mapping between a run of UTF-8 bytes and a run of glyphs.
///
/// Cairo requires both counts to be non-negative and at least one to be
/// nonzero when the value is consumed by a text-cluster API. This pure value
/// preserves the supplied counts; construction itself performs no validation.
pub struct TextCluster {
  num_bytes : Int
  num_glyphs : Int
} derive(Eq, Hash, Debug)

///|
/// Construct a text cluster from its UTF-8 byte and glyph counts.
pub fn TextCluster::new(num_bytes : Int, num_glyphs : Int) -> TextCluster {
  { num_bytes, num_glyphs }
}

///|
/// Return `(num_bytes, num_glyphs)` in pycairo tuple order.
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
/// Return component `0..1` from `(num_bytes, num_glyphs)`.
///
/// Raises `CairoInvalidArgument(InvalidIndex, _)` for any other index.
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
/// Index the `(num_bytes, num_glyphs)` component sequence.
///
/// Raises `CairoInvalidArgument(InvalidIndex, _)` outside `0..1`.
#alias("_[_]")
pub fn TextCluster::at(self : TextCluster, index : Int) -> Int raise CairoError {
  self.component(index)
}

///|
/// User-space ink bounds and advances for text or glyphs.
///
/// Bearings locate the ink rectangle relative to the origin; width and height
/// describe that rectangle; advances locate the next text origin. Metrics can
/// vary slightly with the current transform because of font hinting.
pub struct TextExtents {
  x_bearing : Double
  y_bearing : Double
  width : Double
  height : Double
  x_advance : Double
  y_advance : Double
} derive(Eq, Hash, Debug)

///|
/// Construct text extents from six explicit metric values.
///
/// This pure constructor performs no metric validation.
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
/// Return `(x_bearing, y_bearing, width, height, x_advance, y_advance)`.
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
/// Return metric `0..5` in pycairo tuple order.
///
/// Raises `CairoInvalidArgument(InvalidIndex, _)` for any other index.
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
/// Index the six text-extents metrics in pycairo tuple order.
///
/// Raises `CairoInvalidArgument(InvalidIndex, _)` outside `0..5`.
#alias("_[_]")
pub fn TextExtents::at(
  self : TextExtents,
  index : Int,
) -> Double raise CairoError {
  self.component(index)
}

///|
/// Glyphs plus their UTF-8 cluster mapping from text shaping.
///
/// `flags` describes glyph traversal order. The arrays are ordinary mutable
/// MoonBit arrays, so callers should copy them before independent mutation.
pub struct TextGlyphRun {
  glyphs : Array[Glyph]
  clusters : Array[TextCluster]
  flags : TextClusterFlags
} derive(Eq, Debug)

///|
/// Group glyph, cluster, and flag arrays without copying or validating them.
///
/// Cairo validates complete cluster coverage when a run is consumed by a
/// text-cluster operation.
pub fn TextGlyphRun::new(
  glyphs : Array[Glyph],
  clusters : Array[TextCluster],
  flags : TextClusterFlags,
) -> TextGlyphRun {
  { glyphs, clusters, flags }
}

///|
/// Return the same glyph and cluster arrays together with their flags.
///
/// The returned arrays alias the arrays stored in this run.
pub fn TextGlyphRun::components(
  self : TextGlyphRun,
) -> (Array[Glyph], Array[TextCluster], TextClusterFlags) {
  (self.glyphs, self.clusters, self.flags)
}

///|
/// User-space line metrics for a scaled font.
///
/// Ascent and descent extend above and below the baseline; height is the
/// recommended baseline spacing; maximum advances bound glyph-origin motion.
pub struct FontExtents {
  ascent : Double
  descent : Double
  height : Double
  max_x_advance : Double
  max_y_advance : Double
} derive(Eq, Hash, Debug)

///|
/// Construct font extents from five explicit metric values.
///
/// This pure constructor performs no metric validation.
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
/// Return `(ascent, descent, height, max_x_advance, max_y_advance)`.
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
/// Return metric `0..4` in pycairo tuple order.
///
/// Raises `CairoInvalidArgument(InvalidIndex, _)` for any other index.
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
