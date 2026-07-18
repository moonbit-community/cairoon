///|
enum RegionPropertyOperation {
  RegionPropertyUnion
  RegionPropertyIntersect
  RegionPropertySubtract
  RegionPropertyXor
} derive(Debug)

///|
fn region_property_operation_name(
  operation : RegionPropertyOperation,
) -> String {
  match operation {
    RegionPropertyUnion => "union"
    RegionPropertyIntersect => "intersect"
    RegionPropertySubtract => "subtract"
    RegionPropertyXor => "xor"
  }
}

///|
fn region_property_overlap_name(overlap : @cairoon.RegionOverlap) -> String {
  match overlap {
    RegionOverlapIn => "in"
    RegionOverlapOut => "out"
    RegionOverlapPart => "part"
  }
}

///|
fn region_property_grid_min() -> Int {
  -8
}

///|
fn region_property_grid_side() -> Int {
  16
}

///|
fn region_property_grid_index(x : Int, y : Int) -> Int {
  let offset = region_property_grid_min()
  (y - offset) * region_property_grid_side() + (x - offset)
}

///|
fn region_property_grid_contains(x : Int, y : Int) -> Bool {
  let min = region_property_grid_min()
  let max = min + region_property_grid_side()
  x >= min && x < max && y >= min && y < max
}

///|
fn region_property_rectangle_contains(
  rectangle : @cairoon.RectangleInt,
  x : Int,
  y : Int,
) -> Bool {
  rectangle.width > 0 &&
  rectangle.height > 0 &&
  x >= rectangle.x &&
  x < rectangle.x + rectangle.width &&
  y >= rectangle.y &&
  y < rectangle.y + rectangle.height
}

///|
fn region_property_rectangles(
  seed : Int,
  salt : Int,
) -> Array[@cairoon.RectangleInt] {
  let rectangles : Array[@cairoon.RectangleInt] = []
  for index in 0..<4 {
    let value = seed * 17 + salt * 29 + index * 11
    rectangles.push(
      @cairoon.RectangleInt::new(
        x=-6 + value % 9,
        y=-6 + value / 3 % 9,
        width=value / 5 % 5,
        height=value / 7 % 5,
      ),
    )
  }
  rectangles
}

///|
fn region_property_empty_cells() -> FixedArray[Bool] {
  let side = region_property_grid_side()
  FixedArray::make(side * side, false)
}

///|
fn region_property_cells_from_rectangles(
  rectangles : ArrayView[@cairoon.RectangleInt],
) -> FixedArray[Bool] {
  let cells = region_property_empty_cells()
  let min = region_property_grid_min()
  let max = min + region_property_grid_side()
  for y in min..<max {
    for x in min..<max {
      let mut covered = false
      for rectangle in rectangles {
        if region_property_rectangle_contains(rectangle, x, y) {
          covered = true
        }
      }
      cells[region_property_grid_index(x, y)] = covered
    }
  }
  cells
}

///|
fn region_property_combine_cells(
  left : FixedArray[Bool],
  right : FixedArray[Bool],
  operation : RegionPropertyOperation,
) -> FixedArray[Bool] {
  let result = region_property_empty_cells()
  for index in 0..<result.length() {
    result[index] = match operation {
      RegionPropertyUnion => left[index] || right[index]
      RegionPropertyIntersect => left[index] && right[index]
      RegionPropertySubtract => left[index] && !right[index]
      RegionPropertyXor => left[index] != right[index]
    }
  }
  result
}

///|
fn region_property_translate_cells(
  cells : FixedArray[Bool],
  dx : Int,
  dy : Int,
) -> FixedArray[Bool] {
  let result = region_property_empty_cells()
  let min = region_property_grid_min()
  let max = min + region_property_grid_side()
  for y in min..<max {
    for x in min..<max {
      if cells[region_property_grid_index(x, y)] {
        let translated_x = x + dx
        let translated_y = y + dy
        if region_property_grid_contains(translated_x, translated_y) {
          result[region_property_grid_index(translated_x, translated_y)] = true
        }
      }
    }
  }
  result
}

///|
fn region_property_cells_equal(
  left : FixedArray[Bool],
  right : FixedArray[Bool],
) -> Bool {
  if left.length() != right.length() {
    return false
  }
  for index in 0..<left.length() {
    if left[index] != right[index] {
      return false
    }
  }
  true
}

///|
fn region_property_extents(cells : FixedArray[Bool]) -> @cairoon.RectangleInt {
  let min = region_property_grid_min()
  let max = min + region_property_grid_side()
  let mut seen = false
  let mut min_x = 0
  let mut min_y = 0
  let mut max_x = 0
  let mut max_y = 0
  for y in min..<max {
    for x in min..<max {
      if cells[region_property_grid_index(x, y)] {
        if !seen {
          seen = true
          min_x = x
          min_y = y
          max_x = x
          max_y = y
        } else {
          min_x = min_x.min(x)
          min_y = min_y.min(y)
          max_x = max_x.max(x)
          max_y = max_y.max(y)
        }
      }
    }
  }
  if seen {
    @cairoon.RectangleInt::new(
      x=min_x,
      y=min_y,
      width=max_x - min_x + 1,
      height=max_y - min_y + 1,
    )
  } else {
    @cairoon.RectangleInt::new()
  }
}

///|
fn region_property_overlap(
  cells : FixedArray[Bool],
  rectangle : @cairoon.RectangleInt,
) -> @cairoon.RegionOverlap {
  if rectangle.width <= 0 || rectangle.height <= 0 {
    return RegionOverlapOut
  }
  let mut total = 0
  let mut covered = 0
  for y in rectangle.y..<(rectangle.y + rectangle.height) {
    for x in rectangle.x..<(rectangle.x + rectangle.width) {
      total += 1
      if region_property_grid_contains(x, y) &&
        cells[region_property_grid_index(x, y)] {
        covered += 1
      }
    }
  }
  if covered == 0 {
    RegionOverlapOut
  } else if covered == total {
    RegionOverlapIn
  } else {
    RegionOverlapPart
  }
}

///|
fn region_property_assert_matches(
  region : @cairoon.Region,
  cells : FixedArray[Bool],
  case : String,
) -> Unit raise {
  let min = region_property_grid_min()
  let max = min + region_property_grid_side()
  for y in min..<max {
    for x in min..<max {
      if region.contains_point(x, y) != cells[region_property_grid_index(x, y)] {
        @test.fail("region coverage diverged for \{case} at (\{x}, \{y})")
      }
    }
  }
  let expected_extents = region_property_extents(cells)
  let actual_extents = region.get_extents()
  if expected_extents.width == 0 {
    if actual_extents.width != 0 || actual_extents.height != 0 {
      @test.fail(
        "empty region extents retained area for \{case}: got (\{actual_extents.x}, \{actual_extents.y}, \{actual_extents.width}, \{actual_extents.height})",
      )
    }
  } else if actual_extents != expected_extents {
    @test.fail(
      "region extents diverged for \{case}: expected (\{expected_extents.x}, \{expected_extents.y}, \{expected_extents.width}, \{expected_extents.height}), got (\{actual_extents.x}, \{actual_extents.y}, \{actual_extents.width}, \{actual_extents.height})",
    )
  }
  if region.is_empty() != (expected_extents.width == 0) {
    @test.fail("region emptiness diverged from the independent grid oracle")
  }
}

///|
fn region_property_apply_region_operation(
  left : @cairoon.Region,
  right : @cairoon.Region,
  operation : RegionPropertyOperation,
) -> Unit raise {
  let _ = match operation {
    RegionPropertyUnion => left.union(right)
    RegionPropertyIntersect => left.intersect(right)
    RegionPropertySubtract => left.subtract(right)
    RegionPropertyXor => left.xor(right)
  }
}

///|
fn region_property_apply_rectangle_operation(
  left : @cairoon.Region,
  right : @cairoon.RectangleInt,
  operation : RegionPropertyOperation,
) -> Unit raise {
  let _ = match operation {
    RegionPropertyUnion => left.union_rectangle(right)
    RegionPropertyIntersect => left.intersect_rectangle(right)
    RegionPropertySubtract => left.subtract_rectangle(right)
    RegionPropertyXor => left.xor_rectangle(right)
  }
}
