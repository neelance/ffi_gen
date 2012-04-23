require "test_utils"

run_test(
  library_name:  "Clang",
  ffi_lib:       "clang",
  cflags:        `llvm-config --cflags`.split(" "),
  prefixes:      ["clang_", "CX"],
  file_mappings: {
    "clang-c/Index.h" => "index.rb"
  }
)
