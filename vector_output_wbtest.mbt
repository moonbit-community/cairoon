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
test "pdf output contains stable structural markers" {
  let path = "/tmp/cairoon_vector_output.pdf"
  let surface = Surface::pdf(10.0, 10.0, path=Some(path))
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon-vector-test")
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, ["%PDF-1.", "/Root", "/Info", "%%EOF"])
}

///|
test "ps output contains stable page and drawing markers" {
  let path = "/tmp/cairoon_vector_output.ps"
  let surface = Surface::ps(10.0, 10.0, path=Some(path))
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "%!PS-Adobe-3.0", "%%Pages: 1", "0 0 1 rg", "0 0 10 10 rectfill", "%%EOF",
  ])
}

///|
test "svg output contains stable geometry and color markers" {
  let path = "/tmp/cairoon_vector_output.svg"
  let surface = Surface::svg(10.0, 10.0, path=Some(path))
  let ctx = Context::new(surface)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "<?xml version=\"1.0\"", "<svg", "width=\"10\" height=\"10\"", "fill=\"rgb(100%, 0%, 0%)\"",
    "</svg>",
  ])
}
