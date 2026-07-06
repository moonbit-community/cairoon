///|
fn make_stream_tag_metadata_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(120.0, 96.0, path=Some(path))
    1 => @cairoon.Surface::ps(120.0, 96.0, path=Some(path))
    2 => @cairoon.Surface::svg(120.0, 96.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_tag_metadata_backend(kind, surface)
  surface
}

///|
fn make_stream_tag_metadata_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(120.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(120.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(120.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_tag_metadata_backend(kind, surface)
  surface
}

///|
fn configure_stream_tag_metadata_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataTitle,
        "Cairoon Tag Metadata Matrix",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataSubject,
        "tag metadata page transitions",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon tag metadata",
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
        "TagMeta",
        Some("tag-metadata-page-transitions"),
      )
      surface.pdf_set_custom_metadata("Scratch", Some("drop-me"))
      surface.pdf_set_custom_metadata("Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Tag Metadata Matrix")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType TagMeta")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize TagMeta")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPt)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn resize_stream_tag_metadata_surface(
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
fn render_stream_tag_metadata_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut overlay_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_page_label("tagmeta-cover")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "tag metadata cover",
      "page=1 pos=[12 24]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  ctx.set_source_rgb(0.93, 0.95, 0.99)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/tag-meta/cover'")
  ctx.move_to(12.0, 24.0)
  ctx.show_text("tag metadata cover")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.set_source_rgba(0.15, 0.38, 0.70, 0.70)
  ctx.rectangle(12.0, 36.0, 74.0, 22.0)
  ctx.fill()
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(140.0, 96.0)
    surface.pdf_set_page_label("tagmeta-overlay")
    overlay_id = surface.pdf_add_outline_with_flags(
      root_id,
      "tag metadata overlay",
      "page=2 pos=[18 78]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
  } else {
    resize_stream_tag_metadata_surface(kind, surface, 140.0, 96.0)
  }
  ctx.set_source_rgba(0.85, 0.20, 0.25, 0.55)
  ctx.rectangle(18.0, 44.0, 82.0, 24.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin(@cairoon.TAG_DEST, "name='tag-meta-dest' x=18 y=78")
  ctx.move_to(18.0, 78.0)
  ctx.show_text("tag metadata destination")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.tag_end("Figure")
  ctx.tag_end("Document")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='tag-meta-dest'")
  ctx.set_source_rgba(0.12, 0.50, 0.32, 0.72)
  ctx.arc(108.0, 58.0, 12.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.tag_end(@cairoon.TAG_LINK)
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(100.0, 120.0)
    surface.pdf_set_page_label("tagmeta-final")
    let _ = surface.pdf_add_outline_with_flags(
      overlay_id,
      "tag metadata final",
      "page=3 pos=[14 88]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineOpen),
    )
  } else {
    resize_stream_tag_metadata_surface(kind, surface, 100.0, 120.0)
  }
  ctx.set_source_rgb(0.96, 0.93, 0.84)
  ctx.paint()
  ctx.save()
  ctx.rectangle(8.0, 12.0, 82.0, 84.0)
  ctx.clip()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/tag-meta/final'")
  ctx.move_to(14.0, 88.0)
  ctx.show_text("tag metadata final")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.restore()
  ctx.show_page()
  surface.finish()
}

///|
test "backend tag metadata stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tag_metadata_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_tag_metadata_file_surface(kind, path)
    render_stream_tag_metadata_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_tag_metadata_stream_surface(kind, chunks)
    render_stream_tag_metadata_scene(kind, stream_surface)
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
test "backend tag metadata file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tag_metadata_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_tag_metadata_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_tag_metadata_file_surface(kind, path)
    render_stream_tag_metadata_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        48,
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
test "backend tag metadata output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tag_metadata_markers_\{kind}.\{ext}"
    let surface = make_stream_tag_metadata_file_surface(kind, path)
    render_stream_tag_metadata_scene(kind, surface)
    match kind {
      0 => {
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Tag Metadata Matrix)", "/Subject (tag metadata page transitions)",
          "/Creator (cairoon tag metadata)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/TagMeta (tag-metadata-page-transitions)",
          "/Count 3", "/MediaBox [ 0 0 120 96 ]", "/MediaBox [ 0 0 140 96 ]", "/MediaBox [ 0 0 100 120 ]",
          "/PageLabels", "(tagmeta-cover)", "(tagmeta-overlay)", "(tagmeta-final)",
          "/Outlines", "/Title (tag metadata cover)", "/Title (tag metadata overlay)",
          "/Title (tag metadata final)", "/Annots [", "/Subtype /Link", "/S /URI",
          "/URI (https://example.com/tag-meta/cover)", "/URI (https://example.com/tag-meta/final)",
          "/Dest", "/Dests", "(tag-meta-dest)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /P", "/S /Figure", "/S /Span", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/Scratch", "drop-me"])
      }
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Tag Metadata Matrix",
          "%%IncludeFeature: *MediaType TagMeta", "%%IncludeFeature: *PageSize TagMeta",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_vector_output(path, [
          "<?xml version=\"1.0\"", "<svg", "width=\"120pt\" height=\"96pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend tag metadata output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "/S /Figure", "/S /Span", "https://example.com/tag-meta/cover",
    "https://example.com/tag-meta/final", "tag-meta-dest", "tag-metadata-page-transitions",
    "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tag_metadata_absent_\{kind}.\{ext}"
    let surface = make_stream_tag_metadata_file_surface(kind, path)
    render_stream_tag_metadata_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_tag_metadata_stream_surface(kind, chunks)
    render_stream_tag_metadata_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
