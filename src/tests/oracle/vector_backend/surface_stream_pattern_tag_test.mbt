///|
fn make_stream_pattern_tag_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(132.0, 112.0, path=Some(path))
    1 => @cairoon.Surface::ps(132.0, 112.0, path=Some(path))
    2 => @cairoon.Surface::svg(132.0, 112.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_pattern_tag_backend(kind, surface)
  surface
}

///|
fn make_stream_pattern_tag_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(132.0, 112.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    1 =>
      @cairoon.Surface::ps_stream(132.0, 112.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    2 =>
      @cairoon.Surface::svg_stream(132.0, 112.0, fn(chunk) {
        chunks.push(chunk)
        Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_pattern_tag_backend(kind, surface)
  surface
}

///|
fn configure_stream_pattern_tag_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Pattern Tag Matrix")
      surface.pdf_set_metadata(
        PdfMetadataSubject,
        "pattern tags with font matrix",
      )
      surface.pdf_set_metadata(PdfMetadataKeywords, "pattern,tag,font,matrix")
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon pattern tag")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      set_pdf_custom_metadata_if_supported(
        surface,
        "PatternTag",
        Some("surface-pattern-font-matrix"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Scratch", Some("drop-me"))
      set_pdf_custom_metadata_if_supported(surface, "Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Pattern Tag Matrix")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType PatternTag")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize PatternTag")
    }
    2 => {
      surface.svg_restrict_to_version(SvgVersion1_2)
      surface.svg_set_document_unit(SvgUnitPt)
    }
    _ => @cairoon.check_status(InvalidStatus)
  }
}

///|
fn resize_stream_pattern_tag_surface(
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
fn make_stream_pattern_tag_pattern() -> @cairoon.Pattern raise @cairoon.CairoError {
  let image = @cairoon.Surface::image(Argb32, 14, 14)
  let image_ctx = @cairoon.Context::new(image)
  image_ctx.set_source_rgb(0.94, 0.90, 0.78)
  image_ctx.paint()
  image_ctx.set_source_rgba(0.12, 0.44, 0.76, 0.80)
  image_ctx.rectangle(1.0, 1.0, 6.0, 12.0)
  image_ctx.fill()
  image_ctx.set_source_rgba(0.82, 0.18, 0.22, 0.70)
  image_ctx.arc(9.5, 5.5, 4.0, 0.0, 6.283185307179586)
  image_ctx.fill()
  image_ctx.set_source_rgba(0.08, 0.34, 0.20, 0.75)
  image_ctx.rectangle(7.0, 9.0, 6.0, 4.0)
  image_ctx.fill()

  let pattern = @cairoon.Pattern::for_surface(image)
  pattern.set_extend(Repeat)
  pattern.set_filter(Nearest)
  pattern.set_matrix(
    @cairoon.Matrix::new(xx=0.75, yx=0.12, xy=-0.18, yy=0.85, x0=-6.0, y0=2.0),
  )
  pattern
}

///|
fn draw_stream_pattern_tag_pattern(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  let pattern = make_stream_pattern_tag_pattern()
  let mask = @cairoon.Pattern::radial(66.0, 55.0, 4.0, 66.0, 55.0, 56.0)
  mask.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.96)
  mask.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 0.12)
  ctx.save()
  ctx.rectangle(14.0, 34.0, 96.0, 54.0)
  ctx.clip()
  ctx.set_source(pattern)
  ctx.mask(mask)
  ctx.restore()
}

///|
fn render_stream_pattern_tag_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(11.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_page_label("pattern-cover")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "pattern cover",
      "page=1 pos=[12 28]",
      @cairoon.PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold]),
    )
  }
  ctx.set_source_rgb(0.95, 0.96, 0.90)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "uri='https://example.com/pattern-tag/cover'",
  )
  ctx.move_to(12.0, 28.0)
  ctx.show_text("pattern tag cover")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("P")
  ctx.tag_begin("Figure", "")
  draw_stream_pattern_tag_pattern(ctx)
  ctx.tag_end("Figure")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.copy_page()

  if kind == 0 {
    surface.pdf_set_size(120.0, 138.0)
    surface.pdf_set_page_label("pattern-dest")
    let _ = surface.pdf_add_outline_with_flags(
      root_id,
      "pattern destination",
      "page=2 pos=[16 72]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
    )
  } else {
    resize_stream_pattern_tag_surface(kind, surface, 120.0, 138.0)
  }
  ctx.set_source_rgb(0.92, 0.94, 0.98)
  ctx.paint()
  ctx.set_source_rgb(0.10, 0.36, 0.54)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Figure", "")
  ctx.tag_begin(@cairoon.TAG_DEST, "name='pattern-tag-dest' x=16 y=72")
  ctx.arc(32.0, 54.0, 16.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.tag_end("Figure")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='pattern-tag-dest'")
  ctx.move_to(16.0, 72.0)
  ctx.show_text("pattern destination")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()

  if kind == 0 {
    surface.pdf_set_size(96.0, 120.0)
    surface.pdf_set_page_label("pattern-final")
    let _ = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "pattern final",
      "page=3 pos=[12 78]",
      @cairoon.PDFOutlineFlagSet::of(PdfOutlineBold),
    )
  } else {
    resize_stream_pattern_tag_surface(kind, surface, 96.0, 120.0)
  }
  ctx.set_source_rgb(0.97, 0.92, 0.88)
  ctx.paint()
  ctx.set_source_rgba(0.36, 0.18, 0.52, 0.50)
  ctx.rectangle(12.0, 84.0, 62.0, 20.0)
  ctx.fill()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.set_font_matrix(
    @cairoon.Matrix::new(xx=7.8, yx=0.35, xy=-0.28, yy=8.6, x0=0.0, y0=0.0),
  )
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Div", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "uri='https://example.com/pattern-tag/final'",
  )
  let run = ctx.get_scaled_font().text_to_glyphs(12.0, 78.0, "pattern glyph")
  ctx.show_text_glyphs(
    "pattern glyph",
    run.glyphs,
    run.clusters,
    flags=run.flags,
  )
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Div")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()
  surface.finish()
}

///|
test "backend pattern tag stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_pattern_tag_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_pattern_tag_file_surface(kind, path)
    render_stream_pattern_tag_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_pattern_tag_stream_surface(kind, chunks)
    render_stream_pattern_tag_scene(kind, stream_surface)
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
test "backend pattern tag file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_pattern_tag_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_pattern_tag_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_pattern_tag_file_surface(kind, path)
    render_stream_pattern_tag_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        51,
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
test "backend pattern tag output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_pattern_tag_markers_\{kind}.\{ext}"
    let surface = make_stream_pattern_tag_file_surface(kind, path)
    render_stream_pattern_tag_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon Pattern Tag Matrix)", "/Subject (pattern tags with font matrix)",
          "/Keywords (pattern,tag,font,matrix)", "/Creator (cairoon pattern tag)",
          "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
          "/PatternTag (surface-pattern-font-matrix)", "/Count 3", "/MediaBox [ 0 0 132 112 ]",
          "/MediaBox [ 0 0 120 138 ]", "/MediaBox [ 0 0 96 120 ]", "/PageLabels",
          "(pattern-cover)", "(pattern-dest)", "(pattern-final)", "/Outlines", "/Title (pattern cover)",
          "/Title (pattern destination)", "/Title (pattern final)", "/Annots [",
          "/Subtype /Link", "/S /URI", "/URI (https://example.com/pattern-tag/cover)",
          "/URI (https://example.com/pattern-tag/final)", "/Dest", "/Dests", "(pattern-tag-dest)",
          "/StructTreeRoot", "/S /Document", "/S /Sect", "/S /P", "/S /Figure", "/S /Div",
          "/S /Span", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/Scratch", "drop-me"])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon Pattern Tag Matrix",
          "%%IncludeFeature: *MediaType PatternTag", "%%IncludeFeature: *PageSize PatternTag",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"132pt\" height=\"112pt\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend pattern tag output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "/S /Figure", "/S /Div", "/S /Span", "https://example.com/pattern-tag/cover",
    "https://example.com/pattern-tag/final", "pattern-tag-dest", "surface-pattern-font-matrix",
    "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_pattern_tag_absent_\{kind}.\{ext}"
    let surface = make_stream_pattern_tag_file_surface(kind, path)
    render_stream_pattern_tag_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_pattern_tag_stream_surface(kind, chunks)
    render_stream_pattern_tag_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
