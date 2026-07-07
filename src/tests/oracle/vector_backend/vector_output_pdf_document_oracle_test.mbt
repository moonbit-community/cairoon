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
  inspect(intro_id > @cairoon.PDF_OUTLINE_ROOT, content="true")
  inspect(details_id > intro_id, content="true")
  expect_vector_oracle_match(0, 34, cairoon_path, oracle_path)
}

///|
test "pdf jpeg mime output matches direct cairo C oracle" {
  let cairoon_path = "/tmp/cairoon_vector_pdf_jpeg_mime_oracle.pdf"
  let oracle_path = "/tmp/cairoon_vector_pdf_jpeg_mime_direct_oracle.pdf"
  let jpeg = tiny_jpeg_payload()
  render_pdf_jpeg_mime_scene(cairoon_path, jpeg)
  @cairoon.check_status(
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
  @cairoon.check_status(
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
  let plain = @cairoon.Surface::svg(10.0, 10.0, path=Some(plain_path))
  fill_link_rect(@cairoon.Context::new(plain), false)
  plain.finish()
  let tagged = @cairoon.Surface::svg(10.0, 10.0, path=Some(tagged_path))
  fill_link_rect(@cairoon.Context::new(tagged), true)
  tagged.finish()
  expect_vector_outputs_equal(2, tagged_path, plain_path)
  expect_vector_output_absent(tagged_path, [
    "https://example.com/", "xlink:href=", "<a ",
  ])
}
