///|
test "pdf 1.6 typed version follows linked cairo support" {
  let versions = @cairoon.PDFVersion::supported()
  if versions.any(version => version == @cairoon.PdfVersion1_6) {
    inspect(@cairoon.PdfVersion1_6.to_string(), content="PDF 1.6")
  } else {
    match @cairoon.run_cairo(() => @cairoon.PdfVersion1_6.to_string()) {
      Err(@cairoon.CairoError(@cairoon.InvalidStatus, _)) => ()
      _ => @test.fail("expected PDF 1.6 to require linked Cairo support")
    }
  }
}

///|
test "legacy cairo rejects the custom metadata clear path" {
  if @cairoon.CAIRO_VERSION < 11706 {
    let surface = @cairoon.Surface::pdf(10.0, 10.0)
    expect_pdf_invalid_status(
      @cairoon.run_cairo(() => {
        surface.pdf_set_custom_metadata("legacy-clear", None)
      }),
    )
    surface.finish()
  }
}
