///|
test "internal pdf version helpers delegate to cairo" {
  let status = Ref(0)
  let count = @pdf.get_version_count_raw(status)
  inspect(status.val, content="0")
  inspect(count > 0, content="true")

  let version = @pdf.get_version_raw(0, status)
  inspect(status.val, content="0")
  inspect(version >= 0, content="true")

  let text = @pdf.version_to_string_raw(version, status)
  inspect(status.val, content="0")
  inspect(text.contains("PDF"), content="true")

  ignore(@pdf.version_to_string_raw(-1, status))
  inspect(status.val, content="6")
}
