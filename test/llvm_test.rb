require "test_utils"

run_test(
  library_name:  "LLVM",
  ffi_lib:       ["libLLVM-3.5.so.1", "LLVM-3.5"],
  cflags:        ["-D__STDC_CONSTANT_MACROS", "-D__STDC_LIMIT_MACROS"],
  prefixes:      ["LLVM"],
  blocking:      ["LLVMRunFunction", "LLVMRunFunctionAsMain"],
  files:         find_headers("test/headers", "llvm-c/")
)
