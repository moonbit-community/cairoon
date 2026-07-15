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
  let pdf_default_date_left = @utf8.encode(
    "%PDF-1.4\n   /CreationDate (D:20260102030405+00'00)\n%%EOF\n",
  )
  let pdf_default_date_right = @utf8.encode(
    "%PDF-1.4\n   /CreationDate (D:20260715123456+08'00)\n%%EOF\n",
  )
  inspect(
    test_vector_bytes_equal_ffi(
      0, pdf_default_date_left, pdf_default_date_right,
    ),
    content="true",
  )
  let pdf_explicit_date_left = @utf8.encode(
    "%PDF-1.4\n   /CreationDate (20260102030405+00'00')\n%%EOF\n",
  )
  let pdf_explicit_date_right = @utf8.encode(
    "%PDF-1.4\n   /CreationDate (20260715123456+08'00')\n%%EOF\n",
  )
  inspect(
    test_vector_bytes_equal_ffi(
      0, pdf_explicit_date_left, pdf_explicit_date_right,
    ),
    content="false",
  )
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    for scene in 0..<15 {
      if scene != 7 && scene != 8 {
        let path = "/tmp/cairoon_stream_primitive_vector_file_equivalence_\{kind}_\{scene}.\{ext}"
        let file_surface = make_stream_equivalence_file_surface(kind, path)
        render_stream_glyph_vector_scene(file_surface, scene)
        if kind == 0 && @cairoon.CAIRO_VERSION >= 11706 {
          expect_vector_output(path, [
            "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
          ])
        }

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
