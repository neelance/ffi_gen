require "test_utils"

run_test(
  library_name:  "Clang",
  ffi_lib:       ["libclang.so.1", "clang"],
  prefixes:      ["clang_", "CX"],
  files:         ["clang-c/Index.h"]
)
