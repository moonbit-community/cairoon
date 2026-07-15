///|
test "raw toy font face preserves family and enum state" {
  let face = toy_create_value_raw(b"serif", 1, 1)
  inspect(status_raw(face), content="0")
  let status = Ref(-1)
  inspect(get_family_raw(face, status) == b"serif", content="true")
  inspect(status.val, content="0")
  inspect(get_slant_raw(face, status), content="1")
  inspect(status.val, content="0")
  inspect(get_weight_raw(face, status), content="1")
  inspect(status.val, content="0")
  inspect(equal_raw(face, face), content="true")
  inspect(hash_raw(face) != 0, content="true")
}

///|
test "raw toy font face reports invalid slant and weight" {
  let valid = toy_create_raw(b"sans-serif", 2, 0)
  inspect(status_raw(valid), content="0")
  let status = Ref(-1)
  inspect(get_slant_raw(valid, status), content="2")
  inspect(status.val, content="0")
  inspect(get_weight_raw(valid, status), content="0")
  inspect(status.val, content="0")

  let invalid_slant = toy_create_raw(b"serif", 42, 0)
  inspect(status_raw(invalid_slant), content="30")
  let invalid_weight = toy_create_raw(b"serif", 0, 42)
  inspect(status_raw(invalid_weight), content="31")
}
