///|
test "vector stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_equivalence_file_surface(kind, path)
    render_stream_equivalence_scene(file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
    render_stream_equivalence_scene(stream_surface)
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
test "copy_page retained vector stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_copy_page_retained_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_equivalence_file_surface(kind, path)
    render_stream_copy_page_retained_scene(file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
    render_stream_copy_page_retained_scene(stream_surface)
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
test "surface copy_page retained vector stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_surface_copy_page_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_equivalence_file_surface(kind, path)
    render_stream_surface_page_retained_scene(file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
    render_stream_surface_page_retained_scene(stream_surface)
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
test "surface show_page cleared vector stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_surface_show_page_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_equivalence_file_surface(kind, path)
    render_stream_surface_show_page_cleared_scene(file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
    render_stream_surface_show_page_cleared_scene(stream_surface)
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
test "glyph vector stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    for scene in 32..<34 {
      let path = "/tmp/cairoon_stream_glyph_vector_file_equivalence_\{kind}_\{scene}.\{ext}"
      let file_surface = make_stream_equivalence_file_surface(kind, path)
      render_stream_glyph_vector_scene(file_surface, scene)

      let chunks : Array[Bytes] = []
      let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
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

///|
test "text vector stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    for scene in 7..<9 {
      let path = "/tmp/cairoon_stream_text_vector_file_equivalence_\{kind}_\{scene}.\{ext}"
      let file_surface = make_stream_equivalence_file_surface(kind, path)
      render_stream_glyph_vector_scene(file_surface, scene)

      let chunks : Array[Bytes] = []
      let stream_surface = make_stream_equivalence_stream_surface(kind, chunks)
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

///|
test "non-text primitive vector scenes stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    for scene in 0..<15 {
      if scene != 7 && scene != 8 {
        let path = "/tmp/cairoon_stream_primitive_vector_file_equivalence_\{kind}_\{scene}.\{ext}"
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
