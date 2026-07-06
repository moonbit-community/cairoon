///|
fn make_stream_tag_matrix_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(144.0, 108.0, path=Some(path))
    1 => @cairoon.Surface::ps(144.0, 108.0, path=Some(path))
    2 => @cairoon.Surface::svg(144.0, 108.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_tag_matrix_backend(kind, surface)
  surface
}

///|
fn make_stream_tag_matrix_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(144.0, 108.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(144.0, 108.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(144.0, 108.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_tag_matrix_backend(kind, surface)
  surface
}

///|
fn configure_stream_tag_matrix_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(@cairoon.PdfMetadataTitle, "Cairoon Tag Matrix")
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataAuthor,
        "cairoon matrix author",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataSubject,
        "nested tags with resized pages",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataKeywords,
        "matrix,nested,sequence",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon tag matrix",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreateDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataModDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_custom_metadata("Matrix", Some("nested-resized-tags"))
      surface.pdf_set_custom_metadata("Phase", Some("draft"))
      surface.pdf_set_custom_metadata("Phase", Some("published"))
      surface.pdf_set_custom_metadata("Scratch", Some("remove-me"))
      surface.pdf_set_custom_metadata("Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Tag Matrix")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType MatrixPlain")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize Matrix")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPt)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn resize_stream_tag_matrix_surface(
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
fn render_stream_tag_matrix_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(144.0, 108.0)
    surface.pdf_set_page_label("matrix-cover")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "matrix cover",
      "page=1 pos=[14 24]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  ctx.set_source_rgb(0.90, 0.94, 1.0)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/tag-matrix'")
  ctx.move_to(14.0, 24.0)
  ctx.show_text("matrix cover")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("H1")
  ctx.tag_begin("Figure", "")
  ctx.set_source_rgb(0.12, 0.42, 0.74)
  ctx.rectangle(14.0, 40.0, 54.0, 24.0)
  ctx.fill()
  ctx.tag_end("Figure")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(108.0, 144.0)
    surface.pdf_set_page_label("matrix-retained")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "matrix retained child",
      "page=2 pos=[14 58]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
  } else {
    resize_stream_tag_matrix_surface(kind, surface, 108.0, 144.0)
  }
  ctx.set_source_rgba(0.86, 0.12, 0.16, 0.62)
  ctx.rectangle(14.0, 52.0, 70.0, 28.0)
  ctx.fill()
  ctx.set_source_rgb(0.05, 0.05, 0.05)
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='matrix-dest'")
  ctx.move_to(14.0, 92.0)
  ctx.show_text("retained matrix link")
  ctx.tag_end(@cairoon.TAG_LINK)
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(144.0, 108.0)
    surface.pdf_set_page_label("matrix-nested")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "matrix nested child",
      "page=3 pos=[16 32]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineItalic,
      ]),
    )
  } else {
    resize_stream_tag_matrix_surface(kind, surface, 144.0, 108.0)
  }
  ctx.set_source_rgb(0.94, 0.92, 0.86)
  ctx.paint()
  ctx.set_source_rgb(0.10, 0.45, 0.20)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='matrix-dest' x=16 y=32")
  ctx.arc(28.0, 32.0, 14.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("L", "")
  ctx.tag_begin("LI", "")
  ctx.tag_begin("LBody", "")
  ctx.tag_begin("Span", "")
  let run = ctx.get_scaled_font().text_to_glyphs(16.0, 72.0, "matrix glyph")
  ctx.show_text_glyphs(
    "matrix glyph",
    run.glyphs,
    run.clusters,
    flags=run.flags,
  )
  ctx.tag_end("Span")
  ctx.tag_end("LBody")
  ctx.tag_end("LI")
  ctx.tag_end("L")
  ctx.tag_end("Sect")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(90.0, 132.0)
    surface.pdf_set_page_label("matrix-final")
    let _ = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "matrix final",
      "page=4 pos=[10 40]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineBold),
    )
  } else {
    resize_stream_tag_matrix_surface(kind, surface, 90.0, 132.0)
  }
  ctx.set_source_rgba(0.15, 0.22, 0.80, 0.55)
  ctx.rectangle(10.0, 86.0, 62.0, 24.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Div", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/tag-matrix/final'")
  ctx.move_to(10.0, 40.0)
  ctx.show_text("matrix final")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("P")
  ctx.tag_end("Div")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend tag matrix stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tag_matrix_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_tag_matrix_file_surface(kind, path)
    render_stream_tag_matrix_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_tag_matrix_stream_surface(kind, chunks)
    render_stream_tag_matrix_scene(kind, stream_surface)
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
test "backend tag matrix file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tag_matrix_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_tag_matrix_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_tag_matrix_file_surface(kind, path)
    render_stream_tag_matrix_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        39,
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
test "backend tag matrix output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tag_matrix_markers_\{kind}.\{ext}"
    let surface = make_stream_tag_matrix_file_surface(kind, path)
    render_stream_tag_matrix_scene(kind, surface)
    match kind {
      0 => {
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Tag Matrix)", "/Author (cairoon matrix author)",
          "/Subject (nested tags with resized pages)", "/Keywords (matrix,nested,sequence)",
          "/Creator (cairoon tag matrix)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/Matrix (nested-resized-tags)", "/Phase (published)",
          "/Count 4", "/MediaBox [ 0 0 144 108 ]", "/MediaBox [ 0 0 108 144 ]", "/MediaBox [ 0 0 90 132 ]",
          "/PageLabels", "(matrix-cover)", "(matrix-retained)", "(matrix-nested)",
          "(matrix-final)", "/Outlines", "/Title (matrix cover)", "/Title (matrix retained child)",
          "/Title (matrix nested child)", "/Title (matrix final)", "/F 2", "/F 1",
          "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/tag-matrix)",
          "/URI (https://example.com/tag-matrix/final)", "/Dest", "/Dests", "(matrix-dest)",
          "/StructTreeRoot", "/S /Document", "/S /Sect", "/S /H1", "/S /Figure",
          "/S /L", "/S /LI", "/S /LBody", "/S /Span", "/S /Div", "/S /P", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/Phase (draft)", "remove-me"])
      }
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%Title: Cairoon Tag Matrix", "%%IncludeFeature: *MediaType MatrixPlain",
          "%%IncludeFeature: *PageSize Matrix", "%%Pages: 4", "%%Page: 1 1", "%%Page: 2 2",
          "%%Page: 3 3", "%%Page: 4 4", "%%EOF",
        ])
      2 =>
        expect_vector_output(path, [
          "<?xml version=\"1.0\"", "<svg", "width=\"144pt\" height=\"108pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend tag matrix output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /H1", "/S /Figure", "/S /L", "/S /LI", "/S /LBody", "/S /Span",
    "/S /Div", "/S /P", "https://example.com/tag-matrix", "matrix-dest", "nested-resized-tags",
    "remove-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tag_matrix_absent_\{kind}.\{ext}"
    let surface = make_stream_tag_matrix_file_surface(kind, path)
    render_stream_tag_matrix_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_tag_matrix_stream_surface(kind, chunks)
    render_stream_tag_matrix_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
