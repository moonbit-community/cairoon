///|
test "stream writer chunks remain usable after callback returns" {
  let pdf_chunks : Array[Bytes] = []
  let pdf = @cairoon.Surface::pdf_stream(10.0, 10.0, fn(chunk) {
    pdf_chunks.push(chunk)
    Success
  })
  paint_stream_surface(pdf)

  let ps_chunks : Array[Bytes] = []
  let ps = @cairoon.Surface::ps_stream(10.0, 10.0, fn(chunk) {
    ps_chunks.push(chunk)
    Success
  })
  paint_stream_surface(ps)

  let svg_chunks : Array[Bytes] = []
  let svg = @cairoon.Surface::svg_stream(10.0, 10.0, fn(chunk) {
    svg_chunks.push(chunk)
    Success
  })
  paint_stream_surface(svg)

  let png_chunks : Array[Bytes] = []
  let image = @cairoon.Surface::image(Argb32, 2, 2)
  let image_ctx = @cairoon.Context::new(image)
  image_ctx.set_source_rgb(1.0, 0.0, 0.0)
  image_ctx.paint()
  image.write_to_png_stream(fn(chunk) {
    png_chunks.push(chunk)
    Success
  })

  let script_chunks : Array[Bytes] = []
  let script = @cairoon.Device::script_stream(fn(chunk) {
    script_chunks.push(chunk)
    Success
  })
  script.script_write_comment("retained stream chunk")
  let script_surface = @cairoon.Surface::script(
    script,
    ContentColorAlpha,
    4.0,
    4.0,
  )
  let script_ctx = @cairoon.Context::new(script_surface)
  script_ctx.paint()
  script_surface.finish()
  script.finish()

  inspect(pressure_stream_chunk_storage() > 0, content="true")
  inspect(stream_chunks_contain(pdf_chunks, "%PDF-1."), content="true")
  inspect(stream_chunks_contain(pdf_chunks, "%%EOF"), content="true")
  inspect(stream_chunks_contain(ps_chunks, "%!PS-Adobe-3.0"), content="true")
  inspect(stream_chunks_contain(ps_chunks, "%%EOF"), content="true")
  inspect(
    stream_chunks_contain(svg_chunks, "<?xml version=\"1.0\""),
    content="true",
  )
  inspect(stream_chunks_contain(svg_chunks, "</svg>"), content="true")
  inspect(is_png_signature(chunks_to_bytes(png_chunks)), content="true")
  inspect(
    stream_chunks_contain(script_chunks, "retained stream chunk"),
    content="true",
  )
}
