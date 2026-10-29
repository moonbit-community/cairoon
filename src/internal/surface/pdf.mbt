///|
pub fn pdf_create_raw(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Int32],
) -> RawSurface {
  ensure_native()
  pdf_surface_create_ffi(
    has_filename, filename, width_in_points, height_in_points, status,
  )
}

///|
pub fn pdf_create_stream_raw(
  writer : (Bytes) -> Int32,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Int32],
) -> RawSurface {
  ensure_native()
  pdf_surface_create_for_stream_ffi(
    fn(chunk, writer) { writer(@stream_impl.copy_chunk(chunk)) },
    writer,
    width_in_points,
    height_in_points,
    status,
  )
}

///|
pub fn pdf_restrict_to_version_raw(
  surface : RawSurface,
  version : Int32,
) -> Int32 {
  ensure_native()
  pdf_surface_restrict_to_version_ffi(surface, version)
}

///|
pub fn pdf_set_size_raw(
  surface : RawSurface,
  width_in_points : Double,
  height_in_points : Double,
) -> Int32 {
  ensure_native()
  pdf_surface_set_size_ffi(surface, width_in_points, height_in_points)
}

///|
pub fn pdf_set_metadata_raw(
  surface : RawSurface,
  metadata : Int32,
  value : Bytes,
) -> Int32 {
  ensure_native()
  pdf_surface_set_metadata_ffi(surface, metadata, value)
}

///|
pub fn pdf_set_custom_metadata_raw(
  surface : RawSurface,
  name : Bytes,
  has_value : Bool,
  value : Bytes,
) -> Int32 {
  ensure_native()
  pdf_surface_set_custom_metadata_ffi(surface, name, has_value, value)
}

///|
pub fn pdf_set_page_label_raw(surface : RawSurface, label : Bytes) -> Int32 {
  ensure_native()
  pdf_surface_set_page_label_ffi(surface, label)
}

///|
pub fn pdf_set_thumbnail_size_raw(
  surface : RawSurface,
  width : Int32,
  height : Int32,
) -> Int32 {
  ensure_native()
  pdf_surface_set_thumbnail_size_ffi(surface, width, height)
}

///|
pub fn pdf_add_outline_bits_raw(
  surface : RawSurface,
  parent_id : Int32,
  title : Bytes,
  link_attributes : Bytes,
  flags : Int32,
  status : Ref[Int32],
) -> Int32 {
  ensure_native()
  pdf_surface_add_outline_bits_ffi(
    surface, parent_id, title, link_attributes, flags, status,
  )
}
