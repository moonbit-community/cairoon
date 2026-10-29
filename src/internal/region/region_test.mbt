///|
test "raw region handle preserves geometry and status" {
  let region = @region.create_rectangle_raw(2, 3, 5, 7)
  inspect(@region.status_raw(region), content="0")
  inspect(@region.num_rectangles_raw(region), content="1")
  inspect(@region.is_empty_raw(region), content="false")
  inspect(@region.contains_point_raw(region, 4, 5), content="true")
  inspect(@region.contains_rectangle_raw(region, 3, 4, 1, 1), content="0")
  inspect(@region.contains_rectangle_raw(region, 20, 20, 1, 1), content="1")

  let x = Ref(0)
  let y = Ref(0)
  let width = Ref(0)
  let height = Ref(0)
  inspect(@region.get_extents_raw(region, x, y, width, height), content="0")
  inspect(x.val, content="2")
  inspect(y.val, content="3")
  inspect(width.val, content="5")
  inspect(height.val, content="7")
}

///|
test "raw region handle supports bulk construction and mutation" {
  let status = Ref(-1)
  let region = @region.create_rectangles_raw(
    FixedArray::makei(2, index => if index == 0 { 0 } else { 10 }),
    FixedArray::makei(2, _ => 0),
    FixedArray::makei(2, _ => 5),
    FixedArray::makei(2, _ => 5),
    status,
  )
  inspect(status.val, content="0")
  inspect(@region.num_rectangles_raw(region), content="2")

  let copy = @region.copy_raw(region)
  inspect(@region.equal_raw(region, copy), content="true")
  inspect(@region.translate_raw(copy, 2, 3), content="0")
  inspect(@region.equal_raw(region, copy), content="false")

  let bridge = @region.create_rectangle_raw(4, 0, 7, 5)
  inspect(@region.union_raw(region, bridge), content="0")
  inspect(@region.contains_point_raw(region, 7, 2), content="true")
}
