///|
test "single-page tag scenes stream output matches file output after normalization" {
  for kind in 0..<3 {
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
test "wide multi-page tag vector stream output matches file output after normalization" {
  for kind in 0..<3 {
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
test "mixed tag vector stream output matches file output after normalization" {
  for kind in 0..<3 {
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
test "tagged show_text_glyphs stream output matches file output after normalization" {
  for kind in 0..<3 {
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
test "tagged font matrix text stream output matches file output after normalization" {
  for kind in 0..<3 {
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
test "grouped glyph tag stream output matches file output after normalization" {
  for kind in 0..<3 {
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
test "layered multi-page tag vector stream output matches file output after normalization" {
  for kind in 0..<3 {
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
test "tagged multi-page vector stream output matches file output after normalization" {
  for kind in 0..<3 {
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
