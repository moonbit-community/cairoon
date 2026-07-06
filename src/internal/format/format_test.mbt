///|
test "internal format stride helper delegates to cairo" {
  inspect(stride_for_width_raw(0, 8), content="32")
  inspect(stride_for_width_raw(2, 8), content="8")
  inspect(stride_for_width_raw(0, -1), content="-1")
}
