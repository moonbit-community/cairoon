///|
fn expect_vector_output(path : String, markers : Array[String]) -> Unit raise {
  let filename = checked_path_bytes(path)
  inspect(test_file_size_ffi(filename) > 0, content="true")
  for marker in markers {
    inspect(
      test_file_contains_ffi(filename, @utf8.encode(marker)),
      content="true",
    )
  }
}

///|
fn expect_vector_output_absent(
  path : String,
  markers : Array[String],
) -> Unit raise {
  let filename = checked_path_bytes(path)
  inspect(test_file_size_ffi(filename) > 0, content="true")
  for marker in markers {
    inspect(
      test_file_contains_ffi(filename, @utf8.encode(marker)),
      content="false",
    )
  }
}

///|
fn fixed_pdf_metadata_date() -> String {
  "2026-01-02T03:04:05+00:00"
}

///|
fn expect_vector_outputs_equal(
  kind : Int,
  left_path : String,
  right_path : String,
) -> Unit raise {
  inspect(
    test_vector_files_equal_ffi(
      kind,
      checked_path_bytes(left_path),
      checked_path_bytes(right_path),
    ),
    content="true",
  )
}

///|
fn expect_vector_oracle_match(
  kind : Int,
  cairoon_path : String,
  oracle_path : String,
) -> Unit raise {
  check_status(
    test_render_vector_oracle_ffi(kind, checked_path_bytes(oracle_path)),
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

///|
fn fill_link_rect(ctx : Context, tagged : Bool) -> Unit raise CairoError {
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  if tagged {
    ctx.tag_begin(TAG_LINK, "uri='https://example.com/'")
  }
  ctx.rectangle(1.0, 1.0, 8.0, 8.0)
  ctx.fill()
  if tagged {
    ctx.tag_end(TAG_LINK)
  }
}

///|
test "pdf output contains stable structural markers" {
  let path = "/tmp/cairoon_vector_output.pdf"
  let oracle_path = "/tmp/cairoon_vector_output_oracle.pdf"
  let surface = Surface::pdf(10.0, 10.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon-vector-oracle")
  surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
  surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, ["%PDF-1.4", "/Root", "/Info", "%%EOF"])
  expect_vector_oracle_match(0, path, oracle_path)
}

///|
test "pdf link tag output contains annotation markers" {
  let path = "/tmp/cairoon_vector_tag_output.pdf"
  let surface = Surface::pdf(100.0, 100.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/'")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("example link")
  ctx.tag_end(TAG_LINK)
  surface.finish()
  expect_vector_output(path, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/)",
    "/S /Link", "/StructTreeRoot", "%%EOF",
  ])
}

///|
test "ps output contains stable page and drawing markers" {
  let path = "/tmp/cairoon_vector_output.ps"
  let oracle_path = "/tmp/cairoon_vector_output_oracle.ps"
  let surface = Surface::ps(10.0, 10.0, path=Some(path))
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "%!PS-Adobe-3.0", "%%Pages: 1", "0 0 1 rg", "0 0 10 10 rectfill", "%%EOF",
  ])
  expect_vector_oracle_match(1, path, oracle_path)
}

///|
test "ps link tags are inert for postscript output" {
  let plain_path = "/tmp/cairoon_vector_ps_plain_tag_scene.ps"
  let tagged_path = "/tmp/cairoon_vector_ps_tag_scene.ps"
  let plain = Surface::ps(10.0, 10.0, path=Some(plain_path))
  fill_link_rect(Context::new(plain), false)
  plain.finish()
  let tagged = Surface::ps(10.0, 10.0, path=Some(tagged_path))
  fill_link_rect(Context::new(tagged), true)
  tagged.finish()
  expect_vector_outputs_equal(1, tagged_path, plain_path)
  expect_vector_output_absent(tagged_path, [
    "https://example.com/", "/Subtype /Link", "/URI",
  ])
}

///|
test "svg output contains stable geometry and color markers" {
  let path = "/tmp/cairoon_vector_output.svg"
  let oracle_path = "/tmp/cairoon_vector_output_oracle.svg"
  let surface = Surface::svg(10.0, 10.0, path=Some(path))
  let ctx = Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "<?xml version=\"1.0\"", "<svg", "width=\"10\" height=\"10\"", "fill=\"rgb(100%, 0%, 0%)\"",
    "</svg>",
  ])
  expect_vector_oracle_match(2, path, oracle_path)
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
