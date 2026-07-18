///|
fn make_stream_article_thread_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(132.0, 96.0, path=Some(path))
    1 => @cairoon.Surface::ps(132.0, 96.0, path=Some(path))
    2 => @cairoon.Surface::svg(132.0, 96.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_article_thread_backend(kind, surface)
  surface
}

///|
fn make_stream_article_thread_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(132.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      @cairoon.Surface::ps_stream(132.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      @cairoon.Surface::svg_stream(132.0, 96.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_article_thread_backend(kind, surface)
  surface
}

///|
fn configure_stream_article_thread_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Article Thread")
      surface.pdf_set_metadata(PdfMetadataAuthor, "cairoon backend oracle")
      surface.pdf_set_metadata(PdfMetadataSubject, "draft article thread")
      surface.pdf_set_metadata(PdfMetadataSubject, "final article thread")
      surface.pdf_set_metadata(PdfMetadataKeywords, "article,thread,aside,note")
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon article thread")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      set_pdf_custom_metadata_if_supported(surface, "Thread", Some("draft"))
      set_pdf_custom_metadata_if_supported(surface, "Thread", Some("final"))
      set_pdf_custom_metadata_if_supported(
        surface,
        "Transient",
        Some("drop-me"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Transient", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Article Thread")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType ArticleThread")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize ArticleThread")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPt)
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}

///|
fn resize_stream_article_thread_surface(
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
fn draw_stream_article_thread_intro(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.10, 0.36, 0.62, 0.78)
  ctx.rectangle(14.0, 34.0, 96.0, 20.0)
  ctx.fill()
  ctx.set_source_rgb(0.98, 0.96, 0.86)
  ctx.move_to(18.0, 48.0)
  ctx.show_text("article intro")
  ctx.set_source_rgba(0.70, 0.22, 0.30, 0.62)
  ctx.arc(106.0, 70.0, 12.0, 0.0, 6.283185307179586)
  ctx.fill()
}

///|
fn draw_stream_article_thread_aside(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.14, 0.48, 0.30, 0.76)
  ctx.rectangle(18.0, 48.0, 108.0, 20.0)
  ctx.fill()
  ctx.set_source_rgb(0.02, 0.02, 0.02)
  ctx.move_to(22.0, 62.0)
  ctx.show_text("aside note")
  ctx.set_source_rgba(0.70, 0.48, 0.14, 0.70)
  ctx.move_to(22.0, 80.0)
  ctx.line_to(70.0, 58.0)
  ctx.line_to(124.0, 80.0)
  ctx.stroke()
}

///|
fn draw_stream_article_thread_figure(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgba(0.44, 0.24, 0.62, 0.72)
  ctx.rectangle(20.0, 40.0, 86.0, 22.0)
  ctx.fill()
  ctx.set_source_rgba(0.18, 0.54, 0.66, 0.72)
  ctx.rectangle(20.0, 70.0, 86.0, 18.0)
  ctx.fill()
  ctx.set_source_rgb(0.02, 0.02, 0.02)
  ctx.move_to(24.0, 55.0)
  ctx.show_text("figure")
  ctx.move_to(24.0, 84.0)
  ctx.show_text("caption")
}

///|
fn render_stream_article_thread_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(10.0)

  let mut intro_id = @cairoon.PDF_OUTLINE_ROOT
  let mut note_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(132.0, 96.0)
    surface.pdf_set_page_label("article-intro")
    intro_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "article intro",
      "page=1 pos=[12 28]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  }
  ctx.set_source_rgb(0.96, 0.97, 0.91)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Art", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "uri='https://example.com/article-thread/intro'",
  )
  ctx.move_to(12.0, 28.0)
  ctx.show_text("article thread")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_begin("Span", "")
  draw_stream_article_thread_intro(ctx)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Art")
  ctx.tag_end("Document")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(144.0, 108.0)
    surface.pdf_set_page_label("article-note")
    note_id = surface.pdf_add_outline_with_flags(
      intro_id,
      "article note",
      "page=2 pos=[20 68]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  } else {
    resize_stream_article_thread_surface(kind, surface, 144.0, 108.0)
  }
  ctx.tag_begin(@cairoon.TAG_DEST, "name='article-thread-note' x=20 y=68")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Art", "")
  ctx.tag_begin("BlockQuote", "")
  ctx.tag_begin("Note", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  draw_stream_article_thread_aside(ctx)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Note")
  ctx.tag_end("BlockQuote")
  ctx.tag_end("Art")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.show_page()

  if kind == 0 {
    surface.pdf_set_size(126.0, 116.0)
    surface.pdf_set_page_label("article-figure")
    let _ = surface.pdf_add_outline_with_flags(
      note_id,
      "article figure",
      "page=3 pos=[20 98]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineBold, PdfOutlineItalic]),
    )
  } else {
    resize_stream_article_thread_surface(kind, surface, 126.0, 116.0)
  }
  ctx.set_source_rgb(0.92, 0.98, 0.95)
  ctx.paint()
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Art", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='article-thread-note'")
  draw_stream_article_thread_figure(ctx)
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_begin("Caption", "")
  ctx.move_to(20.0, 98.0)
  ctx.show_text("article caption")
  ctx.tag_end("Caption")
  ctx.tag_end("Figure")
  ctx.tag_begin("Reference", "")
  ctx.move_to(20.0, 108.0)
  ctx.show_text("see article note")
  ctx.tag_end("Reference")
  ctx.tag_end("Sect")
  ctx.tag_end("Art")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend article thread stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_article_thread_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_article_thread_file_surface(kind, path)
    render_stream_article_thread_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_article_thread_stream_surface(kind, chunks)
    render_stream_article_thread_scene(kind, stream_surface)
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
test "backend article thread file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_article_thread_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_article_thread_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_article_thread_file_surface(kind, path)
    render_stream_article_thread_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        56,
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
test "backend article thread output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_article_thread_markers_\{kind}.\{ext}"
    let surface = make_stream_article_thread_file_surface(kind, path)
    render_stream_article_thread_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Article Thread)", "/Author (cairoon backend oracle)",
          "/Subject (final article thread)", "/Keywords (article,thread,aside,note)",
          "/Creator (cairoon article thread)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/Thread (final)", "/MediaBox [ 0 0 132 96 ]",
          "/MediaBox [ 0 0 144 108 ]", "/MediaBox [ 0 0 126 116 ]", "/PageLabels",
          "(article-intro)", "(article-note)", "(article-figure)", "/Outlines", "/Title (article intro)",
          "/Title (article note)", "/Title (article figure)", "/F 3", "/F 1", "/Annots [",
          "/Subtype /Link", "/S /URI", "/URI (https://example.com/article-thread/intro)",
          "/Dest", "/Dests", "(article-thread-note)", "/StructTreeRoot", "/S /Document",
          "/S /Art", "/S /Sect", "/S /P", "/S /Span", "/S /BlockQuote", "/S /Note",
          "/S /Reference", "/S /Figure", "/S /Caption", "%%EOF",
        ])
        expect_vector_output_absent(path, [
          "/Transient", "drop-me", "/Thread (draft)", "/Subject (draft article thread)",
        ])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Article Thread",
          "%%IncludeFeature: *MediaType ArticleThread", "%%IncludeFeature: *PageSize ArticleThread",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"132pt\" height=\"96pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend article thread output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Art", "/S /Sect", "/S /P", "/S /Span", "/S /BlockQuote", "/S /Note", "/S /Reference",
    "/S /Figure", "/S /Caption", "https://example.com/article-thread/intro", "article-thread-note",
    "final article thread", "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_article_thread_absent_\{kind}.\{ext}"
    let surface = make_stream_article_thread_file_surface(kind, path)
    render_stream_article_thread_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_article_thread_stream_surface(kind, chunks)
    render_stream_article_thread_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
