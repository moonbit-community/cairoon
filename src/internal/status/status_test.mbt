///|
test "internal status message helper delegates to cairo" {
  inspect(status_message_raw(0).length() > 0, content="true")
  inspect(status_message_raw(1).length() > 0, content="true")
  inspect(status_message_raw(45).length() > 0, content="true")
}
