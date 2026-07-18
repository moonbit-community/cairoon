///|
fn render_pdf_page_operation_document_feature_surface(
  surface : @cairoon.Surface,
) -> (Int, Int) raise @cairoon.CairoError {
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Page Ops")
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon page ops test")
  surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
  surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
  set_pdf_custom_metadata_if_supported(surface, "Case", Some("copy-show"))
  surface.pdf_set_page_label("copy-intro")
  let intro_id = surface.pdf_add_outline_with_flags(
    @cairoon.PDF_OUTLINE_ROOT,
    "copy intro",
    "page=1 pos=[10 20]",
    @cairoon.PDFOutlineFlagSet::of(PdfOutlineOpen),
  )
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/page-op'")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("copy intro")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='page-op-dest'")
  ctx.move_to(10.0, 40.0)
  ctx.show_text("jump")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.copy_page()
  surface.pdf_set_page_label("copy-details")
  let details_id = surface.pdf_add_outline_with_flags(
    @cairoon.PDF_OUTLINE_ROOT,
    "copy details",
    "page=2 pos=[10 60]",
    @cairoon.PDFOutlineFlagSet::of(PdfOutlineItalic),
  )
  ctx.set_source_rgb(0.8, 0.0, 0.0)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='page-op-dest' x=10 y=60")
  ctx.move_to(10.0, 60.0)
  ctx.show_text("destination")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.set_source_rgb(0.1, 0.1, 0.1)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin("P", "")
  ctx.move_to(10.0, 80.0)
  ctx.show_text("retained copy page")
  ctx.tag_end("P")
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  ctx.show_page()
  surface.finish()
  (intro_id, details_id)
}

///|
fn render_pdf_page_operation_document_feature_scene(
  path : String,
) -> (Int, Int) raise @cairoon.CairoError {
  let surface = @cairoon.Surface::pdf(100.0, 100.0, path=Some(path))
  render_pdf_page_operation_document_feature_surface(surface)
}
