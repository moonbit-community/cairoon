# Matrix

`Matrix` is a pure MoonBit value representing Cairo's affine transform fields
in pycairo order: `xx`, `yx`, `xy`, `yy`, `x0`, `y0`.

Unlike pycairo's mutating `Matrix` methods, cairoon transformation methods
return a new `Matrix`. Keep the returned value when chaining transforms.

## Components

```mbt check
///|
test "matrix docs: construction and component order" {
  let identity = Matrix::new()
  debug_inspect(
    identity,
    content="{ xx: 1, yx: 0, xy: 0, yy: 1, x0: 0, y0: 0 }",
  )

  let matrix = Matrix::new(xx=1.0, yx=2.0, xy=3.0, yy=4.0, x0=5.0, y0=6.0)
  debug_inspect(matrix.components(), content="(1, 2, 3, 4, 5, 6)")
  inspect(matrix.component(0), content="1")
  inspect(matrix.component(5), content="6")
}
```

## Pure Transform Updates

`translate`, `scale`, `rotate`, and `invert` do not mutate the receiver. This
matches MoonBit value semantics while preserving Cairo's field math.

```mbt check
///|
test "matrix docs: transforms return new values" {
  let base = Matrix::new()
  let translated = base.translate(3.0, 4.0)
  debug_inspect(base.transform_point(1.0, 1.0), content="(1, 1)")
  debug_inspect(translated.transform_point(1.0, 1.0), content="(4, 5)")

  let scaled = translated.scale(2.0, 3.0)
  debug_inspect(scaled.transform_distance(2.0, 2.0), content="(4, 6)")
  debug_inspect(scaled.transform_point(1.0, 1.0), content="(5, 7)")
}
```

## Multiplication And Inversion

Matrix multiplication follows Cairo's field order: the result applies the
receiver's transform first, then the second matrix.

```mbt check
///|
test "matrix docs: multiply and invert" {
  let matrix = Matrix::new(xx=1.0, yx=1.0)
  debug_inspect(
    matrix.multiply(matrix),
    content="{ xx: 1, yx: 2, xy: 0, yy: 1, x0: 0, y0: 0 }",
  )
  debug_inspect(
    matrix * matrix,
    content="{ xx: 1, yx: 2, xy: 0, yy: 1, x0: 0, y0: 0 }",
  )

  let inverse = matrix.invert()
  debug_inspect(
    inverse,
    content="{ xx: 1, yx: -1, xy: 0, yy: 1, x0: 0, y0: 0 }",
  )
  debug_inspect(
    matrix.multiply(inverse),
    content="{ xx: 1, yx: 0, xy: 0, yy: 1, x0: 0, y0: 0 }",
  )
}
```

## Checked Errors

Invalid component indexes and singular inversions are reported through
`CairoInvalidArgument`, matching cairoon's checked error policy.

```mbt check
///|
test "matrix docs: invalid operations raise checked cairo errors" {
  let matrix = Matrix::new()
  inspect(matrix[0], content="1")
  inspect(matrix[5], content="0")
  match run_cairo(() => matrix[6]) {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }

  let singular = Matrix::new(xx=1.0, yx=2.0, xy=2.0, yy=4.0)
  match run_cairo(() => singular.invert()) {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}
```
