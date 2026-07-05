///|
#borrow(filename, status)
extern "C" fn pdf_surface_create_ffi(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Status],
) -> Surface = "cairoon_pdf_surface_create"

///|
#borrow(call_writer, status)
#owned(writer)
extern "C" fn pdf_surface_create_for_stream_ffi(
  call_writer : FuncRef[(Bytes, (Bytes) -> Status) -> Status],
  writer : (Bytes) -> Status,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Status],
) -> Surface = "cairoon_pdf_surface_create_for_stream"

///|
#borrow(status)
extern "C" fn pdf_get_version_count_ffi(status : Ref[Status]) -> Int = "cairoon_pdf_get_version_count"

///|
#borrow(status)
extern "C" fn pdf_get_version_ffi(
  index : Int,
  status : Ref[Status],
) -> PDFVersion = "cairoon_pdf_get_version"

///|
#borrow(status)
extern "C" fn pdf_version_to_string_ffi(
  version : PDFVersion,
  status : Ref[Status],
) -> Bytes = "cairoon_pdf_version_to_string"

///|
#borrow(surface)
extern "C" fn pdf_surface_restrict_to_version_ffi(
  surface : Surface,
  version : PDFVersion,
) -> Status = "cairoon_pdf_surface_restrict_to_version"

///|
#borrow(surface)
extern "C" fn pdf_surface_set_size_ffi(
  surface : Surface,
  width_in_points : Double,
  height_in_points : Double,
) -> Status = "cairoon_pdf_surface_set_size"

///|
#borrow(surface, value)
extern "C" fn pdf_surface_set_metadata_ffi(
  surface : Surface,
  metadata : PDFMetadata,
  value : Bytes,
) -> Status = "cairoon_pdf_surface_set_metadata"

///|
#borrow(surface, name, value)
extern "C" fn pdf_surface_set_custom_metadata_ffi(
  surface : Surface,
  name : Bytes,
  has_value : Bool,
  value : Bytes,
) -> Status = "cairoon_pdf_surface_set_custom_metadata"

///|
#borrow(surface, label)
extern "C" fn pdf_surface_set_page_label_ffi(
  surface : Surface,
  label : Bytes,
) -> Status = "cairoon_pdf_surface_set_page_label"

///|
#borrow(surface)
extern "C" fn pdf_surface_set_thumbnail_size_ffi(
  surface : Surface,
  width : Int,
  height : Int,
) -> Status = "cairoon_pdf_surface_set_thumbnail_size"

///|
#borrow(surface, title, link_attributes, status)
extern "C" fn pdf_surface_add_outline_bits_ffi(
  surface : Surface,
  parent_id : Int,
  title : Bytes,
  link_attributes : Bytes,
  flags : Int,
  status : Ref[Status],
) -> Int = "cairoon_pdf_surface_add_outline"
