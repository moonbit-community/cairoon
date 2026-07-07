///|
fn make_stream_structure_sequence_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(116.0, 90.0, path=Some(path))
    1 => @cairoon.Surface::ps(116.0, 90.0, path=Some(path))
    2 => @cairoon.Surface::svg(116.0, 90.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_structure_sequence_backend(kind, surface)
  surface
}

///|
fn make_stream_structure_sequence_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(116.0, 90.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(116.0, 90.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(116.0, 90.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_structure_sequence_backend(kind, surface)
  surface
}

///|
fn configure_stream_structure_sequence_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataTitle,
        "Cairoon Structure Sequence",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataSubject,
        "retained pages and structure tags",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon structure sequence",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreateDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataModDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_custom_metadata(
        "StructureSeq",
        Some("retained-copy-show"),
      )
      surface.pdf_set_custom_metadata("Scratch", Some("drop-me"))
      surface.pdf_set_custom_metadata("Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Structure Sequence")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType StructureSeq")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize StructureSeq")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPt)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn resize_stream_structure_sequence_surface(
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
fn draw_structure_sequence_cover(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgb(0.90, 0.94, 0.98)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("L", "")
  ctx.tag_begin("LI", "")
  ctx.tag_begin("Lbl", "")
  ctx.move_to(12.0, 24.0)
  ctx.show_text("1")
  ctx.tag_end("Lbl")
  ctx.tag_begin("LBody", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/structure/cover'")
  ctx.move_to(24.0, 24.0)
  ctx.show_text("structure sequence cover")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("LBody")
  ctx.tag_end("LI")
  ctx.tag_end("L")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
}

///|
fn draw_structure_sequence_table(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.08, 0.35, 0.62, 0.65)
  ctx.rectangle(16.0, 34.0, 84.0, 24.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='structure-sequence-dest' x=16 y=72")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Table", "")
  ctx.tag_begin("TR", "")
  ctx.tag_begin("TH", "")
  ctx.move_to(16.0, 72.0)
  ctx.show_text("sequence heading")
  ctx.tag_end("TH")
  ctx.tag_begin("TD", "")
  ctx.tag_begin("P", "")
  ctx.move_to(16.0, 84.0)
  ctx.show_text("sequence retained table")
  ctx.tag_end("P")
  ctx.tag_end("TD")
  ctx.tag_end("TR")
  ctx.tag_end("Table")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
}

///|
fn draw_structure_sequence_figure(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.78, 0.16, 0.20, 0.58)
  ctx.arc(92.0, 48.0, 14.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='structure-sequence-dest'")
  ctx.move_to(18.0, 78.0)
  ctx.show_text("sequence figure link")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Figure")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
}

///|
fn draw_structure_sequence_final(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgb(0.96, 0.92, 0.84)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  ctx.move_to(12.0, 68.0)
  ctx.show_text("structure sequence final")
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
}

///|
fn render_stream_structure_sequence_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(9.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut retained_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_page_label("seq-cover")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "structure sequence cover",
      "page=1 pos=[12 24]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  draw_structure_sequence_cover(ctx)
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(128.0, 96.0)
    surface.pdf_set_page_label("seq-retained")
    retained_id = surface.pdf_add_outline_with_flags(
      root_id,
      "structure sequence retained",
      "page=2 pos=[16 72]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
  } else {
    resize_stream_structure_sequence_surface(kind, surface, 128.0, 96.0)
  }
  draw_structure_sequence_table(ctx)
  ctx.copy_page()

  if kind == 0 {
    surface.pdf_set_size(128.0, 96.0)
    surface.pdf_set_page_label("seq-context-copy")
    let _ = surface.pdf_add_outline_with_flags(
      retained_id,
      "structure sequence context copy",
      "page=3 pos=[18 78]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineBold),
    )
  } else {
    resize_stream_structure_sequence_surface(kind, surface, 128.0, 96.0)
  }
  draw_structure_sequence_figure(ctx)
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(96.0, 108.0)
    surface.pdf_set_page_label("seq-final")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "structure sequence final",
      "page=4 pos=[12 68]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineOpen),
    )
  } else {
    resize_stream_structure_sequence_surface(kind, surface, 96.0, 108.0)
  }
  draw_structure_sequence_final(ctx)
  ctx.show_page()
  surface.finish()
}

///|
test "backend structure sequence stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_structure_sequence_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_structure_sequence_file_surface(kind, path)
    render_stream_structure_sequence_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_structure_sequence_stream_surface(
      kind, chunks,
    )
    render_stream_structure_sequence_scene(kind, stream_surface)
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
test "backend structure sequence file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_structure_sequence_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_structure_sequence_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_structure_sequence_file_surface(kind, path)
    render_stream_structure_sequence_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        49,
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
test "backend structure sequence output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_structure_sequence_markers_\{kind}.\{ext}"
    let surface = make_stream_structure_sequence_file_surface(kind, path)
    render_stream_structure_sequence_scene(kind, surface)
    match kind {
      0 => {
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Structure Sequence)", "/Subject (retained pages and structure tags)",
          "/Creator (cairoon structure sequence)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/StructureSeq (retained-copy-show)",
          "/Count 4", "/PageLabels", "(seq-cover)", "(seq-retained)", "(seq-context-copy)",
          "(seq-final)", "/Outlines", "/Title (structure sequence cover)", "/Title (structure sequence retained)",
          "/Title (structure sequence context copy)", "/Title (structure sequence final)",
          "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/structure/cover)",
          "/Dest", "/Dests", "(structure-sequence-dest)", "/StructTreeRoot", "/S /Document",
          "/S /Part", "/S /Sect", "/S /L", "/S /LI", "/S /Lbl", "/S /LBody", "/S /Table",
          "/S /TR", "/S /TH", "/S /TD", "/S /Figure", "/S /P", "/S /Span", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/Scratch", "drop-me"])
      }
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%LanguageLevel:", "%%Title: Cairoon Structure Sequence",
          "%%IncludeFeature: *MediaType StructureSeq", "%%IncludeFeature: *PageSize StructureSeq",
          "%%Pages: 4", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%Page: 4 4",
          "%%EOF",
        ])
      2 =>
        expect_vector_output(path, [
          "<?xml version=\"1.0\"", "<svg", "width=\"116pt\" height=\"90pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend structure sequence output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Part", "/S /Sect", "/S /L", "/S /LI", "/S /Lbl", "/S /LBody", "/S /Table",
    "/S /TR", "/S /TH", "/S /TD", "/S /Figure", "/S /P", "/S /Span", "https://example.com/structure/cover",
    "structure-sequence-dest", "retained-copy-show", "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_structure_sequence_absent_\{kind}.\{ext}"
    let surface = make_stream_structure_sequence_file_surface(kind, path)
    render_stream_structure_sequence_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_structure_sequence_stream_surface(
      kind, chunks,
    )
    render_stream_structure_sequence_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
