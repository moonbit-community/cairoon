///|
/// Create an owning multi-page PDF surface measured in points.
///
/// One point is 1/72 inch. `None` creates a queryable/drawable no-output
/// surface that can also be used as a source; `Some(path)` writes to that UTF-8
/// filename and rejects embedded NUL with
/// `CairoInvalidArgument(InvalidString, _)`. Use `pdf_set_size` between pages
/// when page dimensions differ, and call `finish` to finalize output and report
/// write errors. This requires Cairo's PDF backend (available since Cairo 1.2).
pub fn Surface::pdf(
  width_in_points : Double,
  height_in_points : Double,
  path? : String? = None,
) -> Surface raise CairoError {
  let status = Ref(0)
  let (has_filename, filename) = match path {
    None => (false, @utf8.encode(""))
    Some(path) => (true, checked_path_bytes(path))
  }
  let raw = @surface_impl.pdf_create_raw(
    has_filename, filename, width_in_points, height_in_points, status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Create an owning PDF surface that sends encoded bytes to `writer`.
///
/// Width and height are points. Cairoon retains the writer until the Surface is
/// collected and gives it independent `Bytes` chunks that remain valid after
/// each callback. Return `Success` to continue; callback failures are raised by
/// drawing or `finish`, and non-writer statuses such as `LastStatus` become
/// `CairoIOError(WriteError, _)`. Construction failures release the writer only
/// after Cairo can no longer invoke it.
pub fn Surface::pdf_stream(
  width_in_points : Double,
  height_in_points : Double,
  writer : (Bytes) -> Status,
) -> Surface raise CairoError {
  let status = Ref(0)
  let raw = @surface_impl.pdf_create_stream_raw(
    fn(chunk) { writer(chunk).to_raw() },
    width_in_points,
    height_in_points,
    status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Return a fresh array of PDF versions supported by linked Cairo.
///
/// Query this list instead of assuming every `PDFVersion` constructor is
/// available: PDF 1.6 and 1.7 output support arrived after 1.4 and 1.5. The
/// result is copied from Cairo's static table and may be mutated by the caller.
/// An unavailable PDF backend raises `CairoError(InvalidStatus, _)`.
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
/// Return a copied Cairo display string for this PDF version.
///
/// A typed constructor that linked Cairo does not support, such as PDF 1.7 on
/// the 1.15.10 compatibility floor, raises `CairoError(InvalidStatus, _)`.
/// The returned string does not borrow Cairo storage.
pub fn PDFVersion::to_string(self : PDFVersion) -> String raise CairoError {
  let status = Ref(0)
  let text = @pdf_impl.version_to_string_raw(self.to_raw(), status)
  check_status(status_from_raw(status.val))
  text
}

///|
/// Convert a pycairo-compatible `cairo_pdf_version_t` integer to text.
///
/// Raw ids are `0` (1.4), `1` (1.5), `2` (1.6), and `3` (1.7), but an id is
/// valid only when present in `PDFVersion::supported()`. Negative, unavailable,
/// and other unknown values raise `CairoError(InvalidStatus, _)`; the returned
/// string is copied into MoonBit-owned storage.
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
fn PDFMetadata::to_raw(self : PDFMetadata) -> Int {
  match self {
    PdfMetadataTitle => 0
    PdfMetadataAuthor => 1
    PdfMetadataSubject => 2
    PdfMetadataKeywords => 3
    PdfMetadataCreator => 4
    PdfMetadataCreateDate => 5
    PdfMetadataModDate => 6
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
/// An immutable PDF outline flag bitset.
///
/// Use `none`, `of`, `combine`, and `add` for the portable Open/Bold/Italic
/// bits. `from_bits` preserves an exact pycairo-compatible integer for ported
/// code; bits outside the known `0x07` mask have no portable Cairo semantics.
pub struct PDFOutlineFlagSet {
  bits : Int
} derive(Eq, @debug.Debug)

///|
/// Return this flag's Cairo bit: Open=`0x01`, Bold=`0x02`, Italic=`0x04`.
pub fn PDFOutlineFlags::bits(self : PDFOutlineFlags) -> Int {
  match self {
    PdfOutlineOpen => 0x01
    PdfOutlineBold => 0x02
    PdfOutlineItalic => 0x04
  }
}

///|
/// Return an empty outline flag set with raw value zero.
pub fn PDFOutlineFlagSet::none() -> PDFOutlineFlagSet {
  { bits: 0 }
}

///|
/// Create a set containing exactly one typed outline flag.
pub fn PDFOutlineFlagSet::of(flag : PDFOutlineFlags) -> PDFOutlineFlagSet {
  { bits: flag.bits() }
}

///|
/// Preserve an exact raw outline bitset for pycairo-compatible code.
///
/// Known portable bits occupy mask `0x07`. Other bits are retained by
/// `bits()` and passed unchanged by raw outline APIs, but their PDF rendering
/// behavior is unsupported.
pub fn PDFOutlineFlagSet::from_bits(bits : Int) -> PDFOutlineFlagSet {
  { bits, }
}

///|
/// Combine typed outline flags with bitwise OR.
///
/// The returned value is independent of `flags`; duplicate entries are
/// idempotent and an empty view produces `PDFOutlineFlagSet::none()`.
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
/// Return a new set with `flag` added; the receiver is unchanged.
pub fn PDFOutlineFlagSet::add(
  self : PDFOutlineFlagSet,
  flag : PDFOutlineFlags,
) -> PDFOutlineFlagSet {
  { bits: self.bits.lor(flag.bits()) }
}

///|
/// Return whether this set contains the selected typed flag bit.
pub fn PDFOutlineFlagSet::contains(
  self : PDFOutlineFlagSet,
  flag : PDFOutlineFlags,
) -> Bool {
  self.bits.land(flag.bits()) != 0
}

///|
/// Return the exact stored C-compatible bitset.
pub fn PDFOutlineFlagSet::bits(self : PDFOutlineFlagSet) -> Int {
  self.bits
}

///|
/// Restrict generated output to a PDF version supported by linked Cairo.
///
/// Call this immediately after construction and before any drawing. A typed
/// version absent from `PDFVersion::supported()` raises
/// `CairoError(InvalidStatus, _)` without calling Cairo's restriction function.
/// Finished and non-PDF surfaces raise `SurfaceFinished` and
/// `SurfaceTypeMismatch` respectively. The underlying Cairo API is available
/// since 1.10.
pub fn Surface::pdf_restrict_to_version(
  self : Surface,
  version : PDFVersion,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.pdf_restrict_to_version_raw(self.to_raw(), version.to_raw()),
  )
}

///|
/// Restrict PDF output using a checked C-compatible version integer.
///
/// Only raw ids returned by `PDFVersion::supported()` are accepted. Negative,
/// unavailable, and unknown values such as `99` raise
/// `CairoError(InvalidStatus, _)` before Cairo can alter internal PDF state.
/// Timing and receiver errors match `pdf_restrict_to_version`.
pub fn Surface::pdf_restrict_to_version_raw(
  self : Surface,
  version : Int,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.pdf_restrict_to_version_raw(self.to_raw(), version),
  )
}

///|
/// Set the size, in points, of the current and subsequent PDF pages.
///
/// Call this before drawing on the current page: immediately after creation or
/// after completing a page with `show_page` or `copy_page`. One point is 1/72
/// inch. Finished and non-PDF surfaces raise checked Surface errors. This Cairo
/// API is available since 1.2.
pub fn Surface::pdf_set_size(
  self : Surface,
  width_in_points : Double,
  height_in_points : Double,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.pdf_set_size_raw(
      self.to_raw(),
      width_in_points,
      height_in_points,
    ),
  )
}

///|
/// Set one standard PDF document metadata field.
///
/// Title, Author, Subject, Keywords, and Creator accept arbitrary MoonBit text.
/// CreateDate and ModDate must follow `YYYY-MM-DDThh:mm:ss` with optional `Z`
/// or `[+/-]hh:mm`. Embedded NUL raises
/// `CairoInvalidArgument(InvalidString, _)`. Cairoon supports this API at its
/// 1.15.10 development floor; Cairo documents the stable API since 1.16.
pub fn Surface::pdf_set_metadata(
  self : Surface,
  metadata : PDFMetadata,
  value : String,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.pdf_set_metadata_raw(
      self.to_raw(),
      metadata.to_raw(),
      checked_c_string_bytes(value),
    ),
  )
}

///|
/// Set standard PDF metadata using a checked C-compatible field id.
///
/// Portable ids are 0=Title, 1=Author, 2=Subject, 3=Keywords, 4=Creator,
/// 5=CreateDate, and 6=ModDate. Other integers raise
/// `CairoError(InvalidStatus, _)` before calling Cairo's metadata setter. Value
/// formatting, string validation, version availability, and receiver errors
/// match `pdf_set_metadata`.
pub fn Surface::pdf_set_metadata_raw(
  self : Surface,
  metadata : Int,
  value : String,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.pdf_set_metadata_raw(
      self.to_raw(),
      metadata,
      checked_c_string_bytes(value),
    ),
  )
}

///|
/// Set, replace, or remove a custom PDF metadata entry.
///
/// `name` may not be empty or one of `Title`, `Author`, `Subject`, `Keywords`,
/// `Creator`, `Producer`, `CreationDate`, `ModDate`, or `Trapped`. `None` and
/// `Some("")` both remove the entry. Embedded NUL is rejected before FFI;
/// reserved names set `InvalidString`. This requires Cairo 1.17.6 development
/// or 1.18+, while older linked versions raise `CairoError(InvalidStatus, _)`.
pub fn Surface::pdf_set_custom_metadata(
  self : Surface,
  name : String,
  value : String?,
) -> Unit raise CairoError {
  let (has_value, bytes) = match value {
    None => (false, @utf8.encode(""))
    Some(value) => (true, checked_c_string_bytes(value))
  }
  check_surface_status_raw(
    @surface_impl.pdf_set_custom_metadata_raw(
      self.to_raw(),
      checked_c_string_bytes(name),
      has_value,
      bytes,
    ),
  )
}

///|
/// Set the label for the current PDF page.
///
/// The label is copied as UTF-8; embedded NUL raises
/// `CairoInvalidArgument(InvalidString, _)`. Call this separately for each page
/// that needs a label. Cairoon supports the 1.15.10 development API; Cairo
/// documents the stable API since 1.16.
pub fn Surface::pdf_set_page_label(
  self : Surface,
  label : String,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.pdf_set_page_label_raw(
      self.to_raw(),
      checked_c_string_bytes(label),
    ),
  )
}

///|
/// Set thumbnail dimensions for the current and all subsequent PDF pages.
///
/// Setting either `width` or `height` to zero disables thumbnails until a later
/// call supplies two positive dimensions. Cairoon supports the 1.15.10
/// development API; Cairo documents the stable API since 1.16. Finished and
/// non-PDF surfaces raise checked Surface errors.
pub fn Surface::pdf_set_thumbnail_size(
  self : Surface,
  width : Int,
  height : Int,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.pdf_set_thumbnail_size_raw(self.to_raw(), width, height),
  )
}

///|
/// Add one PDF outline item with a single typed display flag.
///
/// Use `PDF_OUTLINE_ROOT` for a top-level item or an id returned by an earlier
/// outline call for a child. `title` is UTF-8. `link_attributes` uses Cairo's
/// Link-tag key/value grammar without the `rect` key, for example
/// `"page=1 pos=[12 24]"`. The returned positive id can parent later items.
/// String and attribute failures are checked; use
/// `pdf_add_outline_with_flags` to combine display flags.
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
/// Add a PDF outline item with a typed or combined flag set.
///
/// Parent, title, link, return-value, and error contracts match
/// `pdf_add_outline`. The portable mask combines Open (`0x01`), Bold (`0x02`),
/// and Italic (`0x04`). Cairoon supports the 1.15.10 development API; Cairo
/// documents the stable API since 1.16.
pub fn Surface::pdf_add_outline_with_flags(
  self : Surface,
  parent_id : Int,
  title : String,
  link_attributes : String,
  flags : PDFOutlineFlagSet,
) -> Int raise CairoError {
  let status = Ref(0)
  let id = @surface_impl.pdf_add_outline_bits_raw(
    self.to_raw(),
    parent_id,
    checked_c_string_bytes(title),
    checked_c_string_bytes(link_attributes),
    flags.bits(),
    status,
  )
  check_surface_status_raw(status.val)
  id
}

///|
/// Add a PDF outline item with an exact pycairo-compatible flag integer.
///
/// Portable values use only mask `0x07`. Other bits cross the raw boundary
/// unchanged but have no guaranteed PDF rendering semantics. Parent, title,
/// Link-tag attributes, return value, availability, and checked receiver errors
/// match `pdf_add_outline_with_flags`.
pub fn Surface::pdf_add_outline_raw(
  self : Surface,
  parent_id : Int,
  title : String,
  link_attributes : String,
  flags : Int,
) -> Int raise CairoError {
  let status = Ref(0)
  let id = @surface_impl.pdf_add_outline_bits_raw(
    self.to_raw(),
    parent_id,
    checked_c_string_bytes(title),
    checked_c_string_bytes(link_attributes),
    flags,
    status,
  )
  check_surface_status_raw(status.val)
  id
}
