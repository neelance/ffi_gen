require "fileutils"
require "ffi_gen"

mappings = {
  "llvm-c/Analysis.h" => "llvm/analysis.rb",
  "llvm-c/BitReader.h" => "llvm/bit_reader.rb",
  "llvm-c/BitWriter.h" => "llvm/bit_writer.rb",
  "llvm-c/Core.h" => "llvm/core.rb",
  "llvm-c/Disassembler.h" => "llvm/disassembler.rb",
  "llvm-c/ExecutionEngine.h" => "llvm/execution_engine.rb",
  "llvm-c/Initialization.h" => "llvm/initialization.rb",
  "llvm-c/Object.h" => "llvm/object.rb",
  "llvm-c/Target.h" => "llvm/target.rb",
  "llvm-c/Transforms/IPO.h" => "llvm/transforms/ipo.rb",
  "llvm-c/Transforms/PassManagerBuilder.h" => "llvm/transforms/pass_manager_builder.rb",
  "llvm-c/Transforms/Scalar.h" => "llvm/transforms/scalar.rb",
}

FileUtils.mkdir_p File.join(File.dirname(__FILE__), "llvm/transforms")

mappings.each do |header, ruby_file|
  FFIGen.generate(
    ruby_module: "LLVM::C",
    ffi_lib:     "LLVM-3.0",
    headers:     [header],
    cflags:      `llvm-config --cflags`.split(" "),
    prefixes:    ["LLVM"],
    blacklist:   ["LLVMGetMDNodeNumOperands", "LLVMGetMDNodeOperand", "EDGetDisassembler",
                  "LLVMInitializeAllTargetInfos", "LLVMInitializeAllTargets", "LLVMInitializeNativeTarget"],
    output:      File.join(File.dirname(__FILE__), ruby_file)
  )
end

module LLVM
end

mappings.each do |header, ruby_file|
  require File.join(File.dirname(__FILE__), ruby_file)
end

puts "Test successful"
