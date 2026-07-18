///|
fn region_property_operations() -> Array[RegionPropertyOperation] {
  [
    RegionPropertyUnion,
    RegionPropertyIntersect,
    RegionPropertySubtract,
    RegionPropertyXor,
  ]
}

///|
test "region property construction containment and extents match grid oracle" {
  for seed in 0..<32 {
    let rectangles = region_property_rectangles(seed, 0)
    let cells = region_property_cells_from_rectangles(rectangles)
    let region = @cairoon.Region::from_rectangles(rectangles)
    region_property_assert_matches(region, cells, "construction seed \{seed}")
    for rectangle in rectangles {
      let single = @cairoon.Region::from_rectangle(rectangle)
      region_property_assert_matches(
        single,
        region_property_cells_from_rectangles([rectangle]),
        "single rectangle seed \{seed}: (\{rectangle.x}, \{rectangle.y}, \{rectangle.width}, \{rectangle.height})",
      )
    }
    for query in region_property_rectangles(seed, 3) {
      if query.width > 0 &&
        query.height > 0 &&
        region.contains_rectangle(query) !=
        region_property_overlap(cells, query) {
        let expected = region_property_overlap(cells, query)
        let actual = region.contains_rectangle(query)
        @test.fail(
          "region overlap diverged for seed \{seed}, query (\{query.x}, \{query.y}, \{query.width}, \{query.height}): expected \{region_property_overlap_name(expected)}, got \{region_property_overlap_name(actual)}",
        )
      }
    }
  }
}

///|
test "region property boolean operations match grid oracle" {
  for seed in 0..<32 {
    let left_rectangles = region_property_rectangles(seed, 1)
    let right_rectangles = region_property_rectangles(seed, 2)
    let left_cells = region_property_cells_from_rectangles(left_rectangles)
    let right_cells = region_property_cells_from_rectangles(right_rectangles)
    for operation in region_property_operations() {
      let left = @cairoon.Region::from_rectangles(left_rectangles)
      let right = @cairoon.Region::from_rectangles(right_rectangles)
      region_property_apply_region_operation(left, right, operation)
      region_property_assert_matches(
        left,
        region_property_combine_cells(left_cells, right_cells, operation),
        "region operation seed \{seed}: \{region_property_operation_name(operation)}",
      )
      region_property_assert_matches(
        right,
        right_cells,
        "unchanged right operand seed \{seed}",
      )
    }
  }
}

///|
test "region property rectangle operations match grid oracle" {
  for seed in 0..<32 {
    let left_rectangles = region_property_rectangles(seed, 4)
    let right = region_property_rectangles(seed, 5)[seed % 4]
    let left_cells = region_property_cells_from_rectangles(left_rectangles)
    let right_cells = region_property_cells_from_rectangles([right])
    for operation in region_property_operations() {
      let left = @cairoon.Region::from_rectangles(left_rectangles)
      region_property_apply_rectangle_operation(left, right, operation)
      region_property_assert_matches(
        left,
        region_property_combine_cells(left_cells, right_cells, operation),
        "rectangle operation seed \{seed}: \{region_property_operation_name(operation)}, right (\{right.x}, \{right.y}, \{right.width}, \{right.height})",
      )
    }
  }
}

///|
test "region property copy translate and equality preserve coverage" {
  for seed in 0..<32 {
    let rectangles = region_property_rectangles(seed, 6)
    let cells = region_property_cells_from_rectangles(rectangles)
    let original = @cairoon.Region::from_rectangles(rectangles)
    let translated = original.copy()
    let dx = seed % 3 - 1
    let dy = seed / 3 % 3 - 1
    translated.translate(dx, dy)
    let translated_cells = region_property_translate_cells(cells, dx, dy)
    region_property_assert_matches(
      original,
      cells,
      "translate source seed \{seed}",
    )
    region_property_assert_matches(
      translated,
      translated_cells,
      "translated seed \{seed} by (\{dx}, \{dy})",
    )
    if original.equal(translated) !=
      region_property_cells_equal(cells, translated_cells) {
      @test.fail("region equality diverged from the independent grid oracle")
    }
  }
}
