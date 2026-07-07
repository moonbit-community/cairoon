///|
fn make_stream_annotation_sequence_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(128.0, 118.0, path=Some(path))
    1 => @cairoon.Surface::ps(128.0, 118.0, path=Some(path))
    2 => @cairoon.Surface::svg(128.0, 118.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_annotation_sequence_backend(kind, surface)
  surface
}

///|
fn make_stream_annotation_sequence_stream_surface(
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
  configure_stream_annotation_sequence_backend(kind, surface)
  surface
}

///|
fn configure_stream_annotation_sequence_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataTitle,
        "Cairoon Annotation Sequence",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataSubject,
        "list table outline tags",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon annotation sequence",
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
        "AnnotationSequence",
        Some("list-table-outline"),
      )
      surface.pdf_set_custom_metadata("Scratch", Some("drop-me"))
      surface.pdf_set_custom_metadata("Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Annotation Sequence")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType AnnotationSequence")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize AnnotationSequence")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPx)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn resize_stream_annotation_sequence_surface(
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
fn draw_stream_annotation_card(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.17, 0.32, 0.66, 0.86)
  ctx.rectangle(14.0, 34.0, 88.0, 44.0)
  ctx.fill()
  ctx.set_source_rgba(0.96, 0.82, 0.20, 0.70)
  ctx.arc(86.0, 56.0, 18.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.set_source_rgba(0.04, 0.09, 0.18, 0.72)
  ctx.rectangle(22.0, 44.0, 50.0, 10.0)
  ctx.fill()
}

///|
fn draw_stream_annotation_list(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgb(0.12, 0.24, 0.34)
  for i in 0..<3 {
    let y = 34.0 + i.to_double() * 22.0
    ctx.rectangle(18.0, y, 10.0, 10.0)
    ctx.fill()
    ctx.move_to(36.0, y + 9.0)
    ctx.show_text(
      match i {
        0 => "alpha link"
        1 => "beta dest"
        _ => "gamma table"
      },
    )
  }
}

///|
fn draw_stream_annotation_table(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.84, 0.24, 0.18, 0.78)
  ctx.rectangle(18.0, 36.0, 88.0, 12.0)
  ctx.fill()
  ctx.set_source_rgba(0.18, 0.54, 0.28, 0.72)
  ctx.rectangle(18.0, 52.0, 88.0, 16.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.move_to(24.0, 46.0)
  ctx.show_text("tag table")
  ctx.move_to(24.0, 64.0)
  ctx.show_text("final link")
}

///|
fn render_stream_annotation_sequence_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(11.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut list_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(128.0, 118.0)
    surface.pdf_set_page_label("annot-intro")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "annotation intro",
      "page=1 pos=[14 24]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  ctx.set_source_rgb(0.94, 0.96, 0.90)
  ctx.paint()
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.move_to(14.0, 24.0)
  ctx.show_text("annotation intro")
  ctx.tag_end("H1")
  ctx.tag_begin("P", "")
  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "uri='https://example.com/annotation-sequence/intro'",
  )
  draw_stream_annotation_card(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  ctx.show_page()

  if kind == 0 {
    surface.pdf_set_size(118.0, 130.0)
    surface.pdf_set_page_label("annot-list")
    list_id = surface.pdf_add_outline_with_flags(
      root_id,
      "annotation list",
      "page=2 pos=[18 104]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
  } else {
    resize_stream_annotation_sequence_surface(kind, surface, 118.0, 130.0)
  }
  ctx.set_source_rgb(0.90, 0.95, 0.98)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_DEST, "name='annotation-list' x=18 y=104")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("L", "")
  for _ in 0..<3 {
    ctx.tag_begin("LI", "")
    ctx.tag_begin("Lbl", "")
    ctx.tag_end("Lbl")
    ctx.tag_begin("LBody", "")
    ctx.tag_end("LBody")
    ctx.tag_end("LI")
  }
  draw_stream_annotation_list(ctx)
  ctx.tag_end("L")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(124.0, 110.0)
    surface.pdf_set_page_label("annot-table")
    let _ = surface.pdf_add_outline_with_flags(
      list_id,
      "annotation table",
      "page=3 pos=[18 92]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineOpen),
    )
  } else {
    resize_stream_annotation_sequence_surface(kind, surface, 124.0, 110.0)
  }
  ctx.set_source_rgb(0.98, 0.92, 0.88)
  ctx.paint()
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Table", "")
  ctx.tag_begin("TR", "")
  ctx.tag_begin("TH", "")
  ctx.tag_end("TH")
  ctx.tag_end("TR")
  ctx.tag_begin("TR", "")
  ctx.tag_begin("TD", "")
  draw_stream_annotation_table(ctx)
  ctx.tag_end("TD")
  ctx.tag_end("TR")
  ctx.tag_end("Table")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='annotation-list'")
  ctx.move_to(18.0, 92.0)
  ctx.show_text("return to list")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()
  surface.finish()
}

///|
test "backend annotation sequence stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_annotation_sequence_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_annotation_sequence_file_surface(kind, path)
    render_stream_annotation_sequence_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_annotation_sequence_stream_surface(
      kind, chunks,
    )
    render_stream_annotation_sequence_scene(kind, stream_surface)
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
test "backend annotation sequence file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_annotation_sequence_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_annotation_sequence_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_annotation_sequence_file_surface(kind, path)
    render_stream_annotation_sequence_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        52,
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
test "backend annotation sequence output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_annotation_sequence_markers_\{kind}.\{ext}"
    let surface = make_stream_annotation_sequence_file_surface(kind, path)
    render_stream_annotation_sequence_scene(kind, surface)
    match kind {
      0 => {
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Annotation Sequence)", "/Subject (list table outline tags)",
          "/Creator (cairoon annotation sequence)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/AnnotationSequence (list-table-outline)",
          "/Count 3", "/MediaBox [ 0 0 128 118 ]", "/MediaBox [ 0 0 118 130 ]", "/MediaBox [ 0 0 124 110 ]",
          "/PageLabels", "(annot-intro)", "(annot-list)", "(annot-table)", "/Outlines",
          "/Title (annotation intro)", "/Title (annotation list)", "/Title (annotation table)",
          "/F 2", "/F 1", "/F 0", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/annotation-sequence/intro)",
          "/Dest", "/Dests", "(annotation-list)", "/StructTreeRoot", "/S /Document",
          "/S /Part", "/S /Sect", "/S /H1", "/S /P", "/S /L", "/S /LI", "/S /Lbl",
          "/S /LBody", "/S /Table", "/S /TR", "/S /TH", "/S /TD", "/S /Span", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/Scratch", "drop-me"])
      }
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Annotation Sequence",
          "%%IncludeFeature: *MediaType AnnotationSequence", "%%IncludeFeature: *PageSize AnnotationSequence",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_vector_output(path, [
          "<?xml version=\"1.0\"", "<svg", "width=\"128px\" height=\"118px\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend annotation sequence output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Part", "/S /Sect", "/S /H1", "/S /P", "/S /L", "/S /LI", "/S /Lbl", "/S /LBody",
    "/S /Table", "/S /TR", "/S /TH", "/S /TD", "/S /Span", "https://example.com/annotation-sequence/intro",
    "annotation-list", "list-table-outline", "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_annotation_sequence_absent_\{kind}.\{ext}"
    let surface = make_stream_annotation_sequence_file_surface(kind, path)
    render_stream_annotation_sequence_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_annotation_sequence_stream_surface(
      kind, chunks,
    )
    render_stream_annotation_sequence_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
