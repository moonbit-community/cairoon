///|
fn minimal_embedded_jbig2() -> Bytes {
  Bytes::from_array([
    b'\x00', b'\x00', b'\x00', b'\x01', b'\x30', b'\x00', b'\x01', b'\x00', b'\x00',
    b'\x00', b'\x09', b'\x00', b'\x00', b'\x00', b'\x01', b'\x00', b'\x00', b'\x00',
    b'\x01', b'\x00', b'\x00',
  ])
}

///|
test "PDF reports a missing JBIG2 global segment" {
  let result = @cairoon.run_cairo(() => {
    let surface = @cairoon.Surface::pdf_stream(8.0, 8.0, fn(_) { Success })
    let image = @cairoon.Surface::image(A1, 1, 1)
    image.set_mime_data(
      @cairoon.MIME_TYPE_JBIG2,
      Some(minimal_embedded_jbig2()),
    )
    image.set_mime_data(
      @cairoon.MIME_TYPE_JBIG2_GLOBAL_ID,
      Some(@utf8.encode("shared-jbig2-id")),
    )
    let ctx = @cairoon.Context::new(surface)
    ctx.set_source_surface(image)
    ctx.paint()
    surface.finish()
  })
  match result {
    Err(CairoError(Jbig2GlobalMissing, _)) => ()
    _ => @test.fail("expected Jbig2GlobalMissing from PDF finalization")
  }
}
