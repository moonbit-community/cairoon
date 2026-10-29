///|
#borrow(filename, status)
extern "C" fn pdf_surface_create_ffi(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Int32],
) -> RawSurface = "cairoon_pdf_surface_create"

///|
#borrow(call_writer, status)
#owned(writer)
extern "C" fn pdf_surface_create_for_stream_ffi(
  call_writer : FuncRef[(Bytes, (Bytes) -> Int32) -> Int32],
  writer : (Bytes) -> Int32,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Int32],
) -> RawSurface = "cairoon_pdf_surface_create_for_stream"

///|
#borrow(surface)
extern "C" fn pdf_surface_restrict_to_version_ffi(
  surface : RawSurface,
  version : Int32,
) -> Int32 = "cairoon_pdf_surface_restrict_to_version"

///|
#borrow(surface)
extern "C" fn pdf_surface_set_size_ffi(
  surface : RawSurface,
  width_in_points : Double,
  height_in_points : Double,
) -> Int32 = "cairoon_pdf_surface_set_size"

///|
#borrow(surface, value)
extern "C" fn pdf_surface_set_metadata_ffi(
  surface : RawSurface,
  metadata : Int32,
  value : Bytes,
) -> Int32 = "cairoon_pdf_surface_set_metadata"

///|
#borrow(surface, name, value)
extern "C" fn pdf_surface_set_custom_metadata_ffi(
  surface : RawSurface,
  name : Bytes,
  has_value : Bool,
  value : Bytes,
) -> Int32 = "cairoon_pdf_surface_set_custom_metadata"

///|
#borrow(surface, label)
extern "C" fn pdf_surface_set_page_label_ffi(
  surface : RawSurface,
  label : Bytes,
) -> Int32 = "cairoon_pdf_surface_set_page_label"

///|
#borrow(surface)
extern "C" fn pdf_surface_set_thumbnail_size_ffi(
  surface : RawSurface,
  width : Int32,
  height : Int32,
) -> Int32 = "cairoon_pdf_surface_set_thumbnail_size"

///|
#borrow(surface, title, link_attributes, status)
extern "C" fn pdf_surface_add_outline_bits_ffi(
  surface : RawSurface,
  parent_id : Int32,
  title : Bytes,
  link_attributes : Bytes,
  flags : Int32,
  status : Ref[Int32],
) -> Int32 = "cairoon_pdf_surface_add_outline"
