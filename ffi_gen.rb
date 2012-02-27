require "clang"

class << Clang
  def get_children(declaration)
    children = []
    visit_children declaration, lambda { |child, child_parent, child_client_data|
      children << child
      :continue
    }, nil
    children
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

class FFIGen
  attr_reader :blacklist

  def initialize(options = {})
    @blacklist = options.fetch(:blacklist, [])
  end

  class Enum
    attr_reader :constants
    
    def initialize(generator, name)
      @generator = generator
      @name = name
      @constants = []
    end
    
    def to_s
      prefix_length = 0
      
      first_underscore = @constants.first[0].index("_")
      underscore_prefix = @constants.first[0][0..first_underscore]
      prefix_length = first_underscore + 1 if @constants.all? { |(constant_name, constant_value)| constant_name[0..first_underscore] == underscore_prefix }
  
      lines = @constants.map { |(constant_name, constant_value)|
        "\n    :#{@generator.to_ruby_lowercase constant_name[prefix_length..-1]}" +
        (constant_value ? ", #{constant_value}" : "")
      }
      "  enum :#{@generator.to_ruby_lowercase @name}, [#{lines.join(",")}\n  ]"
    end
    
    def reference
      ":#{@generator.to_ruby_lowercase @name}"
    end
  end
  
  class Struct
    attr_reader :fields
    
    def initialize(generator, name)
      @generator = generator
      @name = name
      @fields = []
    end
    
    def to_s
      lines = @fields.map { |(field_name, field_type)| ":#{@generator.to_ruby_lowercase field_name}, #{@generator.to_ffi_type field_type}" }
      "  class #{@generator.to_ruby_camelcase @name} < FFI::Struct\n    layout #{lines.join(",\n           ")}\n  end"
    end
    
    def reference
      "#{@generator.to_ruby_camelcase @name}.by_value"
    end
  end
  
  class Function
    attr_reader :name, :parameters
    attr_accessor :return_type
    
    def initialize(generator, name, is_callback)
      @generator = generator
      @name = name
      @parameters = []
      @is_callback = is_callback
    end
    
    def to_s
      signature = "[#{@parameters.map{ |param| @generator.to_ffi_type param }.join(', ')}], #{@generator.to_ffi_type @return_type}"
      if @is_callback
        "  callback :#{@generator.to_ruby_lowercase @name}, #{signature}"
      else
        "  attach_function :#{@generator.to_ruby_lowercase @name}, :#{@name}, #{signature}"
      end
    end
    
    def reference
      ":#{@generator.to_ruby_lowercase @name}"
    end
  end
  
  def generate
    index = Clang.create_index(0, 0)
    
    args = ["", "test.h"]
    args.concat `llvm-config --cflags`.split(" ")
    args << "-I/usr/lib/gcc/x86_64-linux-gnu/4.6/include"
    args_ptr = FFI::MemoryPointer.new(FFI.type_size(:pointer) * args.size)
    pointers = args.map { |arg| FFI::MemoryPointer.from_string(arg) }
    args_ptr.write_array_of_pointer pointers
    
    unit = Clang.parse_translation_unit(index, nil, args_ptr, args.size, nil, 0, 0)
    
    Clang.get_num_diagnostics(unit).times do |i|
      diag = Clang.get_diagnostic unit, i
      puts Clang.format_diagnostic(diag, Clang.default_diagnostic_display_options).to_s_and_dispose
    end
    
    declarations = []
    @name_map = {}
    Clang.get_children(Clang.get_translation_unit_cursor(unit)).each do |declaration|
      location = Clang.get_cursor_location declaration
      file_ptr = FFI::MemoryPointer.new :pointer
      Clang.get_spelling_location location, file_ptr, nil, nil, nil
      filename = Clang.get_file_name(file_ptr.read_pointer).to_s_and_dispose
    
      next if filename.nil? or not filename.start_with? "/usr/local/include/clang-c/"
    
      name = Clang.get_cursor_spelling(declaration).to_s_and_dispose
      next if blacklist.include? name
      
      case declaration[:kind]
      when :enum_decl
        enum = Enum.new self, name
        declarations << enum
        @name_map[name] = enum
        
        Clang.get_children(declaration).each do |enum_constant|
          constant_name = Clang.get_cursor_spelling(enum_constant).to_s_and_dispose
          
          constant_value = nil
          value_cursor = Clang.get_children(enum_constant).first
          constant_value = value_cursor && case value_cursor[:kind]
          when :integer_literal
            read_literal value_cursor
          when :decl_ref_expr, :binary_operator, :paren_expr
            next # skip those entries for now
          else
            raise value_cursor[:kind].to_s
          end
          
          enum.constants << [constant_name, constant_value]
        end
      
      when :function_decl
        function = Function.new self, name, false
        function.return_type = Clang.get_cursor_result_type declaration
        declarations << function
        
        Clang.get_children(declaration).each do |function_child|
          function.parameters << Clang.get_cursor_type(function_child) if function_child[:kind] == :parm_decl
        end
      
      when :typedef_decl
        typedef_children = Clang.get_children declaration
        if typedef_children.size == 1 and typedef_children.first[:kind] == :struct_decl
          struct = Struct.new self, name
          declarations << struct
          @name_map[name] = struct
          
          Clang.get_children(typedef_children.first).each do |field_decl|
            field_name = Clang.get_cursor_spelling(field_decl).to_s_and_dispose
            field_type = Clang.get_cursor_type field_decl
            struct.fields << [field_name, field_type]
          end
          
        elsif typedef_children.size > 1
          callback = Function.new self, name, true
          callback.return_type = Clang.get_cursor_type typedef_children.first
          declarations << callback
          @name_map[name] = callback
          
          typedef_children[1..-1].each do |param_decl|
            callback.parameters << Clang.get_cursor_type(param_decl)
          end
        end
        
      end
    end
    
    puts "require 'ffi'\n\nclass Clang\n  extend FFI::Library\n  ffi_lib 'clang'\n\n#{declarations.join("\n\n")}\n\nend"
  end
    
  def to_ffi_type(full_type)
    declaration = Clang.get_type_declaration full_type
    name = Clang.get_cursor_spelling(declaration).to_s_and_dispose
    return @name_map[name].reference if @name_map.has_key? name
    
    canonical_type = Clang.get_canonical_type full_type
    case canonical_type[:kind]
    when :int then ":int"
    when :long then ":long"
    when :long_long then ":long_long"
    when :u_int then ":uint"
    when :u_long then ":ulong"
    when :u_long_long then ":ulong_long"
    when :void then ":void"
    when :pointer
      pointee_kind = Clang.get_pointee_type(canonical_type)[:kind]
      pointee_kind == :char_s ? ":string" : ":pointer"
    when :constant_array
      element_type = Clang.get_array_element_type canonical_type
      size = Clang.get_array_size canonical_type
      "[#{to_ffi_type element_type}, #{size}]"
    else
      raise canonical_type[:kind].to_s
    end
  end
  
  def to_ruby_lowercase(str)
    str = str.dup
    str.sub! /^(clang_|CX|)/, '' # remove prefixes
    str.gsub! /([A-Z][a-z])/, '_\1' # add underscores before word beginnings
    str.gsub! /([a-z])([A-Z])/, '\1_\2' # add underscores after word endings
    str.sub! /^_*/, '' # remove underscores at the beginning
    str.gsub! /__+/, '_' # replace multiple underscores by only one
    str.downcase!
    str
  end
  
  def to_ruby_camelcase(str)
    str = str.dup
    str.sub! /^(clang_|CX|)/, '' # remove prefixes
    str
  end
  
  def read_literal(declaration)
    extent = Clang.get_cursor_extent declaration
    start_loc = Clang.get_range_start extent
    end_loc = Clang.get_range_end extent
  
    file_ptr = FFI::MemoryPointer.new :pointer
    start_offset_ptr = FFI::MemoryPointer.new :uint
    end_offset_ptr = FFI::MemoryPointer.new :uint
    
    Clang.get_spelling_location start_loc, file_ptr, nil, nil, start_offset_ptr
    Clang.get_spelling_location end_loc, nil, nil, nil, end_offset_ptr
    
    filename = Clang.get_file_name(file_ptr.read_pointer).to_s_and_dispose
    start_offset = start_offset_ptr.read_uint
    end_offset = end_offset_ptr.read_uint
    
    IO.read(filename, end_offset - start_offset, start_offset)
  end
  
end

ffi_gen = FFIGen.new(
  :blacklist => %w( clang_getExpansionLocation )
)
ffi_gen.generate
