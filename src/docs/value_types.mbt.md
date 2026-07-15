# Value Types

Rectangles, glyphs, text clusters, and extents are ordinary MoonBit values.
They do not own Cairo pointers and can be copied or retained without a
finalizer. Their field and component order follows pycairo.

`Matrix` has its own reference in `src/docs/matrix.mbt.md`, while typed path
segments and PDF outline flag sets are covered by their family documents.

## Rectangles

`Rectangle` uses `Double` fields and supports checked index syntax.
`RectangleInt` uses `Int` fields and exposes checked `component` access.

```mbt check
///|
test "value docs: rectangle fields and component order" {
  let rectangle = Rectangle::new(1.0, 2.0, 3.0, 4.0)
  debug_inspect(rectangle.components(), content="(1, 2, 3, 4)")
  inspect(rectangle[0], content="1")
  inspect(rectangle[3], content="4")

  let integer = RectangleInt::new(x=5, y=6, width=7, height=8)
  debug_inspect(integer.components(), content="(5, 6, 7, 8)")
  inspect(integer.component(2), content="7")
}
```

Invalid component indexes follow the same checked `InvalidIndex` policy as
the rest of cairoon's value API.

```mbt check
///|
test "value docs: rectangle component errors are checked" {
  let rectangle = Rectangle::new(0.0, 0.0, 1.0, 1.0)
  match run_cairo(() => rectangle[4]) {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected Rectangle InvalidIndex")
  }

  let integer = RectangleInt::new()
  match run_cairo(() => integer.component(-1)) {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected RectangleInt InvalidIndex")
  }
}
```

## Glyphs And Text Clusters

`Glyph::index` is a `UInt64`, preserving Cairo's unsigned-long range on
64-bit platforms. `TextCluster` stores the byte and glyph counts used by
`show_text_glyphs`. `TextGlyphRun` is the complete result of
`ScaledFont::text_to_glyphs`.

```mbt check
///|
test "value docs: glyph cluster and run values" {
  let glyph = Glyph::new(42UL, 1.5, 2.5)
  inspect(glyph.index == 42UL, content="true")
  inspect(glyph.x, content="1.5")
  inspect(glyph.y, content="2.5")

  let cluster = TextCluster::new(3, 1)
  debug_inspect(cluster.components(), content="(3, 1)")
  inspect(cluster[0], content="3")
  inspect(cluster[1], content="1")

  let run = TextGlyphRun::new([glyph], [cluster], TextClusterBackward)
  inspect(run.glyphs.length(), content="1")
  inspect(run.clusters.length(), content="1")
  debug_inspect(run.flags, content="TextClusterBackward")
}
```

## Text And Font Extents

The component order matches pycairo's tuple-like values. Named fields are
usually clearer; component access is useful when adapting generic numeric
code.

```mbt check
///|
test "value docs: text and font extents" {
  let text = TextExtents::new(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
  debug_inspect(text.components(), content="(1, 2, 3, 4, 5, 6)")
  inspect(text.x_bearing, content="1")
  inspect(text[5], content="6")

  let font = FontExtents::new(7.0, 8.0, 9.0, 10.0, 11.0)
  debug_inspect(font.components(), content="(7, 8, 9, 10, 11)")
  inspect(font.ascent, content="7")
  inspect(font.component(4), content="11")

  match run_cairo(() => font.component(5)) {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected FontExtents InvalidIndex")
  }
}
```
