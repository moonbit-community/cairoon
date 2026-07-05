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
test "pdf text document feature stream output matches file output after normalization" {
  let path = "/tmp/cairoon_stream_pdf_text_document_feature_equivalence.pdf"
  let file_surface = Surface::pdf(100.0, 100.0, path=Some(path))
  let _ = render_pdf_text_document_feature_surface(file_surface)

  let chunks : Array[Bytes] = []
  let stream_surface = Surface::pdf_stream(100.0, 100.0, fn(chunk) {
    chunks.push(chunk)
    Success
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
  let file_surface = Surface::pdf(100.0, 100.0, path=Some(path))
  let _ = render_pdf_page_operation_document_feature_surface(file_surface)

  let chunks : Array[Bytes] = []
  let stream_surface = Surface::pdf_stream(100.0, 100.0, fn(chunk) {
    chunks.push(chunk)
    Success
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
  let stream_surface = Surface::pdf_stream(3.0, 3.0, fn(chunk) {
    chunks.push(chunk)
    Success
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
  let stream_surface = Surface::pdf_stream(20.0, 20.0, fn(chunk) {
    chunks.push(chunk)
    Success
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
