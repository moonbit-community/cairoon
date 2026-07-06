///|
fn expect_tag_invalid_string(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }
}

///|
fn expect_tag_error(result : Result[Unit, @cairoon.CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.TagError, _)) => ()
    _ => @test.fail("expected TagError")
  }
}

///|
test "context tags accept matching begin and end" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 1, 1),
  )
  ctx.tag_begin("foo", "bar='quux'")
  ctx.tag_end("foo")
  inspect(ctx.status().is_success(), content="true")
}

///|
test "context tag constants mirror cairo string constants" {
  inspect(@cairoon.TAG_DEST, content="cairo.dest")
  inspect(@cairoon.TAG_LINK, content="Link")
  inspect(@cairoon.TAG_CONTENT, content="cairo.content")
  inspect(@cairoon.TAG_CONTENT_REF, content="cairo.content_ref")
}

///|
test "context tags validate embedded nul strings before ffi" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 1, 1),
  )
  expect_tag_invalid_string(
    @cairoon.run_cairo(() => ctx.tag_begin("bad\u{0}tag", "")),
  )
  expect_tag_invalid_string(
    @cairoon.run_cairo(() => ctx.tag_begin("foo", "bad\u{0}attributes")),
  )
  expect_tag_invalid_string(
    @cairoon.run_cairo(() => ctx.tag_end("bad\u{0}tag")),
  )
}

///|
test "context tag nesting errors map to TagError" {
  let unmatched = @cairoon.Context::new(@cairoon.Surface::pdf(10.0, 10.0))
  unmatched.tag_end("foo")
  expect_tag_error(@cairoon.run_cairo(() => unmatched.show_page()))
  debug_inspect(unmatched.status(), content="TagError")

  let mismatched = @cairoon.Context::new(@cairoon.Surface::pdf(10.0, 10.0))
  mismatched.tag_begin("outer", "")
  mismatched.tag_end("inner")
  expect_tag_error(@cairoon.run_cairo(() => mismatched.show_page()))
  debug_inspect(mismatched.status(), content="TagError")
}

///|
test "context tags propagate existing context errors" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 1, 1),
  )
  let invalid_matrix = @cairoon.run_cairo(() => {
    ctx.set_matrix(@cairoon.Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(invalid_matrix is Err(_), content="true")
  let result = @cairoon.run_cairo(() => ctx.tag_end("foo"))
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}
