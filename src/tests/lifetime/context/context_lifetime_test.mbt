///|
fn make_returned_target_surface() -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 1.0)
  ctx.paint()
  ctx.get_target()
}

///|
fn make_returned_group_target_surface() -> @cairoon.Surface raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(surface)
  ctx.push_group()
  let group_target = ctx.get_group_target()
  ctx.set_source_rgba(0.0, 1.0, 0.0, 1.0)
  ctx.paint()
  group_target
}

///|
fn make_context_with_local_surface_source() -> @cairoon.Context raise @cairoon.CairoError {
  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let source = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let source_ctx = @cairoon.Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()

  let ctx = @cairoon.Context::new(target)
  ctx.set_source_surface(source)
  ctx
}

///|
fn make_source_pattern_from_local_context() -> @cairoon.Pattern raise @cairoon.CairoError {
  let source = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let source_ctx = @cairoon.Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()

  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  ctx.set_source_surface(source)
  ctx.get_source()
}

///|
fn lifetime_chunks_to_string(chunks : Array[Bytes]) -> String {
  let builder = StringBuilder()
  for chunk in chunks {
    builder.write_string(@utf8.decode_lossy(chunk))
  }
  builder.to_string()
}

///|
fn lifetime_chunks_contain(chunks : Array[Bytes], marker : String) -> Bool {
  lifetime_chunks_to_string(chunks).contains(marker)
}

///|
fn make_context_with_local_pdf_stream_target(
  chunks : Array[Bytes],
) -> @cairoon.Context raise @cairoon.CairoError {
  let surface = @cairoon.Surface::pdf_stream(8.0, 8.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  @cairoon.Context::new(surface)
}

///|
fn make_context_with_local_ps_stream_target(
  chunks : Array[Bytes],
) -> @cairoon.Context raise @cairoon.CairoError {
  let surface = @cairoon.Surface::ps_stream(8.0, 8.0, fn(chunk) {
    chunks.push(chunk)
    @cairoon.Success
  })
  @cairoon.Context::new(surface)
}

///|
fn paint_and_finish_context_target(
  ctx : @cairoon.Context,
) -> Unit raise @cairoon.CairoError {
  ctx.set_source_rgb(0.0, 0.0, 1.0)
  ctx.paint()
  ctx.show_page()
  ctx.get_target().finish()
}

///|
test "context get_target returns a referenced surface wrapper" {
  let target = make_returned_target_surface()
  let data = target.copy_data()
  inspect(data.length(), content="4")
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="255")
  inspect(data[3].to_int(), content="255")
}

///|
test "context get_group_target survives context scope" {
  let target = make_returned_group_target_surface()
  let data = target.copy_data()
  inspect(data.length(), content="4")
  inspect(data[0].to_int(), content="0")
  inspect(data[1].to_int(), content="255")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
test "context equality and hash use cairo pointer identity" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(surface)
  let same = ctx
  let other = @cairoon.Context::new(surface)
  inspect(ctx.equal(same), content="true")
  inspect(ctx.hash() == same.hash(), content="true")
  inspect(ctx.equal(other), content="false")
}

///|
test "context get_source returns an independent pattern wrapper" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(surface)
  ctx.set_source_rgba(1.0, 0.0, 0.0, 0.5)
  let source = ctx.get_source()
  ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  let (red, green, blue, alpha) = source.get_rgba()
  inspect(red, content="1")
  inspect(green, content="0")
  inspect(blue, content="0")
  inspect(alpha, content="0.5")
}

///|
test "context set_source_surface keeps source cairo surface alive" {
  let ctx = make_context_with_local_surface_source()
  ctx.paint()
  let target = ctx.get_target()
  let data = target.copy_data()
  inspect(data[0].to_int(), content="255")
  inspect(data[1].to_int(), content="0")
  inspect(data[2].to_int(), content="0")
  inspect(data[3].to_int(), content="255")
}

///|
test "context get_source surface pattern survives source and context scopes" {
  let pattern = make_source_pattern_from_local_context()
  let source = pattern.get_surface()
  inspect(source.get_width(), content="1")
  let source_data = source.copy_data()
  inspect(source_data[0].to_int(), content="255")
  inspect(source_data[1].to_int(), content="0")
  inspect(source_data[2].to_int(), content="0")
  inspect(source_data[3].to_int(), content="255")

  let target = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  let ctx = @cairoon.Context::new(target)
  ctx.set_source(pattern)
  ctx.paint()
  let target_data = target.copy_data()
  inspect(target_data[0].to_int(), content="255")
  inspect(target_data[1].to_int(), content="0")
  inspect(target_data[2].to_int(), content="0")
  inspect(target_data[3].to_int(), content="255")
}

///|
test "context keeps pdf and ps stream targets alive after surface scope exits" {
  let pdf_chunks : Array[Bytes] = []
  let pdf_ctx = make_context_with_local_pdf_stream_target(pdf_chunks)
  paint_and_finish_context_target(pdf_ctx)
  inspect(lifetime_chunks_contain(pdf_chunks, "%PDF-1."), content="true")
  inspect(lifetime_chunks_contain(pdf_chunks, "%%EOF"), content="true")

  let ps_chunks : Array[Bytes] = []
  let ps_ctx = make_context_with_local_ps_stream_target(ps_chunks)
  paint_and_finish_context_target(ps_ctx)
  inspect(lifetime_chunks_contain(ps_chunks, "%!PS-Adobe-3.0"), content="true")
  inspect(lifetime_chunks_contain(ps_chunks, "%%EOF"), content="true")
}

///|
test "surface copy_page and show_page are checked operations" {
  let surface = @cairoon.Surface::image(@cairoon.Argb32, 1, 1)
  surface.copy_page()
  surface.show_page()
  debug_inspect(surface.status(), content="Success")
}

///|
test "context borrowed returns propagate cairo error" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 1, 1),
  )
  let set_result = @cairoon.run_cairo(() => {
    ctx.set_matrix(@cairoon.Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(set_result is Err(_), content="true")

  let target_result = @cairoon.run_cairo(() => {
    let _ = ctx.get_target()
    ()
  })
  inspect(target_result is Err(_), content="true")
  match target_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let source_result = @cairoon.run_cairo(() => {
    let _ = ctx.get_source()
    ()
  })
  inspect(source_result is Err(_), content="true")
  match source_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}
