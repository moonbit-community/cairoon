///|
pub fn status_message_raw(status : Int) -> String {
  ignore(@native.native_anchor())
  @utf8.decode_lossy(status_to_string_raw_ffi(status))
}
