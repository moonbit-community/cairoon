name = "CAIMEOX/cairoon"

version = "0.1.0"

readme = "src/README.mbt.md"

repository = "https://github.com/moonbit-community/cairoon"

license = "LGPL-2.1-only OR MPL-1.1"

keywords = [ "cairo", "graphics", "ffi" ]

description = "MoonBit native bindings for the Cairo graphics library."

preferred_target = "native"

supported_targets = "native"

source = "src"

import {
  "moonbitlang/x@0.4.45",
}

options(
  "--moonbit-unstable-prebuild": "scripts/build/cairo_config.py",
  exclude: [ "integration" ],
)
