$:.unshift "#{File.dirname(__FILE__)}/../lib"
require "fileutils"
require "ffi_gen"

$CLANG_HEADERS = "C:\\Program Files (x86)\\LLVM\\lib\\clang\\3.5.0\\include"

def find_headers(dir, prefix = "")
  Dir.chdir dir do
    return Dir.glob("#{prefix}**/*.h")
  end
end

def run_test(options = {})
  options[:files].each do |header|
    output_file = "#{File.dirname(__FILE__)}/output/#{header.sub(/\.h$/, ".rb")}"
    FileUtils.mkdir_p File.dirname(output_file)

    FFIGen.generate(
      module_name: options[:library_name] || options[:module_name],
      ffi_lib:     options[:ffi_lib],
      headers:     [header],
      cflags:      ["-nostdinc", "-Itest/headers"] + options.fetch(:cflags, []),
      prefixes:    options.fetch(:prefixes, []),
      suffixes:    options.fetch(:suffixes, []),
      blocking:    options.fetch(:blocking, []),
      output:      output_file,
      skip_macro_functions: options.fetch(:skip_macro_functions, false),
    )

    require output_file
  end

  puts "#{options[:library_name]} test successful"
end
