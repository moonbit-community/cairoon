///|
fn make_stream_cross_reference_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(126.0, 96.0, path=Some(path))
    1 => @cairoon.Surface::ps(126.0, 96.0, path=Some(path))
    2 => @cairoon.Surface::svg(126.0, 96.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_cross_reference_backend(kind, surface)
  surface
}

///|
fn make_stream_cross_reference_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(126.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      @cairoon.Surface::ps_stream(126.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      @cairoon.Surface::svg_stream(126.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_cross_reference_backend(kind, surface)
  surface
}

///|
fn configure_stream_cross_reference_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Cross Reference")
      surface.pdf_set_metadata(PdfMetadataSubject, "draft cross reference")
      surface.pdf_set_metadata(PdfMetadataSubject, "final cross reference")
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon cross reference")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      set_pdf_custom_metadata_if_supported(surface, "CrossRef", Some("draft"))
      set_pdf_custom_metadata_if_supported(surface, "CrossRef", Some("final"))
      set_pdf_custom_metadata_if_supported(
        surface,
        "StaleCrossRef",
        Some("drop-me"),
      )
      set_pdf_custom_metadata_if_supported(surface, "StaleCrossRef", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Cross Reference")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType CrossReference")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize CrossReference")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPt)
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}

///|
fn resize_stream_cross_reference_surface(
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
fn draw_stream_cross_reference_index(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.16, 0.30, 0.64, 0.80)
  ctx.rectangle(16.0, 38.0, 86.0, 18.0)
  ctx.fill()
  ctx.set_source_rgb(0.98, 0.96, 0.88)
  ctx.move_to(20.0, 51.0)
  ctx.show_text("xref detail")
}

///|
fn draw_stream_cross_reference_detail(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.22, 0.56, 0.34, 0.78)
  ctx.rectangle(18.0, 34.0, 96.0, 28.0)
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(24.0, 50.0)
  ctx.show_text("detail anchor")
  ctx.set_source_rgba(0.86, 0.72, 0.24, 0.84)
  ctx.arc(112.0, 78.0, 11.0, 0.0, 6.283185307179586)
  ctx.fill()
}

///|
fn draw_stream_cross_reference_overlay(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.76, 0.16, 0.22, 0.58)
  ctx.rectangle(26.0, 56.0, 92.0, 18.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.move_to(30.0, 70.0)
  ctx.show_text("overlay link")
}

///|
fn render_stream_cross_reference_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut detail_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(126.0, 96.0)
    surface.pdf_set_page_label("xref-index")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "cross reference index",
      "page=1 pos=[16 28]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  }
  ctx.set_source_rgb(0.94, 0.96, 0.90)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Index", "")
  ctx.tag_begin("Reference", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='xref-detail'")
  ctx.move_to(16.0, 28.0)
  ctx.show_text("index entry")
  draw_stream_cross_reference_index(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Reference")
  ctx.tag_end("Index")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(136.0, 104.0)
    surface.pdf_set_page_label("xref-detail")
    detail_id = surface.pdf_add_outline_with_flags(
      root_id,
      "cross reference detail",
      "page=2 pos=[18 62]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  } else {
    resize_stream_cross_reference_surface(kind, surface, 136.0, 104.0)
  }
  ctx.set_source_rgb(0.90, 0.95, 0.98)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_DEST, "name='xref-detail' x=18 y=62")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Figure", "")
  draw_stream_cross_reference_detail(ctx)
  ctx.tag_begin("Caption", "")
  ctx.move_to(20.0, 88.0)
  ctx.show_text("detail caption")
  ctx.tag_end("Caption")
  ctx.tag_end("Figure")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(136.0, 104.0)
    surface.pdf_set_page_label("xref-overlay")
    let _ = surface.pdf_add_outline_with_flags(
      detail_id,
      "cross reference overlay",
      "page=3 pos=[26 74]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineOpen),
    )
  } else {
    resize_stream_cross_reference_surface(kind, surface, 136.0, 104.0)
  }
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "uri='https://example.com/cross-reference/overlay'",
  )
  draw_stream_cross_reference_overlay(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend cross reference stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_cross_reference_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_cross_reference_file_surface(kind, path)
    render_stream_cross_reference_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_cross_reference_stream_surface(
      kind, chunks,
    )
    render_stream_cross_reference_scene(kind, stream_surface)
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
test "backend cross reference file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_cross_reference_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_cross_reference_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_cross_reference_file_surface(kind, path)
    render_stream_cross_reference_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        60,
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
test "backend cross reference output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_cross_reference_markers_\{kind}.\{ext}"
    let surface = make_stream_cross_reference_file_surface(kind, path)
    render_stream_cross_reference_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Cross Reference)", "/Subject (final cross reference)",
          "/Creator (cairoon cross reference)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/CrossRef (final)", "/MediaBox [ 0 0 126 96 ]",
          "/MediaBox [ 0 0 136 104 ]", "/PageLabels", "(xref-index)", "(xref-detail)",
          "(xref-overlay)", "/Outlines", "/Title (cross reference index)", "/Title (cross reference detail)",
          "/Title (cross reference overlay)", "/Count 1", "/Count -1", "/F 1", "/F 2",
          "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/cross-reference/overlay)",
          "/Dest", "/Dests", "(xref-detail)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /Index", "/S /Reference", "/S /Figure", "/S /Caption",
          "/S /P", "/S /Span", "%%EOF",
        ])
        expect_vector_output_absent(path, [
          "/StaleCrossRef", "drop-me", "/CrossRef (draft)", "/Subject (draft cross reference)",
        ])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Cross Reference",
          "%%IncludeFeature: *MediaType CrossReference", "%%IncludeFeature: *PageSize CrossReference",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"126pt\" height=\"96pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend cross reference output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /Index", "/S /Reference", "/S /Figure", "/S /Caption", "/S /P",
    "/S /Span", "https://example.com/cross-reference/overlay", "xref-detail", "final cross reference",
    "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_cross_reference_absent_\{kind}.\{ext}"
    let surface = make_stream_cross_reference_file_surface(kind, path)
    render_stream_cross_reference_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_cross_reference_stream_surface(
      kind, chunks,
    )
    render_stream_cross_reference_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
