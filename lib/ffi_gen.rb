require 'ffi'

require 'ffi_gen/clang'
require 'ffi_gen/clang/c'
require 'ffi_gen/clang/c_ffi'
require 'ffi_gen/clang/c/cursor'
require 'ffi_gen/clang/c/type'
require 'ffi_gen/clang/index'
require 'ffi_gen/clang/string'
require 'ffi_gen/clang/translation_unit'
require 'ffi_gen/generator'
require 'ffi_gen/generator/type'
require 'ffi_gen/generator/array_type'
require 'ffi_gen/generator/by_value_type'
require 'ffi_gen/generator/define'
require 'ffi_gen/generator/enum'
require 'ffi_gen/generator/function_or_callback'
require 'ffi_gen/generator/name'
require 'ffi_gen/generator/pointer_type'
require 'ffi_gen/generator/primitive_type'
require 'ffi_gen/generator/string_type'
require 'ffi_gen/generator/struct_or_union'
require 'ffi_gen/generator/unknown_type'
require 'ffi_gen/generator/writer'
require 'ffi_gen/generator/java'
require 'ffi_gen/generator/ruby'


module FFIGen

  def self.generate(options = {})
    Generator.new(options).generate
  end

end


if __FILE__ == $0
  FFIGen.generate(
    module_name: "FFIGen::Clang::C",
    ffi_lib:     ["libclang-3.5.so.1", "libclang.so.1", "clang"],
    headers:     ["clang-c/CXErrorCode.h", "clang-c/CXString.h", "clang-c/Index.h"],
    cflags:      `llvm-config --cflags`.split(" "),
    prefixes:    ["clang_", "CX"],
    output:      File.join(File.dirname(__FILE__), "ffi_gen/clang/c_ffi.rb")
  )
end
