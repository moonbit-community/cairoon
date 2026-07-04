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
test "pdf copy_page retained output contains two page markers" {
  let path = "/tmp/cairoon_vector_pdf_copy_page_retained.pdf"
  render_vector_oracle_scene(0, 31, path)
  expect_vector_output(path, [
    "%PDF-1.4", "/Count 2", "/Type /Page % 1", "/Type /Page % 2", "%%EOF",
  ])
}

///|
test "pdf surface copy_page retained output contains two page markers" {
  let path = "/tmp/cairoon_vector_pdf_surface_copy_page_retained.pdf"
  render_surface_page_retained_scene(0, path)
  expect_vector_output(path, [
    "%PDF-1.4", "/Count 2", "/Type /Page % 1", "/Type /Page % 2", "%%EOF",
  ])
}

///|
test "pdf surface show_page cleared output contains two page markers" {
  let path = "/tmp/cairoon_vector_pdf_surface_show_page_cleared.pdf"
  render_surface_show_page_cleared_scene(0, path)
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
test "pdf tagged multi-page text output contains structure markers" {
  let path = "/tmp/cairoon_vector_pdf_tagged_multipage_text_markers.pdf"
  render_vector_oracle_scene(0, 25, path)
  expect_vector_output(path, [
    "%PDF-1.4", "/Count 2", "/Type /Page % 1", "/Type /Page % 2", "/Annots [", "/Subtype /Link",
    "/S /URI", "/URI (https://example.com/multipage)", "/Dest", "(cairoon-multi-dest)",
    "/Type /StructElem", "/S /Link", "/S /Document", "/S /Sect", "/S /P", "/StructTreeRoot",
    "/Names", "/Dests", "%%EOF",
  ])
}

///|
test "pdf mixed vector tag text output contains combined tag markers" {
  let path = "/tmp/cairoon_vector_pdf_mixed_tag_text_markers.pdf"
  render_vector_oracle_scene(0, 26, path)
  expect_vector_output(path, [
    "%PDF-1.4", "/Type /Page % 1", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/mixed)",
    "/Dest (cairoon-mixed-dest)", "/Names", "/Dests", "(cairoon-mixed-dest)", "/StructTreeRoot",
    "/Type /StructElem", "/S /Link", "/S /Document", "/S /Sect", "/S /P", "/StructParents 0",
    "%%EOF",
  ])
}

///|
test "pdf tagged show_text_glyphs output contains link markers" {
  let path = "/tmp/cairoon_vector_pdf_tagged_text_glyphs_markers.pdf"
  render_vector_oracle_scene(0, 29, path)
  expect_vector_output(path, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/text-glyphs)",
    "/S /Link", "/StructTreeRoot", "%%EOF",
  ])
}

///|
test "pdf grouped glyph tag multi-page output contains combined markers" {
  let path = "/tmp/cairoon_vector_pdf_grouped_glyph_tag_markers.pdf"
  render_vector_oracle_scene(0, 30, path)
  expect_vector_output(path, [
    "%PDF-1.4", "/Count 2", "/Type /Page % 1", "/Type /Page % 2", "/Annots [", "/Subtype /Link",
    "/S /URI", "/URI (https://example.com/grouped-glyphs)", "/Dest (cairoon-grouped-dest)",
    "/Names", "/Dests", "(cairoon-grouped-dest)", "/StructTreeRoot", "/Type /StructElem",
    "/S /Link", "/S /Document", "/S /Sect", "/S /P", "%%EOF",
  ])
}

///|
test "ps svg mixed vector tag text output omits pdf tag metadata" {
  let forbidden = [
    "/Annots", "/Subtype /Link", "/URI", "/Dest", "/Dests", "/StructTreeRoot", "/S /Document",
    "/S /Sect", "/S /P", "cairoon-mixed-dest", "https://example.com/mixed", "<a ",
  ]
  for kind in 1..<3 {
    let ext = vector_output_extension(kind)
    let path = "/tmp/cairoon_vector_backend_mixed_tag_absent_\{kind}.\{ext}"
    render_vector_oracle_scene(kind, 26, path)
    expect_vector_output_absent(path, forbidden)
  }
}

///|
test "pdf output embeds jpeg mime data from image source" {
  let path = "/tmp/cairoon_vector_pdf_jpeg_mime.pdf"
  let jpeg = tiny_jpeg_payload()
  let support_surface = Surface::pdf(3.0, 3.0)
  inspect(support_surface.supports_mime_type(MIME_TYPE_JPEG), content="true")
  support_surface.finish()
  render_pdf_jpeg_mime_scene(path, jpeg)
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
  render_ps_dsc_multipage_surface(surface)
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
  render_svg_unit_multipage_surface(surface)
  expect_vector_output(path, [
    "<?xml version=\"1.0\"", "<svg", "width=\"12px\" height=\"12px\"", "<pageSet>",
    "<page>", "fill=\"rgb(0%, 0%, 100%)\"", "fill=\"rgb(100%, 0%, 0%)\"", "</pageSet>",
    "</svg>",
  ])
  expect_vector_oracle_match(2, 20, path, oracle_path)
}
