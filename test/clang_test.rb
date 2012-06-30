require "test_utils"

run_test(
  library_name:  "Clang",
  ffi_lib:       "clang",
  prefixes:      ["clang_", "CX"],
  files:         ["clang-c/Index.h"]
)
