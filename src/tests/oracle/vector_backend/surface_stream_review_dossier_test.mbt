///|
fn make_stream_review_dossier_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(140.0, 112.0, path=Some(path))
    1 => @cairoon.Surface::ps(140.0, 112.0, path=Some(path))
    2 => @cairoon.Surface::svg(140.0, 112.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_review_dossier_backend(kind, surface)
  surface
}

///|
fn make_stream_review_dossier_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(140.0, 112.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      @cairoon.Surface::ps_stream(140.0, 112.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      @cairoon.Surface::svg_stream(140.0, 112.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_review_dossier_backend(kind, surface)
  surface
}

///|
fn configure_stream_review_dossier_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Review Dossier")
      surface.pdf_set_metadata(PdfMetadataSubject, "draft review dossier")
      surface.pdf_set_metadata(PdfMetadataSubject, "final review dossier")
      surface.pdf_set_metadata(
        PdfMetadataKeywords,
        "review,dossier,toc,list,table",
      )
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon review dossier")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      set_pdf_custom_metadata_if_supported(surface, "Dossier", Some("draft"))
      set_pdf_custom_metadata_if_supported(surface, "Dossier", Some("final"))
      set_pdf_custom_metadata_if_supported(surface, "Scratch", Some("drop-me"))
      set_pdf_custom_metadata_if_supported(surface, "Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Review Dossier")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType ReviewDossier")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize ReviewDossier")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPt)
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}

///|
fn resize_stream_review_dossier_surface(
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
fn draw_stream_review_dossier_index(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.18, 0.34, 0.52, 0.78)
  for i in 0..<2 {
    let y = 46.0 + i.to_double() * 22.0
    ctx.rectangle(18.0, y - 10.0, 96.0, 14.0)
    ctx.fill()
    ctx.set_source_rgb(0.96, 0.96, 0.88)
    ctx.move_to(22.0, y)
    ctx.show_text(
      match i {
        0 => "decision list"
        _ => "evidence table"
      },
    )
    ctx.set_source_rgba(0.18, 0.34, 0.52, 0.78)
  }
}

///|
fn draw_stream_review_dossier_list(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.58, 0.24, 0.28, 0.76)
  ctx.rectangle(18.0, 34.0, 100.0, 34.0)
  ctx.fill()
  ctx.set_source_rgb(0.98, 0.96, 0.88)
  ctx.move_to(24.0, 48.0)
  ctx.show_text("1")
  ctx.move_to(38.0, 48.0)
  ctx.show_text("accept")
  ctx.move_to(24.0, 62.0)
  ctx.show_text("2")
  ctx.move_to(38.0, 62.0)
  ctx.show_text("follow up")
  ctx.set_source_rgba(0.18, 0.50, 0.34, 0.74)
  ctx.arc(104.0, 86.0, 14.0, 0.0, 6.283185307179586)
  ctx.fill()
}

///|
fn draw_stream_review_dossier_table(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.20, 0.42, 0.62, 0.76)
  ctx.rectangle(18.0, 32.0, 106.0, 44.0)
  ctx.fill()
  ctx.set_source_rgb(0.98, 0.96, 0.88)
  ctx.move_to(24.0, 48.0)
  ctx.show_text("item")
  ctx.move_to(72.0, 48.0)
  ctx.show_text("state")
  ctx.set_source_rgba(0.94, 0.74, 0.22, 0.84)
  ctx.rectangle(22.0, 56.0, 44.0, 14.0)
  ctx.rectangle(70.0, 56.0, 44.0, 14.0)
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(25.0, 67.0)
  ctx.show_text("api")
  ctx.move_to(74.0, 67.0)
  ctx.show_text("ok")
}

///|
fn render_stream_review_dossier_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut list_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(140.0, 112.0)
    surface.pdf_set_page_label("review-index")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "review index",
      "page=1 pos=[18 28]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  }
  ctx.set_source_rgb(0.96, 0.94, 0.88)
  ctx.paint()
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.move_to(18.0, 28.0)
  ctx.show_text("review dossier")
  ctx.tag_end("H1")
  ctx.tag_begin("TOC", "")
  ctx.tag_begin("TOCI", "")
  ctx.tag_begin("Reference", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='review-list'")
  draw_stream_review_dossier_index(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Reference")
  ctx.tag_end("TOCI")
  ctx.tag_end("TOC")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(132.0, 118.0)
    surface.pdf_set_page_label("review-list")
    list_id = surface.pdf_add_outline_with_flags(
      root_id,
      "review list",
      "page=2 pos=[20 44]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  } else {
    resize_stream_review_dossier_surface(kind, surface, 132.0, 118.0)
  }
  ctx.set_source_rgb(0.90, 0.96, 0.92)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_DEST, "name='review-list' x=20 y=44")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("L", "")
  ctx.tag_begin("LI", "")
  ctx.tag_begin("Lbl", "")
  ctx.move_to(22.0, 82.0)
  ctx.show_text("labels")
  ctx.tag_end("Lbl")
  ctx.tag_begin("LBody", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/review-dossier'")
  draw_stream_review_dossier_list(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("LBody")
  ctx.tag_end("LI")
  ctx.tag_end("L")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.copy_page()

  if kind == 0 {
    surface.pdf_set_size(136.0, 110.0)
    surface.pdf_set_page_label("review-table")
    let _ = surface.pdf_add_outline_with_flags(
      list_id,
      "review table",
      "page=3 pos=[18 86]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineBold),
    )
  } else {
    resize_stream_review_dossier_surface(kind, surface, 136.0, 110.0)
  }
  ctx.set_source_rgb(0.94, 0.92, 0.98)
  ctx.paint()
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Table", "")
  ctx.tag_begin("TR", "")
  ctx.tag_begin("TH", "")
  ctx.move_to(20.0, 88.0)
  ctx.show_text("table header")
  ctx.tag_end("TH")
  ctx.tag_begin("TD", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='review-list'")
  draw_stream_review_dossier_table(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("TD")
  ctx.tag_end("TR")
  ctx.tag_end("Table")
  ctx.tag_begin("NonStruct", "")
  ctx.tag_begin("Note", "")
  ctx.move_to(20.0, 100.0)
  ctx.show_text("review note")
  ctx.tag_end("Note")
  ctx.tag_end("NonStruct")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend review dossier stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_review_dossier_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_review_dossier_file_surface(kind, path)
    render_stream_review_dossier_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_review_dossier_stream_surface(kind, chunks)
    render_stream_review_dossier_scene(kind, stream_surface)
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
test "backend review dossier file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_review_dossier_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_review_dossier_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_review_dossier_file_surface(kind, path)
    render_stream_review_dossier_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        57,
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
test "backend review dossier output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_review_dossier_markers_\{kind}.\{ext}"
    let surface = make_stream_review_dossier_file_surface(kind, path)
    render_stream_review_dossier_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Review Dossier)", "/Subject (final review dossier)",
          "/Keywords (review,dossier,toc,list,table)", "/Creator (cairoon review dossier)",
          "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
          "/Dossier (final)", "/MediaBox [ 0 0 140 112 ]", "/MediaBox [ 0 0 132 118 ]",
          "/MediaBox [ 0 0 136 110 ]", "/PageLabels", "(review-index)", "(review-list)",
          "(review-table)", "/Outlines", "/Title (review index)", "/Title (review list)",
          "/Title (review table)", "/Count 1", "/Count -1", "/F 1", "/F 2", "/Annots [",
          "/Subtype /Link", "/S /URI", "/URI (https://example.com/review-dossier)",
          "/Dest", "/Dests", "(review-list)", "/StructTreeRoot", "/S /Document",
          "/S /Part", "/S /Sect", "/S /H1", "/S /TOC", "/S /TOCI", "/S /Reference",
          "/S /L", "/S /LI", "/S /Lbl", "/S /LBody", "/S /Table", "/S /TR", "/S /TH",
          "/S /TD", "/S /NonStruct", "/S /Note", "%%EOF",
        ])
        expect_vector_output_absent(path, [
          "/Scratch", "drop-me", "/Dossier (draft)", "/Subject (draft review dossier)",
        ])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Review Dossier",
          "%%IncludeFeature: *MediaType ReviewDossier", "%%IncludeFeature: *PageSize ReviewDossier",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"140pt\" height=\"112pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend review dossier output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Part", "/S /Sect", "/S /H1", "/S /TOC", "/S /TOCI", "/S /Reference", "/S /L",
    "/S /LI", "/S /Lbl", "/S /LBody", "/S /Table", "/S /TR", "/S /TH", "/S /TD",
    "/S /NonStruct", "/S /Note", "https://example.com/review-dossier", "review-list",
    "final review dossier", "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_review_dossier_absent_\{kind}.\{ext}"
    let surface = make_stream_review_dossier_file_surface(kind, path)
    render_stream_review_dossier_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_review_dossier_stream_surface(kind, chunks)
    render_stream_review_dossier_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
