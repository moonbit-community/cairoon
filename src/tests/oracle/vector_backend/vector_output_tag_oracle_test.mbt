///|
test "pdf tag output scenes match direct cairo C oracle" {
  for scene in 15..<18 {
    let cairoon_path = "/tmp/cairoon_vector_pdf_tag_scene_\{scene}.pdf"
    let oracle_path = "/tmp/cairoon_vector_pdf_tag_scene_\{scene}_oracle.pdf"
    render_vector_oracle_scene(0, scene, cairoon_path)
    expect_vector_oracle_match(0, scene, cairoon_path, oracle_path)
  }
}

///|
test "pdf text tag output scenes match direct cairo C oracle" {
  for scene in 22..<25 {
    let cairoon_path = "/tmp/cairoon_vector_pdf_text_tag_scene_\{scene}.pdf"
    let oracle_path = "/tmp/cairoon_vector_pdf_text_tag_scene_\{scene}_oracle.pdf"
    render_vector_oracle_scene(0, scene, cairoon_path)
    expect_vector_oracle_match(0, scene, cairoon_path, oracle_path)
  }
}

///|
test "ps svg link tag scenes match direct cairo C oracle" {
  for kind in 1..<3 {
    let ext = vector_output_extension(kind)
    let cairoon_path = "/tmp/cairoon_vector_link_tag_scene_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_vector_link_tag_scene_\{kind}_oracle.\{ext}"
    render_vector_oracle_scene(kind, 15, cairoon_path)
    expect_vector_oracle_match(kind, 15, cairoon_path, oracle_path)
  }
}

///|
test "ps svg tag and text tag scenes match direct cairo C oracle" {
  for kind in 1..<3 {
    let ext = vector_output_extension(kind)
    for scene in 16..<18 {
      let cairoon_path = "/tmp/cairoon_vector_backend_tag_scene_\{kind}_\{scene}.\{ext}"
      let oracle_path = "/tmp/cairoon_vector_backend_tag_scene_\{kind}_\{scene}_oracle.\{ext}"
      render_vector_oracle_scene(kind, scene, cairoon_path)
      expect_vector_oracle_match(kind, scene, cairoon_path, oracle_path)
    }
    for scene in 22..<25 {
      let cairoon_path = "/tmp/cairoon_vector_backend_text_tag_scene_\{kind}_\{scene}.\{ext}"
      let oracle_path = "/tmp/cairoon_vector_backend_text_tag_scene_\{kind}_\{scene}_oracle.\{ext}"
      render_vector_oracle_scene(kind, scene, cairoon_path)
      expect_vector_oracle_match(kind, scene, cairoon_path, oracle_path)
    }
  }
}

///|
test "ps svg destination structure and uri text tags omit pdf metadata markers" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "https://example.com/", "cairoon-direct-dest", "cairoon-dest",
    "xlink:href=", "<a ",
  ]
  let text_forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "https://example.com/", "cairoon-direct-dest", "cairoon-dest",
    "<a ",
  ]
  for kind in 1..<3 {
    let ext = vector_output_extension(kind)
    for scene in 16..<18 {
      let path = "/tmp/cairoon_vector_backend_tag_absent_\{kind}_\{scene}.\{ext}"
      render_vector_oracle_scene(kind, scene, path)
      expect_vector_output_absent(path, forbidden)
    }
    for scene in 22..<25 {
      let path = "/tmp/cairoon_vector_backend_text_tag_absent_\{kind}_\{scene}.\{ext}"
      render_vector_oracle_scene(kind, scene, path)
      expect_vector_output_absent(path, text_forbidden)
    }
  }
}

///|
test "tagged multi-page text scene matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    let cairoon_path = "/tmp/cairoon_vector_tagged_multipage_text_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_vector_tagged_multipage_text_\{kind}_oracle.\{ext}"
    render_vector_oracle_scene(kind, 25, cairoon_path)
    expect_vector_oracle_match(kind, 25, cairoon_path, oracle_path)
  }
}

///|
test "ps svg tagged multi-page text tags stay inert" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Link",
    "/S /Document", "/S /Sect", "/S /P", "https://example.com/multipage", "cairoon-multi-dest",
    "<a ",
  ]
  for kind in 1..<3 {
    let ext = vector_output_extension(kind)
    let path = "/tmp/cairoon_vector_backend_tagged_multipage_absent_\{kind}.\{ext}"
    render_vector_oracle_scene(kind, 25, path)
    expect_vector_output_absent(path, forbidden)
  }
}

///|
test "mixed vector tag text scene matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    let cairoon_path = "/tmp/cairoon_vector_mixed_tag_text_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_vector_mixed_tag_text_\{kind}_oracle.\{ext}"
    render_vector_oracle_scene(kind, 26, cairoon_path)
    expect_vector_oracle_match(kind, 26, cairoon_path, oracle_path)
  }
}

///|
test "tagged show_text_glyphs vector scene matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    let cairoon_path = "/tmp/cairoon_vector_tagged_text_glyphs_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_vector_tagged_text_glyphs_\{kind}_oracle.\{ext}"
    render_vector_oracle_scene(kind, 29, cairoon_path)
    expect_vector_oracle_match(kind, 29, cairoon_path, oracle_path)
  }
}

///|
test "grouped glyph tag multi-page scene matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    let cairoon_path = "/tmp/cairoon_vector_grouped_glyph_tag_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_vector_grouped_glyph_tag_\{kind}_oracle.\{ext}"
    render_vector_oracle_scene(kind, 30, cairoon_path)
    expect_vector_oracle_match(kind, 30, cairoon_path, oracle_path)
  }
}

///|
test "tagged font matrix text scene matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    let cairoon_path = "/tmp/cairoon_vector_font_matrix_tag_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_vector_font_matrix_tag_\{kind}_oracle.\{ext}"
    render_vector_oracle_scene(kind, 43, cairoon_path)
    expect_vector_oracle_match(kind, 43, cairoon_path, oracle_path)
  }
}

///|
test "pdf tagged font matrix text scene contains tag markers" {
  let path = "/tmp/cairoon_vector_pdf_font_matrix_tag_markers.pdf"
  render_vector_oracle_scene(0, 43, path)
  expect_vector_output(path, [
    "%PDF-1.4", "/Subtype /Link", "/S /URI", "/URI (https://example.com/font-matrix)",
    "/Dest", "/Dests", "(font-matrix-dest)", "/StructTreeRoot", "/S /Document", "/S /Sect",
    "%%EOF",
  ])
}

///|
test "ps svg tagged font matrix text tags stay inert" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "https://example.com/font-matrix", "font-matrix-dest", "<a ",
  ]
  for kind in 1..<3 {
    let ext = vector_output_extension(kind)
    let path = "/tmp/cairoon_vector_backend_font_matrix_tag_absent_\{kind}.\{ext}"
    render_vector_oracle_scene(kind, 43, path)
    expect_vector_output_absent(path, forbidden)
  }
}
