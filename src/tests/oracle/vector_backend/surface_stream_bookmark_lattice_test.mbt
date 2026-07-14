///|
fn make_stream_bookmark_lattice_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(128.0, 118.0, path=Some(path))
    1 => @cairoon.Surface::ps(128.0, 118.0, path=Some(path))
    2 => @cairoon.Surface::svg(128.0, 118.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_bookmark_lattice_backend(kind, surface)
  surface
}

///|
fn make_stream_bookmark_lattice_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(128.0, 118.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(128.0, 118.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(128.0, 118.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_bookmark_lattice_backend(kind, surface)
  surface
}

///|
fn configure_stream_bookmark_lattice_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataTitle,
        "Cairoon Bookmark Lattice",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataAuthor,
        "cairoon backend oracle",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon bookmark lattice",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataKeywords,
        "bookmark,lattice,tag,page",
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
        "BookmarkLattice",
        Some("outline-dest-copy"),
      )
      set_pdf_custom_metadata_if_supported(
        surface,
        "Ephemeral",
        Some("remove-me"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Ephemeral", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Bookmark Lattice")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType BookmarkLattice")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize BookmarkLattice")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPt)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn resize_stream_bookmark_lattice_surface(
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
fn draw_stream_bookmark_lattice_index(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgb(0.12, 0.22, 0.38)
  ctx.rectangle(16.0, 38.0, 92.0, 12.0)
  ctx.fill()
  ctx.set_source_rgb(0.88, 0.92, 0.76)
  ctx.move_to(20.0, 47.0)
  ctx.show_text("detail")
  ctx.set_source_rgba(0.68, 0.26, 0.32, 0.82)
  ctx.rectangle(16.0, 60.0, 92.0, 12.0)
  ctx.fill()
  ctx.set_source_rgb(0.96, 0.90, 0.78)
  ctx.move_to(20.0, 69.0)
  ctx.show_text("appendix")
}

///|
fn draw_stream_bookmark_lattice_detail(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.20, 0.46, 0.70, 0.80)
  ctx.arc(36.0, 54.0, 18.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.set_source_rgba(0.82, 0.64, 0.22, 0.78)
  ctx.rectangle(58.0, 38.0, 42.0, 32.0)
  ctx.fill()
  ctx.set_source_rgb(0.02, 0.03, 0.04)
  ctx.move_to(20.0, 91.0)
  ctx.show_text("detail node")
}

///|
fn draw_stream_bookmark_lattice_appendix(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.28, 0.56, 0.34, 0.80)
  ctx.rectangle(20.0, 38.0, 78.0, 22.0)
  ctx.fill()
  ctx.set_source_rgba(0.58, 0.22, 0.66, 0.62)
  ctx.move_to(28.0, 74.0)
  ctx.line_to(64.0, 44.0)
  ctx.line_to(98.0, 74.0)
  ctx.close_path()
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(22.0, 94.0)
  ctx.show_text("appendix link")
}

///|
fn render_stream_bookmark_lattice_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(128.0, 118.0)
    surface.pdf_set_page_label("bookmark-index")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "bookmark index",
      "page=1 pos=[14 28]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  ctx.set_source_rgb(0.96, 0.94, 0.88)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.move_to(14.0, 28.0)
  ctx.show_text("bookmark lattice")
  ctx.tag_end("H1")
  ctx.tag_begin("L", "")
  ctx.tag_begin("LI", "")
  ctx.tag_begin("Lbl", "")
  ctx.show_text("A")
  ctx.tag_end("Lbl")
  ctx.tag_begin("LBody", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='bookmark-detail'")
  draw_stream_bookmark_lattice_index(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("LBody")
  ctx.tag_end("LI")
  ctx.tag_end("L")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(116.0, 132.0)
    surface.pdf_set_page_label("bookmark-detail")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "bookmark detail",
      "page=2 pos=[18 91]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
  } else {
    resize_stream_bookmark_lattice_surface(kind, surface, 116.0, 132.0)
  }
  ctx.set_source_rgb(0.90, 0.95, 0.98)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_DEST, "name='bookmark-detail' x=18 y=91")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  draw_stream_bookmark_lattice_detail(ctx)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(122.0, 126.0)
    surface.pdf_set_page_label("bookmark-appendix")
    let _ = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "bookmark appendix",
      "page=3 pos=[22 94]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineBold),
    )
  } else {
    resize_stream_bookmark_lattice_surface(kind, surface, 122.0, 126.0)
  }
  ctx.set_source_rgb(0.98, 0.93, 0.88)
  ctx.paint()
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/bookmark-lattice'")
  draw_stream_bookmark_lattice_appendix(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Figure")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()
  surface.finish()
}

///|
test "backend bookmark lattice stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_bookmark_lattice_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_bookmark_lattice_file_surface(kind, path)
    render_stream_bookmark_lattice_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_bookmark_lattice_stream_surface(
      kind, chunks,
    )
    render_stream_bookmark_lattice_scene(kind, stream_surface)
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
test "backend bookmark lattice file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_bookmark_lattice_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_bookmark_lattice_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_bookmark_lattice_file_surface(kind, path)
    render_stream_bookmark_lattice_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        54,
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
test "backend bookmark lattice output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_bookmark_lattice_markers_\{kind}.\{ext}"
    let surface = make_stream_bookmark_lattice_file_surface(kind, path)
    render_stream_bookmark_lattice_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Bookmark Lattice)", "/Author (cairoon backend oracle)",
          "/Creator (cairoon bookmark lattice)", "/Keywords (bookmark,lattice,tag,page)",
          "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
          "/BookmarkLattice (outline-dest-copy)", "/Count 3", "/MediaBox [ 0 0 128 118 ]",
          "/MediaBox [ 0 0 116 132 ]", "/MediaBox [ 0 0 122 126 ]", "/PageLabels",
          "(bookmark-index)", "(bookmark-detail)", "(bookmark-appendix)", "/Outlines",
          "/Title (bookmark index)", "/Title (bookmark detail)", "/Title (bookmark appendix)",
          "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/bookmark-lattice)",
          "/Dest", "/Dests", "(bookmark-detail)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /H1", "/S /L", "/S /LI", "/S /Lbl", "/S /LBody", "/S /P",
          "/S /Span", "/S /Figure", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/Ephemeral", "remove-me"])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Bookmark Lattice",
          "%%IncludeFeature: *MediaType BookmarkLattice", "%%IncludeFeature: *PageSize BookmarkLattice",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"128pt\" height=\"118pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend bookmark lattice output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /H1", "/S /L", "/S /LI", "/S /Lbl", "/S /LBody", "/S /P", "/S /Span",
    "/S /Figure", "https://example.com/bookmark-lattice", "bookmark-detail", "outline-dest-copy",
    "remove-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_bookmark_lattice_absent_\{kind}.\{ext}"
    let surface = make_stream_bookmark_lattice_file_surface(kind, path)
    render_stream_bookmark_lattice_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_bookmark_lattice_stream_surface(
      kind, chunks,
    )
    render_stream_bookmark_lattice_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
