///|
/// Create an owning multi-page PostScript surface measured in points.
///
/// One point is 1/72 inch. `None` creates a queryable/drawable no-output
/// surface; `Some(path)` writes to that UTF-8 filename and rejects embedded NUL
/// with `CairoInvalidArgument(InvalidString, _)`. Individual page sizes may be
/// changed with `ps_set_size`. Call `finish` to finalize output and report write
/// errors. This requires Cairo's PS backend (available since Cairo 1.2).
pub fn Surface::ps(
  width_in_points : Double,
  height_in_points : Double,
  path? : String? = None,
) -> Surface raise CairoError {
  let status = Ref(0)
  let (has_filename, filename) = match path {
    None => (false, @utf8.encode(""))
    Some(path) => (true, checked_path_bytes(path))
  }
  let raw = @surface_impl.ps_create_raw(
    has_filename, filename, width_in_points, height_in_points, status,
  )
  check_surface_status_raw(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Create an owning PostScript surface that sends encoded bytes to `writer`.
///
/// Width and height are points. Cairoon retains the writer until the Surface is
/// collected and gives it independent `Bytes` chunks that remain valid after
/// each callback. Return `Success` to continue; callback failures are raised by
/// drawing or `finish`, and non-writer statuses such as `LastStatus` become
/// `CairoIOError(WriteError, _)`. Construction failures release the writer only
/// after Cairo can no longer invoke it.
pub fn Surface::ps_stream(
  width_in_points : Double,
  height_in_points : Double,
  writer : (Bytes) -> Status,
) -> Surface raise CairoError {
  let status = Ref(Success)
  let raw = ps_surface_create_for_stream_ffi(
    fn(chunk, writer) { writer(@stream_impl.copy_chunk(chunk)) },
    writer,
    width_in_points,
    height_in_points,
    status,
  )
  check_status(status.val)
  check_surface_status_raw(@surface_impl.status_raw(raw))
  Surface::from_raw(raw)
}

///|
/// Return a fresh array of PostScript levels supported by linked Cairo.
///
/// The result is copied from Cairo's static table and can be mutated by the
/// caller. An unavailable PS backend raises `CairoError(InvalidStatus, _)`.
pub fn PSLevel::supported() -> Array[PSLevel] raise CairoError {
  let status = Ref(0)
  let count = @ps_impl.get_level_count_raw(status)
  check_status(status_from_raw(status.val))
  let levels : Array[PSLevel] = Array::new(capacity=count)
  for index in 0..<count {
    let level = ps_level_from_raw(@ps_impl.get_level_raw(index, status))
    check_status(status_from_raw(status.val))
    levels.push(level)
  }
  levels
}

///|
/// Return a copied Cairo display string for this PostScript level.
///
/// The result does not borrow Cairo storage. Backend or conversion failures are
/// reported as checked `CairoError` values.
pub fn PSLevel::to_string(self : PSLevel) -> String raise CairoError {
  let status = Ref(0)
  let text = @ps_impl.level_to_string_raw(self.to_raw(), status)
  check_status(status_from_raw(status.val))
  text
}

///|
/// Convert a pycairo-compatible `cairo_ps_level_t` integer to text.
///
/// Portable values are `0` (Level 2) and `1` (Level 3). Negative and other
/// unknown values raise `CairoError(InvalidStatus, _)`; the returned string is
/// copied into MoonBit-owned storage.
pub fn PSLevel::to_string_raw(level : Int) -> String raise CairoError {
  let status = Ref(0)
  let text = @ps_impl.level_to_string_raw(level, status)
  check_status(status_from_raw(status.val))
  text
}

///|
fn PSLevel::to_raw(self : PSLevel) -> Int {
  match self {
    PsLevel2 => 0
    PsLevel3 => 1
  }
}

///|
fn ps_level_from_raw(raw : Int) -> PSLevel raise CairoError {
  match raw {
    0 => PsLevel2
    1 => PsLevel3
    _ =>
      raise CairoInvalidArgument(
        InvalidStatus,
        "unknown cairo ps level: \{raw}",
      )
  }
}

///|
/// Restrict generated PostScript to `level` before performing any drawing.
///
/// Cairo otherwise chooses its backend default. Call this immediately after
/// construction; changing the level after output begins is outside Cairo's
/// contract. Finished and non-PS surfaces raise `SurfaceFinished` and
/// `SurfaceTypeMismatch` respectively. The Cairo API is available since 1.6.
pub fn Surface::ps_restrict_to_level(
  self : Surface,
  level : PSLevel,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.ps_restrict_to_level_raw(self.to_raw(), level.to_raw()),
  )
}

///|
/// Restrict PostScript output using an exact pycairo-compatible C integer.
///
/// Values `0` and `1` select Levels 2 and 3. The positive sentinel `99` crosses
/// the raw ABI unchanged and is observed as a no-op on Cairo 1.15.10 and
/// 1.18.4; other out-of-range values are unsupported. Prefer the typed method
/// for portable code. Timing and checked receiver errors match
/// `ps_restrict_to_level`.
pub fn Surface::ps_restrict_to_level_raw(
  self : Surface,
  level : Int,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.ps_restrict_to_level_raw(self.to_raw(), level),
  )
}

///|
/// Return whether this surface is configured for Encapsulated PostScript.
///
/// New Cairo PS surfaces default to ordinary PostScript. The returned value is
/// current backend state; finished and non-PS surfaces raise checked Surface
/// errors rather than returning a fallback `false`.
pub fn Surface::ps_get_eps(self : Surface) -> Bool raise CairoError {
  let status = Ref(0)
  let eps = @surface_impl.ps_get_eps_raw(self.to_raw(), status)
  check_surface_status_raw(status.val)
  eps
}

///|
/// Enable or disable Encapsulated PostScript for the current document.
///
/// Set this before drawing on the current page, normally immediately after
/// construction. A valid EPS document must contain no more than one page.
/// Finished and non-PS surfaces raise checked Surface errors. This Cairo API is
/// available since 1.6.
pub fn Surface::ps_set_eps(self : Surface, eps : Bool) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.ps_set_eps_raw(self.to_raw(), eps))
}

///|
/// Set the size, in points, of the current and subsequent PostScript pages.
///
/// Call this before drawing on the current page: immediately after creation or
/// after completing a page with `show_page` or `copy_page`. One point is 1/72
/// inch. Finished and non-PS surfaces raise checked Surface errors.
pub fn Surface::ps_set_size(
  self : Surface,
  width_in_points : Double,
  height_in_points : Double,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.ps_set_size_raw(
      self.to_raw(),
      width_in_points,
      height_in_points,
    ),
  )
}

///|
/// Direct subsequent DSC comments to the document-wide Setup section.
///
/// Call this at most once, after any Header comments and before page setup or
/// drawing. Cairo does not rewind a later section when calls are out of order,
/// so this method is a section transition rather than an ordering validator.
/// Finished and non-PS surfaces raise checked Surface errors.
pub fn Surface::ps_dsc_begin_setup(self : Surface) -> Unit raise CairoError {
  check_surface_status_raw(@surface_impl.ps_dsc_begin_setup_raw(self.to_raw()))
}

///|
/// Direct subsequent DSC comments to the current page's PageSetup section.
///
/// For the first page, call this after `ps_dsc_begin_setup` and before drawing.
/// Later `show_page` or `copy_page` transitions already direct comments to the
/// new page; repeating this call is harmless. Cairo does not rewind section
/// state on out-of-order calls. Finished and non-PS surfaces raise checked
/// Surface errors.
pub fn Surface::ps_dsc_begin_page_setup(
  self : Surface,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.ps_dsc_begin_page_setup_raw(self.to_raw()),
  )
}

///|
/// Queue one PostScript Document Structuring Conventions comment.
///
/// `comment` must start with `%`, contain at most 255 UTF-8 bytes including the
/// initial percent characters, and contain no newline. Do not emit Cairo-owned
/// `%!PS-Adobe-3.0`, `%%Creator`, `%%CreationDate`, `%%Pages`, `%%BoundingBox`,
/// `%%DocumentData`, `%%LanguageLevel`, `%%EndComments`, `%%BeginSetup`,
/// `%%EndSetup`, `%%BeginPageSetup`, `%%PageBoundingBox`, `%%EndPageSetup`,
/// `%%BeginProlog`, `%%EndProlog`, `%%Page`, `%%Trailer`, or `%%EOF` markers.
/// Prefix/length failures set sticky `InvalidDscComment`; embedded NUL raises
/// `CairoInvalidArgument(InvalidString, _)` before FFI. Comments target Header,
/// Setup, or PageSetup according to the current DSC section. Finished and non-PS
/// surfaces raise checked Surface errors.
pub fn Surface::ps_dsc_comment(
  self : Surface,
  comment : String,
) -> Unit raise CairoError {
  check_surface_status_raw(
    @surface_impl.ps_dsc_comment_raw(
      self.to_raw(),
      checked_c_string_bytes(comment),
    ),
  )
}
