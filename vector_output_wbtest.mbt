///|
fn expect_vector_output(path : String, markers : Array[String]) -> Unit raise {
  let filename = checked_path_bytes(path)
  inspect(test_file_size_ffi(filename) > 0, content="true")
  for marker in markers {
    inspect(
      test_file_contains_ffi(filename, @utf8.encode(marker)),
      content="true",
    )
  }
}

///|
fn expect_vector_output_bytes(path : String, marker : Bytes) -> Unit raise {
  let filename = checked_path_bytes(path)
  inspect(test_file_size_ffi(filename) > 0, content="true")
  inspect(test_file_contains_ffi(filename, marker), content="true")
}

///|
fn expect_vector_output_absent(
  path : String,
  markers : Array[String],
) -> Unit raise {
  let filename = checked_path_bytes(path)
  inspect(test_file_size_ffi(filename) > 0, content="true")
  for marker in markers {
    inspect(
      test_file_contains_ffi(filename, @utf8.encode(marker)),
      content="false",
    )
  }
}

///|
fn fixed_pdf_metadata_date() -> String {
  "2026-01-02T03:04:05+00:00"
}

///|
fn tiny_jpeg_payload() -> Bytes {
  let data : FixedArray[Byte] = [
    b'\xFF', b'\xD8', b'\xFF', b'\xE0', b'\x00', b'\x10', b'\x4A', b'\x46', b'\x49',
    b'\x46', b'\x00', b'\x01', b'\x01', b'\x01', b'\x00', b'\x48', b'\x00', b'\x48',
    b'\x00', b'\x00', b'\xFF', b'\xDB', b'\x00', b'\x43', b'\x00', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01',
    b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\x01', b'\xFF',
    b'\xC2', b'\x00', b'\x0B', b'\x08', b'\x00', b'\x01', b'\x00', b'\x01', b'\x01',
    b'\x01', b'\x11', b'\x00', b'\xFF', b'\xC4', b'\x00', b'\x14', b'\x00', b'\x01',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x09', b'\xFF', b'\xDA',
    b'\x00', b'\x08', b'\x01', b'\x01', b'\x00', b'\x00', b'\x00', b'\x01', b'\x7F',
    b'\x3F', b'\xFF', b'\xC4', b'\x00', b'\x14', b'\x10', b'\x01', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xDA', b'\x00', b'\x08',
    b'\x01', b'\x01', b'\x00', b'\x01', b'\x05', b'\x02', b'\x7F', b'\xFF', b'\xC4',
    b'\x00', b'\x14', b'\x10', b'\x01', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\xFF', b'\xDA', b'\x00', b'\x08', b'\x01', b'\x01', b'\x00',
    b'\x06', b'\x3F', b'\x02', b'\x7F', b'\xFF', b'\xC4', b'\x00', b'\x14', b'\x10',
    b'\x01', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF',
    b'\xDA', b'\x00', b'\x08', b'\x01', b'\x01', b'\x00', b'\x01', b'\x3F', b'\x21',
    b'\x7F', b'\xFF', b'\xDA', b'\x00', b'\x08', b'\x01', b'\x01', b'\x00', b'\x00',
    b'\x00', b'\x10', b'\x7F', b'\xFF', b'\xC4', b'\x00', b'\x14', b'\x10', b'\x01',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xDA',
    b'\x00', b'\x08', b'\x01', b'\x01', b'\x00', b'\x01', b'\x3F', b'\x10', b'\x7F',
    b'\xFF', b'\xD9',
  ]
  Bytes::from_array(data)
}

///|
fn vector_output_extension(kind : Int) -> String {
  match kind {
    0 => "pdf"
    1 => "ps"
    2 => "svg"
    _ => "out"
  }
}

///|
fn expect_vector_outputs_equal(
  kind : Int,
  left_path : String,
  right_path : String,
) -> Unit raise {
  inspect(
    test_vector_files_equal_ffi(
      kind,
      checked_path_bytes(left_path),
      checked_path_bytes(right_path),
    ),
    content="true",
  )
}

///|
fn expect_vector_oracle_match(
  kind : Int,
  scene : Int,
  cairoon_path : String,
  oracle_path : String,
) -> Unit raise {
  check_status(
    test_render_vector_scene_oracle_ffi(
      kind,
      scene,
      checked_path_bytes(oracle_path),
    ),
  )
  inspect(
    test_vector_files_equal_ffi(
      kind,
      checked_path_bytes(cairoon_path),
      checked_path_bytes(oracle_path),
    ),
    content="true",
  )
}

///|
fn vector_oracle_surface(kind : Int, path : String) -> Surface raise CairoError {
  match kind {
    0 => {
      let surface = Surface::pdf(10.0, 10.0, path=Some(path))
      surface.pdf_restrict_to_version(PdfVersion1_4)
      surface.pdf_set_metadata(PdfMetadataCreator, "cairoon-vector-oracle")
      surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
      surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
      surface
    }
    1 => Surface::ps(10.0, 10.0, path=Some(path))
    2 => Surface::svg(10.0, 10.0, path=Some(path))
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn paint_quad_source_surface(surface : Surface) -> Unit raise CairoError {
  let source_ctx = Context::new(surface)
  source_ctx.set_source_rgb(1.0, 0.0, 0.0)
  source_ctx.rectangle(0.0, 0.0, 1.0, 1.0)
  source_ctx.fill()
  source_ctx.set_source_rgb(0.0, 1.0, 0.0)
  source_ctx.rectangle(1.0, 0.0, 1.0, 1.0)
  source_ctx.fill()
  source_ctx.set_source_rgb(0.0, 0.0, 1.0)
  source_ctx.rectangle(0.0, 1.0, 1.0, 1.0)
  source_ctx.fill()
  source_ctx.set_source_rgb(1.0, 1.0, 1.0)
  source_ctx.rectangle(1.0, 1.0, 1.0, 1.0)
  source_ctx.fill()
}

///|
fn apply_vector_surface_pattern(ctx : Context) -> Unit raise CairoError {
  let source = Surface::image(Argb32, 2, 2)
  paint_quad_source_surface(source)
  let pattern = Pattern::for_surface(source)
  pattern.set_extend(Repeat)
  pattern.set_filter(Nearest)
  ctx.rectangle(0.0, 0.0, 10.0, 10.0)
  ctx.set_source(pattern)
  ctx.fill()
}

///|
fn apply_vector_mask_surface(ctx : Context) -> Unit raise CairoError {
  let mask = Surface::image(Argb32, 2, 2)
  let mask_ctx = Context::new(mask)
  mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
  mask_ctx.rectangle(0.0, 0.0, 1.0, 1.0)
  mask_ctx.fill()
  mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 0.5)
  mask_ctx.rectangle(1.0, 0.0, 1.0, 1.0)
  mask_ctx.fill()
  mask_ctx.set_source_rgba(1.0, 1.0, 1.0, 1.0)
  mask_ctx.rectangle(1.0, 1.0, 1.0, 1.0)
  mask_ctx.fill()
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.mask_surface(mask, x=4.0, y=4.0)
}

///|
fn apply_vector_mesh_pattern(ctx : Context) -> Unit raise CairoError {
  let pattern = Pattern::mesh()
  pattern.mesh_begin_patch()
  pattern.mesh_move_to(0.0, 0.0)
  pattern.mesh_line_to(10.0, 0.0)
  pattern.mesh_line_to(10.0, 10.0)
  pattern.mesh_line_to(0.0, 10.0)
  pattern.mesh_set_corner_color_rgba(0, 1.0, 0.0, 0.0, 1.0)
  pattern.mesh_set_corner_color_rgba(1, 0.0, 1.0, 0.0, 1.0)
  pattern.mesh_set_corner_color_rgba(2, 0.0, 0.0, 1.0, 0.75)
  pattern.mesh_set_corner_color_rgba(3, 1.0, 1.0, 0.0, 1.0)
  pattern.mesh_end_patch()
  ctx.rectangle(0.0, 0.0, 10.0, 10.0)
  ctx.set_source(pattern)
  ctx.fill()
}

///|
fn draw_pdf_uri_tag_scene(ctx : Context) -> Unit raise CairoError {
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/direct'")
  ctx.rectangle(1.0, 1.0, 8.0, 8.0)
  ctx.fill()
  ctx.tag_end(TAG_LINK)
}

///|
fn draw_pdf_dest_tag_scene(ctx : Context) -> Unit raise CairoError {
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.tag_begin(TAG_LINK, "dest='cairoon-direct-dest'")
  ctx.rectangle(1.0, 1.0, 3.0, 3.0)
  ctx.fill()
  ctx.tag_end(TAG_LINK)

  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.tag_begin(TAG_DEST, "name='cairoon-direct-dest' x=6 y=6")
  ctx.rectangle(6.0, 6.0, 3.0, 3.0)
  ctx.fill()
  ctx.tag_end(TAG_DEST)
}

///|
fn draw_pdf_struct_tag_scene(ctx : Context) -> Unit raise CairoError {
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.rectangle(1.0, 1.0, 8.0, 2.0)
  ctx.fill()
  ctx.tag_end("H1")

  ctx.tag_begin("P", "")
  ctx.set_source_rgb(0.25, 0.25, 0.25)
  ctx.rectangle(1.0, 5.0, 8.0, 3.0)
  ctx.fill()
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
}

///|
fn draw_pdf_uri_text_tag_scene(ctx : Context) -> Unit raise CairoError {
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/'")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("example link")
  ctx.tag_end(TAG_LINK)
}

///|
fn draw_pdf_dest_text_tag_scene(ctx : Context) -> Unit raise CairoError {
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.tag_begin(TAG_LINK, "dest='cairoon-dest'")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("jump to destination")
  ctx.tag_end(TAG_LINK)
  ctx.tag_begin(TAG_DEST, "name='cairoon-dest' x=10 y=60")
  ctx.move_to(10.0, 60.0)
  ctx.show_text("destination")
  ctx.tag_end(TAG_DEST)
}

///|
fn draw_pdf_struct_text_tag_scene(ctx : Context) -> Unit raise CairoError {
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("Heading")
  ctx.tag_end("H1")
  ctx.tag_begin("P", "")
  ctx.move_to(10.0, 40.0)
  ctx.show_text("Paragraph")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
}

///|
fn draw_vector_oracle_scene(
  ctx : Context,
  scene : Int,
) -> Unit raise CairoError {
  match scene {
    0 => {
      ctx.set_source_rgb(0.0, 0.0, 1.0)
      ctx.paint()
    }
    1 => {
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.set_line_width(1.5)
      ctx.move_to(1.5, 1.5)
      ctx.line_to(8.5, 8.5)
      ctx.stroke()
    }
    2 => {
      ctx.rectangle(2.0, 2.0, 6.0, 6.0)
      ctx.set_source_rgba(0.0, 1.0, 0.0, 0.75)
      ctx.fill_preserve()
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.set_line_width(1.0)
      ctx.stroke()
    }
    3 => {
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.set_line_width(1.25)
      ctx.move_to(1.0, 9.0)
      ctx.curve_to(3.0, 1.0, 7.0, 9.0, 9.0, 1.0)
      ctx.stroke()
    }
    4 => {
      ctx.translate(5.0, 5.0)
      ctx.rotate(0.25)
      ctx.scale(1.2, 0.8)
      ctx.rectangle(-3.0, -2.0, 6.0, 4.0)
      ctx.set_source_rgb(1.0, 0.5, 0.0)
      ctx.fill()
    }
    5 => {
      let pattern = Pattern::linear(0.0, 0.0, 10.0, 0.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 0.0, 0.0, 1.0)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 1.0)
      ctx.rectangle(0.0, 0.0, 10.0, 10.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    6 => {
      let pattern = Pattern::radial(5.0, 5.0, 1.0, 5.0, 5.0, 5.0)
      pattern.add_color_stop_rgba(0.0, 1.0, 1.0, 1.0, 1.0)
      pattern.add_color_stop_rgba(1.0, 0.0, 0.0, 0.0, 1.0)
      ctx.rectangle(0.0, 0.0, 10.0, 10.0)
      ctx.set_source(pattern)
      ctx.fill()
    }
    7 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(4.0)
      ctx.move_to(1.0, 6.5)
      ctx.text_path("Hi")
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.fill()
    }
    8 => {
      ctx.select_font_face("serif")
      ctx.set_font_size(4.0)
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.move_to(1.0, 6.5)
      ctx.show_text("Hi")
    }
    9 => {
      paint_page(ctx, 0.0, 0.0, 1.0)
      ctx.show_page()
      paint_page(ctx, 1.0, 0.0, 0.0)
      ctx.show_page()
    }
    10 => {
      ctx.rectangle(1.0, 1.0, 8.0, 8.0)
      ctx.clip()
      ctx.set_source_rgb(0.0, 1.0, 0.0)
      ctx.paint()
    }
    11 => {
      ctx.set_source_rgb(0.0, 0.0, 0.0)
      ctx.set_line_width(1.0)
      ctx.set_line_cap(LineCapRound)
      ctx.set_dash([1.0, 1.5], offset=0.5)
      ctx.move_to(1.0, 5.0)
      ctx.line_to(9.0, 5.0)
      ctx.stroke()
    }
    12 => apply_vector_surface_pattern(ctx)
    13 => apply_vector_mask_surface(ctx)
    14 => apply_vector_mesh_pattern(ctx)
    15 => draw_pdf_uri_tag_scene(ctx)
    16 => draw_pdf_dest_tag_scene(ctx)
    17 => draw_pdf_struct_tag_scene(ctx)
    22 => draw_pdf_uri_text_tag_scene(ctx)
    23 => draw_pdf_dest_text_tag_scene(ctx)
    24 => draw_pdf_struct_text_tag_scene(ctx)
    _ => raise CairoInvalidArgument(InvalidStatus, InvalidStatus.message())
  }
}

///|
fn render_vector_oracle_scene(
  kind : Int,
  scene : Int,
  path : String,
) -> Unit raise CairoError {
  let surface = vector_oracle_surface(kind, path)
  let ctx = Context::new(surface)
  draw_vector_oracle_scene(ctx, scene)
  surface.finish()
}

///|
fn render_pdf_document_feature_scene(path : String) -> Unit raise CairoError {
  let surface = Surface::pdf(100.0, 100.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Combined Oracle")
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon-combined-oracle")
  surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
  surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
  surface.pdf_set_custom_metadata("ISBN", Some("978-0123456789"))
  surface.pdf_set_page_label("intro")
  let _ = surface.pdf_add_outline_with_flags(
    PDF_OUTLINE_ROOT,
    "intro page",
    "page=1 pos=[10 20]",
    PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold][:]),
  )

  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/combined'")
  ctx.rectangle(10.0, 10.0, 80.0, 20.0)
  ctx.fill()
  ctx.tag_end(TAG_LINK)

  ctx.set_source_rgb(0.0, 0.5, 0.0)
  ctx.tag_begin(TAG_LINK, "dest='combined-direct-dest'")
  ctx.rectangle(10.0, 40.0, 80.0, 20.0)
  ctx.fill()
  ctx.tag_end(TAG_LINK)

  ctx.show_page()
  surface.pdf_set_page_label("details")
  let _ = surface.pdf_add_outline_with_flags(
    PDF_OUTLINE_ROOT,
    "details page",
    "page=2 pos=[10 60]",
    PDFOutlineFlagSet::of(PdfOutlineItalic),
  )

  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.tag_begin(TAG_DEST, "name='combined-direct-dest' x=10 y=60")
  ctx.rectangle(10.0, 10.0, 80.0, 20.0)
  ctx.fill()
  ctx.tag_end(TAG_DEST)

  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.set_source_rgb(0.25, 0.25, 0.25)
  ctx.rectangle(10.0, 50.0, 80.0, 30.0)
  ctx.fill()
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")

  ctx.show_page()
  surface.finish()
}

///|
fn fill_link_rect(ctx : Context, tagged : Bool) -> Unit raise CairoError {
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  if tagged {
    ctx.tag_begin(TAG_LINK, "uri='https://example.com/'")
  }
  ctx.rectangle(1.0, 1.0, 8.0, 8.0)
  ctx.fill()
  if tagged {
    ctx.tag_end(TAG_LINK)
  }
}

///|
fn paint_page(
  ctx : Context,
  red : Double,
  green : Double,
  blue : Double,
) -> Unit raise CairoError {
  ctx.set_source_rgb(red, green, blue)
  ctx.paint()
}

///|
test "pdf output contains stable structural markers" {
  let path = "/tmp/cairoon_vector_output.pdf"
  let oracle_path = "/tmp/cairoon_vector_output_oracle.pdf"
  let surface = Surface::pdf(10.0, 10.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon-vector-oracle")
  surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
  surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, ["%PDF-1.4", "/Root", "/Info", "%%EOF"])
  expect_vector_oracle_match(0, 0, path, oracle_path)
}

///|
test "pdf output contains metadata and custom metadata markers" {
  let path = "/tmp/cairoon_vector_pdf_metadata.pdf"
  let surface = Surface::pdf(10.0, 10.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Title")
  surface.pdf_set_metadata(PdfMetadataAuthor, "Cairoon Author")
  surface.pdf_set_metadata(PdfMetadataSubject, "Cairoon Subject")
  surface.pdf_set_metadata(PdfMetadataKeywords, "moonbit cairo ffi")
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon metadata test")
  surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
  surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
  surface.pdf_set_custom_metadata("ISBN", Some("978-0123456789"))
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "%PDF-1.4", "/Title (Cairoon Title)", "/Author (Cairoon Author)", "/Subject (Cairoon Subject)",
    "/Keywords (moonbit cairo ffi)", "/Creator (cairoon metadata test)", "/CreationDate (20260102030405+00'00')",
    "/ModDate (20260102030405+00'00')", "/ISBN (978-0123456789)", "%%EOF",
  ])
}

///|
test "pdf output contains page label and outline markers" {
  let path = "/tmp/cairoon_vector_pdf_outline.pdf"
  let surface = Surface::pdf(20.0, 20.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_page_label("intro")
  let outline_id = surface.pdf_add_outline_with_flags(
    PDF_OUTLINE_ROOT,
    "chapter one",
    "page=1 pos=[3 4]",
    PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold][:]),
  )
  inspect(outline_id > PDF_OUTLINE_ROOT, content="true")
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "%PDF-1.4", "/PageLabels", "(intro)", "/Outlines", "/Title (chapter one)", "/Count 1",
    "/F 2", "%%EOF",
  ])
}

///|
test "pdf output contains page thumbnail markers" {
  let path = "/tmp/cairoon_vector_pdf_thumbnail.pdf"
  let surface = Surface::pdf(20.0, 20.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_thumbnail_size(4, 4)
  let ctx = Context::new(surface)
  paint_page(ctx, 0.0, 0.0, 1.0)
  surface.finish()
  expect_vector_output(path, [
    "%PDF-1.4", "/Thumb", "/Subtype /Image", "/Width 4", "/Height 4", "%%EOF",
  ])
}

///|
test "pdf output contains multi-page markers" {
  let path = "/tmp/cairoon_vector_pdf_multipage.pdf"
  let surface = Surface::pdf(12.0, 12.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon multipage test")
  surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
  surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
  let ctx = Context::new(surface)
  paint_page(ctx, 0.0, 0.0, 1.0)
  ctx.show_page()
  paint_page(ctx, 1.0, 0.0, 0.0)
  ctx.show_page()
  surface.finish()
  expect_vector_output(path, [
    "%PDF-1.4", "/Count 2", "/Type /Page % 1", "/Type /Page % 2", "%%EOF",
  ])
}

///|
test "pdf output preserves metadata outlines labels and tags across pages" {
  let path = "/tmp/cairoon_vector_pdf_combined_document.pdf"
  let oracle_path = "/tmp/cairoon_vector_pdf_combined_document_oracle.pdf"
  let surface = Surface::pdf(100.0, 100.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Combined")
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon combined test")
  surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
  surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
  surface.pdf_set_custom_metadata("ISBN", Some("978-0123456789"))
  surface.pdf_set_page_label("intro")
  let intro_id = surface.pdf_add_outline_with_flags(
    PDF_OUTLINE_ROOT,
    "intro page",
    "page=1 pos=[10 20]",
    PDFOutlineFlagSet::combine([PdfOutlineOpen, PdfOutlineBold][:]),
  )
  inspect(intro_id > PDF_OUTLINE_ROOT, content="true")
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/combined'")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("combined intro")
  ctx.tag_end(TAG_LINK)
  ctx.show_page()
  surface.pdf_set_page_label("details")
  let details_id = surface.pdf_add_outline_with_flags(
    PDF_OUTLINE_ROOT,
    "details page",
    "page=2 pos=[10 60]",
    PDFOutlineFlagSet::of(PdfOutlineItalic),
  )
  inspect(details_id > intro_id, content="true")
  ctx.tag_begin(TAG_DEST, "name='combined-dest' x=10 y=60")
  ctx.move_to(10.0, 60.0)
  ctx.show_text("destination")
  ctx.tag_end(TAG_DEST)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.move_to(10.0, 80.0)
  ctx.show_text("combined structure")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()
  surface.finish()
  expect_vector_output(path, [
    "%PDF-1.4", "/Title (Cairoon Combined)", "/Creator (cairoon combined test)",
    "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
    "/ISBN (978-0123456789)", "/Count 2", "/PageLabels", "(intro)", "(details)",
    "/Outlines", "/Title (intro page)", "/Title (details page)", "/F 2", "/F 1",
    "/Annots [", "/Subtype /Link", "/URI (https://example.com/combined)", "/Names",
    "/Dests", "(combined-dest)", "/StructTreeRoot", "/S /Document", "/S /Sect", "/S /P",
    "%%EOF",
  ])
  expect_vector_oracle_match(0, 21, path, oracle_path)
}

///|
test "pdf link tag output contains annotation markers" {
  let path = "/tmp/cairoon_vector_tag_output.pdf"
  let surface = Surface::pdf(100.0, 100.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/'")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("example link")
  ctx.tag_end(TAG_LINK)
  surface.finish()
  expect_vector_output(path, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/)",
    "/S /Link", "/StructTreeRoot", "%%EOF",
  ])
}

///|
test "pdf destination tag output contains named destination markers" {
  let path = "/tmp/cairoon_vector_dest_tag_output.pdf"
  let surface = Surface::pdf(100.0, 100.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.tag_begin(TAG_LINK, "dest='cairoon-dest'")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("jump to destination")
  ctx.tag_end(TAG_LINK)
  ctx.tag_begin(TAG_DEST, "name='cairoon-dest' x=10 y=60")
  ctx.move_to(10.0, 60.0)
  ctx.show_text("destination")
  ctx.tag_end(TAG_DEST)
  surface.finish()
  expect_vector_output(path, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/Dest", "/Names", "/Dests", "(cairoon-dest)",
    "/StructTreeRoot", "%%EOF",
  ])
}

///|
test "pdf document structure tags output structure tree markers" {
  let path = "/tmp/cairoon_vector_structure_tag_output.pdf"
  let surface = Surface::pdf(100.0, 100.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("Heading")
  ctx.tag_end("H1")
  ctx.tag_begin("P", "")
  ctx.move_to(10.0, 40.0)
  ctx.show_text("Paragraph")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.finish()
  expect_vector_output(path, [
    "%PDF-1.4", "/StructTreeRoot", "/MarkInfo << /Marked true >>", "/Type /StructElem",
    "/S /Document", "/S /Sect", "/S /H1", "/S /P", "/StructParents 0", "%%EOF",
  ])
}

///|
test "pdf output embeds jpeg mime data from image source" {
  let path = "/tmp/cairoon_vector_pdf_jpeg_mime.pdf"
  let jpeg = tiny_jpeg_payload()
  let surface = Surface::pdf(3.0, 3.0, path=Some(path))
  inspect(surface.supports_mime_type(MIME_TYPE_JPEG), content="true")
  let ctx = Context::new(surface)
  let image = Surface::image(Rgb24, 1, 1)
  image.set_mime_data(MIME_TYPE_JPEG, Some(jpeg))
  ctx.set_source_surface(image)
  ctx.paint()
  surface.finish()
  expect_vector_output_bytes(path, jpeg)
}

///|
test "ps output contains stable page and drawing markers" {
  let path = "/tmp/cairoon_vector_output.ps"
  let oracle_path = "/tmp/cairoon_vector_output_oracle.ps"
  let surface = Surface::ps(10.0, 10.0, path=Some(path))
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "%!PS-Adobe-3.0", "%%Pages: 1", "0 0 1 rg", "0 0 10 10 rectfill", "%%EOF",
  ])
  expect_vector_oracle_match(1, 0, path, oracle_path)
}

///|
test "ps output contains multi-page markers" {
  let path = "/tmp/cairoon_vector_ps_multipage.ps"
  let surface = Surface::ps(12.0, 12.0, path=Some(path))
  let ctx = Context::new(surface)
  paint_page(ctx, 0.0, 0.0, 1.0)
  ctx.show_page()
  paint_page(ctx, 1.0, 0.0, 0.0)
  ctx.show_page()
  surface.finish()
  expect_vector_output(path, [
    "%!PS-Adobe-3.0", "%%Pages: 2", "%%Page: 1 1", "%%Page: 2 2", "0 0 1 rg", "1 0 0 rg",
    "%%EOF",
  ])
}

///|
test "ps output preserves dsc comments across multiple pages" {
  let path = "/tmp/cairoon_vector_ps_dsc_multipage.ps"
  let oracle_path = "/tmp/cairoon_vector_ps_dsc_multipage_oracle.ps"
  let surface = Surface::ps(12.0, 12.0, path=Some(path))
  surface.ps_restrict_to_level(PsLevel2)
  surface.ps_dsc_begin_setup()
  surface.ps_dsc_comment("%%Title: Cairoon PS Combined")
  surface.ps_dsc_comment("%%IncludeFeature: *MediaColor White")
  surface.ps_dsc_begin_page_setup()
  surface.ps_dsc_comment("%%IncludeFeature: *PageSize A4")
  let ctx = Context::new(surface)
  paint_page(ctx, 0.0, 0.0, 1.0)
  ctx.show_page()
  surface.ps_dsc_begin_page_setup()
  surface.ps_dsc_comment("%%IncludeFeature: *MediaType Plain")
  paint_page(ctx, 1.0, 0.0, 0.0)
  ctx.show_page()
  surface.finish()
  expect_vector_output(path, [
    "%!PS-Adobe-3.0", "%%LanguageLevel: 2", "%%Title: Cairoon PS Combined", "%%IncludeFeature: *MediaColor White",
    "%%IncludeFeature: *PageSize A4", "%%IncludeFeature: *MediaType Plain", "%%Pages: 2",
    "%%Page: 1 1", "%%Page: 2 2", "0 0 1 rg", "1 0 0 rg", "%%EOF",
  ])
  expect_vector_oracle_match(1, 19, path, oracle_path)
}

///|
test "ps link tags are inert for postscript output" {
  let plain_path = "/tmp/cairoon_vector_ps_plain_tag_scene.ps"
  let tagged_path = "/tmp/cairoon_vector_ps_tag_scene.ps"
  let plain = Surface::ps(10.0, 10.0, path=Some(plain_path))
  fill_link_rect(Context::new(plain), false)
  plain.finish()
  let tagged = Surface::ps(10.0, 10.0, path=Some(tagged_path))
  fill_link_rect(Context::new(tagged), true)
  tagged.finish()
  expect_vector_outputs_equal(1, tagged_path, plain_path)
  expect_vector_output_absent(tagged_path, [
    "https://example.com/", "/Subtype /Link", "/URI",
  ])
}

///|
test "svg output contains stable geometry and color markers" {
  let path = "/tmp/cairoon_vector_output.svg"
  let oracle_path = "/tmp/cairoon_vector_output_oracle.svg"
  let surface = Surface::svg(10.0, 10.0, path=Some(path))
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, [
    "<?xml version=\"1.0\"", "<svg", "width=\"10\" height=\"10\"", "fill=\"rgb(0%, 0%, 100%)\"",
    "</svg>",
  ])
  expect_vector_oracle_match(2, 0, path, oracle_path)
}

///|
test "svg output contains multi-page markers" {
  let path = "/tmp/cairoon_vector_svg_multipage.svg"
  let surface = Surface::svg(12.0, 12.0, path=Some(path))
  let ctx = Context::new(surface)
  paint_page(ctx, 0.0, 0.0, 1.0)
  ctx.show_page()
  paint_page(ctx, 1.0, 0.0, 0.0)
  ctx.show_page()
  surface.finish()
  expect_vector_output(path, [
    "<?xml version=\"1.0\"", "<svg", "width=\"12\" height=\"12\"", "<pageSet>", "<page>",
    "fill=\"rgb(0%, 0%, 100%)\"", "fill=\"rgb(100%, 0%, 0%)\"", "</pageSet>", "</svg>",
  ])
}

///|
test "svg output preserves version unit and page markers" {
  let path = "/tmp/cairoon_vector_svg_unit_multipage.svg"
  let oracle_path = "/tmp/cairoon_vector_svg_unit_multipage_oracle.svg"
  let surface = Surface::svg(12.0, 12.0, path=Some(path))
  surface.svg_restrict_to_version(SvgVersion1_2)
  surface.svg_set_document_unit(SvgUnitPx)
  debug_inspect(surface.svg_get_document_unit(), content="SvgUnitPx")
  let ctx = Context::new(surface)
  paint_page(ctx, 0.0, 0.0, 1.0)
  ctx.show_page()
  paint_page(ctx, 1.0, 0.0, 0.0)
  ctx.show_page()
  surface.finish()
  expect_vector_output(path, [
    "<?xml version=\"1.0\"", "<svg", "width=\"12px\" height=\"12px\"", "<pageSet>",
    "<page>", "fill=\"rgb(0%, 0%, 100%)\"", "fill=\"rgb(100%, 0%, 0%)\"", "</pageSet>",
    "</svg>",
  ])
  expect_vector_oracle_match(2, 20, path, oracle_path)
}

///|
test "vector output scenes match direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    for scene in 0..<10 {
      let cairoon_path = "/tmp/cairoon_vector_scene_\{kind}_\{scene}.\{ext}"
      let oracle_path = "/tmp/cairoon_vector_scene_\{kind}_\{scene}_oracle.\{ext}"
      render_vector_oracle_scene(kind, scene, cairoon_path)
      expect_vector_oracle_match(kind, scene, cairoon_path, oracle_path)
    }
  }
}

///|
test "complex vector output scenes match direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    for scene in 10..<15 {
      let cairoon_path = "/tmp/cairoon_vector_complex_scene_\{kind}_\{scene}.\{ext}"
      let oracle_path = "/tmp/cairoon_vector_complex_scene_\{kind}_\{scene}_oracle.\{ext}"
      render_vector_oracle_scene(kind, scene, cairoon_path)
      expect_vector_oracle_match(kind, scene, cairoon_path, oracle_path)
    }
  }
}

///|
test "pdf tag output scenes match direct cairo C oracle" {
  for scene in 15..<18 {
    let cairoon_path = "/tmp/cairoon_vector_pdf_tag_scene_\{scene}.pdf"
    let oracle_path = "/tmp/cairoon_vector_pdf_tag_scene_\{scene}_oracle.pdf"
    render_vector_oracle_scene(0, scene, cairoon_path)
    expect_vector_oracle_match(0, scene, cairoon_path, oracle_path)
  }
}

///|
test "pdf text tag output scenes match direct cairo C oracle" {
  for scene in 22..<25 {
    let cairoon_path = "/tmp/cairoon_vector_pdf_text_tag_scene_\{scene}.pdf"
    let oracle_path = "/tmp/cairoon_vector_pdf_text_tag_scene_\{scene}_oracle.pdf"
    render_vector_oracle_scene(0, scene, cairoon_path)
    expect_vector_oracle_match(0, scene, cairoon_path, oracle_path)
  }
}

///|
test "ps svg link tag scenes match direct cairo C oracle" {
  for kind in 1..<3 {
    let ext = vector_output_extension(kind)
    let cairoon_path = "/tmp/cairoon_vector_link_tag_scene_\{kind}.\{ext}"
    let oracle_path = "/tmp/cairoon_vector_link_tag_scene_\{kind}_oracle.\{ext}"
    render_vector_oracle_scene(kind, 15, cairoon_path)
    expect_vector_oracle_match(kind, 15, cairoon_path, oracle_path)
  }
}

///|
test "svg document structure tag scene matches direct cairo C oracle" {
  let cairoon_path = "/tmp/cairoon_vector_svg_struct_tag_scene.svg"
  let oracle_path = "/tmp/cairoon_vector_svg_struct_tag_scene_oracle.svg"
  render_vector_oracle_scene(2, 17, cairoon_path)
  expect_vector_oracle_match(2, 17, cairoon_path, oracle_path)
}

///|
test "pdf document feature scene matches direct cairo C oracle" {
  let cairoon_path = "/tmp/cairoon_vector_pdf_document_features.pdf"
  let oracle_path = "/tmp/cairoon_vector_pdf_document_features_oracle.pdf"
  render_pdf_document_feature_scene(cairoon_path)
  expect_vector_oracle_match(0, 18, cairoon_path, oracle_path)
}

///|
test "svg link tags are inert for svg output" {
  let plain_path = "/tmp/cairoon_vector_svg_plain_tag_scene.svg"
  let tagged_path = "/tmp/cairoon_vector_svg_tag_scene.svg"
  let plain = Surface::svg(10.0, 10.0, path=Some(plain_path))
  fill_link_rect(Context::new(plain), false)
  plain.finish()
  let tagged = Surface::svg(10.0, 10.0, path=Some(tagged_path))
  fill_link_rect(Context::new(tagged), true)
  tagged.finish()
  expect_vector_outputs_equal(2, tagged_path, plain_path)
  expect_vector_output_absent(tagged_path, [
    "https://example.com/", "xlink:href=", "<a ",
  ])
}
