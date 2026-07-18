///|
test "context accepts reverse-order asymmetric UTF-8 clusters" {
  let chunks : Array[Bytes] = []
  let device = @cairoon.Device::script_stream(fn(chunk) {
    chunks.push(chunk)
    Success
  })
  let surface = @cairoon.Surface::script(device, ContentColorAlpha, 32.0, 16.0)
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("serif")
  ctx.set_font_size(12.0)
  let text = "\u{00e9}a"
  let run = ctx.get_scaled_font().text_to_glyphs(2.0, 12.0, text)
  if run.glyphs.length() != 2 {
    @test.fail("expected two glyphs for the asymmetric UTF-8 fixture")
  }
  let glyphs = [run.glyphs[1], run.glyphs[0]]
  let clusters = [
    @cairoon.TextCluster::new(2, 1),
    @cairoon.TextCluster::new(1, 1),
  ]
  ctx.show_text_glyphs(text, glyphs, clusters, flags=TextClusterBackward)
  surface.finish()
  device.finish()
  let output = StringBuilder()
  for chunk in chunks {
    output.write_string(@utf8.decode_lossy(chunk))
  }
  inspect(
    output.to_string().contains("//BACKWARD show-text-glyphs"),
    content="true",
  )
}
