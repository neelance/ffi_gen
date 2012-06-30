require "test_utils"

run_test(
  library_name:  "Cairo",
  ffi_lib:       "cairo",
  cflags:        ["-Itest/headers/cairo", "-Itest/headers/freetype2", "-Itest/headers/glib-2.0"],
  prefixes:      ["cairo_", "_cairo_", "CAIRO_"],
  files:         find_headers("test/headers/cairo")
)
