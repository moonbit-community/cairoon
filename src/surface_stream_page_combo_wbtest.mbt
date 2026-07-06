///|
fn make_stream_page_combo_file_surface(
  kind : Int,
  path : String,
) -> Surface raise CairoError {
  let surface = match kind {
    0 => Surface::pdf(100.0, 100.0, path=Some(path))
    1 => Surface::ps(100.0, 100.0, path=Some(path))
    2 => Surface::svg(100.0, 100.0, path=Some(path))
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
  configure_stream_page_combo_backend(kind, surface)
  surface
}

///|
fn make_stream_page_combo_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> Surface raise CairoError {
  let surface = match kind {
    0 =>
      Surface::pdf_stream(100.0, 100.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      Surface::ps_stream(100.0, 100.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      Surface::svg_stream(100.0, 100.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
  configure_stream_page_combo_backend(kind, surface)
  surface
}

///|
fn configure_stream_page_combo_backend(
  kind : Int,
  surface : Surface,
) -> Unit raise CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Surface Page Combo")
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon surface page combo")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      surface.pdf_set_custom_metadata("Combo", Some("surface-page-tags"))
      surface.pdf_set_page_label("page-copy-cover")
      let _ = surface.pdf_add_outline_with_flags(
        PDF_OUTLINE_ROOT,
        "page copy cover",
        "page=1 pos=[10 20]",
        PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
      )
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Surface Page Combo")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaColor White")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize Legal")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPx)
    }
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn render_stream_page_combo_scene(
  kind : Int,
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)

  ctx.set_source_rgb(0.9, 0.93, 1.0)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/page-combo'")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("surface page combo")
  ctx.tag_end(TAG_LINK)
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_page_label("page-copy-retained")
    let _ = surface.pdf_add_outline_with_flags(
      PDF_OUTLINE_ROOT,
      "page copy retained",
      "page=2 pos=[10 44]",
      PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  }
  ctx.set_source_rgba(0.85, 0.1, 0.1, 0.72)
  ctx.tag_begin(TAG_LINK, "dest='page-combo-dest'")
  ctx.rectangle(10.0, 36.0, 44.0, 20.0)
  ctx.fill()
  ctx.tag_end(TAG_LINK)
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_page_label("page-copy-final")
    let _ = surface.pdf_add_outline_with_flags(
      PDF_OUTLINE_ROOT,
      "page copy final",
      "page=3 pos=[10 62]",
      PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineItalic]),
    )
  }
  ctx.set_source_rgb(0.1, 0.1, 0.1)
  ctx.tag_begin(TAG_DEST, "name='page-combo-dest' x=10 y=62")
  ctx.move_to(10.0, 62.0)
  ctx.show_text("destination")
  ctx.tag_end(TAG_DEST)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  let run = ctx.get_scaled_font().text_to_glyphs(10.0, 82.0, "page doc")
  ctx.show_text_glyphs("page doc", run.glyphs, run.clusters, flags=run.flags)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend surface page combo stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_combo_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_page_combo_file_surface(kind, path)
    render_stream_page_combo_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_page_combo_stream_surface(kind, chunks)
    render_stream_page_combo_scene(kind, stream_surface)
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
test "backend surface page combo file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_combo_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_page_combo_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_page_combo_file_surface(kind, path)
    render_stream_page_combo_scene(kind, surface)
    check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        36,
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
test "backend surface page combo output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_combo_markers_\{kind}.\{ext}"
    let surface = make_stream_page_combo_file_surface(kind, path)
    render_stream_page_combo_scene(kind, surface)
    match kind {
      0 =>
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Surface Page Combo)", "/Creator (cairoon surface page combo)",
          "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
          "/Combo (surface-page-tags)", "/Count 3", "/PageLabels", "(page-copy-cover)",
          "(page-copy-retained)", "(page-copy-final)", "/Outlines", "/Title (page copy cover)",
          "/Title (page copy retained)", "/Title (page copy final)", "/F 2", "/F 1",
          "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/page-combo)",
          "/Dest", "/Names", "/Dests", "(page-combo-dest)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /P", "/S /Span", "%%EOF",
        ])
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Surface Page Combo",
          "%%IncludeFeature: *MediaColor White", "%%IncludeFeature: *PageSize Legal",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_vector_output(path, [
          "<?xml version=\"1.0\"", "<svg", "width=\"100px\" height=\"100px\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend surface page combo output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "/S /Span", "https://example.com/page-combo", "page-combo-dest",
    "surface-page-tags", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_combo_tag_absent_\{kind}.\{ext}"
    let surface = make_stream_page_combo_file_surface(kind, path)
    render_stream_page_combo_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_page_combo_stream_surface(kind, chunks)
    render_stream_page_combo_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
