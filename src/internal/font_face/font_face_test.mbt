///|
test "raw toy font face preserves family and enum state" {
  let face = @font_face.toy_create_value_raw(b"serif", 1, 1)
  inspect(@font_face.status_raw(face), content="0")
  let status = Ref(-1)
  inspect(@font_face.get_family_raw(face, status) == b"serif", content="true")
  inspect(status.val, content="0")
  inspect(@font_face.get_slant_raw(face, status), content="1")
  inspect(status.val, content="0")
  inspect(@font_face.get_weight_raw(face, status), content="1")
  inspect(status.val, content="0")
  inspect(@font_face.equal_raw(face, face), content="true")
  inspect(@font_face.hash_raw(face) != 0, content="true")
}

///|
test "raw toy font face reports invalid slant and weight" {
  let valid = @font_face.toy_create_raw(b"sans-serif", 2, 0)
  inspect(@font_face.status_raw(valid), content="0")
  let status = Ref(-1)
  inspect(@font_face.get_slant_raw(valid, status), content="2")
  inspect(status.val, content="0")
  inspect(@font_face.get_weight_raw(valid, status), content="0")
  inspect(status.val, content="0")

  let invalid_slant = @font_face.toy_create_raw(b"serif", 42, 0)
  inspect(@font_face.status_raw(invalid_slant), content="30")
  let invalid_weight = @font_face.toy_create_raw(b"serif", 0, 42)
  inspect(@font_face.status_raw(invalid_weight), content="31")
}
