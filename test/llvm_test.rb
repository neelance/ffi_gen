require "fileutils"
require "ffi_gen"

mappings = {
  "llvm-c/Analysis.h" => "analysis.rb",
  "llvm-c/BitReader.h" => "bit_reader.rb",
  "llvm-c/BitWriter.h" => "bit_writer.rb",
  "llvm-c/Core.h" => "core.rb",
  "llvm-c/Disassembler.h" => "disassembler.rb",
  "llvm-c/ExecutionEngine.h" => "execution_engine.rb",
  "llvm-c/Initialization.h" => "initialization.rb",
  "llvm-c/Object.h" => "object.rb",
  "llvm-c/Target.h" => "target.rb",
  "llvm-c/Transforms/IPO.h" => "transforms/ipo.rb",
  "llvm-c/Transforms/Scalar.h" => "transforms/scalar.rb",
}

FileUtils.mkdir_p File.join(File.dirname(__FILE__), "gen/llvm/transforms")

mappings.each do |header, ruby_file|
  FFIGen.generate(
    ruby_module: "LLVM::C",
    ffi_lib:     "LLVM-3.0",
    headers:     [header],
    cflags:      `llvm-config --cflags`.split(" "),
    prefixes:    ["LLVM"],
    blacklist:   ["LLVMGetMDNodeNumOperands", "LLVMGetMDNodeOperand", "EDGetDisassembler",
                  "LLVMInitializeAllTargetInfos", "LLVMInitializeAllTargets", "LLVMInitializeNativeTarget"],
    output:      File.join(File.dirname(__FILE__), "gen/llvm/#{ruby_file}")
  )
end

module LLVM
end

mappings.each do |header, ruby_file|
  require File.join(File.dirname(__FILE__), "gen/llvm/#{ruby_file}")
end

puts "LLVM Test successful"
