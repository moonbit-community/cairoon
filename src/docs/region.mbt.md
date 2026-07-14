# Region

`Region` represents a set of integer-aligned rectangles. It is useful for
tracking raster areas such as invalidated tiles, clip approximations, and dirty
rectangles.

Regions own their Cairo handle. Copying a region creates a distinct Cairo
object. Boolean operations mutate and return the receiver for checked chaining;
this is a cairoon extension over pycairo's `None` return.

`Region` and `RectangleInt` support value equality. They deliberately do not
implement MoonBit's generic `Hash` or `Compare` traits, matching pycairo's
unhashable and non-orderable protocol behavior.

## Construction And Queries

```mbt check
///|
test "region docs: construct and query rectangles" {
  let region = Region::from_rectangles([
    RectangleInt::new(x=0, y=0, width=4, height=4),
    RectangleInt::new(x=10, y=0, width=2, height=4),
  ])

  inspect(region.is_empty(), content="false")
  inspect(region.num_rectangles(), content="2")
  debug_inspect(
    region.get_extents(),
    content="{ x: 0, y: 0, width: 12, height: 4 }",
  )
  inspect(region.contains_point(1, 1), content="true")
  inspect(region.contains_point(8, 1), content="false")
  debug_inspect(
    region.contains_rectangle(RectangleInt::new(x=0, y=0, width=12, height=4)),
    content="RegionOverlapPart",
  )
}
```

## Boolean Operations

Region boolean methods accept either another `Region` or a `RectangleInt`
operand. Rectangle variants map pycairo's rectangle operand behavior without
requiring a temporary `Region` allocation in user code.

```mbt check
///|
test "region docs: boolean rectangle operations" {
  let region = Region::from_rectangle(
    RectangleInt::new(x=0, y=0, width=10, height=10),
  )

  let chained = region.intersect_rectangle(
    RectangleInt::new(x=5, y=0, width=10, height=10),
  )
  inspect(chained.equal(region), content="true")
  debug_inspect(
    region.get_extents(),
    content="{ x: 5, y: 0, width: 5, height: 10 }",
  )

  let _ = chained.union_rectangle(
    RectangleInt::new(x=0, y=0, width=5, height=10),
  )
  debug_inspect(
    region.get_extents(),
    content="{ x: 0, y: 0, width: 10, height: 10 }",
  )

  let _ = chained.xor_rectangle(
    RectangleInt::new(x=5, y=0, width=10, height=10),
  )
  debug_inspect(
    region.contains_rectangle(RectangleInt::new(x=5, y=0, width=5, height=10)),
    content="RegionOverlapOut",
  )
}
```

## Checked Errors

APIs that can fail raise `CairoError` suberrors. For example,
`Region::get_rectangle` validates the index before calling Cairo and maps an
out-of-range index to `CairoInvalidArgument(InvalidIndex, _)`.

```mbt check
///|
test "region docs: invalid rectangle index is checked" {
  let region = Region::new()
  let result = run_cairo(() => region.get_rectangle(0))
  match result {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}
```
