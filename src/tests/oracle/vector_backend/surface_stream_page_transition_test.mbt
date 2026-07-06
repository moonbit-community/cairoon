///|
fn make_stream_page_transition_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(100.0, 80.0, path=Some(path))
    1 => @cairoon.Surface::ps(100.0, 80.0, path=Some(path))
    2 => @cairoon.Surface::svg(100.0, 80.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_page_transition_backend(kind, surface)
  surface
}

///|
fn make_stream_page_transition_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(100.0, 80.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(100.0, 80.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(100.0, 80.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_page_transition_backend(kind, surface)
  surface
}

///|
fn configure_stream_page_transition_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataTitle,
        "Cairoon Transition Tags",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon page transition",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreateDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataModDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_custom_metadata("Transition", Some("show-copy-show"))
      surface.pdf_set_custom_metadata("Transient", Some("drop-me"))
      surface.pdf_set_custom_metadata("Transient", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Transition Tags")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageRegion Transition")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPt)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn resize_stream_page_transition_surface(
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
fn render_stream_page_transition_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(9.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut copy_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(100.0, 80.0)
    surface.pdf_set_page_label("transition-show")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "transition show page",
      "page=1 pos=[12 24]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  ctx.set_source_rgb(0.94, 0.97, 1.0)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/transition/show'")
  ctx.move_to(12.0, 24.0)
  ctx.show_text("show page link")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(120.0, 80.0)
    surface.pdf_set_page_label("transition-copy-source")
    copy_id = surface.pdf_add_outline_with_flags(
      root_id,
      "transition copy source",
      "page=2 pos=[14 42]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
  } else {
    resize_stream_page_transition_surface(kind, surface, 120.0, 80.0)
  }
  ctx.set_source_rgb(0.98, 0.94, 0.88)
  ctx.paint()
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Figure", "")
  ctx.set_source_rgb(0.10, 0.44, 0.65)
  ctx.rectangle(14.0, 30.0, 52.0, 20.0)
  ctx.fill()
  ctx.tag_end("Figure")
  ctx.tag_begin(@cairoon.TAG_DEST, "name='transition-dest-copy' x=14 y=58")
  ctx.tag_begin("P", "")
  ctx.move_to(14.0, 58.0)
  ctx.show_text("copy source destination")
  ctx.tag_end("P")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(120.0, 80.0)
    surface.pdf_set_page_label("transition-copy-overlay")
    let _ = surface.pdf_add_outline_with_flags(
      copy_id,
      "transition copy overlay",
      "page=3 pos=[18 66]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineOpen),
    )
  } else {
    resize_stream_page_transition_surface(kind, surface, 120.0, 80.0)
  }
  ctx.set_source_rgba(0.72, 0.12, 0.18, 0.62)
  ctx.rectangle(18.0, 50.0, 60.0, 16.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Span", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='transition-dest-copy'")
  ctx.move_to(18.0, 72.0)
  ctx.show_text("copy overlay link")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Span")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend page transition stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_transition_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_page_transition_file_surface(kind, path)
    render_stream_page_transition_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_page_transition_stream_surface(
      kind, chunks,
    )
    render_stream_page_transition_scene(kind, stream_surface)
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
test "backend page transition file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_transition_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_page_transition_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_page_transition_file_surface(kind, path)
    render_stream_page_transition_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        41,
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
test "backend page transition output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_transition_markers_\{kind}.\{ext}"
    let surface = make_stream_page_transition_file_surface(kind, path)
    render_stream_page_transition_scene(kind, surface)
    match kind {
      0 => {
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Transition Tags)", "/Creator (cairoon page transition)",
          "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
          "/Transition (show-copy-show)", "/Count 3", "/MediaBox [ 0 0 100 80 ]",
          "/MediaBox [ 0 0 120 80 ]", "/PageLabels", "(transition-show)", "(transition-copy-source)",
          "(transition-copy-overlay)", "/Outlines", "/Title (transition show page)",
          "/Title (transition copy source)", "/Title (transition copy overlay)",
          "/F 2", "/F 1", "/F 0", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/transition/show)",
          "/Dest", "/Dests", "(transition-dest-copy)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /P", "/S /Figure", "/S /Span", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/Transient", "drop-me"])
      }
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 2", "%%Title: Cairoon Transition Tags",
          "%%IncludeFeature: *PageRegion Transition", "%%Pages: 3", "%%Page: 1 1",
          "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_vector_output(path, [
          "<?xml version=\"1.0\"", "<svg", "width=\"100pt\" height=\"80pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend page transition output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "/S /Figure", "/S /Span", "https://example.com/transition/show",
    "transition-dest-copy", "show-copy-show", "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_transition_absent_\{kind}.\{ext}"
    let surface = make_stream_page_transition_file_surface(kind, path)
    render_stream_page_transition_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_page_transition_stream_surface(
      kind, chunks,
    )
    render_stream_page_transition_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
