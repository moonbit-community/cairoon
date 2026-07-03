///|
test "region empty and rectangle construction" {
  let empty = Region::new()
  inspect(empty.is_empty(), content="true")
  inspect(empty.num_rectangles(), content="0")
  debug_inspect(
    empty.get_extents(),
    content="{ x: 0, y: 0, width: 0, height: 0 }",
  )
  let rect = RectangleInt::new(x=0, y=0, width=10, height=10)
  let region = Region::from_rectangle(rect)
  inspect(region.is_empty(), content="false")
  inspect(region.num_rectangles(), content="1")
  debug_inspect(
    region.get_rectangle(0),
    content="{ x: 0, y: 0, width: 10, height: 10 }",
  )
}

///|
test "region construction from multiple rectangles" {
  let empty_rectangles : Array[RectangleInt] = []
  let empty = Region::from_rectangles(empty_rectangles)
  inspect(empty.is_empty(), content="true")
  inspect(empty.num_rectangles(), content="0")

  let region = Region::from_rectangles([
    RectangleInt::new(x=0, y=0, width=2, height=2),
    RectangleInt::new(x=10, y=0, width=3, height=2),
  ])
  inspect(region.is_empty(), content="false")
  inspect(region.num_rectangles(), content="2")
  debug_inspect(
    region.get_extents(),
    content="{ x: 0, y: 0, width: 13, height: 2 }",
  )
  inspect(region.contains_point(1, 1), content="true")
  inspect(region.contains_point(11, 1), content="true")
  inspect(region.contains_point(5, 1), content="false")
  debug_inspect(
    region.contains_rectangle(RectangleInt::new(x=0, y=0, width=13, height=2)),
    content="RegionOverlapPart",
  )
}

///|
test "region get_rectangle invalid index maps to cairo error" {
  let region = Region::from_rectangle(
    RectangleInt::new(x=0, y=0, width=10, height=10),
  )
  let result = run_cairo(() => region.get_rectangle(1))
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}

///|
test "region contains point and rectangle overlap" {
  let region = Region::from_rectangle(
    RectangleInt::new(x=0, y=0, width=10, height=10),
  )
  inspect(region.contains_point(0, 0), content="true")
  inspect(region.contains_point(0, 20), content="false")
  let inside : RegionOverlap = region.contains_rectangle(
    RectangleInt::new(x=1, y=1, width=2, height=2),
  )
  let outside : RegionOverlap = region.contains_rectangle(
    RectangleInt::new(x=20, y=20, width=2, height=2),
  )
  let part : RegionOverlap = region.contains_rectangle(
    RectangleInt::new(x=9, y=9, width=2, height=2),
  )
  debug_inspect(inside, content="RegionOverlapIn")
  debug_inspect(outside, content="RegionOverlapOut")
  debug_inspect(part, content="RegionOverlapPart")
}

///|
test "region copy equal and translate" {
  let region = Region::from_rectangle(
    RectangleInt::new(x=0, y=0, width=10, height=10),
  )
  let copy = region.copy()
  inspect(region.equal(copy), content="true")
  copy.translate(1, 2)
  inspect(region.equal(copy), content="false")
  debug_inspect(
    copy.get_extents(),
    content="{ x: 1, y: 2, width: 10, height: 10 }",
  )
}

///|
test "region boolean operations with rectangles" {
  let base = RectangleInt::new(x=0, y=0, width=10, height=10)
  let overlap = RectangleInt::new(x=5, y=0, width=10, height=10)
  let region = Region::from_rectangle(base)
  let after_intersect = region.intersect_rectangle(overlap)
  inspect(after_intersect.equal(region), content="true")
  debug_inspect(
    region.get_extents(),
    content="{ x: 5, y: 0, width: 5, height: 10 }",
  )
  let after_union = after_intersect.union_rectangle(
    RectangleInt::new(x=0, y=0, width=5, height=10),
  )
  inspect(after_union.equal(region), content="true")
  debug_inspect(
    region.get_extents(),
    content="{ x: 0, y: 0, width: 10, height: 10 }",
  )
  let after_subtract = after_union.subtract_rectangle(
    RectangleInt::new(x=0, y=0, width=5, height=10),
  )
  inspect(after_subtract.equal(region), content="true")
  debug_inspect(
    region.get_extents(),
    content="{ x: 5, y: 0, width: 5, height: 10 }",
  )
}

///|
test "region xor rectangle splits overlapping area" {
  let region = Region::from_rectangle(
    RectangleInt::new(x=0, y=0, width=10, height=10),
  )
  let returned = region.xor_rectangle(
    RectangleInt::new(x=5, y=0, width=10, height=10),
  )
  inspect(returned.equal(region), content="true")
  inspect(region.is_empty(), content="false")
  inspect(region.num_rectangles(), content="2")
  debug_inspect(
    region.get_extents(),
    content="{ x: 0, y: 0, width: 15, height: 10 }",
  )
  debug_inspect(
    region.contains_rectangle(RectangleInt::new(x=0, y=0, width=5, height=10)),
    content="RegionOverlapIn",
  )
  debug_inspect(
    region.contains_rectangle(RectangleInt::new(x=5, y=0, width=5, height=10)),
    content="RegionOverlapOut",
  )
  debug_inspect(
    region.contains_rectangle(RectangleInt::new(x=10, y=0, width=5, height=10)),
    content="RegionOverlapIn",
  )
}

///|
test "region boolean operations with regions" {
  let left = Region::from_rectangle(
    RectangleInt::new(x=0, y=0, width=10, height=10),
  )
  let right = Region::from_rectangle(
    RectangleInt::new(x=5, y=0, width=10, height=10),
  )
  let intersection = left.copy()
  let after_intersect = intersection.intersect(right)
  inspect(after_intersect.equal(intersection), content="true")
  debug_inspect(
    intersection.get_extents(),
    content="{ x: 5, y: 0, width: 5, height: 10 }",
  )
  let combined = left.copy()
  let after_union = combined.union(right)
  inspect(after_union.equal(combined), content="true")
  debug_inspect(
    combined.get_extents(),
    content="{ x: 0, y: 0, width: 15, height: 10 }",
  )
  let difference = combined.copy()
  let after_xor = difference.xor(intersection)
  inspect(after_xor.equal(difference), content="true")
  inspect(difference.is_empty(), content="false")
}

///|
test "region boolean operations chain like pycairo mutators" {
  let base = Region::from_rectangle(
    RectangleInt::new(x=0, y=0, width=10, height=10),
  )
  let chained = base
    .intersect_rectangle(RectangleInt::new(x=2, y=0, width=10, height=10))
    .union_rectangle(RectangleInt::new(x=0, y=0, width=2, height=10))
    .subtract_rectangle(RectangleInt::new(x=0, y=0, width=1, height=10))
    .xor_rectangle(RectangleInt::new(x=11, y=0, width=1, height=10))
  inspect(chained.equal(base), content="true")
  debug_inspect(
    chained.get_extents(),
    content="{ x: 1, y: 0, width: 11, height: 10 }",
  )
}
