///|
fn make_stream_navigation_map_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(132.0, 98.0, path=Some(path))
    1 => @cairoon.Surface::ps(132.0, 98.0, path=Some(path))
    2 => @cairoon.Surface::svg(132.0, 98.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_navigation_map_backend(kind, surface)
  surface
}

///|
fn make_stream_navigation_map_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(132.0, 98.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(132.0, 98.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(132.0, 98.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_navigation_map_backend(kind, surface)
  surface
}

///|
fn configure_stream_navigation_map_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataTitle,
        "Cairoon Navigation Map",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataAuthor,
        "cairoon navigation map",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataSubject,
        "navigation map metadata",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataKeywords,
        "navigation,map,toc",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon navigation map",
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
        "NavigationSet",
        Some("navigation-map-63"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Scratch", Some("drop-me"))
      set_pdf_custom_metadata_if_supported(surface, "Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Navigation Map")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType NavigationMap")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize NavigationMap")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPx)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn resize_stream_navigation_map_surface(
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
fn draw_stream_navigation_map_toc(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.18, 0.36, 0.68, 0.82)
  ctx.rectangle(14.0, 36.0, 92.0, 20.0)
  ctx.fill()
  ctx.set_source_rgba(0.92, 0.76, 0.24, 0.76)
  ctx.rectangle(22.0, 62.0, 72.0, 10.0)
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(18.0, 29.0)
  ctx.show_text("navigation map")
  ctx.move_to(26.0, 70.0)
  ctx.show_text("toc entry")
}

///|
fn draw_stream_navigation_map_detail(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.18, 0.55, 0.42, 0.84)
  ctx.rectangle(18.0, 34.0, 102.0, 26.0)
  ctx.fill()
  ctx.set_source_rgba(0.68, 0.20, 0.52, 0.66)
  ctx.arc(120.0, 76.0, 10.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.set_source_rgb(0.98, 0.96, 0.88)
  ctx.rectangle(26.0, 70.0, 54.0, 14.0)
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(24.0, 51.0)
  ctx.show_text("route detail")
}

///|
fn render_stream_navigation_map_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(132.0, 98.0)
    surface.pdf_set_page_label("navigation-map")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "navigation map",
      "page=1 pos=[16 30]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineItalic,
      ]),
    )
  }
  ctx.set_source_rgb(0.96, 0.94, 0.88)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("TOC", "")
  ctx.tag_begin("TOCI", "")
  ctx.tag_begin("Reference", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/navigation/map'")
  draw_stream_navigation_map_toc(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Reference")
  ctx.tag_end("TOCI")
  ctx.tag_end("TOC")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(148.0, 108.0)
    surface.pdf_set_page_label("navigation-detail")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "navigation detail",
      "page=2 pos=[20 62]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineBold),
    )
  } else {
    resize_stream_navigation_map_surface(kind, surface, 148.0, 108.0)
  }
  ctx.set_source_rgb(0.88, 0.95, 0.96)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_DEST, "name='navigation-detail' x=20 y=62")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Div", "")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin("Caption", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='navigation-detail'")
  draw_stream_navigation_map_detail(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Caption")
  ctx.tag_end("Figure")
  ctx.tag_begin("Code", "")
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(31.0, 80.0)
  ctx.show_text("x+y")
  ctx.tag_end("Code")
  ctx.tag_begin("Formula", "")
  ctx.move_to(86.0, 80.0)
  ctx.show_text("f(x)")
  ctx.tag_end("Formula")
  ctx.tag_end("Div")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.show_page()
  surface.finish()
}

///|
test "backend navigation map stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_navigation_map_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_navigation_map_file_surface(kind, path)
    render_stream_navigation_map_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_navigation_map_stream_surface(kind, chunks)
    render_stream_navigation_map_scene(kind, stream_surface)
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
test "backend navigation map file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_navigation_map_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_navigation_map_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_navigation_map_file_surface(kind, path)
    render_stream_navigation_map_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        63,
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
test "backend navigation map output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_navigation_map_markers_\{kind}.\{ext}"
    let surface = make_stream_navigation_map_file_surface(kind, path)
    render_stream_navigation_map_scene(kind, surface)
    match kind {
      0 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Navigation Map)", "/Author (cairoon navigation map)",
          "/Subject (navigation map metadata)", "/Keywords (navigation,map,toc)",
          "/Creator (cairoon navigation map)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/NavigationSet (navigation-map-63)",
          "/MediaBox [ 0 0 132 98 ]", "/MediaBox [ 0 0 148 108 ]", "/PageLabels",
          "(navigation-map)", "(navigation-detail)", "/Outlines", "/Title (navigation map)",
          "/Title (navigation detail)", "/Annots [", "/Subtype /Link", "/S /URI",
          "/URI (https://example.com/navigation/map)", "/Dest", "/Dests", "(navigation-detail)",
          "/StructTreeRoot", "/S /Document", "/S /Part", "/S /Sect", "/S /TOC", "/S /TOCI",
          "/S /Reference", "/S /Div", "/S /Figure", "/S /Caption", "/S /Code", "/S /Formula",
          "%%EOF",
        ])
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Navigation Map",
          "%%IncludeFeature: *MediaType NavigationMap", "%%IncludeFeature: *PageSize NavigationMap",
          "%%Pages: 2", "%%Page: 1 1", "%%Page: 2 2", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"132px\" height=\"98px\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend navigation map output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Part", "/S /Sect", "/S /TOC", "/S /TOCI", "/S /Reference", "/S /Div", "/S /Code",
    "/S /Formula", "/S /Figure", "/S /Caption", "https://example.com/navigation/map",
    "navigation-detail", "navigation-map-63", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_navigation_map_absent_\{kind}.\{ext}"
    let surface = make_stream_navigation_map_file_surface(kind, path)
    render_stream_navigation_map_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_navigation_map_stream_surface(kind, chunks)
    render_stream_navigation_map_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
