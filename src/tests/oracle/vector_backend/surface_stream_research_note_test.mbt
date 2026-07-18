///|
fn make_stream_research_note_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(132.0, 108.0, path=Some(path))
    1 => @cairoon.Surface::ps(132.0, 108.0, path=Some(path))
    2 => @cairoon.Surface::svg(132.0, 108.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_research_note_backend(kind, surface)
  surface
}

///|
fn make_stream_research_note_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(132.0, 108.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      @cairoon.Surface::ps_stream(132.0, 108.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      @cairoon.Surface::svg_stream(132.0, 108.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_research_note_backend(kind, surface)
  surface
}

///|
fn configure_stream_research_note_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Research Note")
      surface.pdf_set_metadata(PdfMetadataAuthor, "cairoon backend oracle")
      surface.pdf_set_metadata(PdfMetadataSubject, "draft research note")
      surface.pdf_set_metadata(PdfMetadataSubject, "final research note")
      surface.pdf_set_metadata(
        PdfMetadataKeywords,
        "research,note,table,artifact",
      )
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon research note")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      set_pdf_custom_metadata_if_supported(surface, "Review", Some("alpha"))
      set_pdf_custom_metadata_if_supported(surface, "Review", Some("accepted"))
      set_pdf_custom_metadata_if_supported(
        surface,
        "Scratch",
        Some("remove-me"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Research Note")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType ResearchNote")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize ResearchNote")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPt)
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}

///|
fn resize_stream_research_note_surface(
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
fn draw_stream_research_abstract(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.16, 0.36, 0.48, 0.78)
  ctx.rectangle(16.0, 42.0, 92.0, 18.0)
  ctx.fill()
  ctx.set_source_rgb(0.96, 0.96, 0.88)
  ctx.move_to(20.0, 55.0)
  ctx.show_text("abstract link")
  ctx.set_source_rgba(0.60, 0.30, 0.18, 0.74)
  ctx.arc(108.0, 78.0, 12.0, 0.0, 6.283185307179586)
  ctx.fill()
}

///|
fn draw_stream_research_table(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.22, 0.46, 0.34, 0.78)
  ctx.rectangle(18.0, 34.0, 108.0, 40.0)
  ctx.fill()
  ctx.set_source_rgb(0.98, 0.96, 0.88)
  ctx.move_to(24.0, 48.0)
  ctx.show_text("metric")
  ctx.move_to(78.0, 48.0)
  ctx.show_text("value")
  ctx.set_source_rgba(0.86, 0.72, 0.28, 0.86)
  ctx.rectangle(22.0, 56.0, 48.0, 14.0)
  ctx.rectangle(74.0, 56.0, 48.0, 14.0)
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(25.0, 67.0)
  ctx.show_text("ffi")
  ctx.move_to(78.0, 67.0)
  ctx.show_text("ok")
}

///|
fn draw_stream_research_note(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.48, 0.28, 0.58, 0.76)
  ctx.rectangle(18.0, 32.0, 110.0, 22.0)
  ctx.fill()
  ctx.set_source_rgba(0.18, 0.52, 0.62, 0.74)
  ctx.rectangle(26.0, 64.0, 94.0, 18.0)
  ctx.fill()
  ctx.set_source_rgb(0.98, 0.98, 0.88)
  ctx.move_to(22.0, 47.0)
  ctx.show_text("artifact figure")
  ctx.move_to(30.0, 77.0)
  ctx.show_text("see table")
}

///|
fn render_stream_research_note_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut abstract_id = @cairoon.PDF_OUTLINE_ROOT
  let mut table_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(132.0, 108.0)
    surface.pdf_set_page_label("research-abstract")
    abstract_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "research abstract",
      "page=1 pos=[18 30]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  }
  ctx.set_source_rgb(0.94, 0.96, 0.92)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.move_to(18.0, 30.0)
  ctx.show_text("research note")
  ctx.tag_end("H1")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/research-note'")
  draw_stream_research_abstract(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.copy_page()

  if kind == 0 {
    surface.pdf_set_size(144.0, 118.0)
    surface.pdf_set_page_label("research-table")
    table_id = surface.pdf_add_outline_with_flags(
      abstract_id,
      "research table",
      "page=2 pos=[20 52]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  } else {
    resize_stream_research_note_surface(kind, surface, 144.0, 118.0)
  }
  ctx.set_source_rgb(0.90, 0.95, 0.98)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='research-table' x=20 y=52")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Table", "")
  ctx.tag_begin("TR", "")
  ctx.tag_begin("TH", "")
  ctx.move_to(20.0, 28.0)
  ctx.show_text("table header")
  ctx.tag_end("TH")
  ctx.tag_begin("TD", "")
  draw_stream_research_table(ctx)
  ctx.tag_end("TD")
  ctx.tag_end("TR")
  ctx.tag_end("Table")
  ctx.tag_begin("L", "")
  ctx.tag_begin("LI", "")
  ctx.tag_begin("Lbl", "")
  ctx.move_to(22.0, 94.0)
  ctx.show_text("1")
  ctx.tag_end("Lbl")
  ctx.tag_begin("LBody", "")
  ctx.move_to(34.0, 94.0)
  ctx.show_text("stable")
  ctx.tag_end("LBody")
  ctx.tag_end("LI")
  ctx.tag_end("L")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(150.0, 98.0)
    surface.pdf_set_page_label("research-note")
    let _ = surface.pdf_add_outline_with_flags(
      table_id,
      "research artifact",
      "page=3 pos=[22 44]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineBold),
    )
  } else {
    resize_stream_research_note_surface(kind, surface, 150.0, 98.0)
  }
  ctx.set_source_rgb(0.95, 0.93, 0.98)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Note", "")
  ctx.tag_begin("Reference", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='research-table'")
  ctx.move_to(22.0, 24.0)
  ctx.show_text("research note")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Reference")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin("Caption", "")
  ctx.move_to(22.0, 88.0)
  ctx.show_text("artifact caption")
  ctx.tag_end("Caption")
  draw_stream_research_note(ctx)
  ctx.tag_end("Figure")
  ctx.tag_end("Note")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend research note stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_research_note_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_research_note_file_surface(kind, path)
    render_stream_research_note_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_research_note_stream_surface(kind, chunks)
    render_stream_research_note_scene(kind, stream_surface)
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
test "backend research note file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_research_note_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_research_note_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_research_note_file_surface(kind, path)
    render_stream_research_note_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        59,
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
test "backend research note output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_research_note_markers_\{kind}.\{ext}"
    let surface = make_stream_research_note_file_surface(kind, path)
    render_stream_research_note_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Research Note)", "/Author (cairoon backend oracle)",
          "/Subject (final research note)", "/Keywords (research,note,table,artifact)",
          "/Creator (cairoon research note)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/Review (accepted)", "/MediaBox [ 0 0 132 108 ]",
          "/MediaBox [ 0 0 144 118 ]", "/MediaBox [ 0 0 150 98 ]", "/PageLabels",
          "(research-abstract)", "(research-table)", "(research-note)", "/Outlines",
          "/Title (research abstract)", "/Title (research table)", "/Title (research artifact)",
          "/Count 1", "/Count -1", "/F 1", "/F 2", "/Annots [", "/Subtype /Link",
          "/S /URI", "/URI (https://example.com/research-note)", "/Dest", "/Dests",
          "(research-table)", "/StructTreeRoot", "/S /Document", "/S /Sect", "/S /H1",
          "/S /P", "/S /Span", "/S /Table", "/S /TR", "/S /TH", "/S /TD", "/S /L",
          "/S /LI", "/S /Lbl", "/S /LBody", "/S /Note", "/S /Reference", "/S /Figure",
          "/S /Caption", "%%EOF",
        ])
        expect_vector_output_absent(path, [
          "/Scratch", "remove-me", "/Review (alpha)", "/Subject (draft research note)",
        ])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Research Note",
          "%%IncludeFeature: *MediaType ResearchNote", "%%IncludeFeature: *PageSize ResearchNote",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"132pt\" height=\"108pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend research note output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /H1", "/S /P", "/S /Span", "/S /Table", "/S /TR", "/S /TH", "/S /TD",
    "/S /L", "/S /LI", "/S /Lbl", "/S /LBody", "/S /Note", "/S /Reference", "/S /Figure",
    "/S /Caption", "https://example.com/research-note", "research-table", "final research note",
    "remove-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_research_note_absent_\{kind}.\{ext}"
    let surface = make_stream_research_note_file_surface(kind, path)
    render_stream_research_note_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_research_note_stream_surface(kind, chunks)
    render_stream_research_note_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
