///|
fn[T] expect_surface_finished(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.SurfaceFinished, _)) => ()
    _ => @test.fail("expected SurfaceFinished")
  }
}

///|
fn[T] expect_surface_type_mismatch(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.SurfaceTypeMismatch, _)) => ()
    _ => @test.fail("expected SurfaceTypeMismatch")
  }
}

///|
fn[T] expect_surface_invalid_content(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidContent, _)) => ()
    _ => @test.fail("expected InvalidContent")
  }
}

///|
fn[T] expect_surface_invalid_format(
  result : Result[T, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidFormat, _)) => ()
    _ => @test.fail("expected InvalidFormat")
  }
}
