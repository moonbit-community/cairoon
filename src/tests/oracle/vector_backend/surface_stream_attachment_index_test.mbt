///|
fn make_stream_attachment_index_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(124.0, 96.0, path=Some(path))
    1 => @cairoon.Surface::ps(124.0, 96.0, path=Some(path))
    2 => @cairoon.Surface::svg(124.0, 96.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_attachment_index_backend(kind, surface)
  surface
}

///|
fn make_stream_attachment_index_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(124.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      @cairoon.Surface::ps_stream(124.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      @cairoon.Surface::svg_stream(124.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_attachment_index_backend(kind, surface)
  surface
}

///|
fn configure_stream_attachment_index_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Attachment Index")
      surface.pdf_set_metadata(PdfMetadataAuthor, "cairoon attachment index")
      surface.pdf_set_metadata(PdfMetadataSubject, "attachment index metadata")
      surface.pdf_set_metadata(PdfMetadataKeywords, "attachment,index,audit")
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon attachment index")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      set_pdf_custom_metadata_if_supported(
        surface,
        "AttachmentSet",
        Some("attachment-index-62"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Scratch", Some("drop-me"))
      set_pdf_custom_metadata_if_supported(surface, "Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Attachment Index")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType AttachmentIndex")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize AttachmentIndex")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPx)
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}

///|
fn resize_stream_attachment_index_surface(
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
fn draw_stream_attachment_index_badge(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.10, 0.42, 0.70, 0.85)
  ctx.rectangle(14.0, 38.0, 74.0, 18.0)
  ctx.fill()
  ctx.set_source_rgb(0.98, 0.97, 0.88)
  ctx.move_to(18.0, 51.0)
  ctx.show_text("attachment index")
}

///|
fn draw_stream_attachment_index_detail(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.22, 0.58, 0.34, 0.80)
  ctx.rectangle(18.0, 34.0, 92.0, 26.0)
  ctx.fill()
  ctx.set_source_rgba(0.72, 0.22, 0.38, 0.64)
  ctx.arc(112.0, 72.0, 9.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.move_to(24.0, 50.0)
  ctx.show_text("attachment detail")
}

///|
fn render_stream_attachment_index_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(124.0, 96.0)
    surface.pdf_set_page_label("attachments")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "attachment index",
      "page=1 pos=[14 28]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  }
  ctx.set_source_rgb(0.94, 0.97, 0.92)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Index", "")
  ctx.tag_begin("Reference", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/attachment/index'")
  ctx.move_to(14.0, 28.0)
  ctx.show_text("attachments")
  draw_stream_attachment_index_badge(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Reference")
  ctx.tag_end("Index")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(136.0, 104.0)
    surface.pdf_set_page_label("attachment-detail")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "attachment detail",
      "page=2 pos=[18 60]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  } else {
    resize_stream_attachment_index_surface(kind, surface, 136.0, 104.0)
  }
  ctx.set_source_rgb(0.90, 0.94, 0.98)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_DEST, "name='attachment-detail' x=18 y=60")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin("Caption", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='attachment-detail'")
  draw_stream_attachment_index_detail(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Caption")
  ctx.tag_end("Figure")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.show_page()
  surface.finish()
}

///|
test "backend attachment index stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_attachment_index_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_attachment_index_file_surface(kind, path)
    render_stream_attachment_index_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_attachment_index_stream_surface(
      kind, chunks,
    )
    render_stream_attachment_index_scene(kind, stream_surface)
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
test "backend attachment index file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_attachment_index_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_attachment_index_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_attachment_index_file_surface(kind, path)
    render_stream_attachment_index_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        62,
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
test "backend attachment index output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_attachment_index_markers_\{kind}.\{ext}"
    let surface = make_stream_attachment_index_file_surface(kind, path)
    render_stream_attachment_index_scene(kind, surface)
    match kind {
      0 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Attachment Index)", "/Author (cairoon attachment index)",
          "/Subject (attachment index metadata)", "/Keywords (attachment,index,audit)",
          "/Creator (cairoon attachment index)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/AttachmentSet (attachment-index-62)",
          "/MediaBox [ 0 0 124 96 ]", "/MediaBox [ 0 0 136 104 ]", "/PageLabels",
          "(attachments)", "(attachment-detail)", "/Outlines", "/Title (attachment index)",
          "/Title (attachment detail)", "/F 1", "/F 2", "/Annots [", "/Subtype /Link",
          "/S /URI", "/URI (https://example.com/attachment/index)", "/Dest", "/Dests",
          "(attachment-detail)", "/StructTreeRoot", "/S /Document", "/S /Sect", "/S /Index",
          "/S /Reference", "/S /Figure", "/S /Caption", "%%EOF",
        ])
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Attachment Index",
          "%%IncludeFeature: *MediaType AttachmentIndex", "%%IncludeFeature: *PageSize AttachmentIndex",
          "%%Pages: 2", "%%Page: 1 1", "%%Page: 2 2", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"124px\" height=\"96px\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend attachment index output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /Index", "/S /Reference", "/S /Figure", "/S /Caption", "https://example.com/attachment/index",
    "attachment-detail", "attachment-index-62", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_attachment_index_absent_\{kind}.\{ext}"
    let surface = make_stream_attachment_index_file_surface(kind, path)
    render_stream_attachment_index_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_attachment_index_stream_surface(
      kind, chunks,
    )
    render_stream_attachment_index_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
