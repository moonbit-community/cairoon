///|
pub fn Surface::pdf(
  width_in_points : Double,
  height_in_points : Double,
  path? : String? = None,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let (has_filename, filename) = match path {
    None => (false, @utf8.encode(""))
    Some(path) => (true, checked_path_bytes(path))
  }
  let surface = pdf_surface_create_ffi(
    has_filename, filename, width_in_points, height_in_points, status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn Surface::pdf_stream(
  width_in_points : Double,
  height_in_points : Double,
  writer : (Bytes) -> Status,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let surface = pdf_surface_create_for_stream_ffi(
    fn(chunk, writer) { writer(copy_stream_chunk(chunk)) },
    writer,
    width_in_points,
    height_in_points,
    status,
  )
  check_status(status.val)
  check_status(surface_status_ffi(surface))
  surface
}

///|
pub fn PDFVersion::supported() -> Array[PDFVersion] raise CairoError {
  let status = Ref(0)
  let count = @pdf_impl.get_version_count_raw(status)
  check_status(status_from_raw(status.val))
  let versions : Array[PDFVersion] = Array::new(capacity=count)
  for index in 0..<count {
    let version = pdf_version_from_raw(@pdf_impl.get_version_raw(index, status))
    check_status(status_from_raw(status.val))
    versions.push(version)
  }
  versions
}

///|
pub fn PDFVersion::to_string(self : PDFVersion) -> String raise CairoError {
  let status = Ref(0)
  let text = @pdf_impl.version_to_string_raw(self.to_raw(), status)
  check_status(status_from_raw(status.val))
  text
}

///|
pub fn PDFVersion::to_string_raw(version : Int) -> String raise CairoError {
  let status = Ref(0)
  let text = @pdf_impl.version_to_string_raw(version, status)
  check_status(status_from_raw(status.val))
  text
}

///|
fn PDFVersion::to_raw(self : PDFVersion) -> Int {
  match self {
    PdfVersion1_4 => 0
    PdfVersion1_5 => 1
    PdfVersion1_6 => 2
    PdfVersion1_7 => 3
  }
}

///|
fn pdf_version_from_raw(raw : Int) -> PDFVersion raise CairoError {
  match raw {
    0 => PdfVersion1_4
    1 => PdfVersion1_5
    2 => PdfVersion1_6
    3 => PdfVersion1_7
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo pdf version: \{raw}",
      )
  }
}

///|
pub struct PDFOutlineFlagSet {
  bits : Int
} derive(Eq, @debug.Debug)

///|
pub fn PDFOutlineFlags::bits(self : PDFOutlineFlags) -> Int {
  match self {
    PdfOutlineOpen => 0x01
    PdfOutlineBold => 0x02
    PdfOutlineItalic => 0x04
  }
}

///|
pub fn PDFOutlineFlagSet::none() -> PDFOutlineFlagSet {
  { bits: 0 }
}

///|
pub fn PDFOutlineFlagSet::of(flag : PDFOutlineFlags) -> PDFOutlineFlagSet {
  { bits: flag.bits() }
}

///|
pub fn PDFOutlineFlagSet::from_bits(bits : Int) -> PDFOutlineFlagSet {
  { bits, }
}

///|
pub fn PDFOutlineFlagSet::combine(
  flags : ArrayView[PDFOutlineFlags],
) -> PDFOutlineFlagSet {
  let mut bits = 0
  for flag in flags {
    bits = bits.lor(flag.bits())
  }
  { bits, }
}

///|
pub fn PDFOutlineFlagSet::add(
  self : PDFOutlineFlagSet,
  flag : PDFOutlineFlags,
) -> PDFOutlineFlagSet {
  { bits: self.bits.lor(flag.bits()) }
}

///|
pub fn PDFOutlineFlagSet::contains(
  self : PDFOutlineFlagSet,
  flag : PDFOutlineFlags,
) -> Bool {
  self.bits.land(flag.bits()) != 0
}

///|
pub fn PDFOutlineFlagSet::bits(self : PDFOutlineFlagSet) -> Int {
  self.bits
}

///|
pub fn Surface::pdf_restrict_to_version(
  self : Surface,
  version : PDFVersion,
) -> Unit raise CairoError {
  check_status(pdf_surface_restrict_to_version_ffi(self, version))
}

///|
pub fn Surface::pdf_restrict_to_version_raw(
  self : Surface,
  version : Int,
) -> Unit raise CairoError {
  check_status(pdf_surface_restrict_to_version_raw_ffi(self, version))
}

///|
pub fn Surface::pdf_set_size(
  self : Surface,
  width_in_points : Double,
  height_in_points : Double,
) -> Unit raise CairoError {
  check_status(
    pdf_surface_set_size_ffi(self, width_in_points, height_in_points),
  )
}

///|
pub fn Surface::pdf_set_metadata(
  self : Surface,
  metadata : PDFMetadata,
  value : String,
) -> Unit raise CairoError {
  check_status(
    pdf_surface_set_metadata_ffi(self, metadata, checked_c_string_bytes(value)),
  )
}

///|
pub fn Surface::pdf_set_metadata_raw(
  self : Surface,
  metadata : Int,
  value : String,
) -> Unit raise CairoError {
  check_status(
    pdf_surface_set_metadata_raw_ffi(
      self,
      metadata,
      checked_c_string_bytes(value),
    ),
  )
}

///|
pub fn Surface::pdf_set_custom_metadata(
  self : Surface,
  name : String,
  value : String?,
) -> Unit raise CairoError {
  let (has_value, bytes) = match value {
    None => (false, @utf8.encode(""))
    Some(value) => (true, checked_c_string_bytes(value))
  }
  check_status(
    pdf_surface_set_custom_metadata_ffi(
      self,
      checked_c_string_bytes(name),
      has_value,
      bytes,
    ),
  )
}

///|
pub fn Surface::pdf_set_page_label(
  self : Surface,
  label : String,
) -> Unit raise CairoError {
  check_status(
    pdf_surface_set_page_label_ffi(self, checked_c_string_bytes(label)),
  )
}

///|
pub fn Surface::pdf_set_thumbnail_size(
  self : Surface,
  width : Int,
  height : Int,
) -> Unit raise CairoError {
  check_status(pdf_surface_set_thumbnail_size_ffi(self, width, height))
}

///|
pub fn Surface::pdf_add_outline(
  self : Surface,
  parent_id : Int,
  title : String,
  link_attributes : String,
  flags : PDFOutlineFlags,
) -> Int raise CairoError {
  self.pdf_add_outline_with_flags(
    parent_id,
    title,
    link_attributes,
    PDFOutlineFlagSet::of(flags),
  )
}

///|
pub fn Surface::pdf_add_outline_with_flags(
  self : Surface,
  parent_id : Int,
  title : String,
  link_attributes : String,
  flags : PDFOutlineFlagSet,
) -> Int raise CairoError {
  let status = Ref(Success)
  let id = pdf_surface_add_outline_bits_ffi(
    self,
    parent_id,
    checked_c_string_bytes(title),
    checked_c_string_bytes(link_attributes),
    flags.bits(),
    status,
  )
  check_status(status.val)
  id
}

///|
pub fn Surface::pdf_add_outline_raw(
  self : Surface,
  parent_id : Int,
  title : String,
  link_attributes : String,
  flags : Int,
) -> Int raise CairoError {
  let status = Ref(Success)
  let id = pdf_surface_add_outline_bits_ffi(
    self,
    parent_id,
    checked_c_string_bytes(title),
    checked_c_string_bytes(link_attributes),
    flags,
    status,
  )
  check_status(status.val)
  id
}
