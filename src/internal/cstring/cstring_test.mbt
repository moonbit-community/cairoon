///|
test "internal c string helper detects nul bytes" {
  inspect(has_embedded_nul(Bytes::from_array([])), content="false")
  inspect(
    has_embedded_nul(Bytes::from_array([b'c', b'a', b'i', b'r', b'o'])),
    content="false",
  )
  inspect(
    has_embedded_nul(Bytes::from_array([b'c', b'\x00', b'o'])),
    content="true",
  )
  inspect(has_embedded_nul(Bytes::from_array([b'\x00'])), content="true")
}
