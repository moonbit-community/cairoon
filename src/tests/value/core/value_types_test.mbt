///|
fn[T] expect_value_invalid_index(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}

///|
test "rectangle values expose fields and components" {
  let rect = @cairoon.Rectangle::new(0.0, 0.5, 0.25, 0.75)
  inspect(rect.x, content="0")
  inspect(rect.y, content="0.5")
  inspect(rect.width, content="0.25")
  inspect(rect.height, content="0.75")
  debug_inspect(rect.components(), content="(0, 0.5, 0.25, 0.75)")
  inspect(rect.component(1), content="0.5")
  expect_value_invalid_index(@cairoon.run_cairo(() => rect.component(4)))
}

///|
test "rectangle int defaults and components" {
  let default_rect = @cairoon.RectangleInt::new()
  debug_inspect(default_rect.components(), content="(0, 0, 0, 0)")
  let rect = @cairoon.RectangleInt::new(x=1, y=2, width=3, height=4)
  inspect(rect.x, content="1")
  inspect(rect.y, content="2")
  inspect(rect.width, content="3")
  inspect(rect.height, content="4")
  debug_inspect(rect.components(), content="(1, 2, 3, 4)")
  inspect(rect.component(2), content="3")
}

///|
test "glyph uses unsigned index and double offsets" {
  let glyph = @cairoon.Glyph::new(42UL, 0.5, 0.25)
  inspect(glyph.index.to_string(), content="42")
  inspect(glyph.x, content="0.5")
  inspect(glyph.y, content="0.25")
  debug_inspect(glyph.components(), content="(42, 0.5, 0.25)")
}

///|
test "glyph index preserves uint64 range" {
  let max_index : UInt64 = 18446744073709551615
  let glyph = @cairoon.Glyph::new(max_index, 1.0, -1.0)
  inspect(glyph.index.to_string(), content="18446744073709551615")
  debug_inspect(glyph.components(), content="(18446744073709551615, 1, -1)")
}

///|
test "text cluster values expose tuple order" {
  let cluster = @cairoon.TextCluster::new(2, 1)
  inspect(cluster.num_bytes, content="2")
  inspect(cluster.num_glyphs, content="1")
  debug_inspect(cluster.components(), content="(2, 1)")
  inspect(cluster.component(0), content="2")
  expect_value_invalid_index(@cairoon.run_cairo(() => cluster.component(2)))
}

///|
test "text extents values expose pycairo field order" {
  let extents = @cairoon.TextExtents::new(0.0, 0.5, 0.25, 0.75, 0.5, 0.125)
  inspect(extents.x_bearing, content="0")
  inspect(extents.y_bearing, content="0.5")
  inspect(extents.width, content="0.25")
  inspect(extents.height, content="0.75")
  inspect(extents.x_advance, content="0.5")
  inspect(extents.y_advance, content="0.125")
  debug_inspect(
    extents.components(),
    content="(0, 0.5, 0.25, 0.75, 0.5, 0.125)",
  )
  inspect(extents.component(5), content="0.125")
}

///|
test "font extents values expose cairo field order" {
  let extents = @cairoon.FontExtents::new(1.0, 2.0, 3.0, 4.0, 5.0)
  inspect(extents.ascent, content="1")
  inspect(extents.descent, content="2")
  inspect(extents.height, content="3")
  inspect(extents.max_x_advance, content="4")
  inspect(extents.max_y_advance, content="5")
  debug_inspect(extents.components(), content="(1, 2, 3, 4, 5)")
  inspect(extents.component(3), content="4")
}

///|
test "pure value types preserve pycairo numeric limits" {
  let max_double = 1.7976931348623157e308
  let min_double = -max_double
  let rect = @cairoon.Rectangle::new(
    max_double, min_double, max_double, min_double,
  )
  inspect(rect.x == max_double, content="true")
  inspect(rect.y == min_double, content="true")
  inspect(rect.width == max_double, content="true")
  inspect(rect.height == min_double, content="true")

  let extents = @cairoon.TextExtents::new(
    max_double, min_double, max_double, min_double, max_double, min_double,
  )
  inspect(extents.x_bearing == max_double, content="true")
  inspect(extents.y_bearing == min_double, content="true")
  inspect(extents.width == max_double, content="true")
  inspect(extents.height == min_double, content="true")
  inspect(extents.x_advance == max_double, content="true")
  inspect(extents.y_advance == min_double, content="true")

  let max_int = 2147483647
  let min_int = -2147483647 - 1
  let cluster = @cairoon.TextCluster::new(max_int, min_int)
  inspect(cluster.num_bytes, content="2147483647")
  inspect(cluster.num_glyphs, content="-2147483648")
}

///|
test "pure value component invalid indexes map to InvalidIndex" {
  let rect = @cairoon.Rectangle::new(0.0, 0.5, 0.25, 0.75)
  expect_value_invalid_index(@cairoon.run_cairo(() => rect.component(-1)))
  expect_value_invalid_index(@cairoon.run_cairo(() => rect.component(4)))

  let rect_int = @cairoon.RectangleInt::new(x=1, y=2, width=3, height=4)
  expect_value_invalid_index(@cairoon.run_cairo(() => rect_int.component(-1)))
  expect_value_invalid_index(@cairoon.run_cairo(() => rect_int.component(4)))

  let cluster = @cairoon.TextCluster::new(2, 1)
  expect_value_invalid_index(@cairoon.run_cairo(() => cluster.component(-1)))
  expect_value_invalid_index(@cairoon.run_cairo(() => cluster.component(2)))

  let text = @cairoon.TextExtents::new(0.0, 0.5, 0.25, 0.75, 0.5, 0.125)
  expect_value_invalid_index(@cairoon.run_cairo(() => text.component(-1)))
  expect_value_invalid_index(@cairoon.run_cairo(() => text.component(6)))

  let font = @cairoon.FontExtents::new(1.0, 2.0, 3.0, 4.0, 5.0)
  expect_value_invalid_index(@cairoon.run_cairo(() => font.component(-1)))
  expect_value_invalid_index(@cairoon.run_cairo(() => font.component(5)))
}
