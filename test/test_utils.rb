require "fileutils"
require "ffi/gen"

def run_test(options = {})
  options[:file_mappings].each do |header, ruby_file|
    output_file = File.join File.dirname(__FILE__), "output/#{options[:library_name]}/#{ruby_file}"
    FileUtils.mkdir_p File.dirname(output_file)
    
    FFI::Gen.generate(
      module_name: options[:library_name],
      ffi_lib:     options[:ffi_lib],
      headers:     [header],
      cflags:      options.fetch(:cflags, []),
      prefixes:    options.fetch(:prefixes, []),
      blocking:    options.fetch(:blocking, []),
      output:      output_file
    )
    
    require output_file
  end
  
  puts "#{options[:library_name]} test successful"
end
