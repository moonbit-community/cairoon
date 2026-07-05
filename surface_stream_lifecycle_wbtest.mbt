///|
fn make_stream_lifecycle_file_surface(
  kind : Int,
  path : String,
) -> Surface raise CairoError {
  let surface = match kind {
    0 => Surface::pdf(150.0, 110.0, path=Some(path))
    1 => Surface::ps(150.0, 110.0, path=Some(path))
    2 => Surface::svg(150.0, 110.0, path=Some(path))
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
  configure_stream_lifecycle_backend(kind, surface)
  surface
}

///|
fn make_stream_lifecycle_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> Surface raise CairoError {
  let surface = match kind {
    0 =>
      Surface::pdf_stream(150.0, 110.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      Surface::ps_stream(150.0, 110.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      Surface::svg_stream(150.0, 110.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
  configure_stream_lifecycle_backend(kind, surface)
  surface
}

///|
fn configure_stream_lifecycle_backend(
  kind : Int,
  surface : Surface,
) -> Unit raise CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Lifecycle Matrix")
      surface.pdf_set_metadata(PdfMetadataAuthor, "cairoon lifecycle author")
      surface.pdf_set_metadata(PdfMetadataSubject, "page lifecycle matrix")
      surface.pdf_set_metadata(PdfMetadataKeywords, "lifecycle,copy,show,tags")
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon lifecycle matrix")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      surface.pdf_set_custom_metadata("Lifecycle", Some("copy-copy-show-show"))
      surface.pdf_set_custom_metadata("Stage", Some("warmup"))
      surface.pdf_set_custom_metadata("Stage", Some("settled"))
      surface.pdf_set_custom_metadata("Scratch", Some("drop-me"))
      surface.pdf_set_custom_metadata("Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel2)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Lifecycle Matrix")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaColor Ivory")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize Lifecycle")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitMm)
    }
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn resize_stream_lifecycle_surface(
  kind : Int,
  surface : Surface,
  width : Double,
  height : Double,
) -> Unit raise CairoError {
  match kind {
    0 => surface.pdf_set_size(width, height)
    1 => surface.ps_set_size(width, height)
    _ => ()
  }
}

///|
fn render_stream_lifecycle_scene(
  kind : Int,
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(11.0)

  let mut root_id = PDF_OUTLINE_ROOT
  let mut retained_id = PDF_OUTLINE_ROOT
  let mut fresh_id = PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(150.0, 110.0)
    surface.pdf_set_page_label("life-cover")
    root_id = surface.pdf_add_outline_with_flags(
      PDF_OUTLINE_ROOT,
      "life cover",
      "page=1 pos=[16 24]",
      PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  }
  ctx.set_source_rgb(0.91, 0.96, 0.98)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/lifecycle/cover'")
  ctx.move_to(16.0, 24.0)
  ctx.show_text("lifecycle cover")
  ctx.tag_end(TAG_LINK)
  ctx.tag_end("H1")
  ctx.tag_begin("Figure", "")
  ctx.set_source_rgb(0.12, 0.40, 0.72)
  ctx.rectangle(16.0, 42.0, 58.0, 26.0)
  ctx.fill()
  ctx.tag_end("Figure")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(150.0, 110.0)
    surface.pdf_set_page_label("life-retained-copy")
    retained_id = surface.pdf_add_outline_with_flags(
      root_id,
      "life retained copy",
      "page=2 pos=[18 76]",
      PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  } else {
    resize_stream_lifecycle_surface(kind, surface, 150.0, 110.0)
  }
  ctx.set_source_rgba(0.86, 0.16, 0.18, 0.58)
  ctx.rectangle(18.0, 58.0, 74.0, 24.0)
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.tag_begin(TAG_LINK, "dest='life-dest-a'")
  ctx.move_to(18.0, 88.0)
  ctx.show_text("retained copy link")
  ctx.tag_end(TAG_LINK)
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(96.0, 150.0)
    surface.pdf_set_page_label("life-retained-second")
    let _ = surface.pdf_add_outline_with_flags(
      retained_id,
      "life retained second",
      "page=3 pos=[18 82]",
      PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineItalic]),
    )
  } else {
    resize_stream_lifecycle_surface(kind, surface, 96.0, 150.0)
  }
  ctx.set_source_rgba(0.12, 0.22, 0.76, 0.50)
  ctx.rectangle(20.0, 100.0, 52.0, 20.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(TAG_DEST, "name='life-dest-a' x=18 y=82")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Art", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  ctx.move_to(18.0, 82.0)
  ctx.show_text("retained destination")
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Art")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(TAG_DEST)
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(120.0, 120.0)
    surface.pdf_set_page_label("life-fresh")
    fresh_id = surface.pdf_add_outline_with_flags(
      PDF_OUTLINE_ROOT,
      "life fresh root",
      "page=4 pos=[12 38]",
      PDFOutlineFlagSet::of(PdfOutlineBold),
    )
  } else {
    resize_stream_lifecycle_surface(kind, surface, 120.0, 120.0)
  }
  ctx.set_source_rgb(0.96, 0.93, 0.86)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("L", "")
  ctx.tag_begin("LI", "")
  ctx.tag_begin("Lbl", "")
  ctx.move_to(12.0, 34.0)
  ctx.show_text("1.")
  ctx.tag_end("Lbl")
  ctx.tag_begin("LBody", "")
  ctx.tag_begin("Span", "")
  let run = ctx.get_scaled_font().text_to_glyphs(26.0, 34.0, "fresh glyph run")
  ctx.show_text_glyphs(
    "fresh glyph run",
    run.glyphs,
    run.clusters,
    flags=run.flags,
  )
  ctx.tag_end("Span")
  ctx.tag_end("LBody")
  ctx.tag_end("LI")
  ctx.tag_end("L")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(80.0, 140.0)
    surface.pdf_set_page_label("life-final")
    let _ = surface.pdf_add_outline_with_flags(
      fresh_id,
      "life final child",
      "page=5 pos=[10 44]",
      PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  } else {
    resize_stream_lifecycle_surface(kind, surface, 80.0, 140.0)
  }
  ctx.set_source_rgba(0.12, 0.54, 0.32, 0.70)
  ctx.rectangle(10.0, 94.0, 54.0, 22.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Table", "")
  ctx.tag_begin("TR", "")
  ctx.tag_begin("TD", "")
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/lifecycle/final'")
  ctx.move_to(10.0, 44.0)
  ctx.show_text("final table cell")
  ctx.tag_end(TAG_LINK)
  ctx.tag_begin(TAG_DEST, "name='life-dest-final' x=10 y=66")
  ctx.move_to(10.0, 66.0)
  ctx.show_text("final destination")
  ctx.tag_end(TAG_DEST)
  ctx.tag_end("TD")
  ctx.tag_end("TR")
  ctx.tag_end("Table")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend lifecycle matrix stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_lifecycle_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_lifecycle_file_surface(kind, path)
    render_stream_lifecycle_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_lifecycle_stream_surface(kind, chunks)
    render_stream_lifecycle_scene(kind, stream_surface)
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
test "backend lifecycle matrix file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_lifecycle_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_lifecycle_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_lifecycle_file_surface(kind, path)
    render_stream_lifecycle_scene(kind, surface)
    check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        40,
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
test "backend lifecycle matrix output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_lifecycle_markers_\{kind}.\{ext}"
    let surface = make_stream_lifecycle_file_surface(kind, path)
    render_stream_lifecycle_scene(kind, surface)
    match kind {
      0 => {
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Lifecycle Matrix)", "/Author (cairoon lifecycle author)",
          "/Subject (page lifecycle matrix)", "/Keywords (lifecycle,copy,show,tags)",
          "/Creator (cairoon lifecycle matrix)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/Lifecycle (copy-copy-show-show)",
          "/Stage (settled)", "/Count 5", "/MediaBox [ 0 0 150 110 ]", "/MediaBox [ 0 0 96 150 ]",
          "/MediaBox [ 0 0 120 120 ]", "/MediaBox [ 0 0 80 140 ]", "/PageLabels",
          "(life-cover)", "(life-retained-copy)", "(life-retained-second)", "(life-fresh)",
          "(life-final)", "/Outlines", "/Title (life cover)", "/Title (life retained copy)",
          "/Title (life retained second)", "/Title (life fresh root)", "/Title (life final child)",
          "/F 2", "/F 1", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/lifecycle/cover)",
          "/URI (https://example.com/lifecycle/final)", "/Dest", "/Dests", "(life-dest-a)",
          "(life-dest-final)", "/StructTreeRoot", "/S /Document", "/S /Part", "/S /Sect",
          "/S /H1", "/S /Figure", "/S /Art", "/S /P", "/S /Span", "/S /L", "/S /LI",
          "/S /Lbl", "/S /LBody", "/S /Table", "/S /TR", "/S /TD", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/Stage (warmup)", "drop-me"])
      }
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 2", "%%Title: Cairoon Lifecycle Matrix",
          "%%IncludeFeature: *MediaColor Ivory", "%%IncludeFeature: *PageSize Lifecycle",
          "%%Pages: 5", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%Page: 4 4",
          "%%Page: 5 5", "%%EOF",
        ])
      2 =>
        expect_vector_output(path, [
          "<?xml version=\"1.0\"", "<svg", "width=\"150mm\" height=\"110mm\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend lifecycle matrix output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Part", "/S /Sect", "/S /H1", "/S /Figure", "/S /Art", "/S /P", "/S /Span",
    "/S /L", "/S /LI", "/S /Lbl", "/S /LBody", "/S /Table", "/S /TR", "/S /TD", "https://example.com/lifecycle/cover",
    "https://example.com/lifecycle/final", "life-dest-a", "life-dest-final", "copy-copy-show-show",
    "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_lifecycle_absent_\{kind}.\{ext}"
    let surface = make_stream_lifecycle_file_surface(kind, path)
    render_stream_lifecycle_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_lifecycle_stream_surface(kind, chunks)
    render_stream_lifecycle_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
