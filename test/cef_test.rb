require "test_utils"

run_test(
  library_name:  "CEF",
  ffi_lib:       "cef",
  cflags:        ["-Itest/headers/cef"],
  prefixes:      ["cef_", "_cef_", "CEF_"],
  suffixes:      ["_t"],
  files:         find_headers("test/headers/cef")
)
