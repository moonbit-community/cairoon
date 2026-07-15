///|
test "raw font options handle preserves state across copy" {
  let options = create_raw()
  inspect(status_raw(options), content="0")
  inspect(set_antialias_value_raw(options, 2), content="0")
  inspect(set_subpixel_order_value_raw(options, 1), content="0")
  inspect(set_hint_style_value_raw(options, 3), content="0")
  inspect(set_hint_metrics_value_raw(options, 2), content="0")
  inspect(get_antialias_raw(options), content="2")
  inspect(get_subpixel_order_raw(options), content="1")
  inspect(get_hint_style_raw(options), content="3")
  inspect(get_hint_metrics_raw(options), content="2")

  let status = Ref(-1)
  let copy = copy_raw(options, status)
  inspect(status.val, content="0")
  inspect(equal_raw(options, copy), content="true")
  inspect(hash_raw(options) == hash_raw(copy), content="true")

  inspect(set_antialias_raw(copy, 1), content="0")
  inspect(get_antialias_raw(options), content="2")
  inspect(get_antialias_raw(copy), content="1")
  inspect(equal_raw(options, copy), content="false")
}

///|
test "raw font options handle merges non-default state" {
  let options = create_raw()
  let overlay = create_raw()
  inspect(set_antialias_raw(overlay, 3), content="0")
  inspect(set_subpixel_order_raw(overlay, 2), content="0")
  inspect(set_hint_style_raw(overlay, 4), content="0")
  inspect(set_hint_metrics_raw(overlay, 1), content="0")
  inspect(merge_raw(options, overlay), content="0")
  inspect(get_antialias_raw(options), content="3")
  inspect(get_subpixel_order_raw(options), content="2")
  inspect(get_hint_style_raw(options), content="4")
  inspect(get_hint_metrics_raw(options), content="1")
}
