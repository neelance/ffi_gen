require 'ffi'

require 'ffi_gen/generator'

module FFIGen
  require "ffi_gen/clang"

  class << Clang
    def get_children(cursor)
      children = []
      visit_children cursor, lambda { |visit_result, child, child_parent, child_client_data|
        children << child
        :continue
      }, nil
      children
    end

    def get_spelling_location_data(location)
      file_ptr = FFI::MemoryPointer.new :pointer
      line_ptr = FFI::MemoryPointer.new :uint
      column_ptr = FFI::MemoryPointer.new :uint
      offset_ptr = FFI::MemoryPointer.new :uint
      get_spelling_location location, file_ptr, line_ptr, column_ptr, offset_ptr
      { file: file_ptr.read_pointer, line: line_ptr.read_uint, column: column_ptr.read_uint, offset: offset_ptr.read_uint }
    end

    def get_tokens(translation_unit, range)
      tokens_ptr_ptr = FFI::MemoryPointer.new :pointer
      num_tokens_ptr = FFI::MemoryPointer.new :uint
      Clang.tokenize translation_unit, range, tokens_ptr_ptr, num_tokens_ptr
      num_tokens = num_tokens_ptr.read_uint
      tokens_ptr = FFI::Pointer.new Clang::Token, tokens_ptr_ptr.read_pointer
      (num_tokens - 1).times.map { |i| Clang::Token.new tokens_ptr[i] }
    end
  end

  class Clang::String
    def to_s
      Clang.get_c_string self
    end

    def to_s_and_dispose
      str = to_s
      Clang.dispose_string self
      str
    end
  end

  class Clang::Cursor
    def ==(other)
      other.is_a?(Clang::Cursor) && Clang.equal_cursors(self, other) == 1
    end

    def eql?(other)
      self == other
    end

    def hash
      Clang.hash_cursor self
    end
  end

  class Clang::Type
    def ==(other)
      other.is_a?(Clang::Type) && Clang.equal_types(self, other) == 1
    end

    def eql?(other)
      self == other
    end

    def hash
      0 # no hash available
    end
  end

  class Type
  end

  class Enum < Type
    attr_accessor :name

    def initialize(generator, name, constants, description)
      @generator = generator
      @name = name
      @constants = constants
      @description = description
    end

    def shorten_names
      return if @constants.size < 2
      names = @constants.map { |constant| constant[:name].parts }
      names.each(&:shift) while names.map(&:first).uniq.size == 1 and @name.parts.map(&:downcase).include? names.first.first.downcase
      names.each(&:pop) while names.map(&:last).uniq.size == 1 and @name.parts.map(&:downcase).include? names.first.last.downcase
    end
  end

  class StructOrUnion < Type
    attr_accessor :name, :description
    attr_reader :fields, :oo_functions, :written

    def initialize(generator, name, is_union)
      @generator = generator
      @name = name
      @is_union = is_union
      @description = []
      @fields = []
      @oo_functions = []
      @written = false
    end
  end

  class FunctionOrCallback < Type
    attr_reader :name, :parameters, :return_type, :function_description, :return_value_description

    def initialize(generator, name, parameters, return_type, is_callback, blocking, function_description, return_value_description)
      @generator = generator
      @name = name
      @parameters = parameters
      @return_type = return_type
      @is_callback = is_callback
      @blocking = blocking
      @function_description = function_description
      @return_value_description = return_value_description
    end
  end

  class Define
    def initialize(generator, name, parameters, value)
      @generator = generator
      @name = name
      @parameters = parameters
      @value = value
    end
  end

  class Writer
    attr_reader :output

    def initialize(indentation_prefix, comment_prefix, comment_start = nil, comment_end = nil)
      @indentation_prefix = indentation_prefix
      @comment_prefix = comment_prefix
      @comment_start = comment_start
      @comment_end = comment_end
      @current_indentation = ""
      @output = ""
    end

    def indent(prefix = @indentation_prefix)
      previous_indentation = @current_indentation
      @current_indentation += prefix
      yield
      @current_indentation = previous_indentation
    end

    def comment(&block)
      self.puts @comment_start unless @comment_start.nil?
      self.indent @comment_prefix, &block
      self.puts @comment_end unless @comment_end.nil?
    end

    def puts(*lines)
      lines.each do |line|
        @output << "#{@current_indentation}#{line}\n"
      end
    end

    def write_array(array, separator = "", first_line_prefix = "", other_lines_prefix = "")
      array.each_with_index do |entry, index|
        entry = yield entry if block_given?
        puts "#{index == 0 ? first_line_prefix : other_lines_prefix}#{entry}#{index < array.size - 1 ? separator : ''}"
      end
    end

    def write_description(description, not_documented_message = true, first_line_prefix = "", other_lines_prefix = "")
      description.shift while not description.empty? and description.first.strip.empty?
      description.pop while not description.empty? and description.last.strip.empty?
      description.map! { |line| line.gsub "\t", "    " }
      space_prefix_length = description.map{ |line| line.index(/\S/) }.compact.min
      description.map! { |line| line[space_prefix_length..-1] }
      description << (not_documented_message ? "(Not documented)" : "") if description.empty?

      write_array description, "", first_line_prefix, other_lines_prefix
    end
  end

  class Name
    attr_reader :parts, :raw

    def initialize(parts, raw = nil)
      @parts = parts
      @raw = raw
    end

    def format(*modes, keyword_blacklist)
      parts = @parts.dup
      parts.map!(&:downcase) if modes.include? :downcase
      parts.map!(&:upcase) if modes.include? :upcase
      parts.map! { |s| s[0].upcase + s[1..-1] } if modes.include? :camelcase
      parts[0] = parts[0][0].downcase + parts[0][1..-1] if modes.include? :initial_downcase
      str = parts.join(modes.include?(:underscores) ? "_" : "")
      str.sub!(/^\d/, '_\0') # fix illegal beginnings
      str = "#{str}_" if keyword_blacklist.include? str
      str
    end
  end

  class PrimitiveType < Type
    def initialize(clang_type)
      @clang_type = clang_type
    end

    def name
      Name.new [@clang_type.to_s]
    end
  end

  class StringType < Type
    def name
      Name.new ["string"]
    end
  end

  class ByValueType < Type
    def initialize(inner_type)
      @inner_type = inner_type
    end

    def name
      @inner_type.name
    end
  end

  class PointerType < Type
    attr_reader :pointee_name, :depth

    def initialize(pointee_name, depth)
      @pointee_name = pointee_name
      @depth = depth
    end

    def name
      @pointee_name
    end
  end

  class ArrayType < Type
    def initialize(element_type, constant_size)
      @element_type = element_type
      @constant_size = constant_size
    end

    def name
      Name.new ["array"]
    end
  end

  class UnknownType < Type
    def name
      Name.new ["unknown"]
    end
  end

  def self.generate(options = {})
    Generator.new(options).generate
  end

end

require 'ffi_gen/generator/java'
require 'ffi_gen/generator/ruby'

if __FILE__ == $0
  FFIGen.generate(
    module_name: "FFIGen::Clang",
    ffi_lib:     ["libclang-3.5.so.1", "libclang.so.1", "clang"],
    headers:     ["clang-c/CXErrorCode.h", "clang-c/CXString.h", "clang-c/Index.h"],
    cflags:      `llvm-config --cflags`.split(" "),
    prefixes:    ["clang_", "CX"],
    output:      File.join(File.dirname(__FILE__), "ffi_gen/clang.rb")
  )
end
