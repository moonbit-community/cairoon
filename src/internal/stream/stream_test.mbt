///|
test "internal stream chunk copy preserves callback bytes" {
  let chunk = Bytes::from_array([b'c', b'a', b'i', b'r', b'o'])
  let copied = copy_chunk(chunk)
  inspect(copied == chunk, content="true")
  inspect(copied.length(), content="5")
}
