///|
test "vector output scenes match direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    for scene in 0..<10 {
      let cairoon_path = "/tmp/cairoon_vector_scene_\{kind}_\{scene}.\{ext}"
      let oracle_path = "/tmp/cairoon_vector_scene_\{kind}_\{scene}_oracle.\{ext}"
      render_vector_oracle_scene(kind, scene, cairoon_path)
      expect_vector_oracle_match(kind, scene, cairoon_path, oracle_path)
    }
  }
}

///|
test "complex vector output scenes match direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    for scene in 10..<15 {
      let cairoon_path = "/tmp/cairoon_vector_complex_scene_\{kind}_\{scene}.\{ext}"
      let oracle_path = "/tmp/cairoon_vector_complex_scene_\{kind}_\{scene}_oracle.\{ext}"
      render_vector_oracle_scene(kind, scene, cairoon_path)
      expect_vector_oracle_match(kind, scene, cairoon_path, oracle_path)
    }
  }
}

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
test "ps svg destination and structure tags omit pdf metadata markers" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "cairoon-direct-dest", "cairoon-dest", "xlink:href=", "<a ",
  ]
  for kind in 1..<3 {
    let ext = vector_output_extension(kind)
    for scene in 16..<18 {
      let path = "/tmp/cairoon_vector_backend_tag_absent_\{kind}_\{scene}.\{ext}"
      render_vector_oracle_scene(kind, scene, path)
      expect_vector_output_absent(path, forbidden)
    }
    for scene in 23..<25 {
      let path = "/tmp/cairoon_vector_backend_text_tag_absent_\{kind}_\{scene}.\{ext}"
      render_vector_oracle_scene(kind, scene, path)
      expect_vector_output_absent(path, forbidden)
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
    check_status(
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
    check_status(
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
    "/Subtype /Link", "/S /URI", "/URI (https://example.com/wide)", "/Dest (cairoon-wide-dest)",
    "/Names", "/Dests", "(cairoon-wide-dest)", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "%%EOF",
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

///|
test "pdf document feature scene matches direct cairo C oracle" {
  let cairoon_path = "/tmp/cairoon_vector_pdf_document_features.pdf"
  let oracle_path = "/tmp/cairoon_vector_pdf_document_features_oracle.pdf"
  render_pdf_document_feature_scene(cairoon_path)
  expect_vector_oracle_match(0, 18, cairoon_path, oracle_path)
}

///|
test "pdf page operation document feature scene matches direct cairo C oracle" {
  let cairoon_path = "/tmp/cairoon_vector_pdf_page_operation_document.pdf"
  let oracle_path = "/tmp/cairoon_vector_pdf_page_operation_document_oracle.pdf"
  let (intro_id, details_id) = render_pdf_page_operation_document_feature_scene(
    cairoon_path,
  )
  inspect(intro_id > PDF_OUTLINE_ROOT, content="true")
  inspect(details_id > intro_id, content="true")
  expect_vector_oracle_match(0, 34, cairoon_path, oracle_path)
}

///|
test "pdf jpeg mime output matches direct cairo C oracle" {
  let cairoon_path = "/tmp/cairoon_vector_pdf_jpeg_mime_oracle.pdf"
  let oracle_path = "/tmp/cairoon_vector_pdf_jpeg_mime_direct_oracle.pdf"
  let jpeg = tiny_jpeg_payload()
  render_pdf_jpeg_mime_scene(cairoon_path, jpeg)
  check_status(
    test_render_pdf_jpeg_mime_oracle_ffi(checked_path_bytes(oracle_path), jpeg),
  )
  inspect(
    test_vector_files_equal_ffi(
      0,
      checked_path_bytes(cairoon_path),
      checked_path_bytes(oracle_path),
    ),
    content="true",
  )
}

///|
test "pdf thumbnail output matches direct cairo C oracle" {
  let cairoon_path = "/tmp/cairoon_vector_pdf_thumbnail_oracle.pdf"
  let oracle_path = "/tmp/cairoon_vector_pdf_thumbnail_direct_oracle.pdf"
  render_pdf_thumbnail_scene(cairoon_path)
  check_status(
    test_render_pdf_thumbnail_oracle_ffi(checked_path_bytes(oracle_path)),
  )
  inspect(
    test_vector_files_equal_ffi(
      0,
      checked_path_bytes(cairoon_path),
      checked_path_bytes(oracle_path),
    ),
    content="true",
  )
}

///|
test "svg link tags are inert for svg output" {
  let plain_path = "/tmp/cairoon_vector_svg_plain_tag_scene.svg"
  let tagged_path = "/tmp/cairoon_vector_svg_tag_scene.svg"
  let plain = Surface::svg(10.0, 10.0, path=Some(plain_path))
  fill_link_rect(Context::new(plain), false)
  plain.finish()
  let tagged = Surface::svg(10.0, 10.0, path=Some(tagged_path))
  fill_link_rect(Context::new(tagged), true)
  tagged.finish()
  expect_vector_outputs_equal(2, tagged_path, plain_path)
  expect_vector_output_absent(tagged_path, [
    "https://example.com/", "xlink:href=", "<a ",
  ])
}
