///|
fn expect_error_payload(
  actual_status : Status,
  actual_message : String,
  expected_status : Status,
) -> Unit raise {
  inspect(actual_status == expected_status, content="true")
  inspect(actual_message == expected_status.message(), content="true")
  inspect(actual_message.length() > 0, content="true")
}

///|
fn expect_memory_error(status : Status) -> Unit raise {
  match run_cairo(() => check_status(status)) {
    Err(CairoMemoryError(actual_status, actual_message)) =>
      expect_error_payload(actual_status, actual_message, status)
    _ => @test.fail("expected CairoMemoryError")
  }
}

///|
fn expect_io_error(status : Status) -> Unit raise {
  match run_cairo(() => check_status(status)) {
    Err(CairoIOError(actual_status, actual_message)) =>
      expect_error_payload(actual_status, actual_message, status)
    _ => @test.fail("expected CairoIOError")
  }
}

///|
fn expect_invalid_argument(status : Status) -> Unit raise {
  match run_cairo(() => check_status(status)) {
    Err(CairoInvalidArgument(actual_status, actual_message)) =>
      expect_error_payload(actual_status, actual_message, status)
    _ => @test.fail("expected CairoInvalidArgument")
  }
}

///|
fn expect_general_error(status : Status) -> Unit raise {
  match run_cairo(() => check_status(status)) {
    Err(CairoError(actual_status, actual_message)) =>
      expect_error_payload(actual_status, actual_message, status)
    _ => @test.fail("expected CairoError")
  }
}

///|
test "run_cairo returns Ok for success" {
  let result = run_cairo(() => {
    check_status(Success)
    42
  })
  match result {
    Ok(value) => inspect(value, content="42")
    _ => @test.fail("expected Ok")
  }
}

///|
test "status error mapping classifies every cairo status" {
  expect_memory_error(NoMemory)

  let io_statuses : Array[Status] = [ReadError, WriteError, PngError]
  for status in io_statuses {
    expect_io_error(status)
  }

  let invalid_argument_statuses : Array[Status] = [
    InvalidFormat,
    InvalidContent,
    InvalidMatrix,
    InvalidString,
    InvalidDash,
    InvalidIndex,
    InvalidStride,
    InvalidSize,
    NullPointer,
  ]
  for status in invalid_argument_statuses {
    expect_invalid_argument(status)
  }

  let general_error_statuses : Array[Status] = [
    InvalidRestore,
    InvalidPopGroup,
    NoCurrentPoint,
    InvalidStatus,
    InvalidPathData,
    SurfaceFinished,
    SurfaceTypeMismatch,
    PatternTypeMismatch,
    InvalidVisual,
    FileNotFound,
    InvalidDscComment,
    ClipNotRepresentable,
    TempFileError,
    FontTypeMismatch,
    UserFontImmutable,
    UserFontError,
    NegativeCount,
    InvalidClusters,
    InvalidSlant,
    InvalidWeight,
    UserFontNotImplemented,
    DeviceTypeMismatch,
    DeviceError,
    InvalidMeshConstruction,
    DeviceFinished,
    Jbig2GlobalMissing,
    FreetypeError,
    Win32GdiError,
    TagError,
    DwriteError,
    SvgFontError,
    LastStatus,
  ]
  for status in general_error_statuses {
    expect_general_error(status)
  }
}
