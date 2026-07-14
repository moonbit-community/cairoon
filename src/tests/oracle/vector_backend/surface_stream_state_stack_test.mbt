///|
fn make_stream_state_stack_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(140.0, 90.0, path=Some(path))
    1 => @cairoon.Surface::ps(140.0, 90.0, path=Some(path))
    2 => @cairoon.Surface::svg(140.0, 90.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_state_stack_backend(kind, surface)
  surface
}

///|
fn make_stream_state_stack_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(140.0, 90.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(140.0, 90.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(140.0, 90.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_state_stack_backend(kind, surface)
  surface
}

///|
fn configure_stream_state_stack_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(@cairoon.PdfMetadataTitle, "Cairoon State Stack")
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataSubject,
        "clip group mask state stack",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon state stack",
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
        "StateStack",
        Some("clip-group-mask"),
      )
      set_pdf_custom_metadata_if_supported(surface, "Scratch", Some("drop-me"))
      set_pdf_custom_metadata_if_supported(surface, "Scratch", None)
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_set_eps(false)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon State Stack")
      surface.ps_dsc_comment("%%IncludeFeature: *MediaColor StateBlue")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *PageSize StateStack")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitCm)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn resize_stream_state_stack_surface(
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
fn draw_stream_state_stack_surface_pattern(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.save()
  ctx.rectangle(8.0, 10.0, 104.0, 52.0)
  ctx.clip()
  ctx.translate(8.0, 10.0)
  ctx.scale(10.4, 5.2)
  apply_vector_surface_pattern(ctx)
  ctx.restore()
}

///|
fn draw_stream_state_stack_group(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.save()
  ctx.rectangle(10.0, 12.0, 92.0, 58.0)
  ctx.clip()
  ctx.set_source_rgb(0.05, 0.07, 0.18)
  ctx.paint()
  ctx.push_group_with_content(@cairoon.ContentColorAlpha)
  ctx.set_source_rgba(0.95, 0.20, 0.18, 0.76)
  ctx.rectangle(16.0, 20.0, 58.0, 30.0)
  ctx.fill()
  ctx.set_source_rgba(0.10, 0.78, 0.46, 0.58)
  ctx.arc(66.0, 48.0, 20.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.pop_group_to_source()
  ctx.paint_with_alpha(0.72)
  ctx.restore()
}

///|
fn draw_stream_state_stack_mask(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  let mask = @cairoon.Pattern::linear(12.0, 18.0, 108.0, 86.0)
  mask.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 0.0)
  mask.add_color_stop_rgba(0.45, 1.0, 1.0, 1.0, 0.48)
  mask.add_color_stop_rgba(1.0, 1.0, 1.0, 1.0, 1.0)
  ctx.save()
  ctx.rectangle(12.0, 18.0, 96.0, 64.0)
  ctx.clip()
  ctx.set_source_rgba(0.10, 0.30, 0.92, 0.92)
  ctx.mask(mask)
  ctx.restore()
}

///|
fn render_stream_state_stack_scene(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(11.0)

  let mut root_id = @cairoon.PDF_OUTLINE_ROOT
  let mut group_id = @cairoon.PDF_OUTLINE_ROOT
  if kind == 0 {
    surface.pdf_set_size(140.0, 90.0)
    surface.pdf_set_page_label("state-clip")
    root_id = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "state clip",
      "page=1 pos=[12 76]",
      @cairoon.PDFOutlineFlagSet::combine([
        @cairoon.PdfOutlineOpen,
        @cairoon.PdfOutlineBold,
      ]),
    )
  }
  ctx.set_source_rgb(0.92, 0.96, 1.0)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Figure", "")
  draw_stream_state_stack_surface_pattern(ctx)
  ctx.tag_end("Figure")
  ctx.tag_begin("P", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/state/clip'")
  ctx.move_to(12.0, 76.0)
  ctx.show_text("clipped source pattern")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()

  if kind == 0 {
    surface.pdf_set_size(120.0, 100.0)
    surface.pdf_set_page_label("state-group")
    group_id = surface.pdf_add_outline_with_flags(
      root_id,
      "state group",
      "page=2 pos=[14 26]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineItalic),
    )
  } else {
    resize_stream_state_stack_surface(kind, surface, 120.0, 100.0)
  }
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("Figure", "")
  draw_stream_state_stack_group(ctx)
  ctx.tag_end("Figure")
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='state-mask-dest'")
  ctx.set_source_rgba(0.95, 0.75, 0.20, 0.82)
  ctx.rectangle(14.0, 76.0, 82.0, 12.0)
  ctx.fill()
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.copy_page()

  if kind == 0 {
    surface.pdf_set_size(120.0, 100.0)
    surface.pdf_set_page_label("state-mask")
    let _ = surface.pdf_add_outline_with_flags(
      group_id,
      "state mask",
      "page=3 pos=[18 88]",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineOpen),
    )
  } else {
    resize_stream_state_stack_surface(kind, surface, 120.0, 100.0)
  }
  draw_stream_state_stack_mask(ctx)
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='state-mask-dest' x=18 y=88")
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin("Span", "")
  ctx.move_to(18.0, 88.0)
  ctx.show_text("masked destination")
  ctx.tag_end("Span")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.show_page()
  surface.finish()
}

///|
test "backend state stack stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_state_stack_file_equivalence_\{kind}.\{ext}"
    let file_surface = make_stream_state_stack_file_surface(kind, path)
    render_stream_state_stack_scene(kind, file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_state_stack_stream_surface(kind, chunks)
    render_stream_state_stack_scene(kind, stream_surface)
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
test "backend state stack file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_state_stack_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_state_stack_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_state_stack_file_surface(kind, path)
    render_stream_state_stack_scene(kind, surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        42,
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
test "backend state stack output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_state_stack_markers_\{kind}.\{ext}"
    let surface = make_stream_state_stack_file_surface(kind, path)
    render_stream_state_stack_scene(kind, surface)
    match kind {
      0 => {
        expect_backend_output_markers(kind, path, 11706, [
          "%PDF-1.4", "/Title (Cairoon State Stack)", "/Subject (clip group mask state stack)",
          "/Creator (cairoon state stack)", "/CreationDate (20260102030405+00'00')",
          "/ModDate (20260102030405+00'00')", "/StateStack (clip-group-mask)", "/Count 3",
          "/MediaBox [ 0 0 140 90 ]", "/MediaBox [ 0 0 120 100 ]", "/PageLabels",
          "(state-clip)", "(state-group)", "(state-mask)", "/Outlines", "/Title (state clip)",
          "/Title (state group)", "/Title (state mask)", "/F 2", "/F 1", "/F 0",
          "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/state/clip)",
          "/Dest", "/Dests", "(state-mask-dest)", "/StructTreeRoot", "/S /Document",
          "/S /Sect", "/S /Figure", "/S /P", "/S /Span", "%%EOF",
        ])
        expect_vector_output_absent(path, ["/Scratch", "drop-me"])
      }
      1 =>
        expect_backend_output_markers(kind, path, 11706, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 3", "%%Title: Cairoon State Stack",
          "%%IncludeFeature: *MediaColor StateBlue", "%%IncludeFeature: *PageSize StateStack",
          "%%Pages: 3", "%%Page: 1 1", "%%Page: 2 2", "%%Page: 3 3", "%%EOF",
        ])
      2 =>
        expect_backend_output_markers(kind, path, 11706, [
          "<?xml version=\"1.0\"", "<svg", "width=\"140cm\" height=\"90cm\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend state stack output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /Figure", "/S /P", "/S /Span", "https://example.com/state/clip",
    "state-mask-dest", "clip-group-mask", "drop-me", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_state_stack_absent_\{kind}.\{ext}"
    let surface = make_stream_state_stack_file_surface(kind, path)
    render_stream_state_stack_scene(kind, surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_state_stack_stream_surface(kind, chunks)
    render_stream_state_stack_scene(kind, stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
