///|
test "glyph pure value exposes cairo tuple order" {
  let glyph = Glyph::new(42UL, 0.5, 0.25)
  inspect(glyph.index.to_string(), content="42")
  inspect(glyph.x, content="0.5")
  inspect(glyph.y, content="0.25")
  debug_inspect(glyph.components(), content="(42, 0.5, 0.25)")
}

///|
test "glyph preserves unsigned index range" {
  let max_index : UInt64 = 18446744073709551615
  let glyph = Glyph::new(max_index, 1.0, -1.0)
  inspect(glyph.index.to_string(), content="18446744073709551615")
  inspect(glyph == Glyph::new(max_index, 1.0, -1.0), content="true")
  debug_inspect(glyph.components(), content="(18446744073709551615, 1, -1)")
}
