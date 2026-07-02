///|
test "toy font face exposes family slant and weight" {
  let font_face = FontFace::toy(
    "serif",
    slant=FontSlantItalic,
    weight=FontWeightBold,
  )
  inspect(font_face.get_family(), content="serif")
  debug_inspect(font_face.get_slant(), content="FontSlantItalic")
  debug_inspect(font_face.get_weight(), content="FontWeightBold")
  inspect(font_face.status().is_success(), content="true")
}

///|
test "toy font face defaults match cairo defaults" {
  let font_face = FontFace::toy("sans-serif")
  inspect(font_face.get_family(), content="sans-serif")
  debug_inspect(font_face.get_slant(), content="FontSlantNormal")
  debug_inspect(font_face.get_weight(), content="FontWeightNormal")
}

///|
test "context get font face returns referenced wrappers with pointer equality" {
  let surface = Surface::image(Rgb24, 4, 4)
  let ctx = Context::new(surface)
  ctx.select_font_face("serif", slant=FontSlantOblique, weight=FontWeightBold)
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
  let surface = Surface::image(Rgb24, 4, 4)
  let ctx = Context::new(surface)
  let font_face = FontFace::toy(
    "serif",
    slant=FontSlantItalic,
    weight=FontWeightBold,
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
fn make_returned_font_face_from_context() -> FontFace raise CairoError {
  let surface = Surface::image(Rgb24, 4, 4)
  let ctx = Context::new(surface)
  ctx.select_font_face("sans-serif", weight=FontWeightBold)
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
  let ctx = Context::new(Surface::image(Argb32, 1, 1))
  let font_face = FontFace::toy("serif")
  let set_matrix_result = run_cairo(() => {
    ctx.set_matrix(Matrix::new(xx=0.0, yy=0.0))
  })
  inspect(set_matrix_result is Err(_), content="true")

  let get_result = run_cairo(() => {
    let _ = ctx.get_font_face()
    ()
  })
  inspect(get_result is Err(_), content="true")
  match get_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let set_result = run_cairo(() => ctx.set_font_face(Some(font_face)))
  inspect(set_result is Err(_), content="true")
  match set_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let reset_result = run_cairo(() => ctx.set_font_face(None))
  inspect(reset_result is Err(_), content="true")
  match reset_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }

  let select_result = run_cairo(() => ctx.select_font_face("serif"))
  inspect(select_result is Err(_), content="true")
  match select_result {
    Err(CairoInvalidArgument(InvalidMatrix, _)) => ()
    _ => @test.fail("expected InvalidMatrix")
  }
}

///|
test "font face allocation stress" {
  for _ in 0..<1000 {
    let face = FontFace::toy("serif")
    inspect(face.get_family(), content="serif")
  }
}
