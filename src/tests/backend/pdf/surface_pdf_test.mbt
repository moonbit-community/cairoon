///|
fn expect_pdf_surface_type_mismatch(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn expect_pdf_surface_finished(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
test "pdf version helpers expose cairo-supported versions" {
  let versions = @cairoon.PDFVersion::supported()
  let version : @cairoon.PDFVersion = @cairoon.PdfVersion1_4
  inspect(versions.length() > 0, content="true")
  inspect(versions.any(item => item == version), content="true")
  inspect(version.to_string().contains("PDF"), content="true")
  inspect(@cairoon.PDFVersion::to_string_raw(0).contains("PDF"), content="true")
  match @cairoon.run_cairo(() => @cairoon.PDFVersion::to_string_raw(-1)) {
    Err(@cairoon.CairoError(@cairoon.InvalidStatus, _)) => ()
    _ => @test.fail("expected InvalidStatus for invalid raw PDF version")
  }
}

///|
test "pdf surface exposes pycairo-compatible raw C-int backend enums" {
  let surface = @cairoon.Surface::pdf(10.0, 10.0)
  surface.pdf_restrict_to_version_raw(0)
  surface.pdf_set_metadata_raw(4, "cairoon raw creator")
  let flags = @cairoon.PDFOutlineFlagSet::from_bits(0x03)
  inspect(flags.bits(), content="3")
  inspect(flags.contains(@cairoon.PdfOutlineOpen), content="true")
  inspect(flags.contains(@cairoon.PdfOutlineBold), content="true")
  inspect(flags.contains(@cairoon.PdfOutlineItalic), content="false")
  let outline_id = surface.pdf_add_outline_raw(
    @cairoon.PDF_OUTLINE_ROOT,
    "raw chapter",
    "page=1 pos=[3 3]",
    0x03,
  )
  inspect(outline_id > @cairoon.PDF_OUTLINE_ROOT, content="true")
  surface.finish()
  expect_pdf_surface_finished(
    @cairoon.run_cairo(() => surface.pdf_restrict_to_version_raw(0)),
  )
}

///|
test "pdf surface no-output constructor exposes page and document APIs" {
  let surface = @cairoon.Surface::pdf(10.0, 10.0)
  debug_inspect(surface.get_type(), content="SurfaceTypePdf")
  surface.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
  surface.pdf_set_size(12.0, 14.0)
  surface.pdf_set_metadata(@cairoon.PdfMetadataTitle, "Cairoon PDF")
  surface.pdf_set_custom_metadata("ISBN", Some("978-0123456789"))
  surface.pdf_set_custom_metadata("ISBN", None)
  surface.pdf_set_page_label("page one")
  surface.pdf_set_thumbnail_size(4, 4)
  let outline_kinds : Array[@cairoon.PDFOutlineFlags] = [
    @cairoon.PdfOutlineOpen,
    @cairoon.PdfOutlineBold,
    @cairoon.PdfOutlineItalic,
  ]
  let outline_flags = @cairoon.PDFOutlineFlagSet::combine(outline_kinds[:])
  inspect(outline_flags.bits(), content="7")
  inspect(outline_flags.contains(@cairoon.PdfOutlineOpen), content="true")
  inspect(outline_flags.contains(@cairoon.PdfOutlineBold), content="true")
  inspect(outline_flags.contains(@cairoon.PdfOutlineItalic), content="true")
  inspect(
    @cairoon.PDFOutlineFlagSet::none().contains(@cairoon.PdfOutlineBold),
    content="false",
  )
  inspect(
    @cairoon.PDFOutlineFlagSet::none().add(@cairoon.PdfOutlineItalic).bits(),
    content="4",
  )
  let outline_id = surface.pdf_add_outline(
    @cairoon.PDF_OUTLINE_ROOT,
    "chapter",
    "page=1 pos=[1 1]",
    @cairoon.PdfOutlineOpen,
  )
  inspect(outline_id > @cairoon.PDF_OUTLINE_ROOT, content="true")
  let combined_outline_id = surface.pdf_add_outline_with_flags(
    @cairoon.PDF_OUTLINE_ROOT,
    "appendix",
    "page=1 pos=[2 2]",
    outline_flags,
  )
  inspect(combined_outline_id > outline_id, content="true")
  surface.finish()

  expect_pdf_surface_finished(
    @cairoon.run_cairo(() => surface.pdf_set_size(1.0, 1.0)),
  )
  expect_pdf_surface_finished(
    @cairoon.run_cairo(() => {
      surface.pdf_restrict_to_version(@cairoon.PdfVersion1_5)
    }),
  )
  expect_pdf_surface_finished(
    @cairoon.run_cairo(() => surface.pdf_set_page_label("after finish")),
  )
  expect_pdf_surface_finished(
    @cairoon.run_cairo(() => {
      surface.pdf_set_metadata(@cairoon.PdfMetadataAuthor, "after finish")
    }),
  )
  expect_pdf_surface_finished(
    @cairoon.run_cairo(() => {
      surface.pdf_set_custom_metadata("ISBN", Some("after-finish"))
    }),
  )
  expect_pdf_surface_finished(
    @cairoon.run_cairo(() => {
      let _ = surface.pdf_add_outline_with_flags(
        @cairoon.PDF_OUTLINE_ROOT,
        "after finish",
        "page=1",
        outline_flags,
      )
      ()
    }),
  )
}

///|
test "pdf thumbnail size mirrors pycairo reset and finished-status fixture" {
  let surface = @cairoon.Surface::pdf(128.0, 128.0)
  surface.pdf_set_thumbnail_size(10, 10)
  surface.pdf_set_thumbnail_size(0, 0)
  surface.pdf_set_thumbnail_size(1, 1)
  surface.finish()

  expect_pdf_surface_finished(
    @cairoon.run_cairo(() => surface.pdf_set_thumbnail_size(0, 0)),
  )
}

///|
test "pdf surface validates metadata outline and path strings" {
  let surface = @cairoon.Surface::pdf(10.0, 10.0)
  let page_label = @cairoon.run_cairo(() => {
    surface.pdf_set_page_label("bad\u{0}label")
  })
  match page_label {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PDF page label")
  }

  let metadata = @cairoon.run_cairo(() => {
    surface.pdf_set_metadata(@cairoon.PdfMetadataTitle, "bad\u{0}metadata")
  })
  match metadata {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PDF metadata")
  }

  let custom_name = @cairoon.run_cairo(() => {
    surface.pdf_set_custom_metadata("bad\u{0}name", Some("value"))
  })
  match custom_name {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PDF custom metadata name")
  }

  let custom_value = @cairoon.run_cairo(() => {
    surface.pdf_set_custom_metadata("ISBN", Some("bad\u{0}value"))
  })
  match custom_value {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PDF custom metadata value")
  }

  let reserved_surface = @cairoon.Surface::pdf(10.0, 10.0)
  let reserved_name = @cairoon.run_cairo(() => {
    reserved_surface.pdf_set_custom_metadata("Author", Some("reserved"))
  })
  inspect(reserved_name is Err(_), content="true")
  match reserved_name {
    Err(@cairoon.CairoInvalidArgument(status, message)) => {
      inspect(status == @cairoon.InvalidString, content="true")
      inspect(message == @cairoon.InvalidString.message(), content="true")
      inspect(message.length() > 0, content="true")
    }
    _ =>
      @test.fail("expected InvalidString for reserved PDF custom metadata name")
  }

  let outline = @cairoon.run_cairo(() => {
    let _ = surface.pdf_add_outline_with_flags(
      @cairoon.PDF_OUTLINE_ROOT,
      "bad\u{0}title",
      "page=1",
      @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineOpen),
    )
    ()
  })
  match outline {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PDF outline title")
  }

  let invalid_path = "/tmp/cairoon\u{0}bad.pdf"
  let invalid = @cairoon.run_cairo(() => {
    let _ = @cairoon.Surface::pdf(10.0, 10.0, path=Some(invalid_path))
    ()
  })
  match invalid {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString for PDF path")
  }
}

///|
test "pdf surface filename constructor renders and finishes" {
  let path = "/tmp/cairoon_surface_pdf_roundtrip.pdf"
  let surface = @cairoon.Surface::pdf(10.0, 10.0, path=Some(path))
  surface.pdf_set_metadata(@cairoon.PdfMetadataCreator, "cairoon")
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  surface.finish()
}

///|
test "pdf surface methods reject other surface types" {
  let image = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  expect_pdf_surface_type_mismatch(
    @cairoon.run_cairo(() => image.pdf_set_size(10.0, 10.0)),
  )
  expect_pdf_surface_type_mismatch(
    @cairoon.run_cairo(() => {
      image.pdf_restrict_to_version(@cairoon.PdfVersion1_4)
    }),
  )
  expect_pdf_surface_type_mismatch(
    @cairoon.run_cairo(() => image.pdf_restrict_to_version_raw(0)),
  )
  expect_pdf_surface_type_mismatch(
    @cairoon.run_cairo(() => {
      image.pdf_set_metadata(@cairoon.PdfMetadataTitle, "nope")
    }),
  )
  expect_pdf_surface_type_mismatch(
    @cairoon.run_cairo(() => image.pdf_set_metadata_raw(0, "nope")),
  )
  expect_pdf_surface_type_mismatch(
    @cairoon.run_cairo(() => image.pdf_set_page_label("nope")),
  )
  expect_pdf_surface_type_mismatch(
    @cairoon.run_cairo(() => {
      let _ = image.pdf_add_outline_with_flags(
        @cairoon.PDF_OUTLINE_ROOT,
        "nope",
        "page=1",
        @cairoon.PDFOutlineFlagSet::of(@cairoon.PdfOutlineOpen),
      )
      ()
    }),
  )
  expect_pdf_surface_type_mismatch(
    @cairoon.run_cairo(() => {
      let _ = image.pdf_add_outline_raw(
        @cairoon.PDF_OUTLINE_ROOT,
        "nope",
        "page=1",
        0x01,
      )
      ()
    }),
  )
}

///|
test "pdf extended surface methods reject other surface types" {
  let image = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  expect_pdf_surface_type_mismatch(
    @cairoon.run_cairo(() => {
      image.pdf_set_custom_metadata("cairoon-key", Some("nope"))
    }),
  )
  expect_pdf_surface_type_mismatch(
    @cairoon.run_cairo(() => image.pdf_set_thumbnail_size(4, 4)),
  )
  expect_pdf_surface_type_mismatch(
    @cairoon.run_cairo(() => {
      let _ = image.pdf_add_outline(
        @cairoon.PDF_OUTLINE_ROOT,
        "nope",
        "page=1",
        @cairoon.PdfOutlineOpen,
      )
      ()
    }),
  )
}
