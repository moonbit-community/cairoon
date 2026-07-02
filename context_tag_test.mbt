///|
fn expect_tag_invalid_string(result : Result[Unit, CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }
}

///|
test "context tags accept matching begin and end" {
  let ctx = Context::new(Surface::image(Argb32, 1, 1))
  ctx.tag_begin("foo", "bar='quux'")
  ctx.tag_end("foo")
  inspect(ctx.status().is_success(), content="true")
}

///|
test "context tag constants mirror cairo string constants" {
  inspect(TAG_DEST, content="cairo.dest")
  inspect(TAG_LINK, content="Link")
  inspect(TAG_CONTENT, content="cairo.content")
  inspect(TAG_CONTENT_REF, content="cairo.content_ref")
}

///|
test "context tags validate embedded nul strings before ffi" {
  let ctx = Context::new(Surface::image(Argb32, 1, 1))
  expect_tag_invalid_string(run_cairo(() => ctx.tag_begin("bad\u{0}tag", "")))
  expect_tag_invalid_string(
    run_cairo(() => ctx.tag_begin("foo", "bad\u{0}attributes")),
  )
  expect_tag_invalid_string(run_cairo(() => ctx.tag_end("bad\u{0}tag")))
}

///|
test "context tags propagate existing context errors" {
  let ctx = Context::new(Surface::image(Argb32, 1, 1))
  let invalid_matrix = run_cairo(() => {
    ctx.set_matrix(Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(invalid_matrix is Err(_), content="true")
  let result = run_cairo(() => ctx.tag_end("foo"))
  match result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}
