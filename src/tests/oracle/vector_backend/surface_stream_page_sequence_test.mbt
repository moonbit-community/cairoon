///|
fn make_stream_page_sequence_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(132.0, 96.0, path=Some(path))
    1 => @cairoon.Surface::ps(132.0, 96.0, path=Some(path))
    2 => @cairoon.Surface::svg(132.0, 96.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_page_sequence_backend(kind, surface)
  surface
}

///|
fn make_stream_page_sequence_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(132.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(132.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(132.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_page_sequence_backend(kind, surface)
  surface
}

///|
fn configure_stream_page_sequence_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataTitle,
        "Cairoon Page Sequence",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataAuthor,
        "cairoon sequence author",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataSubject,
        "page sequence metadata",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataKeywords,
        "sequence,pages,metadata",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon page sequence",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreateDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataModDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_custom_metadata("Sequence", Some("copy-show-copy-show"))
      surface.pdf_set_custom_metadata("Phase", Some("initial"))
      surface.pdf_set_custom_metadata("Phase", Some("updated"))
      surface.pdf_set_custom_metadata("Transient", Some("remove-me"))
      surface.pdf_set_custom_metadata("Transient", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Page Sequence")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType Plain")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize Letter")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPx)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn resize_stream_page_sequence_surface(
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
fn render_stream_page_sequence_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(132.0, 96.0)
    surface.pdf_set_page_label("sequence-cover")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "sequence cover",
      "page=1 pos=[12 20]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  ctx.set_source_rgb(0.90, 0.95, 1.0)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/page-sequence'")
  ctx.move_to(12.0, 20.0)
  ctx.show_text("sequence cover")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.set_source_rgb(0.10, 0.35, 0.75)
  ctx.rectangle(12.0, 34.0, 44.0, 22.0)
  ctx.fill()
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(96.0, 132.0)
    surface.pdf_set_page_label("sequence-retained")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "sequence retained overlay",
      "page=2 pos=[12 54]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
  } else {
    resize_stream_page_sequence_surface(kind, surface, 96.0, 132.0)
  }
  ctx.set_source_rgba(0.85, 0.10, 0.12, 0.70)
  ctx.rectangle(12.0, 48.0, 64.0, 24.0)
  ctx.fill()
  ctx.set_source_rgb(0.05, 0.05, 0.05)
  ctx.move_to(12.0, 82.0)
  ctx.show_text("retained overlay")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(132.0, 96.0)
    surface.pdf_set_page_label("sequence-fresh")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "sequence fresh copy",
      "page=3 pos=[12 32]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineItalic,
      ]),
    )
  } else {
    resize_stream_page_sequence_surface(kind, surface, 132.0, 96.0)
  }
  ctx.set_source_rgb(0.96, 0.92, 0.86)
  ctx.paint()
  ctx.set_source_rgb(0.10, 0.45, 0.20)
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='page-sequence-dest'")
  ctx.arc(34.0, 34.0, 14.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.move_to(12.0, 66.0)
  ctx.show_text("fresh copy")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(72.0, 120.0)
    surface.pdf_set_page_label("sequence-final")
    let _ = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "sequence final",
      "page=4 pos=[8 28]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineBold),
    )
  } else {
    resize_stream_page_sequence_surface(kind, surface, 72.0, 120.0)
  }
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='page-sequence-dest' x=8 y=28")
  ctx.move_to(8.0, 28.0)
  ctx.show_text("final destination")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Div", "")
  ctx.tag_begin("P", "")
  ctx.move_to(8.0, 54.0)
  ctx.show_text("final structure")
  ctx.tag_end("P")
  ctx.tag_end("Div")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend page sequence stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_sequence_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_page_sequence_file_surface(kind, path)
    render_stream_page_sequence_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_page_sequence_stream_surface(kind, chunks)
    render_stream_page_sequence_scene(kind, stream_surface)
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
test "backend page sequence file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_sequence_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_page_sequence_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_page_sequence_file_surface(kind, path)
    render_stream_page_sequence_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        38,
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
test "backend page sequence output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_sequence_markers_\{kind}.\{ext}"
    let surface = make_stream_page_sequence_file_surface(kind, path)
    render_stream_page_sequence_scene(kind, surface)
    match kind {
      0 => {
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Page Sequence)", "/Author (cairoon sequence author)",
          "/Subject (page sequence metadata)", "/Keywords (sequence,pages,metadata)",
          "/Creator (cairoon page sequence)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/Sequence (copy-show-copy-show)",
          "/Phase (updated)", "/Count 4", "/MediaBox [ 0 0 132 96 ]", "/MediaBox [ 0 0 96 132 ]",
          "/MediaBox [ 0 0 72 120 ]", "/PageLabels", "(sequence-cover)", "(sequence-retained)",
          "(sequence-fresh)", "(sequence-final)", "/Outlines", "/Title (sequence cover)",
          "/Title (sequence retained overlay)", "/Title (sequence fresh copy)", "/Title (sequence final)",
          "/F 2", "/F 1", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/page-sequence)",
          "/Dest", "/Dests", "(page-sequence-dest)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /Div", "/S /P", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/Phase (initial)", "remove-me"])
      }
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 2", "%%Title: Cairoon Page Sequence",
          "%%IncludeFeature: *MediaType Plain", "%%IncludeFeature: *PageSize Letter",
          "%%Pages: 4", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%Page: 4 4",
          "%%EOF",
        ])
      2 =>
        expect_vector_output(path, [
          "<?xml version=\"1.0\"", "<svg", "width=\"132px\" height=\"96px\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend page sequence output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /Div", "/S /P", "https://example.com/page-sequence", "page-sequence-dest",
    "copy-show-copy-show", "remove-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_sequence_absent_\{kind}.\{ext}"
    let surface = make_stream_page_sequence_file_surface(kind, path)
    render_stream_page_sequence_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_page_sequence_stream_surface(kind, chunks)
    render_stream_page_sequence_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
