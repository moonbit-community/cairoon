///|
fn make_stream_text_state_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(144.0, 96.0, path=Some(path))
    1 => @cairoon.Surface::ps(144.0, 96.0, path=Some(path))
    2 => @cairoon.Surface::svg(144.0, 96.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_text_state_backend(kind, surface)
  surface
}

///|
fn make_stream_text_state_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(144.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      @cairoon.Surface::ps_stream(144.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      @cairoon.Surface::svg_stream(144.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_text_state_backend(kind, surface)
  surface
}

///|
fn configure_stream_text_state_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Text State Sequence")
      surface.pdf_set_metadata(PdfMetadataAuthor, "cairoon text author")
      surface.pdf_set_metadata(PdfMetadataSubject, "text-state tags metadata")
      surface.pdf_set_metadata(PdfMetadataKeywords, "text,state,tags")
      surface.pdf_set_metadata(
        PdfMetadataCreator,
        "cairoon text-state sequence",
      )
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      set_pdf_custom_metadata_if_supported(
        surface,
        "TextState",
        Some("font-matrix-copy-sequence"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Scratch", Some("drop-me"))
      set_pdf_custom_metadata_if_supported(surface, "Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Text State Sequence")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType Plain")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize Letter")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPx)
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}

///|
fn resize_stream_text_state_surface(
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
fn text_state_font_matrix(
  ctx : @cairoon.Context,
  xx : Double,
  yx : Double,
  xy : Double,
  yy : Double,
) -> Unit raise @cairoon.CairoError {
  ctx.set_font_matrix(@cairoon.Matrix::new(xx~, yx~, xy~, yy~))
}

///|
fn render_stream_text_state_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  text_state_font_matrix(ctx, 5.0, 0.9, -0.45, 6.5)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(144.0, 96.0)
    surface.pdf_set_page_label("text-state-cover")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "text state cover",
      "page=1 pos=[10 28]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  }
  ctx.set_source_rgb(0.91, 0.95, 1.0)
  ctx.paint()
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "uri='https://example.com/text-state-sequence'",
  )
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.move_to(10.0, 28.0)
  ctx.show_text("matrix link")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("H1")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(108.0, 132.0)
    surface.pdf_set_page_label("text-state-overlay")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "text state overlay",
      "page=2 pos=[12 74]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  } else {
    resize_stream_text_state_surface(kind, surface, 108.0, 132.0)
  }
  text_state_font_matrix(ctx, 4.0, -0.55, 0.35, 5.5)
  ctx.set_source_rgba(0.80, 0.18, 0.12, 0.72)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.move_to(12.0, 74.0)
  ctx.show_text("overlay")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(120.0, 90.0)
    surface.pdf_set_page_label("text-state-final")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "text state final",
      "page=3 pos=[10 30]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineItalic]),
    )
  } else {
    resize_stream_text_state_surface(kind, surface, 120.0, 90.0)
  }
  ctx.set_source_rgb(0.96, 0.92, 0.86)
  ctx.paint()
  text_state_font_matrix(ctx, 4.5, 0.45, -0.25, 5.8)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='text-state-dest'")
  ctx.move_to(10.0, 30.0)
  ctx.show_text("jump")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='text-state-dest' x=10 y=58")
  ctx.move_to(10.0, 58.0)
  ctx.text_path("dest")
  ctx.set_source_rgba(0.1, 0.25, 0.8, 0.75)
  ctx.fill()
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend text-state stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_text_state_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_text_state_file_surface(kind, path)
    render_stream_text_state_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_text_state_stream_surface(kind, chunks)
    render_stream_text_state_scene(kind, stream_surface)
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
test "backend text-state file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_text_state_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_text_state_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_text_state_file_surface(kind, path)
    render_stream_text_state_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        44,
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
test "backend text-state output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_text_state_markers_\{kind}.\{ext}"
    let surface = make_stream_text_state_file_surface(kind, path)
    render_stream_text_state_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Text State Sequence)", "/Author (cairoon text author)",
          "/Subject (text-state tags metadata)", "/Keywords (text,state,tags)", "/Creator (cairoon text-state sequence)",
          "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
          "/TextState (font-matrix-copy-sequence)", "/Count 3", "/MediaBox [ 0 0 144 96 ]",
          "/MediaBox [ 0 0 108 132 ]", "/MediaBox [ 0 0 120 90 ]", "/PageLabels",
          "(text-state-cover)", "(text-state-overlay)", "(text-state-final)", "/Outlines",
          "/Title (text state cover)", "/Title (text state overlay)", "/Title (text state final)",
          "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/text-state-sequence)",
          "/Dest", "/Dests", "(text-state-dest)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /H1", "/S /P", "%%EOF",
        ])
        expect_vector_output_absent(path, ["drop-me"])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Text State Sequence",
          "%%IncludeFeature: *MediaType Plain", "%%IncludeFeature: *PageSize Letter",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"144px\" height=\"96px\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend text-state output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /H1", "/S /P", "https://example.com/text-state-sequence", "text-state-dest",
    "font-matrix-copy-sequence", "text-state-cover", "text-state-overlay", "text-state-final",
    "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_text_state_absent_\{kind}.\{ext}"
    let surface = make_stream_text_state_file_surface(kind, path)
    render_stream_text_state_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_text_state_stream_surface(kind, chunks)
    render_stream_text_state_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
