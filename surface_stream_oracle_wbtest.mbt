///|
fn make_vector_oracle_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> Surface raise CairoError {
  match kind {
    0 => {
      let surface = Surface::pdf_stream(10.0, 10.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon-vector-oracle")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      surface
    }
    1 =>
      Surface::ps_stream(10.0, 10.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      Surface::svg_stream(10.0, 10.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn render_vector_oracle_stream_scene(
  scene : Int,
  kind : Int,
  chunks : Array[Bytes],
) -> Unit raise CairoError {
  let surface = make_vector_oracle_stream_surface(kind, chunks)
  render_stream_glyph_vector_scene(surface, scene)
}

///|
fn render_backend_oracle_stream_scene(
  scene : Int,
  kind : Int,
  chunks : Array[Bytes],
) -> Unit raise CairoError {
  match scene {
    35 => {
      let surface = make_stream_combo_stream_surface(kind, chunks)
      render_stream_combo_scene(kind, surface)
    }
    36 => {
      let surface = make_stream_page_combo_stream_surface(kind, chunks)
      render_stream_page_combo_scene(kind, surface)
    }
    37 => {
      let surface = make_stream_nested_tag_stream_surface(kind, chunks)
      render_stream_nested_tag_scene(kind, surface)
    }
    38 => {
      let surface = make_stream_page_sequence_stream_surface(kind, chunks)
      render_stream_page_sequence_scene(kind, surface)
    }
    39 => {
      let surface = make_stream_tag_matrix_stream_surface(kind, chunks)
      render_stream_tag_matrix_scene(kind, surface)
    }
    40 => {
      let surface = make_stream_lifecycle_stream_surface(kind, chunks)
      render_stream_lifecycle_scene(kind, surface)
    }
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
test "tag-heavy vector streams match direct cairo C oracle after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    for scene in 15..<31 {
      if scene < 18 || scene > 21 {
        let chunks : Array[Bytes] = []
        render_vector_oracle_stream_scene(scene, kind, chunks)
        inspect(chunks.length() > 0, content="true")

        let oracle_path = "/tmp/cairoon_stream_tag_oracle_\{kind}_\{scene}.\{ext}"
        check_status(
          test_render_vector_scene_oracle_ffi(
            kind,
            scene,
            checked_path_bytes(oracle_path),
          ),
        )
        inspect(
          test_vector_file_equals_bytes_ffi(
            kind,
            checked_path_bytes(oracle_path),
            stream_equivalence_chunks_to_bytes(chunks),
          ),
          content="true",
        )
      }
    }
  }
}

///|
test "backend feature streams match direct cairo C oracle after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    for scene in 35..<41 {
      let chunks : Array[Bytes] = []
      render_backend_oracle_stream_scene(scene, kind, chunks)
      inspect(chunks.length() > 0, content="true")

      let oracle_path = "/tmp/cairoon_stream_direct_oracle_\{kind}_\{scene}.\{ext}"
      check_status(
        test_render_vector_scene_oracle_ffi(
          kind,
          scene,
          checked_path_bytes(oracle_path),
        ),
      )
      inspect(
        test_vector_file_equals_bytes_ffi(
          kind,
          checked_path_bytes(oracle_path),
          stream_equivalence_chunks_to_bytes(chunks),
        ),
        content="true",
      )
    }
  }
}
