///|
fn stream_equivalence_extension(kind : Int) -> String {
  match kind {
    0 => "pdf"
    1 => "ps"
    2 => "svg"
    _ => "out"
  }
}

///|
fn make_stream_equivalence_file_surface(
  kind : Int,
  path : String,
) -> Surface raise CairoError {
  match kind {
    0 => {
      let surface = Surface::pdf(12.0, 12.0, path=Some(path))
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface
    }
    1 => Surface::ps(12.0, 12.0, path=Some(path))
    2 => {
      let surface = Surface::svg(12.0, 12.0, path=Some(path))
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPx)
      surface
    }
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn make_stream_equivalence_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> Surface raise CairoError {
  match kind {
    0 => {
      let surface = Surface::pdf_stream(12.0, 12.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface
    }
    1 =>
      Surface::ps_stream(12.0, 12.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 => {
      let surface = Surface::svg_stream(12.0, 12.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPx)
      surface
    }
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn make_stream_document_feature_file_surface(
  kind : Int,
  path : String,
) -> Surface raise CairoError {
  match kind {
    0 => Surface::pdf(100.0, 100.0, path=Some(path))
    1 => Surface::ps(12.0, 12.0, path=Some(path))
    2 => Surface::svg(12.0, 12.0, path=Some(path))
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn make_stream_document_feature_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> Surface raise CairoError {
  match kind {
    0 =>
      Surface::pdf_stream(100.0, 100.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      Surface::ps_stream(12.0, 12.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      Surface::svg_stream(12.0, 12.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn render_stream_equivalence_scene(surface : Surface) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.rectangle(1.0, 1.0, 10.0, 10.0)
  ctx.fill()
  ctx.show_page()
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.arc(6.0, 6.0, 4.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.show_page()
  surface.finish()
}

///|
fn render_stream_copy_page_retained_scene(
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  draw_vector_oracle_scene(ctx, 31)
  surface.finish()
}

///|
fn render_stream_surface_page_retained_scene(
  surface : Surface,
) -> Unit raise CairoError {
  draw_surface_page_retained_scene(surface)
  surface.finish()
}

///|
fn render_stream_tagged_multipage_scene(
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(2.0)

  ctx.set_source_rgb(0.9, 0.95, 1.0)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/stream'")
  ctx.move_to(1.0, 4.0)
  ctx.show_text("stream link")
  ctx.tag_end(TAG_LINK)
  ctx.show_page()

  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.move_to(1.0, 4.0)
  ctx.show_text("stream document")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()

  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.rectangle(2.0, 2.0, 8.0, 8.0)
  ctx.fill()
  ctx.show_page()
  surface.finish()
}

///|
fn render_stream_wide_multipage_tag_vector_scene(
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  draw_wide_multi_page_tag_vector_scene(ctx)
  surface.finish()
}

///|
fn render_stream_mixed_tag_vector_scene(
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  draw_mixed_tag_vector_scene(ctx)
  surface.finish()
}

///|
fn render_stream_tagged_show_text_glyphs_scene(
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  draw_tagged_show_text_glyphs_scene(ctx)
  surface.finish()
}

///|
fn render_stream_grouped_glyph_tag_scene(
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  draw_grouped_glyph_tag_multi_page_scene(ctx)
  surface.finish()
}

///|
fn render_stream_layered_multipage_scene(
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  draw_layered_multi_page_scene(ctx)
  surface.finish()
}

///|
fn render_stream_document_feature_scene(
  kind : Int,
  surface : Surface,
) -> Unit raise CairoError {
  match kind {
    0 => render_pdf_document_feature_surface(surface)
    1 => render_ps_dsc_multipage_surface(surface)
    2 => render_svg_unit_multipage_surface(surface)
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn stream_equivalence_chunks_to_bytes(chunks : Array[Bytes]) -> Bytes {
  let mut bytes = Bytes::default()
  for chunk in chunks {
    bytes = bytes + chunk
  }
  bytes
}

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
