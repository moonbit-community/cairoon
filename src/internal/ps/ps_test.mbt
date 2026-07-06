///|
test "internal ps level helpers delegate to cairo" {
  let status = Ref(0)
  let count = get_level_count_raw(status)
  inspect(status.val, content="0")
  inspect(count > 0, content="true")

  let level = get_level_raw(0, status)
  inspect(status.val, content="0")
  inspect(level >= 0, content="true")

  let text = level_to_string_raw(level, status)
  inspect(status.val, content="0")
  inspect(text.contains("PS"), content="true")

  ignore(level_to_string_raw(99, status))
  inspect(status.val, content="6")
}
