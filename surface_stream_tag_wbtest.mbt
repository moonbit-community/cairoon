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
