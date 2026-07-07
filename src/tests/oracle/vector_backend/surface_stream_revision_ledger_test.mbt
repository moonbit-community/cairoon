///|
fn make_stream_revision_ledger_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(124.0, 104.0, path=Some(path))
    1 => @cairoon.Surface::ps(124.0, 104.0, path=Some(path))
    2 => @cairoon.Surface::svg(124.0, 104.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_revision_ledger_backend(kind, surface)
  surface
}

///|
fn make_stream_revision_ledger_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(124.0, 104.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(124.0, 104.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(124.0, 104.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_revision_ledger_backend(kind, surface)
  surface
}

///|
fn configure_stream_revision_ledger_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataTitle,
        "Cairoon Revision Ledger",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataAuthor,
        "cairoon backend oracle",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataSubject,
        "draft revision sequence",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataSubject,
        "final revision sequence",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataKeywords,
        "revision,ledger,page,tag",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon revision ledger",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreateDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataModDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_custom_metadata("RevisionLedger", Some("draft"))
      surface.pdf_set_custom_metadata("RevisionLedger", Some("final"))
      surface.pdf_set_custom_metadata("Stage", Some("proposal"))
      surface.pdf_set_custom_metadata("Stage", Some("accepted"))
      surface.pdf_set_custom_metadata("Ephemeral", Some("remove-me"))
      surface.pdf_set_custom_metadata("Ephemeral", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Revision Ledger")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType RevisionLedger")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize RevisionLedger")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPt)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn resize_stream_revision_ledger_surface(
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
fn draw_stream_revision_ledger_draft(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.18, 0.34, 0.58, 0.82)
  ctx.rectangle(14.0, 40.0, 86.0, 24.0)
  ctx.fill()
  ctx.set_source_rgb(0.96, 0.94, 0.82)
  ctx.move_to(18.0, 56.0)
  ctx.show_text("draft baseline")
  ctx.set_source_rgba(0.78, 0.28, 0.22, 0.68)
  ctx.arc(94.0, 78.0, 14.0, 0.0, 6.283185307179586)
  ctx.fill()
}

///|
fn draw_stream_revision_ledger_review(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.08, 0.42, 0.28, 0.74)
  ctx.rectangle(18.0, 56.0, 92.0, 18.0)
  ctx.fill()
  ctx.set_source_rgb(0.02, 0.02, 0.02)
  ctx.move_to(22.0, 70.0)
  ctx.show_text("review overlay")
  ctx.set_source_rgba(0.64, 0.42, 0.16, 0.72)
  ctx.move_to(22.0, 84.0)
  ctx.line_to(64.0, 62.0)
  ctx.line_to(112.0, 84.0)
  ctx.stroke()
}

///|
fn draw_stream_revision_ledger_final(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.36, 0.20, 0.58, 0.72)
  ctx.rectangle(18.0, 44.0, 82.0, 18.0)
  ctx.fill()
  ctx.set_source_rgba(0.20, 0.52, 0.66, 0.72)
  ctx.rectangle(18.0, 68.0, 82.0, 18.0)
  ctx.fill()
  ctx.set_source_rgb(0.02, 0.02, 0.02)
  ctx.move_to(22.0, 58.0)
  ctx.show_text("accepted")
  ctx.move_to(22.0, 82.0)
  ctx.show_text("linked back")
}

///|
fn render_stream_revision_ledger_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut review_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(124.0, 104.0)
    surface.pdf_set_page_label("ledger-draft")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "ledger draft",
      "page=1 pos=[12 28]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  ctx.set_source_rgb(0.96, 0.95, 0.88)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "uri='https://example.com/revision-ledger/draft'",
  )
  ctx.move_to(12.0, 28.0)
  ctx.show_text("revision ledger")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("H1")
  ctx.tag_begin("P", "")
  draw_stream_revision_ledger_draft(ctx)
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(136.0, 104.0)
    surface.pdf_set_page_label("ledger-review")
    review_id = surface.pdf_add_outline_with_flags(
      root_id,
      "ledger review",
      "page=2 pos=[18 70]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
  } else {
    resize_stream_revision_ledger_surface(kind, surface, 136.0, 104.0)
  }
  ctx.tag_begin(@cairoon.TAG_DEST, "name='ledger-review' x=18 y=70")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  draw_stream_revision_ledger_review(ctx)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.show_page()

  if kind == 0 {
    surface.pdf_set_size(118.0, 126.0)
    surface.pdf_set_page_label("ledger-final")
    let _ = surface.pdf_add_outline_with_flags(
      review_id,
      "ledger final",
      "page=3 pos=[18 104]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineBold,
        @cairoon.PdfOutlineItalic,
      ]),
    )
  } else {
    resize_stream_revision_ledger_surface(kind, surface, 118.0, 126.0)
  }
  ctx.set_source_rgb(0.92, 0.98, 0.94)
  ctx.paint()
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Table", "")
  ctx.tag_begin("TR", "")
  ctx.tag_begin("TD", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='ledger-review'")
  draw_stream_revision_ledger_final(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("TD")
  ctx.tag_end("TR")
  ctx.tag_end("Table")
  ctx.tag_begin(@cairoon.TAG_DEST, "name='ledger-final' x=18 y=104")
  ctx.tag_begin("P", "")
  ctx.move_to(18.0, 104.0)
  ctx.show_text("final marker")
  ctx.tag_end("P")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend revision ledger stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_revision_ledger_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_revision_ledger_file_surface(kind, path)
    render_stream_revision_ledger_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_revision_ledger_stream_surface(
      kind, chunks,
    )
    render_stream_revision_ledger_scene(kind, stream_surface)
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
test "backend revision ledger file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_revision_ledger_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_revision_ledger_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_revision_ledger_file_surface(kind, path)
    render_stream_revision_ledger_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        55,
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
test "backend revision ledger output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_revision_ledger_markers_\{kind}.\{ext}"
    let surface = make_stream_revision_ledger_file_surface(kind, path)
    render_stream_revision_ledger_scene(kind, surface)
    match kind {
      0 => {
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Revision Ledger)", "/Author (cairoon backend oracle)",
          "/Subject (final revision sequence)", "/Keywords (revision,ledger,page,tag)",
          "/Creator (cairoon revision ledger)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/RevisionLedger (final)", "/Stage (accepted)",
          "/MediaBox [ 0 0 124 104 ]", "/MediaBox [ 0 0 136 104 ]", "/MediaBox [ 0 0 118 126 ]",
          "/PageLabels", "(ledger-draft)", "(ledger-review)", "(ledger-final)", "/Outlines",
          "/Title (ledger draft)", "/Title (ledger review)", "/Title (ledger final)",
          "/F 3", "/F 1", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/revision-ledger/draft)",
          "/Dest", "/Dests", "(ledger-review)", "(ledger-final)", "/StructTreeRoot",
          "/S /Document", "/S /Part", "/S /Sect", "/S /H1", "/S /P", "/S /Span",
          "/S /Table", "/S /TR", "/S /TD", "%%EOF",
        ])
        expect_vector_output_absent(path, [
          "/Ephemeral", "remove-me", "/Stage (proposal)",
        ])
      }
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Revision Ledger",
          "%%IncludeFeature: *MediaType RevisionLedger", "%%IncludeFeature: *PageSize RevisionLedger",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_vector_output(path, [
          "<?xml version=\"1.0\"", "<svg", "width=\"124pt\" height=\"104pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend revision ledger output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Part", "/S /Sect", "/S /H1", "/S /P", "/S /Span", "/S /Table", "/S /TR",
    "/S /TD", "https://example.com/revision-ledger/draft", "ledger-review", "ledger-final",
    "final revision sequence", "remove-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_revision_ledger_absent_\{kind}.\{ext}"
    let surface = make_stream_revision_ledger_file_surface(kind, path)
    render_stream_revision_ledger_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_revision_ledger_stream_surface(
      kind, chunks,
    )
    render_stream_revision_ledger_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
