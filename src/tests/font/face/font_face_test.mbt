///|
fn expect_font_face_invalid_string(
  result : Result[Unit, @cairoon.CairoError],
) -> Unit raise {
  inspect(result is Err(_), content="true")
  match result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidString, _)) => ()
    _ => @test.fail("expected InvalidString")
  }
}

///|
test "toy font face exposes family slant and weight" {
  let font_face = @cairoon.FontFace::toy(
    "serif",
    slant=@cairoon.FontSlantItalic,
    weight=@cairoon.FontWeightBold,
  )
  inspect(font_face.get_family(), content="serif")
  debug_inspect(font_face.get_slant(), content="FontSlantItalic")
  debug_inspect(font_face.get_weight(), content="FontWeightBold")
  inspect(font_face.status().is_success(), content="true")
}

///|
test "toy font face defaults match cairo defaults" {
  let font_face = @cairoon.FontFace::toy("sans-serif")
  inspect(font_face.get_family(), content="sans-serif")
  debug_inspect(font_face.get_slant(), content="FontSlantNormal")
  debug_inspect(font_face.get_weight(), content="FontWeightNormal")
}

///|
test "toy font face raw slant weight mirrors pycairo c int passthrough" {
  let typed = @cairoon.FontFace::toy(
    "serif",
    slant=@cairoon.FontSlantOblique,
    weight=@cairoon.FontWeightBold,
  )
  inspect(typed.get_slant_raw(), content="2")
  inspect(typed.get_weight_raw(), content="1")

  let raw_known = @cairoon.FontFace::toy_raw("serif", slant=1, weight=0)
  debug_inspect(raw_known.get_slant(), content="FontSlantItalic")
  debug_inspect(raw_known.get_weight(), content="FontWeightNormal")

  match
    @cairoon.run_cairo(() => {
      let _ = @cairoon.FontFace::toy_raw("serif", slant=42, weight=0)
      ()
    }) {
    Err(@cairoon.CairoError(@cairoon.InvalidSlant, _)) => ()
    _ => @test.fail("expected invalid raw slant to map to InvalidSlant")
  }
  match
    @cairoon.run_cairo(() => {
      let _ = @cairoon.FontFace::toy_raw("serif", slant=0, weight=42)
      ()
    }) {
    Err(@cairoon.CairoError(@cairoon.InvalidWeight, _)) => ()
    _ => @test.fail("expected invalid raw weight to map to InvalidWeight")
  }
}

///|
test "context select_font_face_raw mirrors pycairo c int passthrough" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 4, 4),
  )
  ctx.select_font_face_raw("serif", slant=2, weight=1)
  let known_selected = ctx.get_font_face()
  inspect(known_selected.get_slant_raw(), content="2")
  inspect(known_selected.get_weight_raw(), content="1")
  debug_inspect(known_selected.get_slant(), content="FontSlantOblique")
  debug_inspect(known_selected.get_weight(), content="FontWeightBold")

  let slant_ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 4, 4),
  )
  match
    @cairoon.run_cairo(() => slant_ctx.select_font_face_raw("serif", slant=42)) {
    Err(@cairoon.CairoError(@cairoon.InvalidSlant, _)) => ()
    _ => @test.fail("expected invalid raw context slant to map to InvalidSlant")
  }

  let weight_ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 4, 4),
  )
  match
    @cairoon.run_cairo(() => weight_ctx.select_font_face_raw("serif", weight=42)) {
    Err(@cairoon.CairoError(@cairoon.InvalidWeight, _)) => ()
    _ =>
      @test.fail("expected invalid raw context weight to map to InvalidWeight")
  }
}

///|
test "font family APIs validate embedded nul strings" {
  expect_font_face_invalid_string(
    @cairoon.run_cairo(() => {
      let _ = @cairoon.FontFace::toy("bad\u{0}family")
      ()
    }),
  )
  expect_font_face_invalid_string(
    @cairoon.run_cairo(() => {
      let _ = @cairoon.FontFace::toy_raw("bad\u{0}family")
      ()
    }),
  )
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 1, 1),
  )
  expect_font_face_invalid_string(
    @cairoon.run_cairo(() => ctx.select_font_face("bad\u{0}family")),
  )
  expect_font_face_invalid_string(
    @cairoon.run_cairo(() => ctx.select_font_face_raw("bad\u{0}family")),
  )
}

///|
test "context get font face returns referenced wrappers with pointer equality" {
  let surface = @cairoon.Surface::image(@cairoon.Rgb24, 4, 4)
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face(
    "serif",
    slant=@cairoon.FontSlantOblique,
    weight=@cairoon.FontWeightBold,
  )
  let first = ctx.get_font_face()
  let second = ctx.get_font_face()
  inspect(first.equal(second), content="true")
  inspect(first.hash() == second.hash(), content="true")
  inspect(first.get_family(), content="serif")
  debug_inspect(second.get_slant(), content="FontSlantOblique")
  debug_inspect(second.get_weight(), content="FontWeightBold")
}

///|
test "context set font face and reset to default" {
  let surface = @cairoon.Surface::image(@cairoon.Rgb24, 4, 4)
  let ctx = @cairoon.Context::new(surface)
  let font_face = @cairoon.FontFace::toy(
    "serif",
    slant=@cairoon.FontSlantItalic,
    weight=@cairoon.FontWeightBold,
  )
  ctx.set_font_face(Some(font_face))
  let returned = ctx.get_font_face()
  inspect(returned.equal(font_face), content="true")
  inspect(returned.get_family(), content="serif")
  debug_inspect(returned.get_slant(), content="FontSlantItalic")
  debug_inspect(returned.get_weight(), content="FontWeightBold")

  ctx.set_font_face(None)
  inspect(ctx.get_font_face().status().is_success(), content="true")
}

///|
fn make_returned_font_face_from_context() -> @cairoon.FontFace raise @cairoon.CairoError {
  let surface = @cairoon.Surface::image(@cairoon.Rgb24, 4, 4)
  let ctx = @cairoon.Context::new(surface)
  ctx.select_font_face("sans-serif", weight=@cairoon.FontWeightBold)
  ctx.get_font_face()
}

///|
test "context font face survives source context scope" {
  let font_face = make_returned_font_face_from_context()
  inspect(font_face.get_family(), content="sans-serif")
  debug_inspect(font_face.get_weight(), content="FontWeightBold")
}

///|
test "font face context methods propagate cairo error" {
  let ctx = @cairoon.Context::new(
    @cairoon.Surface::image(@cairoon.Argb32, 1, 1),
  )
  let font_face = @cairoon.FontFace::toy("serif")
  let set_matrix_result = @cairoon.run_cairo(() => {
    ctx.set_matrix(@cairoon.Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(set_matrix_result is Err(_), content="true")

  let get_result = @cairoon.run_cairo(() => {
    let _ = ctx.get_font_face()
    ()
  })
  inspect(get_result is Err(_), content="true")
  match get_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let set_result = @cairoon.run_cairo(() => ctx.set_font_face(Some(font_face)))
  inspect(set_result is Err(_), content="true")
  match set_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let reset_result = @cairoon.run_cairo(() => ctx.set_font_face(None))
  inspect(reset_result is Err(_), content="true")
  match reset_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let select_result = @cairoon.run_cairo(() => ctx.select_font_face("serif"))
  inspect(select_result is Err(_), content="true")
  match select_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let select_raw_result = @cairoon.run_cairo(() => {
    ctx.select_font_face_raw("serif", slant=2, weight=1)
  })
  inspect(select_raw_result is Err(_), content="true")
  match select_raw_result {
    Err(@cairoon.CairoInvalidArgument(@cairoon.InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}

///|
test "font face allocation stress" {
  for _ in 0..<1000 {
    let face = @cairoon.FontFace::toy("serif")
    inspect(face.get_family(), content="serif")
  }
}
