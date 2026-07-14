///|
test "document feature stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_document_feature_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_document_feature_file_surface(kind, path)
    render_stream_document_feature_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_document_feature_stream_surface(
      kind, chunks,
    )
    render_stream_document_feature_scene(kind, stream_surface)
    inspect(chunks.length() > 0, content="true")
    inspect(
      test_vector_file_equals_bytes_ffi(
        kind,
        @utf8.encode(path),
        stream_equivalence_chunks_to_bytes(chunks),
      ),
      content="true",
    )
  }
}

///|
test "document feature stream output contains backend markers" {
  for kind in 0..<3 {
    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_document_feature_stream_surface(
      kind, chunks,
    )
    render_stream_document_feature_scene(kind, stream_surface)
    match kind {
      0 =>
        expect_stream_output_markers_since(kind, chunks, 11706, [
          "%PDF-1.4", "/Title (Cairoon Combined Oracle)", "/Creator (cairoon-combined-oracle)",
          "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
          "/ISBN (978-0123456789)", "/Count 2", "/PageLabels", "(intro)", "(details)",
          "/Outlines", "/Title (intro page)", "/Title (details page)", "/Annots [",
          "/Subtype /Link", "/S /URI", "/URI (https://example.com/combined)", "/Dest",
          "/Names", "/Dests", "(combined-direct-dest)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /P", "%%EOF",
        ])
      1 =>
        expect_stream_output_markers_since(kind, chunks, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 2", "%%Title: Cairoon PS Combined",
          "%%IncludeFeature: *MediaColor White", "%%IncludeFeature: *PageSize A4",
          "%%IncludeFeature: *MediaType Plain", "%%Pages: 2", "%%Page: 1 1", "%%Page: 2 2",
          "%%EOF",
        ])
      2 =>
        expect_stream_output_markers_since(kind, chunks, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"12px\" height=\"12px\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "pdf text document feature stream output matches file output after normalization" {
  let path = "/tmp/cairoon_stream_pdf_text_document_feature_equivalence.pdf"
  let file_surface = @cairoon.Surface::pdf(100.0, 100.0, path=Some(path))
  let _ = render_pdf_text_document_feature_surface(file_surface)

  let chunks : Array[Bytes] = []
  let stream_surface = @cairoon.Surface::pdf_stream(100.0, 100.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  let _ = render_pdf_text_document_feature_surface(stream_surface)
  inspect(chunks.length() > 0, content="true")
  inspect(
    test_vector_file_equals_bytes_ffi(
      0,
      @utf8.encode(path),
      stream_equivalence_chunks_to_bytes(chunks),
    ),
    content="true",
  )
}

///|
test "pdf page operation document feature stream output matches file output after normalization" {
  let path = "/tmp/cairoon_stream_pdf_page_operation_document_feature.pdf"
  let file_surface = @cairoon.Surface::pdf(100.0, 100.0, path=Some(path))
  let _ = render_pdf_page_operation_document_feature_surface(file_surface)

  let chunks : Array[Bytes] = []
  let stream_surface = @cairoon.Surface::pdf_stream(100.0, 100.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  let _ = render_pdf_page_operation_document_feature_surface(stream_surface)
  inspect(chunks.length() > 0, content="true")
  inspect(
    test_vector_file_equals_bytes_ffi(
      0,
      @utf8.encode(path),
      stream_equivalence_chunks_to_bytes(chunks),
    ),
    content="true",
  )
}

///|
test "pdf jpeg mime stream output matches file output" {
  let path = "/tmp/cairoon_stream_pdf_jpeg_mime_file_equivalence.pdf"
  let jpeg = tiny_jpeg_payload()
  render_pdf_jpeg_mime_scene(path, jpeg)

  let chunks : Array[Bytes] = []
  let stream_surface = @cairoon.Surface::pdf_stream(3.0, 3.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  render_pdf_jpeg_mime_surface(stream_surface, jpeg)
  inspect(chunks.length() > 0, content="true")
  inspect(
    test_vector_file_equals_bytes_ffi(
      0,
      @utf8.encode(path),
      stream_equivalence_chunks_to_bytes(chunks),
    ),
    content="true",
  )
}

///|
test "pdf thumbnail stream output matches file output" {
  let path = "/tmp/cairoon_stream_pdf_thumbnail_file_equivalence.pdf"
  render_pdf_thumbnail_scene(path)

  let chunks : Array[Bytes] = []
  let stream_surface = @cairoon.Surface::pdf_stream(20.0, 20.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  render_pdf_thumbnail_surface(stream_surface)
  inspect(chunks.length() > 0, content="true")
  inspect(
    test_vector_file_equals_bytes_ffi(
      0,
      @utf8.encode(path),
      stream_equivalence_chunks_to_bytes(chunks),
    ),
    content="true",
  )
}
