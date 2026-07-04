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
fn draw_tagged_show_text_glyphs_scene(ctx : Context) -> Unit raise CairoError {
  ctx.select_font_face("serif")
  ctx.set_font_size(4.0)
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/text-glyphs'")
  let run = ctx.get_scaled_font().text_to_glyphs(1.0, 6.5, "a")
  ctx.show_text_glyphs("a", run.glyphs, run.clusters, flags=run.flags)
  ctx.tag_end(TAG_LINK)
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
