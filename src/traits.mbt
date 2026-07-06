///|
pub impl Eq for Context with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for Context with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for Context with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
pub impl Eq for Device with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for Device with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for Device with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
pub impl Eq for FontFace with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for FontFace with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for FontFace with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
pub impl Eq for FontOptions with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for FontOptions with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for FontOptions with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
pub impl Eq for Path with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Compare for Path with fn compare(self, other) {
  self.hash().compare(other.hash())
}

///|
pub impl Hash for Path with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for Path with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
pub impl Eq for Pattern with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for Pattern with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for Pattern with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
pub impl Eq for Region with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Eq for ScaledFont with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for ScaledFont with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for ScaledFont with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}

///|
pub impl Eq for Surface with fn equal(self, other) {
  self.equal(other)
}

///|
pub impl Hash for Surface with fn hash(self) {
  self.hash().hash()
}

///|
pub impl Hash for Surface with fn hash_combine(self, hasher) {
  hasher.combine_uint64(self.hash())
}
