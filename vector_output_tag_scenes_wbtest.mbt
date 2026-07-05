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
  ctx.set_font_size(4.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/'")
  ctx.move_to(1.0, 4.0)
  ctx.show_text("link")
  ctx.tag_end(TAG_LINK)
}

///|
fn draw_pdf_dest_text_tag_scene(ctx : Context) -> Unit raise CairoError {
  ctx.select_font_face("serif")
  ctx.set_font_size(4.0)
  ctx.tag_begin(TAG_LINK, "dest='cairoon-dest'")
  ctx.move_to(1.0, 4.0)
  ctx.show_text("jump")
  ctx.tag_end(TAG_LINK)
  ctx.tag_begin(TAG_DEST, "name='cairoon-dest' x=1 y=7")
  ctx.move_to(1.0, 7.0)
  ctx.show_text("dst")
  ctx.tag_end(TAG_DEST)
}

///|
fn draw_pdf_struct_text_tag_scene(ctx : Context) -> Unit raise CairoError {
  ctx.select_font_face("serif")
  ctx.set_font_size(4.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("H1", "")
  ctx.move_to(1.0, 4.0)
  ctx.show_text("Head")
  ctx.tag_end("H1")
  ctx.tag_begin("P", "")
  ctx.move_to(1.0, 8.0)
  ctx.show_text("Para")
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
fn draw_grouped_glyph_tag_multi_page_scene(
  ctx : Context,
) -> Unit raise CairoError {
  ctx.save()
  ctx.push_group_with_content(ContentColorAlpha)
  let background = Pattern::linear(0.0, 0.0, 10.0, 0.0)
  background.add_color_stop_rgba(0.0, 1.0, 0.0, 0.0, 1.0)
  background.add_color_stop_rgba(1.0, 0.0, 0.0, 1.0, 1.0)
  ctx.rectangle(0.0, 0.0, 10.0, 10.0)
  ctx.set_source(background)
  ctx.fill()
  ctx.set_source_rgba(1.0, 1.0, 1.0, 0.45)
  ctx.arc(5.0, 5.0, 3.0, 0.0, 6.283185307179586)
  ctx.fill()
  let group = ctx.pop_group()
  ctx.translate(1.0, 0.5)
  ctx.scale(0.8, 0.8)
  ctx.set_source(group)
  ctx.paint_with_alpha(0.65)
  ctx.restore()

  ctx.select_font_face("serif")
  ctx.set_font_size(3.0)
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(TAG_LINK, "uri='https://example.com/grouped-glyphs'")
  let first_run = ctx.get_scaled_font().text_to_glyphs(1.0, 6.5, "ffi")
  ctx.show_text_glyphs(
    "ffi",
    first_run.glyphs,
    first_run.clusters,
    flags=first_run.flags,
  )
  ctx.tag_end(TAG_LINK)
  ctx.show_page()

  ctx.set_source_rgb(0.0, 0.35, 0.8)
  ctx.tag_begin(TAG_LINK, "dest='cairoon-grouped-dest'")
  ctx.rectangle(1.0, 1.0, 4.0, 2.0)
  ctx.fill()
  ctx.tag_end(TAG_LINK)

  ctx.set_source_rgb(0.85, 0.1, 0.1)
  ctx.tag_begin(TAG_DEST, "name='cairoon-grouped-dest' x=6 y=3")
  ctx.move_to(6.0, 3.0)
  ctx.show_text("dest")
  ctx.tag_end(TAG_DEST)

  ctx.set_source_rgb(0.1, 0.1, 0.1)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  let second_run = ctx.get_scaled_font().text_to_glyphs(1.0, 8.5, "doc")
  ctx.show_text_glyphs(
    "doc",
    second_run.glyphs,
    second_run.clusters,
    flags=second_run.flags,
  )
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
