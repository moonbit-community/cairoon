///|
pub fn copy_chunk(chunk : Bytes) -> Bytes {
  Bytes::makei(chunk.length(), fn(index) { chunk[index] })
}
