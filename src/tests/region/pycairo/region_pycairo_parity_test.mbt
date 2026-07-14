///|
fn[T] expect_region_invalid_index(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}

///|
fn expect_region_rectangle(
  region : @cairoon.Region,
  index : Int,
  expected : @cairoon.RectangleInt,
) -> Unit raise {
  inspect(region.get_rectangle(index) == expected, content="true")
}

///|
test "pycairo region get_rectangle index fixture" {
  let rect = @cairoon.RectangleInt::new(x=0, y=0, width=10, height=10)
  let region = @cairoon.Region::from_rectangle(rect)
  expect_region_invalid_index(
    @cairoon.run_cairo(() => region.get_rectangle(-1)),
  )
  expect_region_invalid_index(@cairoon.run_cairo(() => region.get_rectangle(1)))
  inspect(region.get_rectangle(0) == rect, content="true")
}

///|
test "pycairo region rectangle int limits and equality fixture" {
  let max_int = 2147483647
  let min_int = -2147483647 - 1
  let rect = @cairoon.RectangleInt::new(
    x=max_int,
    y=min_int,
    width=max_int,
    height=min_int,
  )
  inspect(rect.x, content="2147483647")
  inspect(rect.y, content="-2147483648")
  inspect(rect.width, content="2147483647")
  inspect(rect.height, content="-2147483648")
  debug_inspect(
    rect.components(),
    content="(2147483647, -2147483648, 2147483647, -2147483648)",
  )
  let same = @cairoon.RectangleInt::new(
    x=max_int,
    y=min_int,
    width=max_int,
    height=min_int,
  )
  inspect(rect == same, content="true")
  inspect(
    rect !=
    @cairoon.RectangleInt::new(
      x=max_int - 1,
      y=min_int,
      width=max_int,
      height=min_int,
    ),
    content="true",
  )
}

///|
test "pycairo region equality fixture" {
  let region = @cairoon.Region::new()
  let other_region = @cairoon.Region::new()
  let differ = @cairoon.Region::from_rectangle(
    @cairoon.RectangleInt::new(x=0, y=0, width=10, height=10),
  )
  inspect(region == region, content="true")
  inspect(region == other_region, content="true")
  inspect(region != other_region, content="false")
  inspect(region != differ, content="true")
}

///|
test "pycairo region contains fixture" {
  let rect = @cairoon.RectangleInt::new(x=1, y=2, width=10, height=13)
  let empty = @cairoon.Region::new()
  let overlap : @cairoon.RegionOverlap = empty.contains_rectangle(rect)
  debug_inspect(overlap, content="RegionOverlapOut")

  let region = @cairoon.Region::from_rectangle(
    @cairoon.RectangleInt::new(x=0, y=0, width=10, height=10),
  )
  inspect(region.contains_point(0, 0), content="true")
  inspect(region.contains_point(0, 20), content="false")
}

///|
test "pycairo composite region fixture" {
  let b = @cairoon.RectangleInt::new(x=1, y=2, width=10, height=12)
  let d = @cairoon.RectangleInt::new(x=1, y=1, width=10, height=12)
  let e = @cairoon.RectangleInt::new(x=1, y=3, width=8, height=12)
  let c = @cairoon.Region::from_rectangles([b, e])
  inspect(c.is_empty(), content="false")
  inspect(c.num_rectangles(), content="2")
  expect_region_rectangle(
    c,
    1,
    @cairoon.RectangleInt::new(x=1, y=14, width=8, height=1),
  )
  expect_region_rectangle(
    c,
    0,
    @cairoon.RectangleInt::new(x=1, y=2, width=10, height=12),
  )
  debug_inspect(
    c.get_extents(),
    content="{ x: 1, y: 2, width: 10, height: 13 }",
  )
  debug_inspect(c.contains_rectangle(d), content="RegionOverlapPart")

  c.translate(10, 20)
  debug_inspect(c.contains_rectangle(d), content="RegionOverlapOut")
  expect_region_rectangle(
    c,
    1,
    @cairoon.RectangleInt::new(x=11, y=34, width=8, height=1),
  )
  let cp = c.copy()
  inspect(c.num_rectangles() == cp.num_rectangles(), content="true")
  expect_region_rectangle(cp, 0, c.get_rectangle(0))
  inspect(c == cp, content="true")

  let intersection = @cairoon.Region::from_rectangles([b, e])
  ignore(intersection.intersect(@cairoon.Region::from_rectangle(d)))
  inspect(intersection.num_rectangles(), content="1")
  expect_region_rectangle(
    intersection,
    0,
    @cairoon.RectangleInt::new(x=1, y=2, width=10, height=11),
  )

  let difference = @cairoon.Region::from_rectangles([b, e])
  ignore(difference.subtract_rectangle(d))
  inspect(
    difference ==
    @cairoon.Region::from_rectangles([
      @cairoon.RectangleInt::new(x=1, y=13, width=10, height=1),
      @cairoon.RectangleInt::new(x=1, y=14, width=8, height=1),
    ]),
    content="true",
  )

  let region_difference = @cairoon.Region::from_rectangles([b, e])
  ignore(region_difference.subtract(@cairoon.Region::from_rectangle(d)))
  expect_region_rectangle(
    region_difference,
    0,
    @cairoon.RectangleInt::new(x=1, y=13, width=10, height=1),
  )

  let unioned = @cairoon.Region::from_rectangles([b, e])
  ignore(unioned.union(@cairoon.Region::from_rectangle(d)))
  inspect(
    unioned ==
    @cairoon.Region::from_rectangles([
      @cairoon.RectangleInt::new(x=1, y=1, width=10, height=13),
      @cairoon.RectangleInt::new(x=1, y=14, width=8, height=1),
    ]),
    content="true",
  )

  let xored = @cairoon.Region::from_rectangles([b, e])
  ignore(xored.xor(@cairoon.Region::from_rectangle(d)))
  inspect(xored.num_rectangles(), content="3")
  inspect(
    xored ==
    @cairoon.Region::from_rectangles([
      @cairoon.RectangleInt::new(x=1, y=1, width=10, height=1),
      @cairoon.RectangleInt::new(x=1, y=14, width=8, height=1),
      @cairoon.RectangleInt::new(x=1, y=13, width=10, height=1),
    ]),
    content="true",
  )
}

///|
test "pycairo region mutator receiver fixture" {
  let rect = @cairoon.RectangleInt::new(x=0, y=0, width=10, height=10)
  let overlap = @cairoon.RectangleInt::new(x=5, y=0, width=10, height=10)
  let region = @cairoon.Region::from_rectangle(rect)
  let other = @cairoon.Region::from_rectangle(overlap)

  let intersected = region.intersect(other)
  inspect(intersected.equal(region), content="true")
  debug_inspect(
    region.get_extents(),
    content="{ x: 5, y: 0, width: 5, height: 10 }",
  )

  let unioned = region.union_rectangle(rect)
  inspect(unioned.equal(region), content="true")
  debug_inspect(
    region.get_extents(),
    content="{ x: 0, y: 0, width: 10, height: 10 }",
  )

  let subtracted = region.subtract(region.copy())
  inspect(subtracted.equal(region), content="true")
  inspect(region.is_empty(), content="true")

  let xored = region.xor(other)
  inspect(xored.equal(region), content="true")
  debug_inspect(
    region.get_extents(),
    content="{ x: 5, y: 0, width: 10, height: 10 }",
  )
}

///|
test "pycairo region translate fixture" {
  let empty = @cairoon.Region::new()
  empty.translate(1, 1)
  inspect(empty.is_empty(), content="true")
  debug_inspect(
    empty.get_extents(),
    content="{ x: 1, y: 1, width: 0, height: 0 }",
  )

  let region = @cairoon.Region::from_rectangle(
    @cairoon.RectangleInt::new(x=0, y=0, width=10, height=10),
  )
  region.translate(1, 1)
  debug_inspect(
    region.get_extents(),
    content="{ x: 1, y: 1, width: 10, height: 10 }",
  )
}
