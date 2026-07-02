///|
fn expect_pdf_surface_type_mismatch(
  result : Result[Unit, CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn expect_pdf_surface_finished(result : Result[Unit, CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
test "pdf version helpers expose cairo-supported versions" {
  let versions = PDFVersion::supported()
  let version : PDFVersion = PdfVersion1_4
  inspect(versions.length() > 0, content="true")
  inspect(versions.any(item => item == version), content="true")
  inspect(version.to_string().contains("PDF"), content="true")
}

///|
test "pdf surface no-output constructor exposes page and document APIs" {
  let surface = Surface::pdf(10.0, 10.0)
  debug_inspect(surface.get_type(), content="SurfaceTypePdf")
  surface.pdf_restrict_to_version(PdfVersion1_4)
  surface.pdf_set_size(12.0, 14.0)
  surface.pdf_set_metadata(PdfMetadataTitle, "Cairoon PDF")
  surface.pdf_set_custom_metadata("ISBN", Some("978-0123456789"))
  surface.pdf_set_custom_metadata("ISBN", None)
  surface.pdf_set_page_label("page one")
  surface.pdf_set_thumbnail_size(4, 4)
  let outline_kinds : Array[PDFOutlineFlags] = [
    PdfOutlineOpen,
    PdfOutlineBold,
    PdfOutlineItalic,
  ]
  let outline_flags = PDFOutlineFlagSet::combine(outline_kinds[:])
  inspect(outline_flags.bits(), content="7")
  inspect(outline_flags.contains(PdfOutlineOpen), content="true")
  inspect(outline_flags.contains(PdfOutlineBold), content="true")
  inspect(outline_flags.contains(PdfOutlineItalic), content="true")
  inspect(PDFOutlineFlagSet::none().contains(PdfOutlineBold), content="false")
  inspect(PDFOutlineFlagSet::none().add(PdfOutlineItalic).bits(), content="4")
  let outline_id = surface.pdf_add_outline(
    PDF_OUTLINE_ROOT,
    "chapter",
    "page=1 pos=[1 1]",
    PdfOutlineOpen,
  )
  inspect(outline_id > PDF_OUTLINE_ROOT, content="true")
  let combined_outline_id = surface.pdf_add_outline_with_flags(
    PDF_OUTLINE_ROOT,
    "appendix",
    "page=1 pos=[2 2]",
    outline_flags,
  )
  inspect(combined_outline_id > outline_id, content="true")
  surface.finish()

  expect_pdf_surface_finished(run_cairo(() => surface.pdf_set_size(1.0, 1.0)))
  expect_pdf_surface_finished(
    run_cairo(() => surface.pdf_restrict_to_version(PdfVersion1_5)),
  )
}

///|
test "pdf surface validates metadata outline and path strings" {
  let surface = Surface::pdf(10.0, 10.0)
  let page_label = run_cairo(() => surface.pdf_set_page_label("bad\u{0}label"))
  match page_label {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PDF page label")
  }

  let metadata = run_cairo(() => {
    surface.pdf_set_metadata(PdfMetadataTitle, "bad\u{0}metadata")
  })
  match metadata {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PDF metadata")
  }

  let custom_name = run_cairo(() => {
    surface.pdf_set_custom_metadata("bad\u{0}name", Some("value"))
  })
  match custom_name {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PDF custom metadata name")
  }

  let custom_value = run_cairo(() => {
    surface.pdf_set_custom_metadata("ISBN", Some("bad\u{0}value"))
  })
  match custom_value {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PDF custom metadata value")
  }

  let reserved_surface = Surface::pdf(10.0, 10.0)
  let reserved_name = run_cairo(() => {
    reserved_surface.pdf_set_custom_metadata("Author", Some("reserved"))
  })
  inspect(reserved_name is Err(_), content="true")

  let outline = run_cairo(() => {
    let _ = surface.pdf_add_outline_with_flags(
      PDF_OUTLINE_ROOT,
      "bad\u{0}title",
      "page=1",
      PDFOutlineFlagSet::of(PdfOutlineOpen),
    )
    ()
  })
  match outline {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PDF outline title")
  }

  let invalid_path = "/tmp/cairoon\u{0}bad.pdf"
  let invalid = run_cairo(() => {
    let _ = Surface::pdf(10.0, 10.0, path=Some(invalid_path))
    ()
  })
  match invalid {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PDF path")
  }
}

///|
test "pdf surface filename constructor renders and finishes" {
  let path = "/tmp/cairoon_surface_pdf_roundtrip.pdf"
  let surface = Surface::pdf(10.0, 10.0, path=Some(path))
  surface.pdf_set_metadata(PdfMetadataCreator, "cairoon")
  let ctx = Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
test "pdf surface methods reject other surface types" {
  let image = Surface::image(Argb32, 1, 1)
  expect_pdf_surface_type_mismatch(
    run_cairo(() => image.pdf_set_size(10.0, 10.0)),
  )
  expect_pdf_surface_type_mismatch(
    run_cairo(() => image.pdf_restrict_to_version(PdfVersion1_4)),
  )
  expect_pdf_surface_type_mismatch(
    run_cairo(() => image.pdf_set_metadata(PdfMetadataTitle, "nope")),
  )
  expect_pdf_surface_type_mismatch(
    run_cairo(() => image.pdf_set_page_label("nope")),
  )
  expect_pdf_surface_type_mismatch(
    run_cairo(() => {
      let _ = image.pdf_add_outline_with_flags(
        PDF_OUTLINE_ROOT,
        "nope",
        "page=1",
        PDFOutlineFlagSet::of(PdfOutlineOpen),
      )
      ()
    }),
  )
}
