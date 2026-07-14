///|
fn make_stream_metadata_outline_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(128.0, 112.0, path=Some(path))
    1 => @cairoon.Surface::ps(128.0, 112.0, path=Some(path))
    2 => @cairoon.Surface::svg(128.0, 112.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_metadata_outline_backend(kind, surface)
  surface
}

///|
fn make_stream_metadata_outline_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(128.0, 112.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(128.0, 112.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(128.0, 112.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_metadata_outline_backend(kind, surface)
  surface
}

///|
fn configure_stream_metadata_outline_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataTitle,
        "Cairoon Metadata Outline Matrix",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataAuthor,
        "cairoon outline author",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataSubject,
        "metadata outline tree",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataKeywords,
        "metadata,outline,page-labels",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon metadata outline",
      )
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
        "OutlineScenario",
        Some("metadata-outline-tree"),
      )
      set_pdf_custom_metadata_if_supported(
        surface,
        "OutlineRevision",
        Some("draft"),
      )
      set_pdf_custom_metadata_if_supported(
        surface,
        "OutlineRevision",
        Some("final"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Scratch", Some("drop-me"))
      set_pdf_custom_metadata_if_supported(surface, "Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Metadata Outline Matrix")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType Plain")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize A5")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPt)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn render_stream_metadata_outline_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(11.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut child_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_page_label("outline-cover")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "outline root",
      "page=1 pos=[10 22]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  ctx.set_source_rgb(0.91, 0.96, 0.99)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/outline-matrix'")
  ctx.move_to(10.0, 22.0)
  ctx.show_text("outline root link")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("H1")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.set_source_rgb(0.15, 0.35, 0.65)
  ctx.rectangle(10.0, 38.0, 72.0, 26.0)
  ctx.fill()
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_page_label("outline-overlay")
    child_id = surface.pdf_add_outline_with_flags(
      root_id,
      "outline overlay child",
      "page=2 pos=[10 62]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "outline overlay sibling",
      "page=2 pos=[84 62]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineBold,
        @cairoon.PdfOutlineItalic,
      ]),
    )
  }
  ctx.set_source_rgba(0.82, 0.14, 0.20, 0.72)
  ctx.rectangle(10.0, 54.0, 58.0, 22.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.move_to(10.0, 88.0)
  ctx.show_text("outline retained overlay")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(150.0, 100.0)
    surface.pdf_set_page_label("outline-destination")
    let _ = surface.pdf_add_outline_with_flags(
      child_id,
      "outline destination grandchild",
      "page=3 pos=[16 34]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineOpen),
    )
  } else if kind == 1 {
    surface.ps_set_size(150.0, 100.0)
  }
  ctx.set_source_rgb(0.96, 0.93, 0.84)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='outline-matrix-dest' x=16 y=34")
  ctx.move_to(16.0, 34.0)
  ctx.show_text("outline destination")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='outline-matrix-dest'")
  ctx.set_source_rgb(0.12, 0.48, 0.28)
  ctx.arc(28.0, 58.0, 12.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.tag_end(@cairoon.TAG_LINK)
  surface.show_page()
  surface.finish()
}

///|
test "backend metadata outline stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_metadata_outline_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_metadata_outline_file_surface(kind, path)
    render_stream_metadata_outline_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_metadata_outline_stream_surface(
      kind, chunks,
    )
    render_stream_metadata_outline_scene(kind, stream_surface)
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
test "backend metadata outline file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_metadata_outline_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_metadata_outline_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_metadata_outline_file_surface(kind, path)
    render_stream_metadata_outline_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        46,
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
test "backend metadata outline output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_metadata_outline_markers_\{kind}.\{ext}"
    let surface = make_stream_metadata_outline_file_surface(kind, path)
    render_stream_metadata_outline_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Metadata Outline Matrix)", "/Author (cairoon outline author)",
          "/Subject (metadata outline tree)", "/Keywords (metadata,outline,page-labels)",
          "/Creator (cairoon metadata outline)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/OutlineScenario (metadata-outline-tree)",
          "/OutlineRevision (final)", "/Count -3", "/MediaBox [ 0 0 128 112 ]", "/MediaBox [ 0 0 150 100 ]",
          "/PageLabels", "(outline-cover)", "(outline-overlay)", "(outline-destination)",
          "/Outlines", "/Title (outline root)", "/Title (outline overlay child)",
          "/Title (outline overlay sibling)", "/Title (outline destination grandchild)",
          "/F 2", "/F 1", "/F 3", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/outline-matrix)",
          "/Dest", "/Dests", "(outline-matrix-dest)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /H1", "%%EOF",
        ])
        expect_vector_output_absent(path, [
          "/OutlineRevision (draft)", "drop-me",
        ])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Metadata Outline Matrix",
          "%%IncludeFeature: *MediaType Plain", "%%IncludeFeature: *PageSize A5",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"128pt\" height=\"112pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend metadata outline output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /H1", "metadata-outline-tree", "OutlineRevision", "outline-cover",
    "outline-overlay", "outline-destination", "outline-matrix-dest", "https://example.com/outline-matrix",
    "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_metadata_outline_absent_\{kind}.\{ext}"
    let surface = make_stream_metadata_outline_file_surface(kind, path)
    render_stream_metadata_outline_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_metadata_outline_stream_surface(
      kind, chunks,
    )
    render_stream_metadata_outline_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
