///|
/// The checked error hierarchy raised by cairoon operations.
///
/// Every variant carries the originating Cairo status and its diagnostic
/// message. Memory, I/O, and invalid-argument failures have dedicated
/// variants so callers can handle those classes without inspecting strings.
pub suberror CairoError {
  CairoError(Status, String)
  CairoMemoryError(Status, String)
  CairoIOError(Status, String)
  CairoInvalidArgument(Status, String)
} derive(Debug)

///|
/// Raise the appropriate `CairoError` variant unless `status` is `Success`.
pub fn check_status(status : Status) -> Unit raise CairoError {
  match status {
    Success => ()
    NoMemory => raise CairoMemoryError(status, status.message())
    ReadError | WriteError | PngError =>
      raise CairoIOError(status, status.message())
    InvalidFormat
    | InvalidContent
    | InvalidMatrix
    | InvalidString
    | InvalidDash
    | InvalidIndex
    | InvalidStride
    | InvalidSize
    | NullPointer => raise CairoInvalidArgument(status, status.message())
    _ => raise CairoError(status, status.message())
  }
}

///|
/// Run a checked Cairo operation and capture its raised error as a `Result`.
pub fn[T] run_cairo(f : () -> T raise CairoError) -> Result[T, CairoError] {
  try f() catch {
    err => Err(err)
  } noraise {
    value => Ok(value)
  }
}
