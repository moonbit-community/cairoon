///|
fn consumer_chunks_to_bytes(chunks : Array[Bytes]) -> Bytes {
  let mut output = Bytes::default()
  for chunk in chunks {
    output = output + chunk
  }
  output
}

///|
fn consumer_bytes_slice(bytes : Bytes, offset : Int, length : Int) -> Bytes {
  Bytes::makei(length, fn(index) { bytes[offset + index] })
}

///|
fn consumer_bytes_contain(bytes : Bytes, marker : Array[Int]) -> Bool {
  if marker.length() > bytes.length() {
    return false
  }
  let last_start = bytes.length() - marker.length()
  for start in 0..<(last_start + 1) {
    let mut matches = true
    for index in 0..<marker.length() {
      if bytes[start + index].to_int() != marker[index] {
        matches = false
      }
    }
    if matches {
      return true
    }
  }
  false
}
