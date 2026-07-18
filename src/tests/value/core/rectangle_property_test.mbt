///|
fn rectangle_property_expect_double_index_error(
  result : Result[Double, @cairoon.CairoError],
) -> Unit raise {
  match result {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected Rectangle InvalidIndex error")
  }
}

///|
fn rectangle_property_expect_int_index_error(
  result : Result[Int, @cairoon.CairoError],
) -> Unit raise {
  match result {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected RectangleInt InvalidIndex error")
  }
}

///|
test "rectangle property generated components and index aliases agree" {
  for seed in 0..<128 {
    let x = (seed * 13 - 500).to_double() / 4.0
    let y = (seed * 7 - 300).to_double() / 8.0
    let width = (seed % 17 - 8).to_double() / 2.0
    let height = (seed % 23 - 11).to_double() / 4.0
    let rectangle = @cairoon.Rectangle::new(x, y, width, height)
    let expected = [x, y, width, height]
    if rectangle.components() != (x, y, width, height) {
      @test.fail("Rectangle components changed generated field order")
    }
    for index in 0..<expected.length() {
      if rectangle.component(index) != expected[index] ||
        rectangle[index] != expected[index] {
        @test.fail("Rectangle component and index alias diverged")
      }
    }
    let equal = @cairoon.Rectangle::new(x, y, width, height)
    let changed = @cairoon.Rectangle::new(x, y, width + 0.25, height)
    if rectangle != equal || rectangle == changed {
      @test.fail("Rectangle structural equality diverged from its fields")
    }
  }
}

///|
test "integer rectangle property generated components preserve signed fields" {
  for seed in 0..<128 {
    let x = seed * 13 - 500
    let y = seed * 7 - 300
    let width = seed % 17 - 8
    let height = seed % 23 - 11
    let rectangle = @cairoon.RectangleInt::new(x~, y~, width~, height~)
    let expected = [x, y, width, height]
    if rectangle.components() != (x, y, width, height) {
      @test.fail("RectangleInt components changed generated field order")
    }
    for index in 0..<expected.length() {
      if rectangle.component(index) != expected[index] {
        @test.fail("RectangleInt component diverged from its field")
      }
    }
    let equal = @cairoon.RectangleInt::new(x~, y~, width~, height~)
    let changed = @cairoon.RectangleInt::new(x~, y~, width=width + 1, height~)
    if rectangle != equal || rectangle == changed {
      @test.fail("RectangleInt structural equality diverged from its fields")
    }
  }
}

///|
test "rectangle property every out of range index maps to InvalidIndex" {
  let rectangle = @cairoon.Rectangle::new(1.0, 2.0, 3.0, 4.0)
  let integer = @cairoon.RectangleInt::new(x=1, y=2, width=3, height=4)
  for index in [-1024, -2, -1, 4, 5, 1024] {
    rectangle_property_expect_double_index_error(
      @cairoon.run_cairo(() => rectangle.component(index)),
    )
    rectangle_property_expect_double_index_error(
      @cairoon.run_cairo(() => rectangle[index]),
    )
    rectangle_property_expect_int_index_error(
      @cairoon.run_cairo(() => integer.component(index)),
    )
  }
}
