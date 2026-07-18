///|
test "pdf output contains stable structural markers" {
  let path = "/tmp/cairoon_vector_output.pdf"
  let oracle_path = "/tmp/cairoon_vector_output_oracle.pdf"
  let surface = @cairoon.Surface::pdf(10.0, 10.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon-vector-oracle")
  surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
  surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_vector_output(path, ["%PDF-1.4", "/Root", "/Info", "%%EOF"])
  expect_vector_oracle_match(0, 0, path, oracle_path)
}

///|
test "pdf output contains metadata and custom metadata markers" {
  let path = "/tmp/cairoon_vector_pdf_metadata.pdf"
  let surface = @cairoon.Surface::pdf(10.0, 10.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon Title")
  surface.pdf_set_metadata(PdfMetadataAuthor, "Cairoon Author")
  surface.pdf_set_metadata(PdfMetadataSubject, "Cairoon Subject")
  surface.pdf_set_metadata(PdfMetadataKeywords, "moonbit cairo ffi")
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon metadata test")
  surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
  surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
  set_pdf_custom_metadata_if_supported(surface, "ISBN", Some("978-0123456789"))
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
  expect_backend_output_markers(0, path, 11706, [
    "%PDF-1.4", "/Title (Cairoon Title)", "/Author (Cairoon Author)", "/Subject (Cairoon Subject)",
    "/Keywords (moonbit cairo ffi)", "/Creator (cairoon metadata test)", "/CreationDate (20260102030405+00'00')",
    "/ModDate (20260102030405+00'00')", "/ISBN (978-0123456789)", "%%EOF",
  ])
}

///|
test "pdf output contains page label and outline markers" {
  let path = "/tmp/cairoon_vector_pdf_outline.pdf"
  let surface = @cairoon.Surface::pdf(20.0, 20.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_page_label("intro")
  let outline_id = surface.pdf_add_outline_with_flags(
    @cairoon.PDF_OUTLINE_ROOT,
    "chapter one",
    "page=1 pos=[3 4]",
    @cairoon.PDFOutlineFlagSet::combine(
      [@cairoon.PdfOutlineOpen, PdfOutlineBold][:],
    ),
  )
  inspect(outline_id > @cairoon.PDF_OUTLINE_ROOT, content="true")
  let ctx = @cairoon.Context::new(surface)
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
  render_pdf_thumbnail_scene(path)
  expect_vector_output(path, [
    "%PDF-1.4", "/Thumb", "/Subtype /Image", "/Width 4", "/Height 4", "%%EOF",
  ])
}

///|
test "pdf output contains multi-page markers" {
  let path = "/tmp/cairoon_vector_pdf_multipage.pdf"
  let surface = @cairoon.Surface::pdf(12.0, 12.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon multipage test")
  surface.pdf_set_metadata(PdfMetadataCreateDate, fixed_pdf_metadata_date())
  surface.pdf_set_metadata(PdfMetadataModDate, fixed_pdf_metadata_date())
  let ctx = @cairoon.Context::new(surface)
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
  let (intro_id, details_id) = render_pdf_text_document_feature_scene(path)
  inspect(intro_id > @cairoon.PDF_OUTLINE_ROOT, content="true")
  inspect(details_id > intro_id, content="true")
  expect_backend_output_markers(0, path, 11706, [
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
test "pdf direct document feature output contains combined markers" {
  let path = "/tmp/cairoon_vector_pdf_direct_document_markers.pdf"
  render_pdf_document_feature_scene(path)
  expect_backend_output_markers(0, path, 11706, [
    "%PDF-1.4", "/Title (Cairoon Combined Oracle)", "/Creator (cairoon-combined-oracle)",
    "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
    "/ISBN (978-0123456789)", "/Count 2", "/Type /Page % 1", "/Type /Page % 2", "/PageLabels",
    "(intro)", "(details)", "/Outlines", "/Title (intro page)", "/Title (details page)",
    "/F 2", "/F 1", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/combined)",
    "/Dest", "/Names", "/Dests", "(combined-direct-dest)", "/StructTreeRoot", "/S /Link",
    "/S /Document", "/S /Sect", "/S /P", "%%EOF",
  ])
}

///|
test "pdf page operation document feature output contains retained markers" {
  let path = "/tmp/cairoon_vector_pdf_page_operation_document.pdf"
  let (intro_id, details_id) = render_pdf_page_operation_document_feature_scene(
    path,
  )
  inspect(intro_id > @cairoon.PDF_OUTLINE_ROOT, content="true")
  inspect(details_id > intro_id, content="true")
  expect_backend_output_markers(0, path, 11706, [
    "%PDF-1.4", "/Title (Cairoon Page Ops)", "/Creator (cairoon page ops test)",
    "/CreationDate (20260102030405+00'00')", "/ModDate (20260102030405+00'00')",
    "/Case (copy-show)", "/Count 2", "/PageLabels", "(copy-intro)", "(copy-details)",
    "/Outlines", "/Title (copy intro)", "/Title (copy details)", "/Annots [", "/Subtype /Link",
    "/S /URI", "/URI (https://example.com/page-op)", "/Dest", "/Names", "/Dests",
    "(page-op-dest)", "/StructTreeRoot", "/S /Document", "/S /Sect", "/S /P", "%%EOF",
  ])
}

///|
test "pdf link tag output contains annotation markers" {
  let path = "/tmp/cairoon_vector_tag_output.pdf"
  let surface = @cairoon.Surface::pdf(100.0, 100.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/'")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("example link")
  ctx.tag_end(@cairoon.TAG_LINK)
  surface.finish()
  expect_backend_output_markers(0, path, 11600, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/)",
    "/S /Link", "/StructTreeRoot", "%%EOF",
  ])
}

///|
test "pdf destination tag output contains named destination markers" {
  let path = "/tmp/cairoon_vector_dest_tag_output.pdf"
  let surface = @cairoon.Surface::pdf(100.0, 100.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='cairoon-dest'")
  ctx.move_to(10.0, 20.0)
  ctx.show_text("jump to destination")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='cairoon-dest' x=10 y=60")
  ctx.move_to(10.0, 60.0)
  ctx.show_text("destination")
  ctx.tag_end(@cairoon.TAG_DEST)
  surface.finish()
  expect_backend_output_markers(0, path, 11600, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/Dest", "/Names", "/Dests", "(cairoon-dest)",
    "/StructTreeRoot", "%%EOF",
  ])
}

///|
test "pdf document structure tags output structure tree markers" {
  let path = "/tmp/cairoon_vector_structure_tag_output.pdf"
  let surface = @cairoon.Surface::pdf(100.0, 100.0, path=Some(path))
  surface.pdf_restrict_to_version(PdfVersion1_4)
  let ctx = @cairoon.Context::new(surface)
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
test "pdf rectangle tag oracle scenes contain tag markers" {
  let uri_path = "/tmp/cairoon_vector_pdf_rectangle_uri_tag_markers.pdf"
  render_vector_oracle_scene(0, 15, uri_path)
  expect_backend_output_markers(0, uri_path, 11600, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/direct)",
    "/S /Link", "/StructTreeRoot", "%%EOF",
  ])

  let dest_path = "/tmp/cairoon_vector_pdf_rectangle_dest_tag_markers.pdf"
  render_vector_oracle_scene(0, 16, dest_path)
  expect_backend_output_markers(0, dest_path, 11600, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/Dest", "/Names", "/Dests", "(cairoon-direct-dest)",
    "/StructTreeRoot", "%%EOF",
  ])

  let structure_path = "/tmp/cairoon_vector_pdf_rectangle_structure_tag_markers.pdf"
  render_vector_oracle_scene(0, 17, structure_path)
  expect_backend_output_markers(0, structure_path, 11600, [
    "%PDF-1.4", "/StructTreeRoot", "/MarkInfo << /Marked true >>", "/Type /StructElem",
    "/S /Document", "/S /Sect", "/S /H1", "/S /P", "/StructParents 0", "%%EOF",
  ])
}

///|
test "pdf text tag oracle scenes contain tag markers" {
  let uri_path = "/tmp/cairoon_vector_pdf_text_uri_tag_markers.pdf"
  render_vector_oracle_scene(0, 22, uri_path)
  expect_backend_output_markers(0, uri_path, 11600, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/)",
    "/S /Link", "/StructTreeRoot", "%%EOF",
  ])

  let dest_path = "/tmp/cairoon_vector_pdf_text_dest_tag_markers.pdf"
  render_vector_oracle_scene(0, 23, dest_path)
  expect_backend_output_markers(0, dest_path, 11600, [
    "%PDF-1.4", "/Annots [", "/Subtype /Link", "/Dest", "/Names", "/Dests", "(cairoon-dest)",
    "/StructTreeRoot", "%%EOF",
  ])

  let structure_path = "/tmp/cairoon_vector_pdf_text_structure_tag_markers.pdf"
  render_vector_oracle_scene(0, 24, structure_path)
  expect_backend_output_markers(0, structure_path, 11600, [
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
  expect_backend_output_markers(0, path, 11600, [
    "%PDF-1.4", "/Type /Page % 1", "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/mixed)",
    "/Dest", "/Names", "/Dests", "(cairoon-mixed-dest)", "/StructTreeRoot", "/Type /StructElem",
    "/S /Link", "/S /Document", "/S /Sect", "/S /P", "/StructParents 0", "%%EOF",
  ])
}

///|
test "pdf tagged show_text_glyphs output contains link markers" {
  let path = "/tmp/cairoon_vector_pdf_tagged_text_glyphs_markers.pdf"
  render_vector_oracle_scene(0, 29, path)
  expect_backend_output_markers(0, path, 11600, [
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
    "/S /URI", "/URI (https://example.com/grouped-glyphs)", "/Dest", "/Names", "/Dests",
    "(cairoon-grouped-dest)", "/StructTreeRoot", "/Type /StructElem", "/S /Link",
    "/S /Document", "/S /Sect", "/S /P", "%%EOF",
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
  let support_surface = @cairoon.Surface::pdf(3.0, 3.0)
  inspect(
    support_surface.supports_mime_type(@cairoon.MIME_TYPE_JPEG),
    content="true",
  )
  support_surface.finish()
  render_pdf_jpeg_mime_scene(path, jpeg)
  expect_vector_output_bytes(path, jpeg)
}
