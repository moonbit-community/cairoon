///|
fn expect_mesh_error(result : Result[Unit, @cairoon.CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoError(@cairoon.InvalidMeshConstruction, _)) => ()
    _ => @test.fail("expected InvalidMeshConstruction")
  }
}

///|
fn expect_mesh_invalid_index(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}
