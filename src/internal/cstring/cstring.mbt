///|
pub fn has_embedded_nul(bytes : Bytes) -> Bool {
  let nul : Byte = 0
  for index in 0..<bytes.length() {
    if bytes[index] == nul {
      return true
    }
  }
  false
}
