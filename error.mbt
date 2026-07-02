///|
pub suberror CairoError {
  CairoError(Status, String)
  CairoMemoryError(Status, String)
  CairoIOError(Status, String)
  CairoInvalidArgument(Status, String)
} derive(Debug)

///|
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
pub fn[T] run_cairo(f : () -> T raise CairoError) -> Result[T, CairoError] {
  try f() catch {
    err => Err(err)
  } noraise {
    value => Ok(value)
  }
}
