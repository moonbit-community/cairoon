///|
test "consumer round trips PNG stream callbacks" {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 2, 2)
  let ctx = @cairoon.Context::new(source)
  ctx.set_source_rgb(0.0, 1.0, 0.0)
  ctx.paint()

  let chunks : Array[Bytes] = []
  source.write_to_png_stream(fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  let png = consumer_chunks_to_bytes(chunks)
  inspect(
    consumer_bytes_contain(png, [137, 80, 78, 71, 13, 10, 26, 10]),
    content="true",
  )

  let offset = Ref(0)
  let decoded = @cairoon.Surface::image_from_png_stream(fn(length) {
    let chunk = consumer_bytes_slice(png, offset.val, length)
    offset.val += length
    chunk
  })
  inspect(offset.val == png.length(), content="true")
  inspect(decoded.get_width(), content="2")
  inspect(decoded.get_height(), content="2")
  inspect(decoded.copy_data() == source.copy_data(), content="true")
}
