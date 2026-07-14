///|
fn make_stream_deep_tag_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(140.0, 130.0, path=Some(path))
    1 => @cairoon.Surface::ps(140.0, 130.0, path=Some(path))
    2 => @cairoon.Surface::svg(140.0, 130.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_deep_tag_backend(kind, surface)
  surface
}

///|
fn make_stream_deep_tag_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(140.0, 130.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(140.0, 130.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(140.0, 130.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_deep_tag_backend(kind, surface)
  surface
}

///|
fn configure_stream_deep_tag_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataTitle,
        "Cairoon Deep Tag Tree",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataAuthor,
        "cairoon deep tag author",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataSubject,
        "deep tag tree metadata",
      )
      surface.pdf_set_metadata(@cairoon.PdfMetadataKeywords, "deep,tags,tree")
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon deep tag tree",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreateDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataModDate,
        fixed_pdf_metadata_date(),
      )
      set_pdf_custom_metadata_if_supported(
        surface,
        "Scenario",
        Some("deep-tag-tree"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Depth", Some("part-table"))
      set_pdf_custom_metadata_if_supported(surface, "Scratch", Some("drop-me"))
      set_pdf_custom_metadata_if_supported(surface, "Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Deep Tag Tree")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType Plain")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize A5")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPt)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn render_stream_deep_tag_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(11.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_page_label("deep-cover")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "deep cover",
      "page=1 pos=[12 24]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  ctx.set_source_rgb(0.91, 0.96, 1.0)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Div", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/deep-tree'")
  ctx.move_to(12.0, 24.0)
  ctx.show_text("deep tree link")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_begin("Figure", "")
  ctx.set_source_rgb(0.18, 0.45, 0.74)
  ctx.rectangle(12.0, 42.0, 72.0, 28.0)
  ctx.fill()
  ctx.tag_end("Figure")
  ctx.tag_end("Div")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_page_label("deep-table")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "deep table",
      "page=2 pos=[12 34]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
  }
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='deep-tree-dest'")
  ctx.move_to(12.0, 34.0)
  ctx.show_text("jump to table")
  ctx.tag_end(@cairoon.TAG_LINK)

  ctx.tag_begin(@cairoon.TAG_DEST, "name='deep-tree-dest' x=12 y=64")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Table", "")
  ctx.tag_begin("TR", "")
  ctx.tag_begin("TH", "")
  ctx.move_to(12.0, 64.0)
  ctx.show_text("deep heading")
  ctx.tag_end("TH")
  ctx.tag_begin("TD", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  ctx.move_to(12.0, 84.0)
  ctx.show_text("deep table dest")
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("TD")
  ctx.tag_end("TR")
  ctx.tag_end("Table")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.show_page()
  surface.finish()
}

///|
test "backend deep tag tree file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_deep_tag_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_deep_tag_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_deep_tag_file_surface(kind, path)
    render_stream_deep_tag_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        45,
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
test "pdf deep tag tree stream output contains stable markers" {
  let chunks : Array[Bytes] = []
  let surface = make_stream_deep_tag_stream_surface(0, chunks)
  render_stream_deep_tag_scene(0, surface)
  expect_stream_output_markers_since(0, chunks, 11600, [
    "%PDF-1.4", "/Title (Cairoon Deep Tag Tree)", "/Author (cairoon deep tag author)",
    "/Subject (deep tag tree metadata)", "/Keywords (deep,tags,tree)", "/Creator (cairoon deep tag tree)",
    "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
    "/Scenario (deep-tag-tree)", "/Depth (part-table)", "/Count 2", "/PageLabels",
    "(deep-cover)", "(deep-table)", "/Outlines", "/Title (deep cover)", "/Title (deep table)",
    "/F 2", "/F 1", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/deep-tree)",
    "/Dest", "/Dests", "(deep-tree-dest)", "/StructTreeRoot", "/S /Document", "/S /Part",
    "/S /Sect", "/S /Div", "/S /P", "/S /Span", "/S /Figure", "/S /Table", "/S /TR",
    "/S /TH", "/S /TD", "%%EOF",
  ])
}

///|
test "ps svg deep tag tree stream output matches file output after normalization" {
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_deep_tag_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_deep_tag_file_surface(kind, path)
    render_stream_deep_tag_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_deep_tag_stream_surface(kind, chunks)
    render_stream_deep_tag_scene(kind, stream_surface)
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
test "backend deep tag tree output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_deep_tag_markers_\{kind}.\{ext}"
    let surface = make_stream_deep_tag_file_surface(kind, path)
    render_stream_deep_tag_scene(kind, surface)
    match kind {
      0 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Deep Tag Tree)", "/Scenario (deep-tag-tree)",
          "/Depth (part-table)", "/Count 2", "(deep-cover)", "(deep-table)", "/Title (deep cover)",
          "/Title (deep table)", "/URI (https://example.com/deep-tree)", "(deep-tree-dest)",
          "/StructTreeRoot", "/S /Document", "/S /Part", "/S /Sect", "/S /Div", "/S /P",
          "/S /Span", "/S /Figure", "/S /Table", "/S /TR", "/S /TH", "/S /TD", "%%EOF",
        ])
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 2", "%%Title: Cairoon Deep Tag Tree",
          "%%IncludeFeature: *MediaType Plain", "%%IncludeFeature: *PageSize A5",
          "%%Pages: 2", "%%Page: 1 1", "%%Page: 2 2", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"140pt\" height=\"130pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg deep tag tree output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Part", "/S /Sect", "/S /Div", "/S /P", "/S /Span", "/S /Figure", "/S /Table",
    "/S /TR", "/S /TH", "/S /TD", "deep-tag-tree", "part-table", "drop-me", "deep-tree-dest",
    "https://example.com/deep-tree", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_deep_tag_absent_\{kind}.\{ext}"
    let surface = make_stream_deep_tag_file_surface(kind, path)
    render_stream_deep_tag_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_deep_tag_stream_surface(kind, chunks)
    render_stream_deep_tag_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
