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
