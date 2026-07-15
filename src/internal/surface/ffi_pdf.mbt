///|
#borrow(filename, status)
extern "C" fn pdf_surface_create_ffi(
  has_filename : Bool,
  filename : Bytes,
  width_in_points : Double,
  height_in_points : Double,
  status : Ref[Int],
) -> RawSurface = "cairoon_pdf_surface_create"

///|
#borrow(surface)
extern "C" fn pdf_surface_restrict_to_version_ffi(
  surface : RawSurface,
  version : Int,
) -> Int = "cairoon_pdf_surface_restrict_to_version"

///|
#borrow(surface)
extern "C" fn pdf_surface_set_size_ffi(
  surface : RawSurface,
  width_in_points : Double,
  height_in_points : Double,
) -> Int = "cairoon_pdf_surface_set_size"

///|
#borrow(surface, value)
extern "C" fn pdf_surface_set_metadata_ffi(
  surface : RawSurface,
  metadata : Int,
  value : Bytes,
) -> Int = "cairoon_pdf_surface_set_metadata"

///|
#borrow(surface, name, value)
extern "C" fn pdf_surface_set_custom_metadata_ffi(
  surface : RawSurface,
  name : Bytes,
  has_value : Bool,
  value : Bytes,
) -> Int = "cairoon_pdf_surface_set_custom_metadata"

///|
#borrow(surface, label)
extern "C" fn pdf_surface_set_page_label_ffi(
  surface : RawSurface,
  label : Bytes,
) -> Int = "cairoon_pdf_surface_set_page_label"

///|
#borrow(surface)
extern "C" fn pdf_surface_set_thumbnail_size_ffi(
  surface : RawSurface,
  width : Int,
  height : Int,
) -> Int = "cairoon_pdf_surface_set_thumbnail_size"

///|
#borrow(surface, title, link_attributes, status)
extern "C" fn pdf_surface_add_outline_bits_ffi(
  surface : RawSurface,
  parent_id : Int,
  title : Bytes,
  link_attributes : Bytes,
  flags : Int,
  status : Ref[Int],
) -> Int = "cairoon_pdf_surface_add_outline"
