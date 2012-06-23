require "test_utils"

run_test(
  library_name:  "LLVM",
  ffi_lib:       "LLVM-3.0",
  cflags:        ["-D__STDC_CONSTANT_MACROS", "-D__STDC_LIMIT_MACROS"],
  prefixes:      ["LLVM"],
  blocking:      ["LLVMRunFunction", "LLVMRunFunctionAsMain"],
  file_mappings: {
    "llvm-c/Analysis.h"          => "analysis.rb",
    "llvm-c/BitReader.h"         => "bit_reader.rb",
    "llvm-c/BitWriter.h"         => "bit_writer.rb",
    "llvm-c/Core.h"              => "core.rb",
    "llvm-c/Disassembler.h"      => "disassembler.rb",
    "llvm-c/ExecutionEngine.h"   => "execution_engine.rb",
    "llvm-c/Initialization.h"    => "initialization.rb",
    "llvm-c/Object.h"            => "object.rb",
    "llvm-c/Target.h"            => "target.rb",
    "llvm-c/Transforms/IPO.h"    => "transforms/ipo.rb",
    "llvm-c/Transforms/Scalar.h" => "transforms/scalar.rb",
  }
)
