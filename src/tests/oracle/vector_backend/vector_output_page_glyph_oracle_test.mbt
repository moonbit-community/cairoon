///|
test "copy_page retained vector scene matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    let cairoon_path = "/tmp/cairoon_vector_copy_page_retained_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_vector_copy_page_retained_\{kind}_oracle.\{ext}"
    render_vector_oracle_scene(kind, 31, cairoon_path)
    expect_vector_oracle_match(kind, 31, cairoon_path, oracle_path)
  }
}

///|
test "surface copy_page retained vector scene matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    let cairoon_path = "/tmp/cairoon_vector_surface_copy_page_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_vector_surface_copy_page_\{kind}_oracle.\{ext}"
    render_surface_page_retained_scene(kind, cairoon_path)
    @cairoon.check_status(
      test_render_surface_page_oracle_ffi(kind, checked_path_bytes(oracle_path)),
    )
    inspect(
      test_vector_files_equal_ffi(
        kind,
        checked_path_bytes(cairoon_path),
        checked_path_bytes(oracle_path),
      ),
      content="true",
    )
  }
}

///|
test "surface show_page cleared vector scene matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    let cairoon_path = "/tmp/cairoon_vector_surface_show_page_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_vector_surface_show_page_\{kind}_oracle.\{ext}"
    render_surface_show_page_cleared_scene(kind, cairoon_path)
    @cairoon.check_status(
      test_render_surface_show_page_oracle_ffi(
        kind,
        checked_path_bytes(oracle_path),
      ),
    )
    inspect(
      test_vector_files_equal_ffi(
        kind,
        checked_path_bytes(cairoon_path),
        checked_path_bytes(oracle_path),
      ),
      content="true",
    )
  }
}

///|
test "glyph vector scenes match direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    for scene in 32..<34 {
      let cairoon_path = "/tmp/cairoon_vector_glyph_scene_\{kind}_\{scene}.\{ext}"
      let oracle_path = "/tmp/cairoon_vector_glyph_scene_\{kind}_\{scene}_oracle.\{ext}"
      render_vector_oracle_scene(kind, scene, cairoon_path)
      expect_vector_oracle_match(kind, scene, cairoon_path, oracle_path)
    }
  }
}

///|
test "ps svg tagged show_text_glyphs tags stay inert" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/StructTreeRoot", "/S /Link", "https://example.com/text-glyphs",
    "<a ",
  ]
  for kind in 1..<3 {
    let ext = vector_output_extension(kind)
    let path = "/tmp/cairoon_vector_backend_text_glyphs_tag_absent_\{kind}.\{ext}"
    render_vector_oracle_scene(kind, 29, path)
    expect_vector_output_absent(path, forbidden)
  }
}

///|
test "ps svg grouped glyph tags stay inert" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "https://example.com/grouped-glyphs", "cairoon-grouped-dest",
    "<a ",
  ]
  for kind in 1..<3 {
    let ext = vector_output_extension(kind)
    let path = "/tmp/cairoon_vector_backend_grouped_glyph_tag_absent_\{kind}.\{ext}"
    render_vector_oracle_scene(kind, 30, path)
    expect_vector_output_absent(path, forbidden)
  }
}

///|
test "layered multi-page vector tag scene matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    let cairoon_path = "/tmp/cairoon_vector_layered_multipage_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_vector_layered_multipage_\{kind}_oracle.\{ext}"
    render_vector_oracle_scene(kind, 27, cairoon_path)
    expect_vector_oracle_match(kind, 27, cairoon_path, oracle_path)
  }
}

///|
test "wide multi-page tag vector scene matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    let cairoon_path = "/tmp/cairoon_vector_wide_multipage_tag_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_vector_wide_multipage_tag_\{kind}_oracle.\{ext}"
    render_vector_oracle_scene(kind, 28, cairoon_path)
    expect_vector_oracle_match(kind, 28, cairoon_path, oracle_path)
  }
}

///|
test "pdf layered multi-page vector tag output contains combined markers" {
  let path = "/tmp/cairoon_vector_pdf_layered_multipage_markers.pdf"
  render_vector_oracle_scene(0, 27, path)
  expect_vector_output(path, [
    "%PDF-1.4", "/Count 3", "/Type /Page % 1", "/Type /Page % 2", "/Type /Page % 3",
    "/Subtype /Link", "/S /URI", "/URI (https://example.com/layered)", "/StructTreeRoot",
    "/S /Document", "/S /Sect", "/S /P", "%%EOF",
  ])
}

///|
test "pdf wide multi-page tag vector output contains combined markers" {
  let path = "/tmp/cairoon_vector_pdf_wide_multipage_tag_markers.pdf"
  render_vector_oracle_scene(0, 28, path)
  expect_vector_output(path, [
    "%PDF-1.4", "/Count 3", "/Type /Page % 1", "/Type /Page % 2", "/Type /Page % 3",
    "/Subtype /Link", "/S /URI", "/URI (https://example.com/wide)", "/Dest", "/Names",
    "/Dests", "(cairoon-wide-dest)", "/StructTreeRoot", "/S /Document", "/S /Sect",
    "/S /P", "%%EOF",
  ])
}

///|
test "ps svg layered multi-page vector tags stay inert" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/StructTreeRoot", "/S /Document", "/S /Sect",
    "/S /P", "https://example.com/layered", "<a ",
  ]
  for kind in 1..<3 {
    let ext = vector_output_extension(kind)
    let path = "/tmp/cairoon_vector_backend_layered_tag_absent_\{kind}.\{ext}"
    render_vector_oracle_scene(kind, 27, path)
    expect_vector_output_absent(path, forbidden)
  }
}

///|
test "ps svg wide multi-page vector tags stay inert" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "https://example.com/wide", "cairoon-wide-dest", "<a ",
  ]
  for kind in 1..<3 {
    let ext = vector_output_extension(kind)
    let path = "/tmp/cairoon_vector_backend_wide_tag_absent_\{kind}.\{ext}"
    render_vector_oracle_scene(kind, 28, path)
    expect_vector_output_absent(path, forbidden)
  }
}
