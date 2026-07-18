///|
fn expect_mesh_error(result : Result[Unit, @cairoon.CairoError]) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoError(InvalidMeshConstruction, _)) => ()
    _ => @test.fail("expected InvalidMeshConstruction")
  }
}

///|
fn expect_mesh_invalid_index(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(CairoInvalidArgument(InvalidIndex, _)) => ()
    _ => @test.fail("expected InvalidIndex")
  }
}
