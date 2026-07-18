///|
test "path property generated command model survives copy and append" {
  for seed in 0..<32 {
    let (context, path, expected, current) = path_property_build_model(seed)
    path_property_assert_point(
      context.get_current_point(),
      current,
      "source seed \{seed}",
    )
    path_property_assert_roundtrip(path, expected, current, "seed \{seed}")

    context.new_path()
    context.move_to(100.0, 200.0)
    context.line_to(300.0, 400.0)
    path_property_assert_roundtrip(
      path,
      expected,
      current,
      "saved seed \{seed} after source mutation",
    )
  }
}

///|
test "path property flattened copies contain only replayable line data" {
  for seed in 0..<32 {
    let (context, _, _, current) = path_property_build_model(seed)
    let flat = context.copy_path_flat()
    let flat_segments = flat.segments()
    for segment in flat_segments {
      match segment {
        PathSegmentCurveTo(_, _, _, _, _, _) =>
          @test.fail("copy_path_flat retained a curve segment")
        _ => ()
      }
    }
    if flat.length() != flat_segments.length() {
      @test.fail("flattened Path::length diverged from segments")
    }
    let replay = path_property_new_context()
    replay.append_path(flat)
    path_property_assert_segments(
      replay.copy_path().segments(),
      path_property_canonicalize_replay(flat_segments),
      "flattened replay seed \{seed}",
    )
    path_property_assert_point(
      replay.get_current_point(),
      current,
      "flattened replay seed \{seed}",
    )
  }
}
