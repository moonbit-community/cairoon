///|
pub(all) enum Status {
  Success = 0
  NoMemory = 1
  InvalidRestore = 2
  InvalidPopGroup = 3
  NoCurrentPoint = 4
  InvalidMatrix = 5
  InvalidStatus = 6
  NullPointer = 7
  InvalidString = 8
  InvalidPathData = 9
  ReadError = 10
  WriteError = 11
  SurfaceFinished = 12
  SurfaceTypeMismatch = 13
  PatternTypeMismatch = 14
  InvalidContent = 15
  InvalidFormat = 16
  InvalidVisual = 17
  FileNotFound = 18
  InvalidDash = 19
  InvalidDscComment = 20
  InvalidIndex = 21
  ClipNotRepresentable = 22
  TempFileError = 23
  InvalidStride = 24
  FontTypeMismatch = 25
  UserFontImmutable = 26
  UserFontError = 27
  NegativeCount = 28
  InvalidClusters = 29
  InvalidSlant = 30
  InvalidWeight = 31
  InvalidSize = 32
  UserFontNotImplemented = 33
  DeviceTypeMismatch = 34
  DeviceError = 35
  InvalidMeshConstruction = 36
  DeviceFinished = 37
  Jbig2GlobalMissing = 38
  PngError = 39
  FreetypeError = 40
  Win32GdiError = 41
  TagError = 42
  DwriteError = 43
  SvgFontError = 44
  LastStatus = 45
} derive(Eq, Debug)

///|
pub fn Status::message(self : Status) -> String {
  @utf8.decode_lossy(status_to_string_ffi(self))
}

///|
pub fn Status::is_success(self : Status) -> Bool {
  self == Success
}
