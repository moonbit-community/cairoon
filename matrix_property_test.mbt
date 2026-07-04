///|
fn assert_property_close(actual : Double, expected : Double) -> Unit raise {
  if !actual.is_close(expected, absolute_tolerance=0.000001) {
    @test.fail("expected close property value")
  }
}

///|
fn assert_property_matrix_close(
  actual : Matrix,
  expected : Matrix,
) -> Unit raise {
  assert_property_close(actual.xx, expected.xx)
  assert_property_close(actual.yx, expected.yx)
  assert_property_close(actual.xy, expected.xy)
  assert_property_close(actual.yy, expected.yy)
  assert_property_close(actual.x0, expected.x0)
  assert_property_close(actual.y0, expected.y0)
}

///|
fn assert_property_point_close(
  actual : (Double, Double),
  expected : (Double, Double),
) -> Unit raise {
  let (actual_x, actual_y) = actual
  let (expected_x, expected_y) = expected
  assert_property_close(actual_x, expected_x)
  assert_property_close(actual_y, expected_y)
}

///|
fn property_matrices() -> Array[Matrix] {
  [
    Matrix::new(xx=1.0, yx=0.25, xy=-0.5, yy=2.0, x0=3.0, y0=-4.0),
    Matrix::new(xx=-2.0, yx=1.5, xy=0.75, yy=1.25, x0=-1.0, y0=2.0),
    Matrix::init_rotate(0.375).scale(1.5, -0.75).translate(2.0, -3.0),
    Matrix::new(xx=0.5, yx=-1.25, xy=2.0, yy=0.75, x0=4.0, y0=5.0),
  ]
}

///|
fn property_points() -> Array[(Double, Double)] {
  [(0.0, 0.0), (1.5, -2.25), (-3.0, 4.5), (8.0, 0.25)]
}

///|
test "matrix property multiply is associative for deterministic cases" {
  let matrices = property_matrices()
  for i in 0..<matrices.length() {
    let a = matrices[i]
    let b = matrices[(i + 1) % matrices.length()]
    let c = matrices[(i + 2) % matrices.length()]
    assert_property_matrix_close(
      a.multiply(b).multiply(c),
      a.multiply(b.multiply(c)),
    )
  }
}

///|
test "matrix property inverse composes to identity" {
  let identity = Matrix::new()
  for matrix in property_matrices() {
    let inverse = matrix.invert()
    assert_property_matrix_close(matrix.multiply(inverse), identity)
    assert_property_matrix_close(inverse.multiply(matrix), identity)
  }
}

///|
test "matrix property multiply composes point and distance transforms" {
  let matrices = property_matrices()
  let points = property_points()
  for i in 0..<matrices.length() {
    let first = matrices[i]
    let second = matrices[(i + 1) % matrices.length()]
    let composed = first.multiply(second)
    for point in points {
      let (x, y) = point
      let (first_x, first_y) = first.transform_point(x, y)
      let (first_dx, first_dy) = first.transform_distance(x, y)
      assert_property_point_close(
        composed.transform_point(x, y),
        second.transform_point(first_x, first_y),
      )
      assert_property_point_close(
        composed.transform_distance(x, y),
        second.transform_distance(first_dx, first_dy),
      )
    }
  }
}

///|
test "matrix property distance equals point delta" {
  for matrix in property_matrices() {
    for point in property_points() {
      let (x, y) = point
      let (tx, ty) = matrix.transform_point(x, y)
      let (moved_x, moved_y) = matrix.transform_point(x + 1.25, y - 0.5)
      assert_property_point_close(
        matrix.transform_distance(1.25, -0.5),
        (moved_x - tx, moved_y - ty),
      )
    }
  }
}
