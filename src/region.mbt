///|
/// An owned, mutable Cairo region made from integer-aligned rectangles.
///
/// Assigning this wrapper shares the same underlying region. Use `copy()` for
/// an independently mutable snapshot. MoonBit releases the Cairo handle when
/// the final wrapper becomes unreachable. Unlike pycairo, boolean mutators
/// return the receiver so operations can be chained.
struct Region(@region_impl.RawRegion)

///|
fn Region::from_raw(raw : @region_impl.RawRegion) -> Region {
  Region(raw)
}

///|
fn Region::to_raw(self : Region) -> @region_impl.RawRegion {
  self.0
}

///|
fn region_status_from_raw(raw : Int) -> Status {
  status_from_raw(raw) catch {
    _ => InvalidStatus
  }
}

///|
fn check_region_status_raw(raw : Int) -> Unit raise CairoError {
  check_status(status_from_raw(raw))
}

///|
fn region_overlap_from_raw(raw : Int) -> RegionOverlap {
  match raw {
    0 => RegionOverlapIn
    1 => RegionOverlapOut
    2 => RegionOverlapPart
    _ => RegionOverlapOut
  }
}

///|
/// Create a new empty region.
///
/// Raises `CairoMemoryError(NoMemory, _)` if Cairo cannot allocate it.
pub fn Region::new() -> Region raise CairoError {
  let raw = @region_impl.create_raw()
  check_region_status_raw(@region_impl.status_raw(raw))
  Region::from_raw(raw)
}

///|
/// Create a region containing `rectangle`.
///
/// The rectangle is copied into Cairo and is not retained. Raises
/// `CairoMemoryError(NoMemory, _)` if Cairo cannot allocate the region.
pub fn Region::from_rectangle(
  rectangle : RectangleInt,
) -> Region raise CairoError {
  let raw = @region_impl.create_rectangle_raw(
    rectangle.x,
    rectangle.y,
    rectangle.width,
    rectangle.height,
  )
  check_region_status_raw(@region_impl.status_raw(raw))
  Region::from_raw(raw)
}

///|
/// Create a region containing the union of `rectangles`.
///
/// An empty view creates an empty region. Cairo copies and normalizes the
/// input, so it may merge or split rectangles and does not preserve their
/// count or order. Raises `CairoMemoryError(NoMemory, _)` on allocation
/// failure.
pub fn Region::from_rectangles(
  rectangles : ArrayView[RectangleInt],
) -> Region raise CairoError {
  let count = rectangles.length()
  let status = Ref(0)
  let raw = @region_impl.create_rectangles_raw(
    FixedArray::makei(count, index => rectangles[index].x),
    FixedArray::makei(count, index => rectangles[index].y),
    FixedArray::makei(count, index => rectangles[index].width),
    FixedArray::makei(count, index => rectangles[index].height),
    status,
  )
  check_region_status_raw(status.val)
  check_region_status_raw(@region_impl.status_raw(raw))
  Region::from_raw(raw)
}

///|
/// Create an independently owned copy of this region's current coverage.
///
/// Later mutations of either region do not affect the other. Raises
/// `CairoMemoryError(NoMemory, _)` if Cairo cannot allocate the copy.
pub fn Region::copy(self : Region) -> Region raise CairoError {
  let raw = @region_impl.copy_raw(self.to_raw())
  check_region_status_raw(@region_impl.status_raw(raw))
  Region::from_raw(raw)
}

///|
/// Return the status stored in this region without raising it.
///
/// Public constructors and mutators check their status before returning, so
/// `Success` is expected for regions obtained through the public API.
pub fn Region::status(self : Region) -> Status {
  region_status_from_raw(@region_impl.status_raw(self.to_raw()))
}

///|
fn rectangle_int_from_region_output(
  f : (Ref[Int], Ref[Int], Ref[Int], Ref[Int]) -> Int,
) -> RectangleInt raise CairoError {
  let x = Ref(0)
  let y = Ref(0)
  let width = Ref(0)
  let height = Ref(0)
  check_region_status_raw(f(x, y, width, height))
  RectangleInt::new(x=x.val, y=y.val, width=width.val, height=height.val)
}

///|
/// Return the integer bounding rectangle of the entire region.
///
/// This is an extent, not one element of Cairo's normalized decomposition.
/// Raises the region's checked `CairoError` status if the query fails.
pub fn Region::get_extents(self : Region) -> RectangleInt raise CairoError {
  rectangle_int_from_region_output((x, y, width, height) => {
    @region_impl.get_extents_raw(self.to_raw(), x, y, width, height)
  })
}

///|
/// Return the number of rectangles in Cairo's normalized decomposition.
///
/// The result need not equal the number passed to `from_rectangles`.
pub fn Region::num_rectangles(self : Region) -> Int {
  @region_impl.num_rectangles_raw(self.to_raw())
}

///|
/// Return rectangle `index` from Cairo's normalized decomposition.
///
/// Decomposition order is Cairo-defined and must not be used as a stable
/// serialization format. Raises `CairoInvalidArgument(InvalidIndex, _)` for a
/// negative or out-of-range index, or the region's checked status on failure.
pub fn Region::get_rectangle(
  self : Region,
  index : Int,
) -> RectangleInt raise CairoError {
  if index < 0 || index >= self.num_rectangles() {
    raise CairoInvalidArgument(InvalidIndex, InvalidIndex.message())
  }
  rectangle_int_from_region_output((x, y, width, height) => {
    @region_impl.get_rectangle_raw(self.to_raw(), index, x, y, width, height)
  })
}

///|
/// Return whether this region covers no area.
pub fn Region::is_empty(self : Region) -> Bool {
  @region_impl.is_empty_raw(self.to_raw())
}

///|
/// Return whether the integer point `(x, y)` lies inside this region.
pub fn Region::contains_point(self : Region, x : Int, y : Int) -> Bool {
  @region_impl.contains_point_raw(self.to_raw(), x, y)
}

///|
/// Classify how this region covers `rectangle`.
///
/// Returns `RegionOverlapIn` for complete coverage, `RegionOverlapOut` for no
/// overlap, and `RegionOverlapPart` for partial coverage.
pub fn Region::contains_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> RegionOverlap {
  region_overlap_from_raw(
    @region_impl.contains_rectangle_raw(
      self.to_raw(),
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
}

///|
/// Return whether two regions cover exactly the same area.
///
/// Equality is independent of wrapper identity, allocation identity, and the
/// rectangle decomposition chosen by Cairo.
pub fn Region::equal(self : Region, other : Region) -> Bool {
  @region_impl.equal_raw(self.to_raw(), other.to_raw())
}

///|
pub impl Eq for Region with fn equal(self, other) {
  self.equal(other)
}

///|
/// Translate this region in place by the integer offset `(dx, dy)`.
///
/// This method returns `Unit`. Raises the checked `CairoError` status reported
/// after the mutation.
pub fn Region::translate(
  self : Region,
  dx : Int,
  dy : Int,
) -> Unit raise CairoError {
  check_region_status_raw(@region_impl.translate_raw(self.to_raw(), dx, dy))
}

///|
/// Replace this region with its intersection with `other`.
///
/// `other` is neither retained nor mutated. Returns this same receiver for
/// chaining. Raises `CairoMemoryError(NoMemory, _)` if Cairo cannot allocate
/// the result.
pub fn Region::intersect(
  self : Region,
  other : Region,
) -> Region raise CairoError {
  check_region_status_raw(
    @region_impl.intersect_raw(self.to_raw(), other.to_raw()),
  )
  self
}

///|
/// Replace this region with its intersection with `rectangle`.
///
/// The rectangle is not retained. Returns this same receiver for chaining.
/// Raises `CairoMemoryError(NoMemory, _)` if Cairo cannot allocate the result.
pub fn Region::intersect_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> Region raise CairoError {
  check_region_status_raw(
    @region_impl.intersect_rectangle_raw(
      self.to_raw(),
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
  self
}

///|
/// Remove every point covered by `other` from this region.
///
/// `other` is neither retained nor mutated. Returns this same receiver for
/// chaining. Raises `CairoMemoryError(NoMemory, _)` if Cairo cannot allocate
/// the result.
pub fn Region::subtract(
  self : Region,
  other : Region,
) -> Region raise CairoError {
  check_region_status_raw(
    @region_impl.subtract_raw(self.to_raw(), other.to_raw()),
  )
  self
}

///|
/// Remove every point covered by `rectangle` from this region.
///
/// The rectangle is not retained. Returns this same receiver for chaining.
/// Raises `CairoMemoryError(NoMemory, _)` if Cairo cannot allocate the result.
pub fn Region::subtract_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> Region raise CairoError {
  check_region_status_raw(
    @region_impl.subtract_rectangle_raw(
      self.to_raw(),
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
  self
}

///|
/// Replace this region with its union with `other`.
///
/// `other` is neither retained nor mutated. Returns this same receiver for
/// chaining. Raises `CairoMemoryError(NoMemory, _)` if Cairo cannot allocate
/// the result.
pub fn Region::union(self : Region, other : Region) -> Region raise CairoError {
  check_region_status_raw(@region_impl.union_raw(self.to_raw(), other.to_raw()))
  self
}

///|
/// Replace this region with its union with `rectangle`.
///
/// The rectangle is not retained. Returns this same receiver for chaining.
/// Raises `CairoMemoryError(NoMemory, _)` if Cairo cannot allocate the result.
pub fn Region::union_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> Region raise CairoError {
  check_region_status_raw(
    @region_impl.union_rectangle_raw(
      self.to_raw(),
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
  self
}

///|
/// Replace this region with the symmetric difference from `other`.
///
/// The result covers points present in exactly one operand. `other` is neither
/// retained nor mutated. Returns this same receiver for chaining. Raises
/// `CairoMemoryError(NoMemory, _)` if Cairo cannot allocate the result.
pub fn Region::xor(self : Region, other : Region) -> Region raise CairoError {
  check_region_status_raw(@region_impl.xor_raw(self.to_raw(), other.to_raw()))
  self
}

///|
/// Replace this region with the symmetric difference from `rectangle`.
///
/// The result covers points present in exactly one operand. The rectangle is
/// not retained. Returns this same receiver for chaining. Raises
/// `CairoMemoryError(NoMemory, _)` if Cairo cannot allocate the result.
pub fn Region::xor_rectangle(
  self : Region,
  rectangle : RectangleInt,
) -> Region raise CairoError {
  check_region_status_raw(
    @region_impl.xor_rectangle_raw(
      self.to_raw(),
      rectangle.x,
      rectangle.y,
      rectangle.width,
      rectangle.height,
    ),
  )
  self
}
