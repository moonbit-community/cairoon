///|
fn make_stream_appendix_rubric_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(128.0, 104.0, path=Some(path))
    1 => @cairoon.Surface::ps(128.0, 104.0, path=Some(path))
    2 => @cairoon.Surface::svg(128.0, 104.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_appendix_rubric_backend(kind, surface)
  surface
}

///|
fn make_stream_appendix_rubric_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(128.0, 104.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      @cairoon.Surface::ps_stream(128.0, 104.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      @cairoon.Surface::svg_stream(128.0, 104.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_appendix_rubric_backend(kind, surface)
  surface
}

///|
fn configure_stream_appendix_rubric_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Appendix Rubric")
      surface.pdf_set_metadata(PdfMetadataAuthor, "cairoon backend oracle")
      surface.pdf_set_metadata(PdfMetadataSubject, "draft appendix rubric")
      surface.pdf_set_metadata(PdfMetadataSubject, "final appendix rubric")
      surface.pdf_set_metadata(
        PdfMetadataKeywords,
        "appendix,rubric,code,formula",
      )
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon appendix rubric")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      set_pdf_custom_metadata_if_supported(surface, "Rubric", Some("draft"))
      set_pdf_custom_metadata_if_supported(surface, "Rubric", Some("final"))
      set_pdf_custom_metadata_if_supported(surface, "Obsolete", Some("drop-me"))
      set_pdf_custom_metadata_if_supported(surface, "Obsolete", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Appendix Rubric")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType AppendixRubric")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize AppendixRubric")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPt)
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}

///|
fn resize_stream_appendix_rubric_surface(
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
fn draw_stream_appendix_index(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.18, 0.26, 0.58, 0.78)
  ctx.rectangle(16.0, 40.0, 92.0, 18.0)
  ctx.fill()
  ctx.set_source_rgb(0.96, 0.96, 0.88)
  ctx.move_to(20.0, 53.0)
  ctx.show_text("index link")
  ctx.set_source_rgba(0.58, 0.22, 0.36, 0.72)
  ctx.arc(104.0, 74.0, 12.0, 0.0, 6.283185307179586)
  ctx.fill()
}

///|
fn draw_stream_appendix_code(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.20, 0.44, 0.34, 0.78)
  ctx.rectangle(18.0, 34.0, 104.0, 26.0)
  ctx.fill()
  ctx.set_source_rgb(0.98, 0.98, 0.88)
  ctx.move_to(22.0, 50.0)
  ctx.show_text("let score = 42")
  ctx.set_source_rgba(0.62, 0.38, 0.16, 0.76)
  ctx.rectangle(26.0, 70.0, 88.0, 18.0)
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(30.0, 83.0)
  ctx.show_text("x+y=z")
}

///|
fn draw_stream_appendix_bibliography(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.42, 0.25, 0.62, 0.74)
  ctx.rectangle(18.0, 32.0, 100.0, 22.0)
  ctx.fill()
  ctx.set_source_rgba(0.18, 0.50, 0.62, 0.72)
  ctx.rectangle(18.0, 64.0, 100.0, 18.0)
  ctx.fill()
  ctx.set_source_rgb(0.98, 0.98, 0.88)
  ctx.move_to(22.0, 47.0)
  ctx.show_text("figure caption")
  ctx.move_to(22.0, 77.0)
  ctx.show_text("bib entry")
}

///|
fn render_stream_appendix_rubric_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut index_id = @cairoon.PDF_OUTLINE_ROOT
  let mut code_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(128.0, 104.0)
    surface.pdf_set_page_label("appendix-index")
    index_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "appendix index",
      "page=1 pos=[16 28]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  }
  ctx.set_source_rgb(0.95, 0.94, 0.88)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Part", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Index", "")
  ctx.tag_begin("Reference", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/appendix-rubric'")
  ctx.move_to(16.0, 28.0)
  ctx.show_text("appendix rubric")
  draw_stream_appendix_index(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Reference")
  ctx.tag_end("Index")
  ctx.tag_end("Sect")
  ctx.tag_end("Part")
  ctx.tag_end("Document")
  ctx.copy_page()

  if kind == 0 {
    surface.pdf_set_size(142.0, 116.0)
    surface.pdf_set_page_label("appendix-code")
    code_id = surface.pdf_add_outline_with_flags(
      index_id,
      "appendix code",
      "page=2 pos=[18 48]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  } else {
    resize_stream_appendix_rubric_surface(kind, surface, 142.0, 116.0)
  }
  ctx.set_source_rgb(0.90, 0.96, 0.92)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='appendix-code' x=18 y=48")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Code", "")
  ctx.move_to(18.0, 28.0)
  ctx.show_text("code sample")
  ctx.tag_end("Code")
  ctx.tag_begin("Formula", "")
  draw_stream_appendix_code(ctx)
  ctx.tag_end("Formula")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(150.0, 96.0)
    surface.pdf_set_page_label("appendix-bibliography")
    let _ = surface.pdf_add_outline_with_flags(
      code_id,
      "appendix bibliography",
      "page=3 pos=[18 40]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineBold),
    )
  } else {
    resize_stream_appendix_rubric_surface(kind, surface, 150.0, 96.0)
  }
  ctx.set_source_rgb(0.94, 0.92, 0.98)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin("Caption", "")
  ctx.move_to(18.0, 24.0)
  ctx.show_text("caption")
  ctx.tag_end("Caption")
  ctx.tag_begin("BlockQuote", "")
  ctx.tag_begin("BibEntry", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='appendix-code'")
  draw_stream_appendix_bibliography(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("BibEntry")
  ctx.tag_end("BlockQuote")
  ctx.tag_end("Figure")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend appendix rubric stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_appendix_rubric_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_appendix_rubric_file_surface(kind, path)
    render_stream_appendix_rubric_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_appendix_rubric_stream_surface(
      kind, chunks,
    )
    render_stream_appendix_rubric_scene(kind, stream_surface)
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
test "backend appendix rubric file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_appendix_rubric_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_appendix_rubric_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_appendix_rubric_file_surface(kind, path)
    render_stream_appendix_rubric_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        58,
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
test "backend appendix rubric output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_appendix_rubric_markers_\{kind}.\{ext}"
    let surface = make_stream_appendix_rubric_file_surface(kind, path)
    render_stream_appendix_rubric_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Appendix Rubric)", "/Author (cairoon backend oracle)",
          "/Subject (final appendix rubric)", "/Keywords (appendix,rubric,code,formula)",
          "/Creator (cairoon appendix rubric)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/Rubric (final)", "/MediaBox [ 0 0 128 104 ]",
          "/MediaBox [ 0 0 142 116 ]", "/MediaBox [ 0 0 150 96 ]", "/PageLabels",
          "(appendix-index)", "(appendix-code)", "(appendix-bibliography)", "/Outlines",
          "/Title (appendix index)", "/Title (appendix code)", "/Title (appendix bibliography)",
          "/Count 1", "/Count -1", "/F 1", "/F 2", "/Annots [", "/Subtype /Link",
          "/S /URI", "/URI (https://example.com/appendix-rubric)", "/Dest", "/Dests",
          "(appendix-code)", "/StructTreeRoot", "/S /Document", "/S /Part", "/S /Sect",
          "/S /Index", "/S /Reference", "/S /Code", "/S /Formula", "/S /Figure",
          "/S /Caption", "/S /BlockQuote", "/S /BibEntry", "%%EOF",
        ])
        expect_vector_output_absent(path, [
          "/Obsolete", "drop-me", "/Rubric (draft)", "/Subject (draft appendix rubric)",
        ])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Appendix Rubric",
          "%%IncludeFeature: *MediaType AppendixRubric", "%%IncludeFeature: *PageSize AppendixRubric",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"128pt\" height=\"104pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend appendix rubric output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Part", "/S /Sect", "/S /Index", "/S /Reference", "/S /Code", "/S /Formula",
    "/S /Figure", "/S /Caption", "/S /BlockQuote", "/S /BibEntry", "https://example.com/appendix-rubric",
    "appendix-code", "final appendix rubric", "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_appendix_rubric_absent_\{kind}.\{ext}"
    let surface = make_stream_appendix_rubric_file_surface(kind, path)
    render_stream_appendix_rubric_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_appendix_rubric_stream_surface(
      kind, chunks,
    )
    render_stream_appendix_rubric_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
