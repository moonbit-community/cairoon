///|
test "internal ps level helpers delegate to cairo" {
  let status = Ref(0)
  let count = @ps.get_level_count_raw(status)
  inspect(status.val, content="0")
  inspect(count > 0, content="true")

  let level = @ps.get_level_raw(0, status)
  inspect(status.val, content="0")
  inspect(level >= 0, content="true")

  let text = @ps.level_to_string_raw(level, status)
  inspect(status.val, content="0")
  inspect(text.contains("PS"), content="true")

  ignore(@ps.level_to_string_raw(99, status))
  inspect(status.val, content="6")
}
