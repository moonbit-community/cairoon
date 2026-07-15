///|
#borrow(ctx, family)
extern "C" fn context_select_font_face_ffi(
  ctx : @context_impl.RawContext,
  family : Bytes,
  slant : FontSlant,
  weight : FontWeight,
) -> Status = "cairoon_context_select_font_face"

///|
#borrow(ctx, text, indices, xs, ys, cluster_num_bytes, cluster_num_glyphs)
extern "C" fn context_show_text_glyphs_ffi(
  ctx : @context_impl.RawContext,
  text : Bytes,
  indices : FixedArray[UInt64],
  xs : FixedArray[Double],
  ys : FixedArray[Double],
  cluster_num_bytes : FixedArray[Int],
  cluster_num_glyphs : FixedArray[Int],
  flags : TextClusterFlags,
) -> Status = "cairoon_context_show_text_glyphs"
