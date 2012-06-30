require "test_utils"

run_test(
  library_name:  "LLVM",
  ffi_lib:       "LLVM-3.0",
  cflags:        ["-D__STDC_CONSTANT_MACROS", "-D__STDC_LIMIT_MACROS"],
  prefixes:      ["LLVM"],
  blocking:      ["LLVMRunFunction", "LLVMRunFunctionAsMain"],
  files:         find_headers("test/headers", "llvm-c/")
)
