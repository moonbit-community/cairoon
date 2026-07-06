///|
fn make_stream_nested_tag_file_surface(
  kind : Int,
  path : String,
) -> Surface raise CairoError {
  let surface = match kind {
    0 => Surface::pdf(120.0, 120.0, path=Some(path))
    1 => Surface::ps(120.0, 120.0, path=Some(path))
    2 => Surface::svg(120.0, 120.0, path=Some(path))
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
  configure_stream_nested_tag_backend(kind, surface)
  surface
}

///|
fn make_stream_nested_tag_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> Surface raise CairoError {
  let surface = match kind {
    0 =>
      Surface::pdf_stream(120.0, 120.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      Surface::ps_stream(120.0, 120.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      Surface::svg_stream(120.0, 120.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
  configure_stream_nested_tag_backend(kind, surface)
  surface
}

///|
fn configure_stream_nested_tag_backend(
  kind : Int,
  surface : Surface,
) -> Unit raise CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Nested Tags")
      surface.pdf_set_metadata(PdfMetadataAuthor, "cairoon nested author")
      surface.pdf_set_metadata(PdfMetadataSubject, "nested tags and pages")
      surface.pdf_set_metadata(PdfMetadataKeywords, "cairoon,nested,tags")
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon nested tags")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      surface.pdf_set_custom_metadata("Trace", Some("nested-page-sequence"))
      surface.pdf_set_custom_metadata("Scenario", Some("deep-structure"))
      surface.pdf_set_custom_metadata("Transient", Some("drop-me"))
      surface.pdf_set_custom_metadata("Transient", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Nested Tags")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType Plain")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize A5")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPt)
    }
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn render_stream_nested_tag_scene(
  kind : Int,
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)

  let mut root_id = PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_page_label("nested-front")
    root_id = surface.pdf_add_outline_with_flags(
      PDF_OUTLINE_ROOT,
      "nested front",
      "page=1 pos=[12 22]",
      PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  }
  ctx.set_source_rgb(0.94, 0.97, 1.0)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/nested-tags'")
  ctx.move_to(12.0, 22.0)
  ctx.show_text("nested uri")
  ctx.tag_end(TAG_LINK)
  ctx.tag_end("H1")
  ctx.tag_begin("Figure", "")
  ctx.set_source_rgb(0.15, 0.45, 0.8)
  ctx.rectangle(12.0, 36.0, 48.0, 20.0)
  ctx.fill()
  ctx.tag_end("Figure")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()

  if kind == 0 {
    surface.pdf_set_page_label("nested-body")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "nested body child",
      "page=2 pos=[12 34]",
      PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  }
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("L", "")
  ctx.tag_begin("LI", "")
  ctx.tag_begin("LBody", "")
  ctx.tag_begin(TAG_LINK, "dest='nested-dest'")
  ctx.move_to(12.0, 34.0)
  ctx.show_text("nested destination link")
  ctx.tag_end(TAG_LINK)
  ctx.tag_end("LBody")
  ctx.tag_end("LI")
  ctx.tag_end("L")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_page_label("nested-retained-overlay")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "nested retained overlay",
      "page=3 pos=[12 58]",
      PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineItalic]),
    )
  }
  ctx.set_source_rgba(0.85, 0.1, 0.1, 0.68)
  ctx.rectangle(12.0, 50.0, 70.0, 22.0)
  ctx.fill()
  ctx.tag_begin(TAG_DEST, "name='nested-dest' x=12 y=58")
  ctx.set_source_rgb(0.05, 0.05, 0.05)
  ctx.move_to(12.0, 58.0)
  ctx.show_text("retained destination")
  ctx.tag_end(TAG_DEST)
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_page_label("nested-final")
    let _ = surface.pdf_add_outline_with_flags(
      PDF_OUTLINE_ROOT,
      "nested final",
      "page=4 pos=[12 82]",
      PDFOutlineFlagSet::of(PdfOutlineBold),
    )
  }
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  let run = ctx.get_scaled_font().text_to_glyphs(12.0, 82.0, "deep glyph")
  ctx.show_text_glyphs("deep glyph", run.glyphs, run.clusters, flags=run.flags)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend nested tag stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_nested_tag_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_nested_tag_file_surface(kind, path)
    render_stream_nested_tag_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_nested_tag_stream_surface(kind, chunks)
    render_stream_nested_tag_scene(kind, stream_surface)
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
test "backend nested tag file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_nested_tag_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_nested_tag_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_nested_tag_file_surface(kind, path)
    render_stream_nested_tag_scene(kind, surface)
    check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        37,
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
test "backend nested tag output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_nested_tag_markers_\{kind}.\{ext}"
    let surface = make_stream_nested_tag_file_surface(kind, path)
    render_stream_nested_tag_scene(kind, surface)
    match kind {
      0 =>
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Nested Tags)", "/Author (cairoon nested author)",
          "/Subject (nested tags and pages)", "/Keywords (cairoon,nested,tags)",
          "/Creator (cairoon nested tags)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/Trace (nested-page-sequence)", "/Scenario (deep-structure)",
          "/Count 4", "/PageLabels", "(nested-front)", "(nested-body)", "(nested-retained-overlay)",
          "(nested-final)", "/Outlines", "/Title (nested front)", "/Title (nested body child)",
          "/Title (nested retained overlay)", "/Title (nested final)", "/F 2", "/F 1",
          "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/nested-tags)",
          "/Dest", "/Dests", "(nested-dest)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /H1", "/S /Figure", "/S /L", "/S /LI", "/S /LBody", "/S /P",
          "/S /Span", "%%EOF",
        ])
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 2", "%%Title: Cairoon Nested Tags",
          "%%IncludeFeature: *MediaType Plain", "%%IncludeFeature: *PageSize A5",
          "%%Pages: 4", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%Page: 4 4",
          "%%EOF",
        ])
      2 =>
        expect_vector_output(path, [
          "<?xml version=\"1.0\"", "<svg", "width=\"120pt\" height=\"120pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend nested tag output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /H1", "/S /Figure", "/S /L", "/S /LI", "/S /LBody", "/S /P",
    "/S /Span", "https://example.com/nested-tags", "nested-dest", "nested-page-sequence",
    "deep-structure", "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_nested_tag_absent_\{kind}.\{ext}"
    let surface = make_stream_nested_tag_file_surface(kind, path)
    render_stream_nested_tag_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_nested_tag_stream_surface(kind, chunks)
    render_stream_nested_tag_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
