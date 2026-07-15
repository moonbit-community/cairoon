///|
test "raw region handle preserves geometry and status" {
  let region = create_rectangle_raw(2, 3, 5, 7)
  inspect(status_raw(region), content="0")
  inspect(num_rectangles_raw(region), content="1")
  inspect(is_empty_raw(region), content="false")
  inspect(contains_point_raw(region, 4, 5), content="true")
  inspect(contains_rectangle_raw(region, 3, 4, 1, 1), content="0")
  inspect(contains_rectangle_raw(region, 20, 20, 1, 1), content="1")

  let x = Ref(0)
  let y = Ref(0)
  let width = Ref(0)
  let height = Ref(0)
  inspect(get_extents_raw(region, x, y, width, height), content="0")
  inspect(x.val, content="2")
  inspect(y.val, content="3")
  inspect(width.val, content="5")
  inspect(height.val, content="7")
}

///|
test "raw region handle supports bulk construction and mutation" {
  let status = Ref(-1)
  let region = create_rectangles_raw(
    FixedArray::makei(2, index => if index == 0 { 0 } else { 10 }),
    FixedArray::makei(2, _ => 0),
    FixedArray::makei(2, _ => 5),
    FixedArray::makei(2, _ => 5),
    status,
  )
  inspect(status.val, content="0")
  inspect(num_rectangles_raw(region), content="2")

  let copy = copy_raw(region)
  inspect(equal_raw(region, copy), content="true")
  inspect(translate_raw(copy, 2, 3), content="0")
  inspect(equal_raw(region, copy), content="false")

  let bridge = create_rectangle_raw(4, 0, 7, 5)
  inspect(union_raw(region, bridge), content="0")
  inspect(contains_point_raw(region, 7, 2), content="true")
}
