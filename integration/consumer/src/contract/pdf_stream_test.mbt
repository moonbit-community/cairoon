///|
test "consumer finishes PDF stream callbacks" {
  let chunks : Array[Bytes] = []
  let surface = @cairoon.Surface::pdf_stream(24.0, 24.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  surface.with_finished(() => {
    let ctx = @cairoon.Context::new(surface)
    ctx.set_source_rgb(0.0, 0.0, 1.0)
    ctx.paint()
  })

  let pdf = consumer_chunks_to_bytes(chunks)
  inspect(pdf.length() > 100, content="true")
  inspect(consumer_bytes_contain(pdf, [37, 80, 68, 70, 45]), content="true")
  inspect(consumer_bytes_contain(pdf, [37, 37, 69, 79, 70]), content="true")
}
