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
fn Status::to_raw(self : Status) -> Int {
  match self {
    Success => 0
    NoMemory => 1
    InvalidRestore => 2
    InvalidPopGroup => 3
    NoCurrentPoint => 4
    InvalidMatrix => 5
    InvalidStatus => 6
    NullPointer => 7
    InvalidString => 8
    InvalidPathData => 9
    ReadError => 10
    WriteError => 11
    SurfaceFinished => 12
    SurfaceTypeMismatch => 13
    PatternTypeMismatch => 14
    InvalidContent => 15
    InvalidFormat => 16
    InvalidVisual => 17
    FileNotFound => 18
    InvalidDash => 19
    InvalidDscComment => 20
    InvalidIndex => 21
    ClipNotRepresentable => 22
    TempFileError => 23
    InvalidStride => 24
    FontTypeMismatch => 25
    UserFontImmutable => 26
    UserFontError => 27
    NegativeCount => 28
    InvalidClusters => 29
    InvalidSlant => 30
    InvalidWeight => 31
    InvalidSize => 32
    UserFontNotImplemented => 33
    DeviceTypeMismatch => 34
    DeviceError => 35
    InvalidMeshConstruction => 36
    DeviceFinished => 37
    Jbig2GlobalMissing => 38
    PngError => 39
    FreetypeError => 40
    Win32GdiError => 41
    TagError => 42
    DwriteError => 43
    SvgFontError => 44
    LastStatus => 45
  }
}

///|
fn status_from_raw(raw : Int) -> Status raise CairoError {
  match raw {
    0 => Success
    1 => NoMemory
    2 => InvalidRestore
    3 => InvalidPopGroup
    4 => NoCurrentPoint
    5 => InvalidMatrix
    6 => InvalidStatus
    7 => NullPointer
    8 => InvalidString
    9 => InvalidPathData
    10 => ReadError
    11 => WriteError
    12 => SurfaceFinished
    13 => SurfaceTypeMismatch
    14 => PatternTypeMismatch
    15 => InvalidContent
    16 => InvalidFormat
    17 => InvalidVisual
    18 => FileNotFound
    19 => InvalidDash
    20 => InvalidDscComment
    21 => InvalidIndex
    22 => ClipNotRepresentable
    23 => TempFileError
    24 => InvalidStride
    25 => FontTypeMismatch
    26 => UserFontImmutable
    27 => UserFontError
    28 => NegativeCount
    29 => InvalidClusters
    30 => InvalidSlant
    31 => InvalidWeight
    32 => InvalidSize
    33 => UserFontNotImplemented
    34 => DeviceTypeMismatch
    35 => DeviceError
    36 => InvalidMeshConstruction
    37 => DeviceFinished
    38 => Jbig2GlobalMissing
    39 => PngError
    40 => FreetypeError
    41 => Win32GdiError
    42 => TagError
    43 => DwriteError
    44 => SvgFontError
    45 => LastStatus
    _ => raise CairoError(InvalidStatus, "unknown cairo status: \{raw}")
  }
}

///|
pub fn Status::message(self : Status) -> String {
  @status_impl.status_message_raw(self.to_raw())
}

///|
pub fn Status::is_success(self : Status) -> Bool {
  self == Success
}
