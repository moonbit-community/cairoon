///|
fn make_vector_oracle_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  match kind {
    0 => {
      let surface = @cairoon.Surface::pdf_stream(10.0, 10.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon-vector-oracle",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreateDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataModDate,
        fixed_pdf_metadata_date(),
      )
      surface
    }
    1 =>
      @cairoon.Surface::ps_stream(10.0, 10.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(10.0, 10.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
}

///|
fn render_vector_oracle_stream_scene(
  scene : Int,
  kind : Int,
  chunks : Array[Bytes],
) -> Unit raise @cairoon.CairoError {
  let surface = make_vector_oracle_stream_surface(kind, chunks)
  render_stream_glyph_vector_scene(surface, scene)
}

///|
fn render_backend_oracle_stream_scene(
  scene : Int,
  kind : Int,
  chunks : Array[Bytes],
) -> Unit raise @cairoon.CairoError {
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
    41 => {
      let surface = make_stream_page_transition_stream_surface(kind, chunks)
      render_stream_page_transition_scene(kind, surface)
    }
    42 => {
      let surface = make_stream_state_stack_stream_surface(kind, chunks)
      render_stream_state_stack_scene(kind, surface)
    }
    44 => {
      let surface = make_stream_text_state_stream_surface(kind, chunks)
      render_stream_text_state_scene(kind, surface)
    }
    45 => {
      let surface = make_stream_deep_tag_stream_surface(kind, chunks)
      render_stream_deep_tag_scene(kind, surface)
    }
    46 => {
      let surface = make_stream_metadata_outline_stream_surface(kind, chunks)
      render_stream_metadata_outline_scene(kind, surface)
    }
    47 => {
      let surface = make_stream_page_ops_stream_surface(kind, chunks)
      render_stream_page_ops_scene(kind, surface)
    }
    48 => {
      let surface = make_stream_tag_metadata_stream_surface(kind, chunks)
      render_stream_tag_metadata_scene(kind, surface)
    }
    49 => {
      let surface = make_stream_structure_sequence_stream_surface(kind, chunks)
      render_stream_structure_sequence_scene(kind, surface)
    }
    50 => {
      let surface = make_stream_outline_sequence_stream_surface(kind, chunks)
      render_stream_outline_sequence_scene(kind, surface)
    }
    51 => {
      let surface = make_stream_pattern_tag_stream_surface(kind, chunks)
      render_stream_pattern_tag_scene(kind, surface)
    }
    52 => {
      let surface = make_stream_annotation_sequence_stream_surface(kind, chunks)
      render_stream_annotation_sequence_scene(kind, surface)
    }
    53 => {
      let surface = make_stream_semantic_index_stream_surface(kind, chunks)
      render_stream_semantic_index_scene(kind, surface)
    }
    54 => {
      let surface = make_stream_bookmark_lattice_stream_surface(kind, chunks)
      render_stream_bookmark_lattice_scene(kind, surface)
    }
    55 => {
      let surface = make_stream_revision_ledger_stream_surface(kind, chunks)
      render_stream_revision_ledger_scene(kind, surface)
    }
    56 => {
      let surface = make_stream_article_thread_stream_surface(kind, chunks)
      render_stream_article_thread_scene(kind, surface)
    }
    57 => {
      let surface = make_stream_review_dossier_stream_surface(kind, chunks)
      render_stream_review_dossier_scene(kind, surface)
    }
    58 => {
      let surface = make_stream_appendix_rubric_stream_surface(kind, chunks)
      render_stream_appendix_rubric_scene(kind, surface)
    }
    59 => {
      let surface = make_stream_research_note_stream_surface(kind, chunks)
      render_stream_research_note_scene(kind, surface)
    }
    60 => {
      let surface = make_stream_cross_reference_stream_surface(kind, chunks)
      render_stream_cross_reference_scene(kind, surface)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
test "primitive vector streams match direct cairo C oracle after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    for scene in 0..<15 {
      let chunks : Array[Bytes] = []
      render_vector_oracle_stream_scene(scene, kind, chunks)
      inspect(chunks.length() > 0, content="true")

      let oracle_path = "/tmp/cairoon_stream_primitive_oracle_\{kind}_\{scene}.\{ext}"
      @cairoon.check_status(
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
        @cairoon.check_status(
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
test "tagged font matrix text streams match direct cairo C oracle after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let chunks : Array[Bytes] = []
    render_vector_oracle_stream_scene(43, kind, chunks)
    inspect(chunks.length() > 0, content="true")

    let oracle_path = "/tmp/cairoon_stream_font_matrix_tag_oracle_\{kind}.\{ext}"
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        43,
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

///|
test "copy-page and glyph vector streams match direct cairo C oracle after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    for scene in [31, 32, 33] {
      let chunks : Array[Bytes] = []
      render_vector_oracle_stream_scene(scene, kind, chunks)
      inspect(chunks.length() > 0, content="true")

      let oracle_path = "/tmp/cairoon_stream_page_glyph_oracle_\{kind}_\{scene}.\{ext}"
      @cairoon.check_status(
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

///|
test "single-backend document feature streams match direct cairo C oracle after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let scene = match kind {
      0 => 18
      1 => 19
      2 => 20
      _ => -1
    }
    let chunks : Array[Bytes] = []
    let surface = make_stream_document_feature_stream_surface(kind, chunks)
    render_stream_document_feature_scene(kind, surface)
    inspect(chunks.length() > 0, content="true")

    let oracle_path = "/tmp/cairoon_stream_single_backend_oracle_\{kind}_\{scene}.\{ext}"
    @cairoon.check_status(
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

  for scene in [21, 34] {
    let chunks : Array[Bytes] = []
    let surface = @cairoon.Surface::pdf_stream(100.0, 100.0, fn(chunk) {
      chunks.push(chunk)
      @cairoon.Success
    })
    match scene {
      21 => ignore(render_pdf_text_document_feature_surface(surface))
      34 => ignore(render_pdf_page_operation_document_feature_surface(surface))
      _ => @cairoon.check_status(@cairoon.InvalidStatus)
    }
    inspect(chunks.length() > 0, content="true")

    let oracle_path = "/tmp/cairoon_stream_pdf_document_oracle_\{scene}.pdf"
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        0,
        scene,
        checked_path_bytes(oracle_path),
      ),
    )
    inspect(
      test_vector_file_equals_bytes_ffi(
        0,
        checked_path_bytes(oracle_path),
        stream_equivalence_chunks_to_bytes(chunks),
      ),
      content="true",
    )
  }
}

///|
test "pdf mime and thumbnail streams match direct cairo C oracle after normalization" {
  let jpeg = tiny_jpeg_payload()
  let jpeg_chunks : Array[Bytes] = []
  let jpeg_surface = @cairoon.Surface::pdf_stream(3.0, 3.0, fn(chunk) {
    jpeg_chunks.push(chunk)
    @cairoon.Success
  })
  render_pdf_jpeg_mime_surface(jpeg_surface, jpeg)
  inspect(jpeg_chunks.length() > 0, content="true")

  let jpeg_oracle_path = "/tmp/cairoon_stream_pdf_jpeg_mime_oracle.pdf"
  @cairoon.check_status(
    test_render_pdf_jpeg_mime_oracle_ffi(
      checked_path_bytes(jpeg_oracle_path),
      jpeg,
    ),
  )
  inspect(
    test_vector_file_equals_bytes_ffi(
      0,
      checked_path_bytes(jpeg_oracle_path),
      stream_equivalence_chunks_to_bytes(jpeg_chunks),
    ),
    content="true",
  )

  let thumbnail_chunks : Array[Bytes] = []
  let thumbnail_surface = @cairoon.Surface::pdf_stream(20.0, 20.0, fn(chunk) {
    thumbnail_chunks.push(chunk)
    @cairoon.Success
  })
  render_pdf_thumbnail_surface(thumbnail_surface)
  inspect(thumbnail_chunks.length() > 0, content="true")

  let thumbnail_oracle_path = "/tmp/cairoon_stream_pdf_thumbnail_oracle.pdf"
  @cairoon.check_status(
    test_render_pdf_thumbnail_oracle_ffi(
      checked_path_bytes(thumbnail_oracle_path),
    ),
  )
  inspect(
    test_vector_file_equals_bytes_ffi(
      0,
      checked_path_bytes(thumbnail_oracle_path),
      stream_equivalence_chunks_to_bytes(thumbnail_chunks),
    ),
    content="true",
  )
}

///|
test "backend feature streams match direct cairo C oracle after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    for
      scene in [
        35, 36, 37, 38, 39, 40, 41, 42, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54,
        55, 56, 57, 58, 59, 60,
      ] {
      let chunks : Array[Bytes] = []
      render_backend_oracle_stream_scene(scene, kind, chunks)
      inspect(chunks.length() > 0, content="true")

      let oracle_path = "/tmp/cairoon_stream_direct_oracle_\{kind}_\{scene}.\{ext}"
      @cairoon.check_status(
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
