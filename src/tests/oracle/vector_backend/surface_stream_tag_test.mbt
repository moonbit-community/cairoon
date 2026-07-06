///|
fn expect_pdf_tag_stream_markers(
  scene : Int,
  markers : Array[String],
) -> Unit raise {
  let chunks : Array[Bytes] = []
  let stream_surface = make_stream_equivalence_stream_surface(0, chunks)
  render_stream_glyph_vector_scene(stream_surface, scene)
  expect_stream_output_markers(chunks, markers)
}

///|
test "pdf single-page tag vector stream output contains stable markers" {
  expect_pdf_tag_stream_markers(15, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/direct)",
    "/S /Link", "/StructTreeRoot", "%%EOF",
  ])
  expect_pdf_tag_stream_markers(16, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/Dest", "/Names", "/Dests", "(cairoon-direct-dest)",
    "/StructTreeRoot", "%%EOF",
  ])
  expect_pdf_tag_stream_markers(17, [
    "%PDF-1.4", "/StructTreeRoot", "/MarkInfo << /Marked true >>", "/Type /StructElem",
    "/S /Document", "/S /Sect", "/S /H1", "/S /P", "/StructParents 0", "%%EOF",
  ])
  expect_pdf_tag_stream_markers(22, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/)",
    "/S /Link", "/StructTreeRoot", "%%EOF",
  ])
  expect_pdf_tag_stream_markers(23, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/Dest", "/Names", "/Dests", "(cairoon-dest)",
    "/StructTreeRoot", "%%EOF",
  ])
  expect_pdf_tag_stream_markers(24, [
    "%PDF-1.4", "/StructTreeRoot", "/MarkInfo << /Marked true >>", "/Type /StructElem",
    "/S /Document", "/S /Sect", "/S /H1", "/S /P", "/StructParents 0", "%%EOF",
  ])
}

///|
test "ps svg single-page tag scenes stream output matches file output after normalization" {
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    for scene in 15..<25 {
      if scene < 18 || scene > 21 {
        let path = "/tmp/cairoon_stream_tag_scene_file_equivalence_\{kind}_\{scene}.\{ext}"
        let file_surface = make_stream_equivalence_file_surface(kind, path)
        render_stream_glyph_vector_scene(file_surface, scene)

        let chunks : Array[Bytes] = []
        let stream_surface = make_stream_equivalence_stream_surface(
          kind, chunks,
        )
        render_stream_glyph_vector_scene(stream_surface, scene)
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
  }
}

///|
test "pdf wide multi-page tag vector stream output contains combined markers" {
  let chunks : Array[Bytes] = []
  let stream_surface = make_stream_equivalence_stream_surface(0, chunks)
  render_stream_wide_multipage_tag_vector_scene(stream_surface)
  expect_stream_output_markers(chunks, [
    "%PDF-1.4", "/Count 3", "/Type /Page % 1", "/Type /Page % 2", "/Type /Page % 3",
    "/Subtype /Link", "/S /URI", "/URI (https://example.com/wide)", "/Dest", "/Names",
    "/Dests", "(cairoon-wide-dest)", "/StructTreeRoot", "/S /Document", "/S /Sect",
    "/S /P", "%%EOF",
  ])
}

///|
test "ps svg wide multi-page tag vector stream output matches file output after normalization" {
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_wide_multipage_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_equivalence_file_surface(kind, path)
    render_stream_wide_multipage_tag_vector_scene(file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
    render_stream_wide_multipage_tag_vector_scene(stream_surface)
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
test "ps svg mixed tag vector stream output matches file output after normalization" {
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_mixed_tag_vector_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_equivalence_file_surface(kind, path)
    render_stream_mixed_tag_vector_scene(file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
    render_stream_mixed_tag_vector_scene(stream_surface)
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
test "pdf mixed tag vector stream output contains combined markers" {
  let chunks : Array[Bytes] = []
  let stream_surface = make_stream_equivalence_stream_surface(0, chunks)
  render_stream_mixed_tag_vector_scene(stream_surface)
  expect_stream_output_markers(chunks, [
    "%PDF-1.4", "/Type /Page % 1", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/mixed)",
    "/Dest", "/Names", "/Dests", "(cairoon-mixed-dest)", "/StructTreeRoot", "/Type /StructElem",
    "/S /Link", "/S /Document", "/S /Sect", "/S /P", "/StructParents 0", "%%EOF",
  ])
}

///|
test "ps svg tagged show_text_glyphs stream output matches file output after normalization" {
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tagged_text_glyphs_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_equivalence_file_surface(kind, path)
    render_stream_tagged_show_text_glyphs_scene(file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
    render_stream_tagged_show_text_glyphs_scene(stream_surface)
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
test "pdf tagged show_text_glyphs stream output contains link markers" {
  let chunks : Array[Bytes] = []
  let stream_surface = make_stream_equivalence_stream_surface(0, chunks)
  render_stream_tagged_show_text_glyphs_scene(stream_surface)
  expect_stream_output_markers(chunks, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/text-glyphs)",
    "/S /Link", "/StructTreeRoot", "%%EOF",
  ])
}

///|
test "ps svg tagged font matrix text stream output matches file output after normalization" {
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_font_matrix_tag_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_equivalence_file_surface(kind, path)
    render_stream_glyph_vector_scene(file_surface, 43)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
    render_stream_glyph_vector_scene(stream_surface, 43)
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
test "pdf tagged font matrix text stream output contains combined markers" {
  let chunks : Array[Bytes] = []
  let stream_surface = make_stream_equivalence_stream_surface(0, chunks)
  render_stream_glyph_vector_scene(stream_surface, 43)
  expect_stream_output_markers(chunks, [
    "%PDF-1.4", "/Subtype /Link", "/S /URI", "/URI (https://example.com/font-matrix)",
    "/Dest", "/Dests", "(font-matrix-dest)", "/StructTreeRoot", "/S /Document", "/S /Sect",
    "%%EOF",
  ])
}

///|
test "ps svg grouped glyph tag stream output matches file output after normalization" {
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_grouped_glyph_tag_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_equivalence_file_surface(kind, path)
    render_stream_grouped_glyph_tag_scene(file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
    render_stream_grouped_glyph_tag_scene(stream_surface)
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
test "pdf grouped glyph tag stream output contains combined markers" {
  let chunks : Array[Bytes] = []
  let stream_surface = make_stream_equivalence_stream_surface(0, chunks)
  render_stream_grouped_glyph_tag_scene(stream_surface)
  expect_stream_output_markers(chunks, [
    "%PDF-1.4", "/Count 2", "/Type /Page % 1", "/Type /Page % 2", "/Annots [", "/Subtype /Link",
    "/S /URI", "/URI (https://example.com/grouped-glyphs)", "/Dest", "/Names", "/Dests",
    "(cairoon-grouped-dest)", "/StructTreeRoot", "/Type /StructElem", "/S /Link",
    "/S /Document", "/S /Sect", "/S /P", "%%EOF",
  ])
}

///|
test "ps svg layered multi-page tag vector stream output matches file output after normalization" {
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_layered_multipage_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_equivalence_file_surface(kind, path)
    render_stream_layered_multipage_scene(file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
    render_stream_layered_multipage_scene(stream_surface)
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
test "pdf layered multi-page tag vector stream output contains combined markers" {
  let chunks : Array[Bytes] = []
  let stream_surface = make_stream_equivalence_stream_surface(0, chunks)
  render_stream_layered_multipage_scene(stream_surface)
  expect_stream_output_markers(chunks, [
    "%PDF-1.4", "/Count 3", "/Type /Page % 1", "/Type /Page % 2", "/Type /Page % 3",
    "/Subtype /Link", "/S /URI", "/URI (https://example.com/layered)", "/StructTreeRoot",
    "/S /Document", "/S /Sect", "/S /P", "%%EOF",
  ])
}

///|
test "ps svg tagged multi-page vector stream output matches file output after normalization" {
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tagged_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_equivalence_file_surface(kind, path)
    render_stream_tagged_multipage_scene(file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
    render_stream_tagged_multipage_scene(stream_surface)
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
test "pdf tagged multi-page vector stream output contains structure markers" {
  let chunks : Array[Bytes] = []
  let stream_surface = make_stream_equivalence_stream_surface(0, chunks)
  render_stream_tagged_multipage_scene(stream_surface)
  expect_stream_output_markers(chunks, [
    "%PDF-1.4", "/Count 3", "/Type /Page % 1", "/Type /Page % 2", "/Type /Page % 3",
    "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/stream)",
    "/Type /StructElem", "/S /Link", "/S /Document", "/S /Sect", "/S /P", "/StructTreeRoot",
    "%%EOF",
  ])
}
