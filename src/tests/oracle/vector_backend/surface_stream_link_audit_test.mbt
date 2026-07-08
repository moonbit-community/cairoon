///|
fn make_stream_link_audit_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(118.0, 92.0, path=Some(path))
    1 => @cairoon.Surface::ps(118.0, 92.0, path=Some(path))
    2 => @cairoon.Surface::svg(118.0, 92.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_link_audit_backend(kind, surface)
  surface
}

///|
fn make_stream_link_audit_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(118.0, 92.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(118.0, 92.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(118.0, 92.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_link_audit_backend(kind, surface)
  surface
}

///|
fn configure_stream_link_audit_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(@cairoon.PdfMetadataTitle, "Cairoon Link Audit")
      surface.pdf_set_metadata(@cairoon.PdfMetadataAuthor, "cairoon link audit")
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataKeywords,
        "link,audit,destination",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon link audit",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreateDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataModDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_custom_metadata("AuditID", Some("link-audit-61"))
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Link Audit")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType LinkAudit")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize LinkAudit")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPx)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn resize_stream_link_audit_surface(
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
fn draw_stream_link_audit_badge(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.12, 0.38, 0.70, 0.82)
  ctx.rectangle(16.0, 38.0, 72.0, 18.0)
  ctx.fill()
  ctx.set_source_rgb(0.97, 0.96, 0.88)
  ctx.move_to(20.0, 51.0)
  ctx.show_text("audit index")
}

///|
fn draw_stream_link_audit_detail(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.18, 0.58, 0.36, 0.78)
  ctx.rectangle(18.0, 34.0, 92.0, 26.0)
  ctx.fill()
  ctx.set_source_rgba(0.76, 0.18, 0.30, 0.62)
  ctx.arc(112.0, 70.0, 10.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.set_source_rgb(0.05, 0.05, 0.05)
  ctx.move_to(24.0, 50.0)
  ctx.show_text("audit detail")
}

///|
fn render_stream_link_audit_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(118.0, 92.0)
    surface.pdf_set_page_label("audit-index")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "link audit index",
      "page=1 pos=[16 28]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  ctx.set_source_rgb(0.94, 0.96, 0.90)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/link-audit/index'")
  ctx.move_to(16.0, 28.0)
  ctx.show_text("link audit")
  draw_stream_link_audit_badge(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(142.0, 108.0)
    surface.pdf_set_page_label("audit-detail")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "link audit detail",
      "page=2 pos=[18 68]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
  } else {
    resize_stream_link_audit_surface(kind, surface, 142.0, 108.0)
  }
  ctx.set_source_rgb(0.90, 0.94, 0.98)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_DEST, "name='audit-detail' x=18 y=68")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("L", "")
  ctx.tag_begin("LI", "")
  ctx.tag_begin("LBody", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='audit-detail'")
  draw_stream_link_audit_detail(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("LBody")
  ctx.tag_end("LI")
  ctx.tag_end("L")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.show_page()
  surface.finish()
}

///|
test "backend link audit stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_link_audit_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_link_audit_file_surface(kind, path)
    render_stream_link_audit_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_link_audit_stream_surface(kind, chunks)
    render_stream_link_audit_scene(kind, stream_surface)
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
test "backend link audit file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_link_audit_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_link_audit_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_link_audit_file_surface(kind, path)
    render_stream_link_audit_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        61,
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
test "backend link audit output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_link_audit_markers_\{kind}.\{ext}"
    let surface = make_stream_link_audit_file_surface(kind, path)
    render_stream_link_audit_scene(kind, surface)
    match kind {
      0 =>
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Link Audit)", "/Author (cairoon link audit)",
          "/Keywords (link,audit,destination)", "/Creator (cairoon link audit)",
          "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
          "/AuditID (link-audit-61)", "/MediaBox [ 0 0 118 92 ]", "/MediaBox [ 0 0 142 108 ]",
          "/PageLabels", "(audit-index)", "(audit-detail)", "/Outlines", "/Title (link audit index)",
          "/Title (link audit detail)", "/F 1", "/F 2", "/Annots [", "/Subtype /Link",
          "/S /URI", "/URI (https://example.com/link-audit/index)", "/Dest", "/Dests",
          "(audit-detail)", "/StructTreeRoot", "/S /Document", "/S /Sect", "/S /P",
          "/S /L", "/S /LI", "/S /LBody", "%%EOF",
        ])
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Link Audit",
          "%%IncludeFeature: *MediaType LinkAudit", "%%IncludeFeature: *PageSize LinkAudit",
          "%%Pages: 2", "%%Page: 1 1", "%%Page: 2 2", "%%EOF",
        ])
      2 =>
        expect_vector_output(path, [
          "<?xml version=\"1.0\"", "<svg", "width=\"118px\" height=\"92px\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend link audit output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "/S /L", "/S /LI", "/S /LBody", "https://example.com/link-audit/index",
    "audit-detail", "link-audit-61", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_link_audit_absent_\{kind}.\{ext}"
    let surface = make_stream_link_audit_file_surface(kind, path)
    render_stream_link_audit_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_link_audit_stream_surface(kind, chunks)
    render_stream_link_audit_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
