///|
fn assert_pycairo_matrix_close(
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
fn assert_pycairo_matrix_point_close(
  actual : (Double, Double),
  expected : (Double, Double),
) -> Unit raise {
  let (actual_x, actual_y) = actual
  let (expected_x, expected_y) = expected
  assert_close(actual_x, expected_x)
  assert_close(actual_y, expected_y)
}

///|
fn expect_pycairo_matrix_invalid_index(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}

///|
test "pycairo matrix equality and component fixture" {
  let identity = @cairoon.Matrix::new()
  inspect(identity == identity, content="true")
  inspect(identity == @cairoon.Matrix::init_rotate(0.0), content="true")
  inspect(identity != @cairoon.Matrix::new(x0=1.0), content="true")

  let matrix = @cairoon.Matrix::new(
    xx=1.0,
    yx=2.0,
    xy=3.0,
    yy=4.0,
    x0=5.0,
    y0=6.0,
  )
  for index in 0..<6 {
    inspect(matrix.component(index), content="\{index + 1}")
  }
  expect_pycairo_matrix_invalid_index(
    @cairoon.run_cairo(() => {
      let _ = matrix.component(6)
      ()
    }),
  )
  expect_pycairo_matrix_invalid_index(
    @cairoon.run_cairo(() => {
      let _ = matrix.component(-1)
      ()
    }),
  )
}

///|
test "pycairo matrix invert and multiply fixtures" {
  assert_pycairo_matrix_close(
    @cairoon.Matrix::new(xx=1.0, yx=1.0).invert(),
    @cairoon.Matrix::new(xx=1.0, yx=-1.0, xy=0.0, yy=1.0, x0=0.0, y0=0.0),
  )

  let matrix = @cairoon.Matrix::new(xx=1.0, yx=1.0)
  inspect(
    matrix.multiply(matrix) ==
    @cairoon.Matrix::new(xx=1.0, yx=2.0, xy=0.0, yy=1.0, x0=0.0, y0=0.0),
    content="true",
  )
}

///|
test "pycairo matrix translate scale and rotate fixtures" {
  inspect(
    @cairoon.Matrix::new().translate(1.0, 1.0) ==
    @cairoon.Matrix::new(xx=1.0, yx=0.0, xy=0.0, yy=1.0, x0=1.0, y0=1.0),
    content="true",
  )

  let scaled = @cairoon.Matrix::new().scale(2.0, 2.0)
  inspect(scaled != @cairoon.Matrix::new(), content="true")
  inspect(scaled.scale(0.5, 0.5) == @cairoon.Matrix::new(), content="true")

  let rotated = @cairoon.Matrix::new().rotate(10.0)
  let scaled_after_rotate = rotated.scale(1.5, 2.5)
  let transformed = scaled_after_rotate.translate(10.0, 20.0)
  inspect(transformed != @cairoon.Matrix::new(), content="true")
}

///|
test "pycairo matrix transform point and distance fixtures" {
  let identity = @cairoon.Matrix::new()
  assert_pycairo_matrix_point_close(
    identity.transform_point(1.0, 1.0),
    (1.0, 1.0),
  )
  assert_pycairo_matrix_point_close(
    identity.transform_distance(1.0, 1.0),
    (1.0, 1.0),
  )
}
