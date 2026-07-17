///|
test "rectangle component indexes follow field order" {
  let rect = @cairoon.Rectangle::new(1.0, 2.0, 3.0, 4.0)
  inspect(rect.component(0), content="1")
  inspect(rect.component(1), content="2")
  inspect(rect.component(2), content="3")
  inspect(rect.component(3), content="4")
}

///|
test "integer rectangle component indexes follow field order" {
  let rect = @cairoon.RectangleInt::new(x=1, y=2, width=3, height=4)
  inspect(rect.component(0), content="1")
  inspect(rect.component(1), content="2")
  inspect(rect.component(2), content="3")
  inspect(rect.component(3), content="4")
}

///|
test "text extents component indexes follow pycairo field order" {
  let extents = @cairoon.TextExtents::new(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
  inspect(extents.component(0), content="1")
  inspect(extents.component(1), content="2")
  inspect(extents.component(2), content="3")
  inspect(extents.component(3), content="4")
  inspect(extents.component(4), content="5")
  inspect(extents.component(5), content="6")
}

///|
test "font extents component indexes follow cairo field order" {
  let extents = @cairoon.FontExtents::new(1.0, 2.0, 3.0, 4.0, 5.0)
  inspect(extents.component(0), content="1")
  inspect(extents.component(1), content="2")
  inspect(extents.component(2), content="3")
  inspect(extents.component(3), content="4")
  inspect(extents.component(4), content="5")
}
