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
    31 => {
      ctx.set_source_rgb(0.0, 0.0, 1.0)
      ctx.rectangle(1.0, 1.0, 3.0, 8.0)
      ctx.fill()
      ctx.copy_page()
      ctx.set_source_rgb(1.0, 0.0, 0.0)
      ctx.rectangle(1.0, 6.0, 8.0, 3.0)
      ctx.fill()
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
    29 => draw_tagged_show_text_glyphs_scene(ctx)
    30 => draw_grouped_glyph_tag_multi_page_scene(ctx)
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
fn draw_surface_page_retained_scene(surface : Surface) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.rectangle(1.0, 1.0, 3.0, 8.0)
  ctx.fill()
  surface.copy_page()
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.rectangle(1.0, 6.0, 8.0, 3.0)
  ctx.fill()
  surface.show_page()
}

///|
fn render_surface_page_retained_scene(
  kind : Int,
  path : String,
) -> Unit raise CairoError {
  let surface = vector_oracle_surface(kind, path)
  draw_surface_page_retained_scene(surface)
  surface.finish()
}

///|
fn draw_surface_show_page_cleared_scene(
  surface : Surface,
) -> Unit raise CairoError {
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.rectangle(1.0, 1.0, 3.0, 8.0)
  ctx.fill()
  surface.show_page()
  ctx.set_source_rgb(1.0, 0.0, 0.0)
  ctx.rectangle(1.0, 6.0, 8.0, 3.0)
  ctx.fill()
  surface.show_page()
}

///|
fn render_surface_show_page_cleared_scene(
  kind : Int,
  path : String,
) -> Unit raise CairoError {
  let surface = vector_oracle_surface(kind, path)
  draw_surface_show_page_cleared_scene(surface)
  surface.finish()
}

///|
fn render_pdf_document_feature_surface(
  surface : Surface,
) -> Unit raise CairoError {
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
fn render_pdf_document_feature_scene(path : String) -> Unit raise CairoError {
  let surface = Surface::pdf(100.0, 100.0, path=Some(path))
  render_pdf_document_feature_surface(surface)
}

///|
fn render_ps_dsc_multipage_surface(surface : Surface) -> Unit raise CairoError {
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
}

///|
fn render_svg_unit_multipage_surface(
  surface : Surface,
) -> Unit raise CairoError {
  surface.svg_restrict_to_version(SvgVersion1_2)
  surface.svg_set_document_unit(SvgUnitPx)
  let ctx = Context::new(surface)
  paint_page(ctx, 0.0, 0.0, 1.0)
  ctx.show_page()
  paint_page(ctx, 1.0, 0.0, 0.0)
  ctx.show_page()
  surface.finish()
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
