///|
fn make_stream_semantic_index_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(132.0, 120.0, path=Some(path))
    1 => @cairoon.Surface::ps(132.0, 120.0, path=Some(path))
    2 => @cairoon.Surface::svg(132.0, 120.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_semantic_index_backend(kind, surface)
  surface
}

///|
fn make_stream_semantic_index_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(132.0, 120.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      @cairoon.Surface::ps_stream(132.0, 120.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      @cairoon.Surface::svg_stream(132.0, 120.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_semantic_index_backend(kind, surface)
  surface
}

///|
fn configure_stream_semantic_index_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Semantic Index")
      surface.pdf_set_metadata(PdfMetadataSubject, "toc quote caption tags")
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon semantic index")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      set_pdf_custom_metadata_if_supported(
        surface,
        "SemanticIndex",
        Some("toc-caption-note"),
      )
      set_pdf_custom_metadata_if_supported(
        surface,
        "Transient",
        Some("remove-me"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Transient", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Semantic Index")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType SemanticIndex")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize SemanticIndex")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPt)
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}

///|
fn resize_stream_semantic_index_surface(
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
fn draw_stream_semantic_toc(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgb(0.10, 0.22, 0.42)
  for i in 0..<3 {
    let y = 44.0 + i.to_double() * 18.0
    ctx.rectangle(18.0, y - 8.0, 78.0, 11.0)
    ctx.fill()
    ctx.set_source_rgb(0.95, 0.96, 0.86)
    ctx.move_to(22.0, y)
    ctx.show_text(
      match i {
        0 => "quote"
        1 => "figure"
        _ => "note"
      },
    )
    ctx.set_source_rgb(0.10, 0.22, 0.42)
  }
}

///|
fn draw_stream_semantic_quote(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.66, 0.20, 0.25, 0.78)
  ctx.rectangle(18.0, 38.0, 88.0, 26.0)
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(24.0, 54.0)
  ctx.show_text("quoted text")
  ctx.set_source_rgba(0.18, 0.46, 0.64, 0.72)
  ctx.arc(96.0, 86.0, 14.0, 0.0, 6.283185307179586)
  ctx.fill()
}

///|
fn draw_stream_semantic_figure(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.20, 0.55, 0.30, 0.78)
  ctx.rectangle(22.0, 28.0, 74.0, 36.0)
  ctx.fill()
  ctx.set_source_rgba(0.98, 0.74, 0.20, 0.82)
  ctx.move_to(32.0, 56.0)
  ctx.line_to(58.0, 34.0)
  ctx.line_to(86.0, 56.0)
  ctx.close_path()
  ctx.fill()
  ctx.set_source_rgb(0.02, 0.02, 0.02)
  ctx.move_to(24.0, 86.0)
  ctx.show_text("caption link")
}

///|
fn render_stream_semantic_index_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(11.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut quote_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(132.0, 120.0)
    surface.pdf_set_page_label("semantic-toc")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "semantic toc",
      "page=1 pos=[16 26]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  }
  ctx.set_source_rgb(0.96, 0.94, 0.88)
  ctx.paint()
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.move_to(16.0, 26.0)
  ctx.show_text("semantic index")
  ctx.tag_end("H1")
  ctx.tag_begin("TOC", "")
  ctx.tag_begin("TOCI", "")
  ctx.tag_begin("Reference", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='semantic-quote'")
  draw_stream_semantic_toc(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Reference")
  ctx.tag_end("TOCI")
  ctx.tag_end("TOC")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  ctx.show_page()

  if kind == 0 {
    surface.pdf_set_size(126.0, 124.0)
    surface.pdf_set_page_label("semantic-quote")
    quote_id = surface.pdf_add_outline_with_flags(
      root_id,
      "semantic quote",
      "page=2 pos=[18 86]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  } else {
    resize_stream_semantic_index_surface(kind, surface, 126.0, 124.0)
  }
  ctx.set_source_rgb(0.88, 0.94, 0.98)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_DEST, "name='semantic-quote' x=18 y=86")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Art", "")
  ctx.tag_begin("BlockQuote", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  draw_stream_semantic_quote(ctx)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("BlockQuote")
  ctx.tag_begin("NonStruct", "")
  ctx.tag_begin("Note", "")
  ctx.move_to(20.0, 102.0)
  ctx.show_text("aside note")
  ctx.tag_end("Note")
  ctx.tag_end("NonStruct")
  ctx.tag_end("Art")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(134.0, 112.0)
    surface.pdf_set_page_label("semantic-figure")
    let _ = surface.pdf_add_outline_with_flags(
      quote_id,
      "semantic figure",
      "page=3 pos=[22 86]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineOpen),
    )
  } else {
    resize_stream_semantic_index_surface(kind, surface, 134.0, 112.0)
  }
  ctx.set_source_rgb(0.98, 0.92, 0.86)
  ctx.paint()
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin("Caption", "")
  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "uri='https://example.com/semantic-index/figure'",
  )
  draw_stream_semantic_figure(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Caption")
  ctx.tag_end("Figure")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()
  surface.finish()
}

///|
test "backend semantic index stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_semantic_index_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_semantic_index_file_surface(kind, path)
    render_stream_semantic_index_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_semantic_index_stream_surface(kind, chunks)
    render_stream_semantic_index_scene(kind, stream_surface)
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
test "backend semantic index file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_semantic_index_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_semantic_index_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_semantic_index_file_surface(kind, path)
    render_stream_semantic_index_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        53,
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
test "backend semantic index output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_semantic_index_markers_\{kind}.\{ext}"
    let surface = make_stream_semantic_index_file_surface(kind, path)
    render_stream_semantic_index_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Semantic Index)", "/Subject (toc quote caption tags)",
          "/Creator (cairoon semantic index)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/SemanticIndex (toc-caption-note)",
          "/Count 3", "/MediaBox [ 0 0 132 120 ]", "/MediaBox [ 0 0 126 124 ]", "/MediaBox [ 0 0 134 112 ]",
          "/PageLabels", "(semantic-toc)", "(semantic-quote)", "(semantic-figure)",
          "/Outlines", "/Title (semantic toc)", "/Title (semantic quote)", "/Title (semantic figure)",
          "/F 2", "/F 1", "/F 0", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/semantic-index/figure)",
          "/Dest", "/Dests", "(semantic-quote)", "/StructTreeRoot", "/S /Document",
          "/S /Part", "/S /Sect", "/S /H1", "/S /TOC", "/S /TOCI", "/S /Reference",
          "/S /Art", "/S /BlockQuote", "/S /P", "/S /Span", "/S /NonStruct", "/S /Note",
          "/S /Figure", "/S /Caption", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/Transient", "remove-me"])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Semantic Index",
          "%%IncludeFeature: *MediaType SemanticIndex", "%%IncludeFeature: *PageSize SemanticIndex",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"132pt\" height=\"120pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend semantic index output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Part", "/S /Sect", "/S /H1", "/S /TOC", "/S /TOCI", "/S /Reference", "/S /Art",
    "/S /BlockQuote", "/S /P", "/S /Span", "/S /NonStruct", "/S /Note", "/S /Figure",
    "/S /Caption", "https://example.com/semantic-index/figure", "semantic-quote",
    "toc-caption-note", "remove-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_semantic_index_absent_\{kind}.\{ext}"
    let surface = make_stream_semantic_index_file_surface(kind, path)
    render_stream_semantic_index_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_semantic_index_stream_surface(kind, chunks)
    render_stream_semantic_index_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
