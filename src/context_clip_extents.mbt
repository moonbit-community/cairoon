///|
pub fn Context::clip(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.clip_raw(self.to_raw()))
}

///|
pub fn Context::clip_preserve(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.clip_preserve_raw(self.to_raw()))
}

///|
pub fn Context::reset_clip(self : Context) -> Unit raise CairoError {
  check_context_status_raw(@context_impl.reset_clip_raw(self.to_raw()))
}

///|
pub fn Context::clip_extents(
  self : Context,
) -> (Double, Double, Double, Double) raise CairoError {
  context_extents_from_output((x1, y1, x2, y2) => {
    @context_impl.clip_extents_raw(self.to_raw(), x1, y1, x2, y2)
  })
}

///|
fn context_extents_from_output(
  f : (Ref[Double], Ref[Double], Ref[Double], Ref[Double]) -> Int,
) -> (Double, Double, Double, Double) raise CairoError {
  let x1 = Ref(0.0)
  let y1 = Ref(0.0)
  let x2 = Ref(0.0)
  let y2 = Ref(0.0)
  check_context_status_raw(f(x1, y1, x2, y2))
  (x1.val, y1.val, x2.val, y2.val)
}

///|
pub fn Context::in_clip(
  self : Context,
  x : Double,
  y : Double,
) -> Bool raise CairoError {
  context_hit_test_from_output(result => {
    @context_impl.in_clip_raw(self.to_raw(), x, y, result)
  })
}

///|
pub fn Context::copy_clip_rectangle_list(
  self : Context,
) -> Array[Rectangle] raise CairoError {
  let status = Ref(0)
  let values = @context_impl.copy_clip_rectangle_list_raw(self.to_raw(), status)
  check_context_status_raw(status.val)
  Array::makei(values.length() / 4, index => {
    let offset = index * 4
    Rectangle::new(
      values[offset],
      values[offset + 1],
      values[offset + 2],
      values[offset + 3],
    )
  })
}

///|
pub fn Context::fill_extents(
  self : Context,
) -> (Double, Double, Double, Double) raise CairoError {
  context_extents_from_output((x1, y1, x2, y2) => {
    @context_impl.fill_extents_raw(self.to_raw(), x1, y1, x2, y2)
  })
}

///|
pub fn Context::stroke_extents(
  self : Context,
) -> (Double, Double, Double, Double) raise CairoError {
  context_extents_from_output((x1, y1, x2, y2) => {
    @context_impl.stroke_extents_raw(self.to_raw(), x1, y1, x2, y2)
  })
}

///|
pub fn Context::path_extents(
  self : Context,
) -> (Double, Double, Double, Double) raise CairoError {
  context_extents_from_output((x1, y1, x2, y2) => {
    @context_impl.path_extents_raw(self.to_raw(), x1, y1, x2, y2)
  })
}

///|
fn context_hit_test_from_output(f : (Ref[Int]) -> Int) -> Bool raise CairoError {
  let result = Ref(0)
  check_context_status_raw(f(result))
  result.val != 0
}

///|
pub fn Context::in_fill(
  self : Context,
  x : Double,
  y : Double,
) -> Bool raise CairoError {
  context_hit_test_from_output(result => {
    @context_impl.in_fill_raw(self.to_raw(), x, y, result)
  })
}

///|
pub fn Context::in_stroke(
  self : Context,
  x : Double,
  y : Double,
) -> Bool raise CairoError {
  context_hit_test_from_output(result => {
    @context_impl.in_stroke_raw(self.to_raw(), x, y, result)
  })
}
