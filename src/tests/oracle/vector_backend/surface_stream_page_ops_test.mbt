///|
fn make_stream_page_ops_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(110.0, 90.0, path=Some(path))
    1 => @cairoon.Surface::ps(110.0, 90.0, path=Some(path))
    2 => @cairoon.Surface::svg(110.0, 90.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_page_ops_backend(kind, surface)
  surface
}

///|
fn make_stream_page_ops_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(110.0, 90.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(110.0, 90.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(110.0, 90.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_page_ops_backend(kind, surface)
  surface
}

///|
fn configure_stream_page_ops_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataTitle,
        "Cairoon Page Ops Matrix",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataSubject,
        "surface and context page operations",
      )
      surface.pdf_set_metadata(@cairoon.PdfMetadataCreator, "cairoon page ops")
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreateDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataModDate,
        fixed_pdf_metadata_date(),
      )
      set_pdf_custom_metadata_if_supported(
        surface,
        "PageOps",
        Some("surface-context-mixed"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Scratch", Some("drop-me"))
      set_pdf_custom_metadata_if_supported(surface, "Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Page Ops Matrix")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType PageOps")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize PageOps")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPt)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn resize_stream_page_ops_surface(
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
fn render_stream_page_ops_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut copy_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(110.0, 90.0)
    surface.pdf_set_page_label("ops-surface-show")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "ops surface show",
      "page=1 pos=[10 24]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  ctx.set_source_rgb(0.92, 0.97, 0.98)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/page-ops/show'")
  ctx.move_to(10.0, 24.0)
  ctx.show_text("surface show page")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(130.0, 90.0)
    surface.pdf_set_page_label("ops-surface-copy")
    copy_id = surface.pdf_add_outline_with_flags(
      root_id,
      "ops surface copy",
      "page=2 pos=[14 48]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
  } else {
    resize_stream_page_ops_surface(kind, surface, 130.0, 90.0)
  }
  ctx.set_source_rgb(0.98, 0.93, 0.86)
  ctx.paint()
  ctx.set_source_rgb(0.10, 0.36, 0.60)
  ctx.rectangle(14.0, 30.0, 74.0, 22.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin(@cairoon.TAG_DEST, "name='ops-copy-dest' x=14 y=68")
  ctx.tag_begin("P", "")
  ctx.move_to(14.0, 68.0)
  ctx.show_text("surface copy destination")
  ctx.tag_end("P")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(130.0, 90.0)
    surface.pdf_set_page_label("ops-context-copy")
    let _ = surface.pdf_add_outline_with_flags(
      copy_id,
      "ops context copy",
      "page=3 pos=[18 78]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineBold),
    )
  } else {
    resize_stream_page_ops_surface(kind, surface, 130.0, 90.0)
  }
  ctx.set_source_rgba(0.82, 0.12, 0.18, 0.64)
  ctx.rectangle(18.0, 56.0, 68.0, 16.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Span", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='ops-copy-dest'")
  ctx.move_to(18.0, 80.0)
  ctx.show_text("context copy link")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Span")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.copy_page()

  if kind == 0 {
    surface.pdf_set_size(90.0, 110.0)
    surface.pdf_set_page_label("ops-context-show")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "ops context show",
      "page=4 pos=[12 96]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineOpen),
    )
  } else {
    resize_stream_page_ops_surface(kind, surface, 90.0, 110.0)
  }
  ctx.set_source_rgba(0.18, 0.50, 0.24, 0.72)
  ctx.arc(44.0, 86.0, 16.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.move_to(12.0, 104.0)
  ctx.show_text("context show final")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()
  surface.finish()
}

///|
test "backend page ops stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_ops_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_page_ops_file_surface(kind, path)
    render_stream_page_ops_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_page_ops_stream_surface(kind, chunks)
    render_stream_page_ops_scene(kind, stream_surface)
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
test "backend page ops file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_ops_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_page_ops_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_page_ops_file_surface(kind, path)
    render_stream_page_ops_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        47,
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
test "backend page ops output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_ops_markers_\{kind}.\{ext}"
    let surface = make_stream_page_ops_file_surface(kind, path)
    render_stream_page_ops_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Page Ops Matrix)", "/Subject (surface and context page operations)",
          "/Creator (cairoon page ops)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/PageOps (surface-context-mixed)",
          "/Count 4", "/MediaBox [ 0 0 110 90 ]", "/MediaBox [ 0 0 130 90 ]", "/MediaBox [ 0 0 90 110 ]",
          "/PageLabels", "(ops-surface-show)", "(ops-surface-copy)", "(ops-context-copy)",
          "(ops-context-show)", "/Outlines", "/Title (ops surface show)", "/Title (ops surface copy)",
          "/Title (ops context copy)", "/Title (ops context show)", "/F 2", "/F 1",
          "/F 0", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/page-ops/show)",
          "/Dest", "/Dests", "(ops-copy-dest)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /P", "/S /Span", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/Scratch", "drop-me"])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 2", "%%Title: Cairoon Page Ops Matrix",
          "%%IncludeFeature: *MediaType PageOps", "%%IncludeFeature: *PageSize PageOps",
          "%%Pages: 4", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%Page: 4 4",
          "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"110pt\" height=\"90pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend page ops output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "/S /Span", "https://example.com/page-ops/show", "ops-copy-dest",
    "surface-context-mixed", "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_page_ops_absent_\{kind}.\{ext}"
    let surface = make_stream_page_ops_file_surface(kind, path)
    render_stream_page_ops_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_page_ops_stream_surface(kind, chunks)
    render_stream_page_ops_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
