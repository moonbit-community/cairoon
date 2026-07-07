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
