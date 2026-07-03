///|
test "raster source acquire-only releases retained owner after paint" {
  let source = Surface::image(Argb32, 1, 1)
  let source_ctx = Context::new(source)
  source_ctx.set_source_rgba(0.0, 0.0, 1.0, 1.0)
  source_ctx.paint()
  inspect(test_raster_surface_owner_count_ffi(source), content="0")

  let acquire_calls = Ref(0)
  let pattern = Pattern::raster_source(ContentColorAlpha, 1, 1)
  pattern.raster_set_acquire(fn(_, _) {
    acquire_calls.val += 1
    source
  })

  for _ in 0..<3 {
    let target = Surface::image(Argb32, 1, 1)
    let ctx = Context::new(target)
    ctx.set_source(pattern)
    ctx.paint()
    target.flush()
    let data = target.copy_data()
    inspect(data[0].to_int(), content="255")
    inspect(data[1].to_int(), content="0")
    inspect(data[2].to_int(), content="0")
    inspect(data[3].to_int(), content="255")
    inspect(test_raster_surface_owner_count_ffi(source), content="0")
  }

  inspect(acquire_calls.val > 0, content="true")
}
