///|
test "matrix pure value operations" {
  let identity = @cairoon.Matrix::new()
  debug_inspect(identity.transform_point(2.0, 3.0), content="(2, 3)")
  let translated = identity.translate(5.0, 7.0)
  debug_inspect(translated.transform_point(2.0, 3.0), content="(7, 10)")
  let scaled = identity.scale(2.0, 3.0)
  debug_inspect(scaled.transform_distance(4.0, 5.0), content="(8, 15)")
}

///|
fn assert_close(actual : Double, expected : Double) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    @test.fail("expected close doubles")
  }
}

///|
fn assert_matrix_close(
  actual : @cairoon.Matrix,
  expected : @cairoon.Matrix,
) -> Unit raise {
  assert_close(actual.xx, expected.xx)
  assert_close(actual.yx, expected.yx)
  assert_close(actual.xy, expected.xy)
  assert_close(actual.yy, expected.yy)
  assert_close(actual.x0, expected.x0)
  assert_close(actual.y0, expected.y0)
}

///|
test "matrix multiply matches cairo field order" {
  let a = @cairoon.Matrix::new(xx=1.0, yx=2.0, xy=3.0, yy=4.0, x0=5.0, y0=6.0)
  let b = @cairoon.Matrix::new(
    xx=7.0,
    yx=8.0,
    xy=9.0,
    yy=10.0,
    x0=11.0,
    y0=12.0,
  )
  debug_inspect(
    a.multiply(b),
    content="{ xx: 25, yx: 28, xy: 57, yy: 64, x0: 100, y0: 112 }",
  )
}

///|
test "matrix rotate and init_rotate match cairo values" {
  let rotation = @cairoon.Matrix::init_rotate(0.5)
  assert_matrix_close(
    rotation,
    @cairoon.Matrix::new(
      xx=0.8775825618903728,
      yx=0.479425538604203,
      xy=-0.479425538604203,
      yy=0.8775825618903728,
    ),
  )
  let rotated = @cairoon.Matrix::new(
    xx=1.0,
    yx=2.0,
    xy=3.0,
    yy=4.0,
    x0=5.0,
    y0=6.0,
  ).rotate(0.5)
  assert_matrix_close(
    rotated,
    @cairoon.Matrix::new(
      xx=2.3158591777029818,
      yx=3.6728672781975573,
      xy=2.1533221470669153,
      yy=2.551479170353085,
      x0=5.0,
      y0=6.0,
    ),
  )
}

///|
test "matrix invert maps invalid matrix to cairo error" {
  let matrix = @cairoon.Matrix::new(
    xx=1.0,
    yx=2.0,
    xy=3.0,
    yy=4.0,
    x0=5.0,
    y0=6.0,
  )
  debug_inspect(
    matrix.invert(),
    content="{ xx: -2, yx: 1, xy: 1.5, yy: -0.5, x0: 1, y0: -2 }",
  )
  let singular = @cairoon.Matrix::new(xx=1.0, yx=2.0, xy=2.0, yy=4.0)
  let result = @cairoon.run_cairo(() => singular.invert())
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}

///|
test "matrix component access mirrors pycairo order" {
  let matrix = @cairoon.Matrix::new(
    xx=1.0,
    yx=2.0,
    xy=3.0,
    yy=4.0,
    x0=5.0,
    y0=6.0,
  )
  debug_inspect(matrix.components(), content="(1, 2, 3, 4, 5, 6)")
  inspect(matrix.component(0), content="1")
  inspect(matrix.component(5), content="6")
  let result = @cairoon.run_cairo(() => matrix.component(6))
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}
