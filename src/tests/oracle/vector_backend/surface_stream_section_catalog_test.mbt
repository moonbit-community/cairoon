///|
fn make_stream_section_catalog_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(116.0, 88.0, path=Some(path))
    1 => @cairoon.Surface::ps(116.0, 88.0, path=Some(path))
    2 => @cairoon.Surface::svg(116.0, 88.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_section_catalog_backend(kind, surface)
  surface
}

///|
fn make_stream_section_catalog_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(116.0, 88.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      @cairoon.Surface::ps_stream(116.0, 88.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      @cairoon.Surface::svg_stream(116.0, 88.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_section_catalog_backend(kind, surface)
  surface
}

///|
fn configure_stream_section_catalog_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Section Catalog")
      surface.pdf_set_metadata(PdfMetadataAuthor, "cairoon section catalog")
      surface.pdf_set_metadata(PdfMetadataSubject, "section metadata and tags")
      surface.pdf_set_metadata(
        PdfMetadataKeywords,
        "section,catalog,links,tags",
      )
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon section catalog")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      set_pdf_custom_metadata_if_supported(
        surface,
        "SectionCatalog",
        Some("section-catalog-65"),
      )
      set_pdf_custom_metadata_if_supported(
        surface,
        "TempSection",
        Some("remove-me"),
      )
      set_pdf_custom_metadata_if_supported(surface, "TempSection", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Section Catalog")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType SectionCatalog")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize SectionCatalog")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPx)
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}

///|
fn resize_stream_section_catalog_surface(
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
fn draw_stream_section_catalog_overview(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.18, 0.34, 0.62, 0.86)
  ctx.rectangle(14.0, 30.0, 86.0, 20.0)
  ctx.fill()
  ctx.set_source_rgba(0.90, 0.64, 0.18, 0.72)
  ctx.rectangle(22.0, 58.0, 62.0, 12.0)
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(18.0, 24.0)
  ctx.show_text("section map")
  ctx.move_to(28.0, 67.0)
  ctx.show_text("intro")
}

///|
fn draw_stream_section_catalog_detail(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.22, 0.56, 0.40, 0.84)
  ctx.rectangle(18.0, 34.0, 106.0, 24.0)
  ctx.fill()
  ctx.set_source_rgba(0.62, 0.22, 0.62, 0.62)
  ctx.arc(118.0, 76.0, 10.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(24.0, 50.0)
  ctx.show_text("detail")
  ctx.move_to(30.0, 78.0)
  ctx.show_text("code x+1")
}

///|
fn draw_stream_section_catalog_appendix(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.52, 0.26, 0.66, 0.82)
  ctx.rectangle(16.0, 30.0, 92.0, 26.0)
  ctx.fill()
  ctx.set_source_rgba(0.18, 0.58, 0.76, 0.66)
  ctx.rectangle(32.0, 64.0, 74.0, 12.0)
  ctx.fill()
  ctx.set_source_rgb(0.98, 0.96, 0.88)
  ctx.move_to(24.0, 47.0)
  ctx.show_text("appendix")
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(36.0, 72.0)
  ctx.show_text("figure")
}

///|
fn render_stream_section_catalog_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut detail_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(116.0, 88.0)
    surface.pdf_set_page_label("section-root")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "section catalog",
      "page=1 pos=[18 24]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineOpen),
    )
  }
  ctx.set_source_rgb(0.97, 0.95, 0.88)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("TOC", "")
  ctx.tag_begin("TOCI", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/section/catalog'")
  draw_stream_section_catalog_overview(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("TOCI")
  ctx.tag_begin("Reference", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='section-detail'")
  ctx.move_to(62.0, 78.0)
  ctx.show_text("detail")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Reference")
  ctx.tag_end("TOC")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(140.0, 102.0)
    surface.pdf_set_page_label("section-detail")
    detail_id = surface.pdf_add_outline_with_flags(
      root_id,
      "section detail",
      "page=2 pos=[24 50]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineBold),
    )
  } else {
    resize_stream_section_catalog_surface(kind, surface, 140.0, 102.0)
  }
  ctx.set_source_rgb(0.89, 0.96, 0.92)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_DEST, "name='section-detail' x=24 y=50")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H2", "")
  ctx.tag_begin("Code", "")
  draw_stream_section_catalog_detail(ctx)
  ctx.tag_end("Code")
  ctx.tag_begin("Formula", "")
  ctx.move_to(72.0, 88.0)
  ctx.show_text("y=x+1")
  ctx.tag_end("Formula")
  ctx.tag_begin("Reference", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='section-appendix'")
  ctx.move_to(92.0, 92.0)
  ctx.show_text("appendix")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Reference")
  ctx.tag_end("H2")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(126.0, 94.0)
    surface.pdf_set_page_label("section-appendix")
    let _ = surface.pdf_add_outline_with_flags(
      detail_id,
      "section appendix",
      "page=3 pos=[22 48]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  } else {
    resize_stream_section_catalog_surface(kind, surface, 126.0, 94.0)
  }
  ctx.set_source_rgb(0.94, 0.91, 0.97)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_DEST, "name='section-appendix' x=22 y=48")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Note", "")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin("Caption", "")
  draw_stream_section_catalog_appendix(ctx)
  ctx.tag_end("Caption")
  ctx.tag_end("Figure")
  ctx.tag_begin("BibEntry", "")
  ctx.move_to(28.0, 84.0)
  ctx.show_text("ref")
  ctx.tag_end("BibEntry")
  ctx.tag_end("Note")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.show_page()
  surface.finish()
}

///|
test "backend section catalog stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_section_catalog_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_section_catalog_file_surface(kind, path)
    render_stream_section_catalog_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_section_catalog_stream_surface(
      kind, chunks,
    )
    render_stream_section_catalog_scene(kind, stream_surface)
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
test "backend section catalog file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_section_catalog_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_section_catalog_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_section_catalog_file_surface(kind, path)
    render_stream_section_catalog_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        65,
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
test "backend section catalog output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_section_catalog_markers_\{kind}.\{ext}"
    let surface = make_stream_section_catalog_file_surface(kind, path)
    render_stream_section_catalog_scene(kind, surface)
    match kind {
      0 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Section Catalog)", "/Author (cairoon section catalog)",
          "/Subject (section metadata and tags)", "/Keywords (section,catalog,links,tags)",
          "/Creator (cairoon section catalog)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/SectionCatalog (section-catalog-65)",
          "/MediaBox [ 0 0 116 88 ]", "/MediaBox [ 0 0 140 102 ]", "/MediaBox [ 0 0 126 94 ]",
          "/PageLabels", "(section-root)", "(section-detail)", "(section-appendix)",
          "/Outlines", "/Title (section catalog)", "/Title (section detail)", "/Title (section appendix)",
          "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/section/catalog)",
          "/Dest", "/Dests", "(section-detail)", "(section-appendix)", "/StructTreeRoot",
          "/S /Document", "/S /Part", "/S /Sect", "/S /TOC", "/S /TOCI", "/S /Reference",
          "/S /H2", "/S /Code", "/S /Formula", "/S /Note", "/S /Figure", "/S /Caption",
          "/S /BibEntry", "%%EOF",
        ])
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Section Catalog",
          "%%IncludeFeature: *MediaType SectionCatalog", "%%IncludeFeature: *PageSize SectionCatalog",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"116px\" height=\"88px\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend section catalog output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Part", "/S /Sect", "/S /TOC", "/S /TOCI", "/S /Reference", "/S /H2", "/S /Code",
    "/S /Formula", "/S /Note", "/S /Figure", "/S /Caption", "/S /BibEntry", "https://example.com/section/catalog",
    "section-detail", "section-appendix", "section-catalog-65", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_section_catalog_absent_\{kind}.\{ext}"
    let surface = make_stream_section_catalog_file_surface(kind, path)
    render_stream_section_catalog_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_section_catalog_stream_surface(
      kind, chunks,
    )
    render_stream_section_catalog_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
