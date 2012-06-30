require "test_utils"

run_test(
  library_name:  "CEF",
  ffi_lib:       "cef",
  cflags:        ["-Itest/headers/cef"],
  prefixes:      ["cef_", "CEF_"],
  files:         find_headers("test/headers/cef")
)
