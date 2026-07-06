///|
fn expect_error_payload(
  actual_status : @cairoon.Status,
  actual_message : String,
  expected_status : @cairoon.Status,
) -> Unit raise {
  inspect(actual_status == expected_status, content="true")
  inspect(actual_message == expected_status.message(), content="true")
  inspect(actual_message.length() > 0, content="true")
}

///|
fn expect_memory_error(status : @cairoon.Status) -> Unit raise {
  match @cairoon.run_cairo(() => @cairoon.check_status(status)) {
    Err(@cairoon.CairoMemoryError(actual_status, actual_message)) =>
      expect_error_payload(actual_status, actual_message, status)
    _ => @test.fail("expected CairoMemoryError")
  }
}

///|
fn expect_io_error(status : @cairoon.Status) -> Unit raise {
  match @cairoon.run_cairo(() => @cairoon.check_status(status)) {
    Err(@cairoon.CairoIOError(actual_status, actual_message)) =>
      expect_error_payload(actual_status, actual_message, status)
    _ => @test.fail("expected CairoIOError")
  }
}

///|
fn expect_invalid_argument(status : @cairoon.Status) -> Unit raise {
  match @cairoon.run_cairo(() => @cairoon.check_status(status)) {
    Err(@cairoon.CairoInvalidArgument(actual_status, actual_message)) =>
      expect_error_payload(actual_status, actual_message, status)
    _ => @test.fail("expected CairoInvalidArgument")
  }
}

///|
fn expect_general_error(status : @cairoon.Status) -> Unit raise {
  match @cairoon.run_cairo(() => @cairoon.check_status(status)) {
    Err(@cairoon.CairoError(actual_status, actual_message)) =>
      expect_error_payload(actual_status, actual_message, status)
    _ => @test.fail("expected CairoError")
  }
}

///|
test "run_cairo returns Ok for success" {
  let result = @cairoon.run_cairo(() => {
    @cairoon.check_status(@cairoon.Success)
    42
  })
  match result {
    Ok(value) => inspect(value, content="42")
    _ => @test.fail("expected Ok")
  }
}

///|
test "status error mapping classifies every cairo status" {
  expect_memory_error(@cairoon.NoMemory)

  let io_statuses : Array[@cairoon.Status] = [
    @cairoon.ReadError,
    @cairoon.WriteError,
    @cairoon.PngError,
  ]
  for status in io_statuses {
    expect_io_error(status)
  }

  let invalid_argument_statuses : Array[@cairoon.Status] = [
    @cairoon.InvalidFormat,
    @cairoon.InvalidContent,
    @cairoon.InvalidMatrix,
    @cairoon.InvalidString,
    @cairoon.InvalidDash,
    @cairoon.InvalidIndex,
    @cairoon.InvalidStride,
    @cairoon.InvalidSize,
    @cairoon.NullPointer,
  ]
  for status in invalid_argument_statuses {
    expect_invalid_argument(status)
  }

  let general_error_statuses : Array[@cairoon.Status] = [
    @cairoon.InvalidRestore,
    @cairoon.InvalidPopGroup,
    @cairoon.NoCurrentPoint,
    @cairoon.InvalidStatus,
    @cairoon.InvalidPathData,
    @cairoon.SurfaceFinished,
    @cairoon.SurfaceTypeMismatch,
    @cairoon.PatternTypeMismatch,
    @cairoon.InvalidVisual,
    @cairoon.FileNotFound,
    @cairoon.InvalidDscComment,
    @cairoon.ClipNotRepresentable,
    @cairoon.TempFileError,
    @cairoon.FontTypeMismatch,
    @cairoon.UserFontImmutable,
    @cairoon.UserFontError,
    @cairoon.NegativeCount,
    @cairoon.InvalidClusters,
    @cairoon.InvalidSlant,
    @cairoon.InvalidWeight,
    @cairoon.UserFontNotImplemented,
    @cairoon.DeviceTypeMismatch,
    @cairoon.DeviceError,
    @cairoon.InvalidMeshConstruction,
    @cairoon.DeviceFinished,
    @cairoon.Jbig2GlobalMissing,
    @cairoon.FreetypeError,
    @cairoon.Win32GdiError,
    @cairoon.TagError,
    @cairoon.DwriteError,
    @cairoon.SvgFontError,
    @cairoon.LastStatus,
  ]
  for status in general_error_statuses {
    expect_general_error(status)
  }
}
