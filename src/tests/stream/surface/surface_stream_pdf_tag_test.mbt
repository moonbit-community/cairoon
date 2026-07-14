///|
fn expect_pdf_stream_markers(
  chunks : Array[Bytes],
  markers : Array[String],
) -> Unit raise {
  inspect(chunks.length() > 0, content="true")
  let output = @utf8.decode_lossy(chunks_to_bytes(chunks))
  for marker in markers {
    inspect(output.contains(marker), content="true")
  }
}

///|
test "pdf stream public tag metadata markers stay stable" {
  let chunks : Array[Bytes] = []
  let surface = @cairoon.Surface::pdf_stream(96.0, 72.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
  surface.pdf_set_metadata(
    @cairoon.PdfMetadataTitle,
    "Cairoon Public Stream Tags",
  )
  surface.pdf_set_metadata(@cairoon.PdfMetadataCreator, "cairoon public stream")
  if @cairoon.CAIRO_VERSION >= 11706 {
    surface.pdf_set_custom_metadata(
      "PublicTag",
      Some("stream-marker-regression"),
    )
  }
  surface.pdf_set_page_label("stream-cover")
  let cover_id = surface.pdf_add_outline_with_flags(
    @cairoon.PDF_OUTLINE_ROOT,
    "stream cover",
    "page=1 pos=[8 16]",
    @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineOpen),
  )

  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(8.0)
  ctx.set_source_rgb(0.95, 0.97, 1.0)
  ctx.paint()
  ctx.set_source_rgb(0.0, 0.0, 0.0)
  ctx.tag_begin("Document", "")
  ctx.tag_begin("Sect", "")
  ctx.tag_begin(@cairoon.TAG_LINK, "uri='https://example.com/public-stream'")
  ctx.move_to(8.0, 16.0)
  ctx.show_text("public stream link")
  ctx.tag_end(@cairoon.TAG_LINK)
  ctx.tag_begin(@cairoon.TAG_DEST, "name='public-stream-dest' x=8 y=30")
  ctx.move_to(8.0, 30.0)
  ctx.show_text("public stream destination")
  ctx.tag_end(@cairoon.TAG_DEST)
  ctx.tag_end("Sect")
  ctx.tag_end("Document")
  surface.show_page()

  surface.pdf_set_page_label("stream-final")
  let _ = surface.pdf_add_outline_with_flags(
    cover_id,
    "stream final",
    "page=2 pos=[12 24]",
    @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineBold),
  )
  ctx.set_source_rgb(1.0, 0.94, 0.88)
  ctx.paint()
  ctx.tag_begin(@cairoon.TAG_LINK, "dest='public-stream-dest'")
  ctx.set_source_rgba(0.10, 0.40, 0.75, 0.70)
  ctx.rectangle(12.0, 24.0, 40.0, 18.0)
  ctx.fill()
  ctx.tag_end(@cairoon.TAG_LINK)
  surface.finish()

  if @cairoon.CAIRO_VERSION >= 11706 {
    expect_pdf_stream_markers(chunks, [
      "%PDF-1.4", "/Title (Cairoon Public Stream Tags)", "/Creator (cairoon public stream)",
      "/PublicTag (stream-marker-regression)", "/Count 2", "/PageLabels", "(stream-cover)",
      "(stream-final)", "/Outlines", "/Title (stream cover)", "/Title (stream final)",
      "/Annots [", "/Subtype /Link", "/S /URI", "/URI (https://example.com/public-stream)",
      "/Dest", "/Dests", "(public-stream-dest)", "/StructTreeRoot", "/S /Document",
      "/S /Sect", "%%EOF",
    ])
  } else {
    expect_pdf_stream_markers(chunks, [
      "%PDF-1.4", "/Title (Cairoon Public Stream Tags)", "/Creator (cairoon public stream)",
      "/Count 2", "/PageLabels", "(stream-cover)", "(stream-final)", "/Outlines",
      "/Title (stream cover)", "/Title (stream final)", "%%EOF",
    ])
  }
}
