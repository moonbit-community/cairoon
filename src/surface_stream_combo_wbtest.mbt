///|
fn make_stream_combo_file_surface(
  kind : Int,
  path : String,
) -> Surface raise CairoError {
  let surface = match kind {
    0 => Surface::pdf(100.0, 100.0, path=Some(path))
    1 => Surface::ps(100.0, 100.0, path=Some(path))
    2 => Surface::svg(100.0, 100.0, path=Some(path))
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
  configure_stream_combo_backend(kind, surface)
  surface
}

///|
fn make_stream_combo_stream_surface(
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
  configure_stream_combo_backend(kind, surface)
  surface
}

///|
fn configure_stream_combo_backend(
  kind : Int,
  surface : Surface,
) -> Unit raise CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Stream Combo")
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon stream combo")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      surface.pdf_set_custom_metadata("Combo", Some("tag-metadata-multipage"))
      surface.pdf_set_page_label("combo-cover")
      let _ = surface.pdf_add_outline_with_flags(
        PDF_OUTLINE_ROOT,
        "combo cover",
        "page=1 pos=[12 18]",
        PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
      )
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Stream Combo")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaColor White")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize Letter")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPx)
    }
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn render_stream_combo_scene(
  kind : Int,
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)

  ctx.set_source_rgb(0.92, 0.95, 1.0)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/combo'")
  ctx.move_to(12.0, 18.0)
  ctx.show_text("combo link")
  ctx.tag_end(TAG_LINK)
  ctx.show_page()

  if kind == 0 {
    surface.pdf_set_page_label("combo-dest")
    let _ = surface.pdf_add_outline_with_flags(
      PDF_OUTLINE_ROOT,
      "combo dest",
      "page=2 pos=[12 30]",
      PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  }
  apply_vector_surface_pattern(ctx)
  ctx.set_source_rgb(0.1, 0.2, 0.8)
  ctx.tag_begin(TAG_LINK, "dest='combo-destination'")
  ctx.rectangle(12.0, 18.0, 32.0, 18.0)
  ctx.fill()
  ctx.tag_end(TAG_LINK)
  ctx.set_source_rgb(0.8, 0.1, 0.1)
  ctx.tag_begin(TAG_DEST, "name='combo-destination' x=62 y=62")
  ctx.arc(62.0, 62.0, 8.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.tag_end(TAG_DEST)
  ctx.show_page()

  if kind == 0 {
    surface.pdf_set_page_label("combo-structure")
    let _ = surface.pdf_add_outline_with_flags(
      PDF_OUTLINE_ROOT,
      "combo structure",
      "page=3 pos=[12 42]",
      PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineItalic]),
    )
  }
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.move_to(12.0, 24.0)
  ctx.show_text("combo heading")
  ctx.tag_end("H1")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  let run = ctx.get_scaled_font().text_to_glyphs(12.0, 42.0, "glyph doc")
  ctx.show_text_glyphs("glyph doc", run.glyphs, run.clusters, flags=run.flags)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()
  surface.finish()
}

///|
test "backend feature tag multipage stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_combo_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_combo_file_surface(kind, path)
    render_stream_combo_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_combo_stream_surface(kind, chunks)
    render_stream_combo_scene(kind, stream_surface)
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
test "backend feature tag multipage file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_combo_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_combo_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_combo_file_surface(kind, path)
    render_stream_combo_scene(kind, surface)
    check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        35,
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
test "backend feature tag multipage output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_combo_markers_\{kind}.\{ext}"
    let surface = make_stream_combo_file_surface(kind, path)
    render_stream_combo_scene(kind, surface)
    match kind {
      0 =>
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Stream Combo)", "/Creator (cairoon stream combo)",
          "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
          "/Combo (tag-metadata-multipage)", "/Count 3", "/PageLabels", "(combo-cover)",
          "(combo-dest)", "(combo-structure)", "/Outlines", "/Title (combo cover)",
          "/Title (combo dest)", "/Title (combo structure)", "/F 2", "/F 1", "/Annots [",
          "/Subtype /Link", "/S /URI", "/URI (https://example.com/combo)", "/Dest",
          "/Names", "/Dests", "(combo-destination)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /H1", "/S /P", "/S /Span", "%%EOF",
        ])
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Stream Combo",
          "%%IncludeFeature: *MediaColor White", "%%IncludeFeature: *PageSize Letter",
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
test "ps svg backend feature tag multipage output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /H1", "/S /P", "/S /Span", "https://example.com/combo", "combo-destination",
    "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_combo_tag_absent_\{kind}.\{ext}"
    let surface = make_stream_combo_file_surface(kind, path)
    render_stream_combo_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)
  }
}

///|
test "ps svg backend feature tag multipage stream output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /H1", "/S /P", "/S /Span", "https://example.com/combo", "combo-destination",
    "<a ",
  ]
  for kind in 1..<3 {
    let chunks : Array[Bytes] = []
    let surface = make_stream_combo_stream_surface(kind, chunks)
    render_stream_combo_scene(kind, surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
