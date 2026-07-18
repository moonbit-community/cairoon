///|
fn make_stream_accessibility_index_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(118.0, 86.0, path=Some(path))
    1 => @cairoon.Surface::ps(118.0, 86.0, path=Some(path))
    2 => @cairoon.Surface::svg(118.0, 86.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_accessibility_index_backend(kind, surface)
  surface
}

///|
fn make_stream_accessibility_index_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(118.0, 86.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      @cairoon.Surface::ps_stream(118.0, 86.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      @cairoon.Surface::svg_stream(118.0, 86.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_accessibility_index_backend(kind, surface)
  surface
}

///|
fn configure_stream_accessibility_index_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Accessibility Index")
      surface.pdf_set_metadata(PdfMetadataAuthor, "cairoon accessibility index")
      surface.pdf_set_metadata(PdfMetadataSubject, "tagged index metadata")
      surface.pdf_set_metadata(
        PdfMetadataKeywords,
        "accessibility,index,outline,tags",
      )
      surface.pdf_set_metadata(
        PdfMetadataCreator,
        "cairoon accessibility index",
      )
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      set_pdf_custom_metadata_if_supported(
        surface,
        "AccessibilityIndex",
        Some("accessibility-index-64"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Draft", Some("remove-me"))
      set_pdf_custom_metadata_if_supported(surface, "Draft", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Accessibility Index")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType AccessibilityIndex")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize AccessibilityIndex")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPx)
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}

///|
fn resize_stream_accessibility_index_surface(
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
fn draw_stream_accessibility_overview(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.12, 0.30, 0.58, 0.84)
  ctx.rectangle(14.0, 30.0, 88.0, 22.0)
  ctx.fill()
  ctx.set_source_rgba(0.94, 0.82, 0.28, 0.78)
  ctx.rectangle(24.0, 58.0, 58.0, 10.0)
  ctx.fill()
  ctx.set_source_rgb(0.05, 0.05, 0.05)
  ctx.move_to(18.0, 24.0)
  ctx.show_text("access index")
  ctx.move_to(26.0, 66.0)
  ctx.show_text("summary")
}

///|
fn draw_stream_accessibility_terms(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.22, 0.52, 0.44, 0.86)
  ctx.rectangle(18.0, 34.0, 104.0, 24.0)
  ctx.fill()
  ctx.set_source_rgba(0.72, 0.20, 0.54, 0.64)
  ctx.arc(118.0, 74.0, 10.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(24.0, 50.0)
  ctx.show_text("terms")
  ctx.move_to(30.0, 78.0)
  ctx.show_text("alpha beta")
}

///|
fn draw_stream_accessibility_notes(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.50, 0.24, 0.66, 0.82)
  ctx.rectangle(16.0, 30.0, 94.0, 26.0)
  ctx.fill()
  ctx.set_source_rgba(0.24, 0.54, 0.78, 0.68)
  ctx.rectangle(32.0, 64.0, 76.0, 12.0)
  ctx.fill()
  ctx.set_source_rgb(0.98, 0.96, 0.88)
  ctx.move_to(24.0, 47.0)
  ctx.show_text("note")
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(36.0, 72.0)
  ctx.show_text("caption")
}

///|
fn render_stream_accessibility_index_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut terms_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(118.0, 86.0)
    surface.pdf_set_page_label("access-overview")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "accessibility overview",
      "page=1 pos=[18 24]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineOpen),
    )
  }
  ctx.set_source_rgb(0.97, 0.95, 0.89)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "uri='https://example.com/accessibility/index'",
  )
  draw_stream_accessibility_overview(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("H1")
  ctx.tag_begin("L", "")
  ctx.tag_begin("LI", "")
  ctx.tag_begin("Lbl", "")
  ctx.move_to(18.0, 74.0)
  ctx.show_text("1")
  ctx.tag_end("Lbl")
  ctx.tag_begin("LBody", "")
  ctx.move_to(28.0, 74.0)
  ctx.show_text("overview")
  ctx.tag_end("LBody")
  ctx.tag_end("LI")
  ctx.tag_end("L")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(142.0, 104.0)
    surface.pdf_set_page_label("access-terms")
    terms_id = surface.pdf_add_outline_with_flags(
      root_id,
      "term index",
      "page=2 pos=[24 50]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineBold),
    )
  } else {
    resize_stream_accessibility_index_surface(kind, surface, 142.0, 104.0)
  }
  ctx.set_source_rgb(0.89, 0.96, 0.94)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_DEST, "name='access-terms' x=24 y=50")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Index", "")
  ctx.tag_begin("Span", "")
  draw_stream_accessibility_terms(ctx)
  ctx.tag_end("Span")
  ctx.tag_begin("Reference", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='access-notes'")
  ctx.move_to(72.0, 88.0)
  ctx.show_text("notes")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Reference")
  ctx.tag_end("Index")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(128.0, 96.0)
    surface.pdf_set_page_label("access-notes")
    let _ = surface.pdf_add_outline_with_flags(
      terms_id,
      "accessibility notes",
      "page=3 pos=[22 48]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  } else {
    resize_stream_accessibility_index_surface(kind, surface, 128.0, 96.0)
  }
  ctx.set_source_rgb(0.94, 0.91, 0.97)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_DEST, "name='access-notes' x=22 y=48")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Note", "")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin("Caption", "")
  draw_stream_accessibility_notes(ctx)
  ctx.tag_end("Caption")
  ctx.tag_end("Figure")
  ctx.tag_end("Note")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.show_page()
  surface.finish()
}

///|
test "backend accessibility index stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_accessibility_index_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_accessibility_index_file_surface(kind, path)
    render_stream_accessibility_index_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_accessibility_index_stream_surface(
      kind, chunks,
    )
    render_stream_accessibility_index_scene(kind, stream_surface)
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
test "backend accessibility index file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_accessibility_index_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_accessibility_index_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_accessibility_index_file_surface(kind, path)
    render_stream_accessibility_index_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        64,
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
test "backend accessibility index output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_accessibility_index_markers_\{kind}.\{ext}"
    let surface = make_stream_accessibility_index_file_surface(kind, path)
    render_stream_accessibility_index_scene(kind, surface)
    match kind {
      0 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Accessibility Index)", "/Author (cairoon accessibility index)",
          "/Subject (tagged index metadata)", "/Keywords (accessibility,index,outline,tags)",
          "/Creator (cairoon accessibility index)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/AccessibilityIndex (accessibility-index-64)",
          "/MediaBox [ 0 0 118 86 ]", "/MediaBox [ 0 0 142 104 ]", "/MediaBox [ 0 0 128 96 ]",
          "/PageLabels", "(access-overview)", "(access-terms)", "(access-notes)",
          "/Outlines", "/Title (accessibility overview)", "/Title (term index)",
          "/Title (accessibility notes)", "/Annots [", "/Subtype /Link", "/S /URI",
          "/URI (https://example.com/accessibility/index)", "/Dest", "/Dests", "(access-terms)",
          "(access-notes)", "/StructTreeRoot", "/S /Document", "/S /Part", "/S /Sect",
          "/S /H1", "/S /L", "/S /LI", "/S /Lbl", "/S /LBody", "/S /Index", "/S /Reference",
          "/S /Note", "/S /Figure", "/S /Caption", "%%EOF",
        ])
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Accessibility Index",
          "%%IncludeFeature: *MediaType AccessibilityIndex", "%%IncludeFeature: *PageSize AccessibilityIndex",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"118px\" height=\"86px\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend accessibility index output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Part", "/S /Sect", "/S /H1", "/S /L", "/S /LI", "/S /Lbl", "/S /LBody",
    "/S /Index", "/S /Reference", "/S /Note", "/S /Figure", "/S /Caption", "https://example.com/accessibility/index",
    "access-terms", "access-notes", "accessibility-index-64", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_accessibility_index_absent_\{kind}.\{ext}"
    let surface = make_stream_accessibility_index_file_surface(kind, path)
    render_stream_accessibility_index_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_accessibility_index_stream_surface(
      kind, chunks,
    )
    render_stream_accessibility_index_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
