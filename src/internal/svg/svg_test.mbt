///|
test "internal svg version helpers delegate to cairo" {
  let status = Ref(0)
  let count = get_version_count_raw(status)
  inspect(status.val, content="0")
  inspect(count > 0, content="true")

  let version = get_version_raw(0, status)
  inspect(status.val, content="0")
  inspect(version >= 0, content="true")

  let text = version_to_string_raw(version, status)
  inspect(status.val, content="0")
  inspect(text.contains("SVG"), content="true")

  ignore(version_to_string_raw(99, status))
  inspect(status.val, content="6")
}
