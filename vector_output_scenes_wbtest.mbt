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
fn draw_tagged_multi_page_text_scene(ctx : Context) -> Unit raise CairoError {
  ctx.select_font_face("serif")
  ctx.set_font_size(4.0)
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/multipage'")
  ctx.move_to(1.0, 4.0)
  ctx.show_text("one")
  ctx.tag_end(TAG_LINK)
  ctx.show_page()

  ctx.tag_begin(TAG_LINK, "dest='cairoon-multi-dest'")
  ctx.move_to(1.0, 4.0)
  ctx.show_text("two")
  ctx.tag_end(TAG_LINK)
  ctx.tag_begin(TAG_DEST, "name='cairoon-multi-dest' x=1 y=7")
  ctx.move_to(1.0, 7.0)
  ctx.show_text("dst")
  ctx.tag_end(TAG_DEST)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.move_to(1.0, 9.0)
  ctx.show_text("doc")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()
}

///|
fn draw_mixed_tag_vector_scene(ctx : Context) -> Unit raise CairoError {
  ctx.save()
  ctx.rectangle(0.5, 0.5, 9.0, 9.0)
  ctx.clip()
  ctx.set_source_rgba(0.85, 0.9, 1.0, 1.0)
  ctx.paint()
  ctx.restore()

  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.set_line_width(0.75)
  ctx.set_dash([1.0, 0.75], offset=0.25)
  ctx.move_to(1.0, 1.0)
  ctx.line_to(9.0, 1.0)
  ctx.stroke()
  ctx.set_dash([])

  ctx.select_font_face("serif")
  ctx.set_font_size(3.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/mixed'")
  ctx.move_to(1.0, 3.5)
  ctx.show_text("mix")
  ctx.tag_end(TAG_LINK)

  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.tag_begin(TAG_LINK, "dest='cairoon-mixed-dest'")
  ctx.rectangle(1.0, 5.0, 3.0, 2.0)
  ctx.fill()
  ctx.tag_end(TAG_LINK)

  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.tag_begin(TAG_DEST, "name='cairoon-mixed-dest' x=7 y=8")
  ctx.arc(7.0, 8.0, 1.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.tag_end(TAG_DEST)

  ctx.set_source_rgb(0.15, 0.15, 0.15)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.move_to(4.0, 9.0)
  ctx.show_text("doc")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
}

///|
fn draw_layered_multi_page_scene(ctx : Context) -> Unit raise CairoError {
  ctx.save()
  ctx.rectangle(0.75, 0.75, 8.5, 8.5)
  ctx.clip()
  ctx.set_source_rgb(0.8, 0.9, 1.0)
  ctx.paint()
  ctx.restore()

  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.set_line_width(0.75)
  ctx.set_dash([1.0, 0.75], offset=0.25)
  ctx.move_to(1.0, 1.0)
  ctx.line_to(9.0, 3.0)
  ctx.stroke()
  ctx.set_dash([])

  ctx.select_font_face("serif")
  ctx.set_font_size(3.0)
  ctx.move_to(1.0, 8.5)
  ctx.show_text("page one")
  ctx.show_page()

  apply_vector_surface_pattern(ctx)
  apply_vector_mask_surface(ctx)
  ctx.show_page()

  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.select_font_face("serif")
  ctx.set_font_size(3.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/layered'")
  ctx.move_to(1.0, 3.0)
  ctx.show_text("layered link")
  ctx.tag_end(TAG_LINK)

  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.move_to(1.0, 7.0)
  ctx.show_text("layered doc")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()
}

///|
fn draw_wide_multi_page_tag_vector_scene(
  ctx : Context,
) -> Unit raise CairoError {
  ctx.save()
  ctx.rectangle(0.75, 0.75, 8.5, 8.5)
  ctx.clip()
  ctx.set_source_rgb(0.9, 0.92, 1.0)
  ctx.paint()
  ctx.restore()

  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.select_font_face("serif")
  ctx.set_font_size(3.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/wide'")
  ctx.move_to(1.0, 4.0)
  ctx.show_text("wide uri")
  ctx.tag_end(TAG_LINK)
  ctx.show_page()

  apply_vector_surface_pattern(ctx)
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.tag_begin(TAG_LINK, "dest='cairoon-wide-dest'")
  ctx.rectangle(1.0, 1.0, 4.0, 3.0)
  ctx.fill()
  ctx.tag_end(TAG_LINK)
  ctx.show_page()

  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.tag_begin(TAG_DEST, "name='cairoon-wide-dest' x=1 y=5")
  ctx.arc(2.0, 5.0, 1.0, 0.0, 6.283185307179586)
  ctx.fill()
  ctx.tag_end(TAG_DEST)

  ctx.set_source_rgb(0.1, 0.1, 0.1)
  ctx.select_font_face("serif")
  ctx.set_font_size(3.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.move_to(1.0, 8.5)
  ctx.show_text("wide doc")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()
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
    25 => draw_tagged_multi_page_text_scene(ctx)
    26 => draw_mixed_tag_vector_scene(ctx)
    27 => draw_layered_multi_page_scene(ctx)
    28 => draw_wide_multi_page_tag_vector_scene(ctx)
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
