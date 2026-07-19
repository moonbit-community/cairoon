///|
test "consumer composes matrix and region values" {
  let translated = @cairoon.Matrix::new(x0=2.0, y0=3.0)
  inspect(translated.transform_point(1.0, 1.0) == (3.0, 4.0), content="true")
  inspect(
    translated.invert().transform_point(3.0, 4.0) == (1.0, 1.0),
    content="true",
  )

  let region = @cairoon.Region::from_rectangle(
    @cairoon.RectangleInt::new(x=0, y=0, width=4, height=4),
  )
  ignore(
    region.union_rectangle(
      @cairoon.RectangleInt::new(x=4, y=0, width=2, height=4),
    ),
  )
  inspect(
    region.get_extents() ==
    @cairoon.RectangleInt::new(x=0, y=0, width=6, height=4),
    content="true",
  )
  inspect(region.contains_point(5, 3), content="true")
}

///|
test "consumer matches typed cairo errors" {
  match
    @cairoon.run_cairo(() => @cairoon.Surface::image(@cairoon.Argb32, -1, 1)) {
    Err(CairoInvalidArgument(InvalidSize, message)) =>
      inspect(message.length() > 0, content="true")
    _ => @test.fail("expected InvalidSize")
  }

  let empty = @cairoon.Region::new()
  match @cairoon.run_cairo(() => empty.get_rectangle(0)) {
    Err(CairoInvalidArgument(InvalidIndex, message)) =>
      inspect(message.length() > 0, content="true")
    _ => @test.fail("expected InvalidIndex")
  }
}
