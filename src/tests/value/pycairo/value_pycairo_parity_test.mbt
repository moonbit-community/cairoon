///|
fn expect_value_invalid_index(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}

///|
test "pycairo rectangle tuple-like fixture" {
  let rect = @cairoon.Rectangle::new(0.0, 0.5, 0.25, 0.75)
  inspect(rect == @cairoon.Rectangle::new(0.0, 0.5, 0.25, 0.75), content="true")
  inspect(
    Hash::hash(rect) ==
    Hash::hash(@cairoon.Rectangle::new(0.0, 0.5, 0.25, 0.75)),
    content="true",
  )
  inspect(rect.x, content="0")
  inspect(rect.y, content="0.5")
  inspect(rect.width, content="0.25")
  inspect(rect.height, content="0.75")
  debug_inspect(rect.components(), content="(0, 0.5, 0.25, 0.75)")
  inspect(rect.component(1), content="0.5")
  inspect(rect[1], content="0.5")
  expect_value_invalid_index(
    @cairoon.run_cairo(() => {
      let _ = rect[4]
      ()
    }),
  )
}

///|
test "pycairo rectangle producing APIs return rectangle values" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 10, 10),
  )
  ctx.line_to(0.0, 5.0)
  ctx.line_to(5.0, 5.0)
  ctx.line_to(5.0, 0.0)
  ctx.line_to(0.0, 0.0)
  ctx.clip()
  let rectangles = ctx.copy_clip_rectangle_list()
  inspect(rectangles.length(), content="1")
  inspect(rectangles[0].x, content="0")
  inspect(rectangles[0].y, content="0")
  inspect(rectangles[0].width, content="5")
  inspect(rectangles[0].height, content="5")

  let recording = @cairoon.Surface::recording(
    @cairoon.ContentColor,
    extents=Some(@cairoon.Rectangle::new(1.0, 1.0, 10.0, 10.0)),
  )
  let extents = recording.recording_get_extents()
  match extents {
    Some(rect) =>
      inspect(
        rect == @cairoon.Rectangle::new(1.0, 1.0, 10.0, 10.0),
        content="true",
      )
    None => @test.fail("expected recording extents")
  }
}

///|
test "pycairo glyph tuple-like fixture" {
  let glyph = @cairoon.Glyph::new(0UL, 0.5, 0.25)
  inspect(glyph == @cairoon.Glyph::new(0UL, 0.5, 0.25), content="true")
  inspect(
    Hash::hash(glyph) == Hash::hash(@cairoon.Glyph::new(0UL, 0.5, 0.25)),
    content="true",
  )
  inspect(glyph.index.to_string(), content="0")
  inspect(glyph.x, content="0.5")
  inspect(glyph.y, content="0.25")
  debug_inspect(glyph.components(), content="(0, 0.5, 0.25)")
  let (_, tuple_x, _) = glyph.components()
  inspect(tuple_x, content="0.5")

  let max_index : UInt64 = 18446744073709551615
  let max_double = 1.7976931348623157e308
  let min_double = -max_double
  let limit = @cairoon.Glyph::new(max_index, max_double, min_double)
  inspect(limit.index.to_string(), content="18446744073709551615")
  inspect(limit.x == max_double, content="true")
  inspect(limit.y == min_double, content="true")
}

///|
test "pycairo text cluster tuple-like fixture" {
  let cluster = @cairoon.TextCluster::new(2, 1)
  inspect(cluster == @cairoon.TextCluster::new(2, 1), content="true")
  inspect(
    Hash::hash(cluster) == Hash::hash(@cairoon.TextCluster::new(2, 1)),
    content="true",
  )
  inspect(cluster.num_bytes, content="2")
  inspect(cluster.num_glyphs, content="1")
  debug_inspect(cluster.components(), content="(2, 1)")
  inspect(cluster.component(1), content="1")
  inspect(cluster[1], content="1")
  expect_value_invalid_index(
    @cairoon.run_cairo(() => {
      let _ = cluster[2]
      ()
    }),
  )

  let max_int = 2147483647
  let min_int = -2147483647 - 1
  let limits = @cairoon.TextCluster::new(max_int, min_int)
  inspect(limits.num_bytes, content="2147483647")
  inspect(limits.num_glyphs, content="-2147483648")
}

///|
test "pycairo text extents tuple-like fixture" {
  let extents = @cairoon.TextExtents::new(0.0, 0.5, 0.25, 0.75, 0.5, 0.125)
  inspect(
    extents == @cairoon.TextExtents::new(0.0, 0.5, 0.25, 0.75, 0.5, 0.125),
    content="true",
  )
  inspect(
    Hash::hash(extents) ==
    Hash::hash(@cairoon.TextExtents::new(0.0, 0.5, 0.25, 0.75, 0.5, 0.125)),
    content="true",
  )
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
  inspect(extents.component(1), content="0.5")
  inspect(extents[1], content="0.5")
  expect_value_invalid_index(
    @cairoon.run_cairo(() => {
      let _ = extents[6]
      ()
    }),
  )

  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 10, 10),
  )
  inspect(ctx.text_extents("foo").width > 0.0, content="true")
  let scaled = ctx.get_scaled_font()
  inspect(scaled.text_extents("foo").width > 0.0, content="true")
  inspect(
    ctx.glyph_extents([@cairoon.Glyph::new(0UL, 0.0, 0.0)]).height >= 0.0,
    content="true",
  )
  inspect(
    scaled.glyph_extents([@cairoon.Glyph::new(0UL, 0.0, 0.0)]).height >= 0.0,
    content="true",
  )
}

///|
test "pycairo font extents value fixture" {
  let extents = @cairoon.FontExtents::new(1.0, 2.0, 3.0, 4.0, 5.0)
  inspect(
    extents == @cairoon.FontExtents::new(1.0, 2.0, 3.0, 4.0, 5.0),
    content="true",
  )
  inspect(
    Hash::hash(extents) ==
    Hash::hash(@cairoon.FontExtents::new(1.0, 2.0, 3.0, 4.0, 5.0)),
    content="true",
  )
  inspect(extents.ascent, content="1")
  inspect(extents.descent, content="2")
  inspect(extents.height, content="3")
  inspect(extents.max_x_advance, content="4")
  inspect(extents.max_y_advance, content="5")
  debug_inspect(extents.components(), content="(1, 2, 3, 4, 5)")

  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 10, 10),
  )
  inspect(ctx.font_extents().height > 0.0, content="true")
  inspect(ctx.get_scaled_font().extents().height > 0.0, content="true")
}
