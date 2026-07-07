///|
test "vector output scenes match direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    for scene in 0..<10 {
      let cairoon_path = "/tmp/cairoon_vector_scene_\{kind}_\{scene}.\{ext}"
      let oracle_path = "/tmp/cairoon_vector_scene_\{kind}_\{scene}_oracle.\{ext}"
      render_vector_oracle_scene(kind, scene, cairoon_path)
      expect_vector_oracle_match(kind, scene, cairoon_path, oracle_path)
    }
  }
}

///|
test "complex vector output scenes match direct cairo C oracle" {
  for kind in 0..<3 {
    let ext = vector_output_extension(kind)
    for scene in 10..<15 {
      let cairoon_path = "/tmp/cairoon_vector_complex_scene_\{kind}_\{scene}.\{ext}"
      let oracle_path = "/tmp/cairoon_vector_complex_scene_\{kind}_\{scene}_oracle.\{ext}"
      render_vector_oracle_scene(kind, scene, cairoon_path)
      expect_vector_oracle_match(kind, scene, cairoon_path, oracle_path)
    }
  }
}
