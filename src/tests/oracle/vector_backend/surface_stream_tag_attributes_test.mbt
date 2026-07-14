///|
fn make_stream_tag_attribute_file_surface(
  kind : Int,
  path : String,
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 => @cairoon.Surface::pdf(144.0, 120.0, path=Some(path))
    1 => @cairoon.Surface::ps(144.0, 120.0, path=Some(path))
    2 => @cairoon.Surface::svg(144.0, 120.0, path=Some(path))
    _ => vector_backend_invalid_surface()
  }
  configure_stream_tag_attribute_backend(kind, surface)
  surface
}

///|
fn make_stream_tag_attribute_stream_surface(
  kind : Int,
  chunks : Array[Bytes],
) -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = match kind {
    0 =>
      @cairoon.Surface::pdf_stream(144.0, 120.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    1 =>
      @cairoon.Surface::ps_stream(144.0, 120.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    2 =>
      @cairoon.Surface::svg_stream(144.0, 120.0, fn(chunk) {
        chunks.push(chunk)
        @cairoon.Success
      })
    _ => vector_backend_invalid_surface()
  }
  configure_stream_tag_attribute_backend(kind, surface)
  surface
}

///|
fn configure_stream_tag_attribute_backend(
  kind : Int,
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  match kind {
    0 => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataTitle,
        "Cairoon Tag Attribute Matrix",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreator,
        "cairoon tag attribute matrix",
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataCreateDate,
        fixed_pdf_metadata_date(),
      )
      surface.pdf_set_metadata(
        @cairoon.PdfMetadataModDate,
        fixed_pdf_metadata_date(),
      )
    }
    1 => {
      surface.ps_restrict_to_level(@cairoon.PsLevel3)
      surface.ps_dsc_begin_setup()
      surface.ps_dsc_comment("%%Title: Cairoon Tag Attribute Matrix")
      surface.ps_dsc_begin_page_setup()
      surface.ps_dsc_comment("%%IncludeFeature: *MediaType TagAttributes")
    }
    2 => {
      surface.svg_restrict_to_version(@cairoon.SvgVersion1_2)
      surface.svg_set_document_unit(@cairoon.SvgUnitPx)
    }
    _ => @cairoon.check_status(@cairoon.InvalidStatus)
  }
}

///|
fn draw_tag_attribute_text(
  ctx : @cairoon.Context,
  x : Double,
  y : Double,
  text : String,
) -> Unit raise @cairoon.CairoError {
  ctx.move_to(x, y)
  ctx.show_text(text)
}

///|
fn render_stream_tag_attribute_scene(
  surface : @cairoon.Surface,
) -> Unit raise @cairoon.CairoError {
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(8.0)

  ctx.set_source_rgb(0.96, 0.97, 1.0)
  ctx.paint()
  ctx.set_source_rgb(0.04, 0.04, 0.04)

  ctx.tag_begin(
    @cairoon.TAG_CONTENT,
    "tag_name='H1' id='tag-attribute-heading'",
  )
  draw_tag_attribute_text(ctx, 10.0, 16.0, "tag attribute matrix")
  ctx.tag_end(@cairoon.TAG_CONTENT)

  ctx.tag_begin(@cairoon.TAG_CONTENT, "tag_name='P' id='tag-attribute-body'")
  draw_tag_attribute_text(ctx, 10.0, 104.0, "content reference body")
  ctx.tag_end(@cairoon.TAG_CONTENT)

  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "rect=[10 28 52 12 72 28 58 12] uri='https://example.com/tag-attributes'",
  )
  draw_tag_attribute_text(ctx, 12.0, 36.0, "uri rect one")
  draw_tag_attribute_text(ctx, 74.0, 36.0, "uri rect two")
  ctx.tag_end(@cairoon.TAG_LINK)

  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "rect=[10 48 52 10] dest='tag-attribute-target'",
  )
  draw_tag_attribute_text(ctx, 12.0, 55.0, "named target")
  ctx.tag_end(@cairoon.TAG_LINK)

  ctx.tag_begin(@cairoon.TAG_LINK, "rect=[72 48 58 10] page=2 pos=[18 44]")
  draw_tag_attribute_text(ctx, 74.0, 55.0, "page position")
  ctx.tag_end(@cairoon.TAG_LINK)

  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "rect=[10 66 52 10] file='external.pdf' page=3 pos=[12 34]",
  )
  draw_tag_attribute_text(ctx, 12.0, 73.0, "file page")
  ctx.tag_end(@cairoon.TAG_LINK)

  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "rect=[72 66 58 10] file='external.pdf' dest='appendix'",
  )
  draw_tag_attribute_text(ctx, 74.0, 73.0, "file destination")
  ctx.tag_end(@cairoon.TAG_LINK)

  ctx.tag_begin(
    @cairoon.TAG_LINK,
    "rect=[10 84 52 10] dest='tag-attribute-extent'",
  )
  draw_tag_attribute_text(ctx, 12.0, 91.0, "extent target")
  ctx.tag_end(@cairoon.TAG_LINK)

  ctx.tag_begin("Document", "")
  ctx.tag_begin("H1", "")
  ctx.tag_begin(@cairoon.TAG_CONTENT_REF, "ref='tag-attribute-heading'")
  ctx.tag_end(@cairoon.TAG_CONTENT_REF)
  ctx.tag_end("H1")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.tag_begin(@cairoon.TAG_CONTENT_REF, "ref='tag-attribute-body'")
  ctx.tag_end(@cairoon.TAG_CONTENT_REF)
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()

  ctx.set_source_rgb(0.94, 1.0, 0.95)
  ctx.paint()
  ctx.set_source_rgb(0.04, 0.04, 0.04)
  ctx.tag_begin(
    @cairoon.TAG_DEST,
    "name='tag-attribute-target' x=18 y=44 internal",
  )
  draw_tag_attribute_text(ctx, 18.0, 44.0, "internal destination")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='tag-attribute-extent'")
  draw_tag_attribute_text(ctx, 18.0, 72.0, "extent destination")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.show_page()
  surface.finish()
}

///|
fn expect_tag_attribute_error(
  tag_name : String,
  attributes : String,
) -> Unit raise {
  let ctx = @cairoon.Context::new(@cairoon.Surface::pdf(32.0, 32.0))
  let result = @cairoon.run_cairo(() => {
    ctx.tag_begin(tag_name, attributes)
    ctx.show_page()
  })
  match result {
    Err(@cairoon.CairoError(@cairoon.TagError, _)) => ()
    _ => @test.fail("expected TagError")
  }
}

///|
test "tag attribute matrix invalid attributes map to TagError" {
  expect_tag_attribute_error(
    @cairoon.TAG_LINK,
    "uri='https://example.com' rect=[1 2 3]",
  )
  expect_tag_attribute_error(
    @cairoon.TAG_LINK,
    "uri='https://example.com' page=2",
  )
  expect_tag_attribute_error(@cairoon.TAG_DEST, "x=1 y=2")
  expect_tag_attribute_error(@cairoon.TAG_CONTENT, "id='missing-tag-name'")
  expect_tag_attribute_error(@cairoon.TAG_CONTENT_REF, "")
  expect_tag_attribute_error("UnknownStructure", "")

  let nested = @cairoon.Context::new(@cairoon.Surface::pdf(32.0, 32.0))
  let nested_result = @cairoon.run_cairo(() => {
    nested.tag_begin(@cairoon.TAG_CONTENT, "tag_name='P' id='nested-content'")
    nested.tag_begin("Span", "")
    nested.show_page()
  })
  match nested_result {
    Err(@cairoon.CairoError(@cairoon.TagError, _)) => ()
    _ => @test.fail("expected nested content TagError")
  }
}

///|
test "backend tag attribute matrix stream output matches file output after normalization" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tag_attributes_file_\{kind}.\{ext}"
    let file_surface = make_stream_tag_attribute_file_surface(kind, path)
    render_stream_tag_attribute_scene(file_surface)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_tag_attribute_stream_surface(kind, chunks)
    render_stream_tag_attribute_scene(stream_surface)
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
test "backend tag attribute matrix file output matches direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tag_attributes_file_oracle_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_stream_tag_attributes_direct_oracle_\{kind}.\{ext}"
    let surface = make_stream_tag_attribute_file_surface(kind, path)
    render_stream_tag_attribute_scene(surface)
    @cairoon.check_status(
      test_render_vector_scene_oracle_ffi(
        kind,
        66,
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
test "backend tag attribute matrix output contains stable markers" {
  for kind in 0..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tag_attributes_markers_\{kind}.\{ext}"
    let surface = make_stream_tag_attribute_file_surface(kind, path)
    render_stream_tag_attribute_scene(surface)
    match kind {
      0 =>
        expect_vector_output(path, [
          "%PDF-1.4", "/Title (Cairoon Tag Attribute Matrix)", "/Creator (cairoon tag attribute matrix)",
          "/Count 2", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/tag-attributes)",
          "/S /GoToR", "/F (external.pdf)", "/StructTreeRoot", "/S /Document", "/S /H1",
          "/S /Sect", "/S /P", "%%EOF",
        ])
      1 =>
        expect_vector_output(path, [
          "%!PS-Adobe-3.0", "%%LanguageLevel: 2", "%%Title: Cairoon Tag Attribute Matrix",
          "%%IncludeFeature: *MediaType TagAttributes", "%%Pages: 2", "%%Page: 1 1",
          "%%Page: 2 2", "%%EOF",
        ])
      2 =>
        expect_vector_output(path, [
          "<?xml version=\"1.0\"", "<svg", "width=\"144px\" height=\"120px\"", "<pageSet>",
          "<page>", "</pageSet>", "</svg>",
        ])
      _ => ()
    }
  }
}

///|
test "ps svg backend tag attribute matrix omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/S /URI", "/S /GoToR", "/Dest", "/Dests", "/StructTreeRoot",
    "/S /Document", "/S /H1", "/S /Sect", "/S /P", "https://example.com/tag-attributes",
    "external.pdf", "tag-attribute-target", "tag-attribute-heading", "<a ",
  ]
  for kind in 1..<3 {
    let ext = stream_equivalence_extension(kind)
    let path = "/tmp/cairoon_stream_tag_attributes_absent_\{kind}.\{ext}"
    let surface = make_stream_tag_attribute_file_surface(kind, path)
    render_stream_tag_attribute_scene(surface)
    expect_vector_output_absent(path, forbidden)

    let chunks : Array[Bytes] = []
    let stream_surface = make_stream_tag_attribute_stream_surface(kind, chunks)
    render_stream_tag_attribute_scene(stream_surface)
    expect_stream_output_absent(chunks, forbidden)
  }
}
