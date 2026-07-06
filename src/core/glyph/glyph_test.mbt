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

///|
test "glyph field arrays preserve cairo array order" {
  let glyphs = [Glyph::new(10UL, 1.5, 2.5), Glyph::new(20UL, -1.0, -2.0)]
  let (indices, xs, ys) = field_arrays(glyphs)
  inspect(indices.length(), content="2")
  inspect(indices[0].to_string(), content="10")
  inspect(indices[1].to_string(), content="20")
  inspect(xs[0], content="1.5")
  inspect(xs[1], content="-1")
  inspect(ys[0], content="2.5")
  inspect(ys[1], content="-2")
}
