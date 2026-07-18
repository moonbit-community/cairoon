///|
fn make_stream_outline_sequence_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(112.0, 88.0, path=Some(path))
    1 => @cairoon.Surface::ps(112.0, 88.0, path=Some(path))
    2 => @cairoon.Surface::svg(112.0, 88.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_outline_sequence_backend(kind, surface)
  surface
}

///|
fn make_stream_outline_sequence_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(112.0, 88.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      @cairoon.Surface::ps_stream(112.0, 88.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      @cairoon.Surface::svg_stream(112.0, 88.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_outline_sequence_backend(kind, surface)
  surface
}

///|
fn configure_stream_outline_sequence_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Outline Sequence")
      surface.pdf_set_metadata(
        PdfMetadataSubject,
        "outline sequence page operations",
      )
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon outline sequence")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      set_pdf_custom_metadata_if_supported(
        surface,
        "OutlineSeq",
        Some("context-surface-page-ops"),
      )
      set_pdf_custom_metadata_if_supported(
        surface,
        "OutlineScratch",
        Some("drop"),
      )
      set_pdf_custom_metadata_if_supported(surface, "OutlineScratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Outline Sequence")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType OutlineSeq")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize OutlineSeq")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPt)
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}

///|
fn resize_stream_outline_sequence_surface(
  kind : Int,
  surface : @cairoon.Surface,
  width : Double,
  height : Double,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => surface.pdf_set_size(width, height)
    1 => surface.ps_set_size(width, height)
    _ => ()
  }
}

///|
fn draw_outline_sequence_cover(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgb(0.88, 0.94, 0.99)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/outline-sequence'")
  ctx.move_to(10.0, 26.0)
  ctx.show_text("outline sequence cover")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.set_source_rgb(0.15, 0.38, 0.66)
  ctx.rectangle(10.0, 42.0, 78.0, 24.0)
  ctx.fill()
}

///|
fn draw_outline_sequence_branch(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgb(0.96, 0.92, 0.84)
  ctx.paint()
  ctx.set_source_rgba(0.76, 0.18, 0.22, 0.70)
  ctx.rectangle(16.0, 34.0, 82.0, 22.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='outline-sequence-dest' x=16 y=72")
  ctx.move_to(16.0, 72.0)
  ctx.show_text("outline sequence branch")
  ctx.tag_end(@cairoon.TAG_DEST)
}

///|
fn draw_outline_sequence_final(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgb(0.91, 0.96, 0.90)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='outline-sequence-dest'")
  ctx.move_to(12.0, 66.0)
  ctx.show_text("outline sequence final link")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Figure")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.set_source_rgb(0.24, 0.50, 0.28)
  ctx.arc(78.0, 38.0, 14.0, 0.0, 6.283185307179586)
  ctx.fill()
}

///|
fn render_stream_outline_sequence_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(9.5)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut branch_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_page_label("outline-seq-cover")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "outline sequence cover",
      "page=1 pos=[10 26]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  }
  draw_outline_sequence_cover(ctx)
  ctx.copy_page()

  resize_stream_outline_sequence_surface(kind, surface, 132.0, 92.0)
  if kind == 0 {
    surface.pdf_set_page_label("outline-seq-branch")
    branch_id = surface.pdf_add_outline_with_flags(
      root_id,
      "outline sequence branch",
      "page=2 pos=[16 72]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "outline sequence sibling",
      "page=2 pos=[72 34]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineBold, PdfOutlineItalic]),
    )
  }
  draw_outline_sequence_branch(ctx)
  surface.copy_page()

  resize_stream_outline_sequence_surface(kind, surface, 108.0, 102.0)
  if kind == 0 {
    surface.pdf_set_page_label("outline-seq-final")
    let _ = surface.pdf_add_outline_with_flags(
      branch_id,
      "outline sequence final",
      "page=3 pos=[12 66]",
      @cairoon.PDFOutlineFlagSet::combine([
        PdfOutlineOpen,
        PdfOutlineBold,
        PdfOutlineItalic,
      ]),
    )
  }
  draw_outline_sequence_final(ctx)
  surface.show_page()
  surface.finish()
}

///|
test "backend outline sequence stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_outline_sequence_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_outline_sequence_file_surface(kind, path)
    render_stream_outline_sequence_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_outline_sequence_stream_surface(
      kind, chunks,
    )
    render_stream_outline_sequence_scene(kind, stream_surface)
    inspect(chunks.length() > 0, content="true")
    inspect(
      test_vector_file_equals_bytes_ffi(
        kind,
        checked_path_bytes(path),
        stream_equivalence_chunks_to_bytes(chunks),
      ),
      content="true",
    )
  }
}

///|
test "backend outline sequence file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_outline_sequence_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_outline_sequence_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_outline_sequence_file_surface(kind, path)
    render_stream_outline_sequence_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        50,
        checked_path_bytes(oracle_path),
      ),
    )
    inspect(
      test_vector_files_equal_ffi(
        kind,
        checked_path_bytes(path),
        checked_path_bytes(oracle_path),
      ),
      content="true",
    )
  }
}

///|
test "backend outline sequence output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_outline_sequence_markers_\{kind}.\{ext}"
    let surface = make_stream_outline_sequence_file_surface(kind, path)
    render_stream_outline_sequence_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Outline Sequence)", "/Subject (outline sequence page operations)",
          "/Creator (cairoon outline sequence)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/OutlineSeq (context-surface-page-ops)",
          "/Count -3", "/MediaBox [ 0 0 112 88 ]", "/MediaBox [ 0 0 132 92 ]", "/MediaBox [ 0 0 108 102 ]",
          "/PageLabels", "(outline-seq-cover)", "(outline-seq-branch)", "(outline-seq-final)",
          "/Outlines", "/Title (outline sequence cover)", "/Title (outline sequence branch)",
          "/Title (outline sequence sibling)", "/Title (outline sequence final)",
          "/F 2", "/F 1", "/F 3", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/outline-sequence)",
          "/Dest", "/Dests", "(outline-sequence-dest)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /Figure", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/OutlineScratch", "drop"])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Outline Sequence",
          "%%IncludeFeature: *MediaType OutlineSeq", "%%IncludeFeature: *PageSize OutlineSeq",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"112pt\" height=\"88pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend outline sequence output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /Figure", "https://example.com/outline-sequence", "outline-sequence-dest",
    "context-surface-page-ops", "OutlineScratch", "outline-seq-cover", "outline-seq-branch",
    "outline-seq-final", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_outline_sequence_absent_\{kind}.\{ext}"
    let surface = make_stream_outline_sequence_file_surface(kind, path)
    render_stream_outline_sequence_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_outline_sequence_stream_surface(
      kind, chunks,
    )
    render_stream_outline_sequence_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
