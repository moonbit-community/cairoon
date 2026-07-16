///|
/// Create an empty tensor-product mesh pattern.
///
/// Mesh patterns require Cairo 1.12 or newer. Define one or more complete
/// patches before drawing; using a partially open patch produces
/// `InvalidMeshConstruction`. The returned pattern is independently owned.
pub fn Pattern::mesh() -> Pattern raise CairoError {
  let raw = @pattern_impl.create_mesh_raw()
  check_pattern_status_raw(@pattern_impl.status_raw(raw))
  Pattern::from_raw(raw)
}

///|
/// Begin a new patch in this mesh pattern.
///
/// Follow with one initial point, up to four sides, optional control points and
/// corner colors, then `mesh_end_patch()`. Raises `PatternTypeMismatch` on a
/// non-mesh or `InvalidMeshConstruction` if a patch is already open.
pub fn Pattern::mesh_begin_patch(self : Pattern) -> Unit raise CairoError {
  check_pattern_status_raw(@pattern_impl.mesh_begin_patch_raw(self.to_raw()))
}

///|
/// Complete the current mesh patch.
///
/// Cairo closes fewer than four sides back to the first point and fills any
/// remaining sides degenerately there. Corners introduced by that closing copy
/// corner 0; other unset colors stay transparent black. Unspecified internal
/// controls use Coons-patch defaults. Raises `InvalidMeshConstruction` if no
/// usable patch is open.
pub fn Pattern::mesh_end_patch(self : Pattern) -> Unit raise CairoError {
  check_pattern_status_raw(@pattern_impl.mesh_end_patch_raw(self.to_raw()))
}

///|
/// Define the first point of the open patch in pattern-space coordinates.
///
/// This point is corner 0 and becomes current. Raises `PatternTypeMismatch` on
/// a non-mesh or `InvalidMeshConstruction` without an open patch or after a
/// side has already been added.
pub fn Pattern::mesh_move_to(
  self : Pattern,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_pattern_status_raw(@pattern_impl.mesh_move_to_raw(self.to_raw(), x, y))
}

///|
/// Add a straight side to the open patch in pattern space.
///
/// With no current point this behaves like `mesh_move_to(x, y)`; otherwise the
/// endpoint becomes current. Raises `InvalidMeshConstruction` without an open
/// patch or after four sides, and `PatternTypeMismatch` on a non-mesh.
pub fn Pattern::mesh_line_to(
  self : Pattern,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_pattern_status_raw(@pattern_impl.mesh_line_to_raw(self.to_raw(), x, y))
}

///|
/// Add a cubic Bezier side to the open patch in pattern space.
///
/// `(x1, y1)` and `(x2, y2)` are controls and `(x3, y3)` becomes current. With
/// no current point Cairo first moves to `(x1, y1)`. Raises
/// `InvalidMeshConstruction` without an open patch or after four sides.
pub fn Pattern::mesh_curve_to(
  self : Pattern,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  x3 : Double,
  y3 : Double,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.mesh_curve_to_raw(self.to_raw(), x1, y1, x2, y2, x3, y3),
  )
}

///|
/// Set one internal control point of the open tensor-product patch.
///
/// `point_num` must be `0..3`; coordinates are in pattern space. Unspecified
/// points retain their Coons-patch defaults. Raises `InvalidIndex`,
/// `InvalidMeshConstruction`, `PatternTypeMismatch`, or another sticky status.
pub fn Pattern::mesh_set_control_point(
  self : Pattern,
  point_num : Int,
  x : Double,
  y : Double,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.mesh_set_control_point_raw(self.to_raw(), point_num, x, y),
  )
}

///|
/// Set an opaque color for one corner of the open patch.
///
/// `corner_num` must be `0..3`; RGB components are clamped to `[0.0, 1.0]`.
/// Unspecified corners default to transparent black before patch completion.
/// Raises `InvalidIndex`, `InvalidMeshConstruction`, or `PatternTypeMismatch`.
pub fn Pattern::mesh_set_corner_color_rgb(
  self : Pattern,
  corner_num : Int,
  red : Double,
  green : Double,
  blue : Double,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.mesh_set_corner_color_rgb_raw(
      self.to_raw(),
      corner_num,
      red,
      green,
      blue,
    ),
  )
}

///|
/// Set an RGBA color for one corner of the open patch.
///
/// `corner_num` must be `0..3`, and components are clamped to `[0.0, 1.0]`.
/// Raises `InvalidIndex`, `InvalidMeshConstruction`, `PatternTypeMismatch`, or
/// another sticky pattern status.
pub fn Pattern::mesh_set_corner_color_rgba(
  self : Pattern,
  corner_num : Int,
  red : Double,
  green : Double,
  blue : Double,
  alpha : Double,
) -> Unit raise CairoError {
  check_pattern_status_raw(
    @pattern_impl.mesh_set_corner_color_rgba_raw(
      self.to_raw(),
      corner_num,
      red,
      green,
      blue,
      alpha,
    ),
  )
}

///|
/// Return the number of completed patches in this mesh.
///
/// The currently open patch is not a drawable completed patch. Raises
/// `PatternTypeMismatch` on another subtype and propagates sticky errors.
pub fn Pattern::mesh_get_patch_count(self : Pattern) -> Int raise CairoError {
  let count = Ref(0)
  check_pattern_status_raw(
    @pattern_impl.mesh_get_patch_count_raw(self.to_raw(), count),
  )
  count.val
}

///|
/// Copy the boundary path of completed patch `patch_num`.
///
/// The returned `Path` owns an independent native snapshot and remains usable
/// after this pattern leaves scope. Raises `InvalidIndex` for an unknown patch,
/// `PatternTypeMismatch` for a non-mesh, or a path/allocation status.
pub fn Pattern::mesh_get_path(
  self : Pattern,
  patch_num : Int,
) -> Path raise CairoError {
  let status = Ref(0)
  let raw = @pattern_impl.mesh_get_path_raw(self.to_raw(), patch_num, status)
  check_pattern_status_raw(status.val)
  check_path_status_raw(@path_impl.status_raw(raw))
  Path::from_raw(raw)
}

///|
/// Return internal control point `point_num` of completed patch `patch_num`.
///
/// Both indices are zero-based and the control-point index must be `0..3`.
/// Coordinates are in pattern space. Raises `InvalidIndex`,
/// `PatternTypeMismatch`, or an existing sticky error.
pub fn Pattern::mesh_get_control_point(
  self : Pattern,
  patch_num : Int,
  point_num : Int,
) -> (Double, Double) raise CairoError {
  let x = Ref(0.0)
  let y = Ref(0.0)
  check_pattern_status_raw(
    @pattern_impl.mesh_get_control_point_raw(
      self.to_raw(),
      patch_num,
      point_num,
      x,
      y,
    ),
  )
  (x.val, y.val)
}

///|
/// Return one completed patch corner as unpremultiplied RGBA.
///
/// `patch_num` is zero-based and `corner_num` must be `0..3`; components are in
/// `[0.0, 1.0]`. Raises `InvalidIndex`, `PatternTypeMismatch`, or an existing
/// sticky pattern error.
pub fn Pattern::mesh_get_corner_color_rgba(
  self : Pattern,
  patch_num : Int,
  corner_num : Int,
) -> (Double, Double, Double, Double) raise CairoError {
  let red = Ref(0.0)
  let green = Ref(0.0)
  let blue = Ref(0.0)
  let alpha = Ref(0.0)
  check_pattern_status_raw(
    @pattern_impl.mesh_get_corner_color_rgba_raw(
      self.to_raw(),
      patch_num,
      corner_num,
      red,
      green,
      blue,
      alpha,
    ),
  )
  (red.val, green.val, blue.val, alpha.val)
}
