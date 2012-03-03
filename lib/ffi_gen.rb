require "ffi_gen/clang"

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
  class Enum
    attr_reader :constants
    
    def initialize(generator, name, comment)
      @generator = generator
      @name = name
      @comment = comment
      @constants = []
    end
    
    def to_s
      prefix_length = 0
      suffix_length = 0
      
      unless @constants.size < 2
        search_pattern = @constants.all? { |constant| constant[0].include? "_" } ? /(?<=_)/ : /[A-Z]/
        first_name = @constants.first[0]
        
        loop do
          position = first_name.index(search_pattern, prefix_length + 1) or break
          prefix = first_name[0...position]
          break if not @constants.all? { |constant| constant[0].start_with? prefix }
          prefix_length = position
        end
        
        loop do
          position = first_name.rindex(search_pattern, first_name.size - suffix_length - 1) or break
          prefix = first_name[position..-1]
          break if not @constants.all? { |constant| constant[0].end_with? prefix }
          suffix_length = first_name.size - position
        end
      end
      
      symbols = []
      definitions = []
      symbol_descriptions = []
      @constants.map do |(constant_name, constant_value, constant_comment)|
        symbol = ":#{@generator.to_ruby_lowercase constant_name[prefix_length..(-1 - suffix_length)]}"
        symbols << symbol
        definitions << "    #{symbol}#{constant_value ? ", #{constant_value}" : ""}"
        symbol_descriptions << "  # #{symbol} ::\n  #   #{@generator.create_description_comment(constant_comment, '  #   ', true)}\n"
      end
      
      str = ""
      str << @generator.create_description_comment(@comment, '  # ')
      str << "  # \n"
      str << "  # === Options:\n#{symbol_descriptions.join}  #\n"
      str << "  # @return [Array<Symbol>]\n"
      str << "  def self.#{@generator.to_ruby_lowercase @name}_enum\n    [#{symbols.join(', ')}]\n  end\n"
      str << "  enum :#{@generator.to_ruby_lowercase @name}, [\n#{definitions.join(",\n")}\n  ]"
      str
    end
    
    def type_name(short)
      short ? @name : "Symbol from #{@generator.to_ruby_lowercase @name}_enum"
    end
    
    def reference
      ":#{@generator.to_ruby_lowercase @name}"
    end
  end
  
  class Struct
    attr_reader :fields
    
    def initialize(generator, name, comment)
      @generator = generator
      @name = name
      @comment = comment
      @fields = []
    end
    
    def to_s
      field_definitions = []
      field_descriptions = []
      @fields.each do |(field_name, field_type, field_comment)|
        symbol = ":#{@generator.to_ruby_lowercase field_name}"
        field_definitions << "#{symbol}, #{@generator.to_ffi_type field_type}"
        field_descriptions << "  # #{symbol} ::\n  #   (#{@generator.to_type_name field_type}) #{@generator.create_description_comment(field_comment, '  #   ', true)}\n"
      end
      
      str = ""
      str << @generator.create_description_comment(@comment, '  # ')
      str << "  # \n"
      str << "  # = Fields:\n#{field_descriptions.join}  #\n"
      str << "  class #{@generator.to_ruby_camelcase @name} < FFI::Struct\n"
      str << "    layout #{field_definitions.join(",\n           ")}\n" unless @fields.empty?
      str << "  end"
      str
    end
    
    def type_name(short)
      @generator.to_ruby_camelcase @name
    end
    
    def reference
      "#{type_name(false)}.by_value"
    end
  end
  
  class Function
    attr_reader :name, :parameters
    attr_accessor :return_type
    
    def initialize(generator, name, is_callback, comment)
      @generator = generator
      @name = name
      @parameters = []
      @is_callback = is_callback
      @comment = comment
    end
    
    def to_s
      ruby_name = @generator.to_ruby_lowercase @name
      ruby_parameters = @parameters.map do |(name, type)|
        ruby_param_type = @generator.to_type_name type
        ruby_param_name = @generator.to_ruby_lowercase(name.empty? ? @generator.to_type_name(type, true) : name)
        [ruby_param_name, ruby_param_type, []]
      end
      
      ffi_signature = "[#{@parameters.map{ |(name, type)| @generator.to_ffi_type type }.join(', ')}], #{@generator.to_ffi_type @return_type}"
      
      function_description = []
      return_value_description = []
      current_description = function_description
      @comment.split("\n").map do |line|
        line = @generator.prepare_comment_line line
        if line.gsub! /\\param (.*?) /, ''
          index = @parameters.index { |(name, type)| name == $1 }
          if index
            current_description = ruby_parameters[index][2]
          else
            current_description << "#{$1}: "
          end
        end
        current_description = return_value_description if line.gsub! '\\returns ', ''
        current_description << line
      end
      
      str = ""
      if @is_callback
        str << "  # <em>This is no real method. This entry is only for documentation of the callback.</em>\n"
        str << "  # \n"
      end
      str << @generator.create_description_comment(function_description, '  # ')
      str << "  # \n"
      str << "  # @method #{ruby_name}#{@is_callback ? '_callback' : ''}(#{ruby_parameters.map{ |(name, type, description)| name }.join(', ')})\n"
      ruby_parameters.each do |(name, type, description)|
        str << "  # @param [#{type}] #{name} #{@generator.create_description_comment(description, '  #   ', true)}\n"
      end
      str << "  # @return [#{@generator.to_type_name @return_type}] #{@generator.create_description_comment(return_value_description, '  #   ', true)}\n"
      str << "  # @scope class\n"
      if @is_callback
        str << "  callback :#{ruby_name}, #{ffi_signature}"
      else
        str << "  attach_function :#{ruby_name}, :#{@name}, #{ffi_signature}"
      end
      str
    end
    
    def type_name(short)
      "Proc(#{@generator.to_ruby_lowercase @name}_callback)"
    end
    
    def reference
      ":#{@generator.to_ruby_lowercase @name}"
    end
  end
  
  attr_reader :ruby_module, :ffi_lib, :headers, :output, :blacklist, :cflags

  def initialize(options = {})
    @ruby_module = options[:ruby_module] or fail "No module name given."
    @ffi_lib     = options[:ffi_lib] or fail "No FFI library given."
    @headers     = options[:headers] or fail "No headers given."
    @cflags      = options.fetch :cflags, []
    @prefixes    = options.fetch :prefixes, []
    @blacklist   = options.fetch :blacklist, []
    @output      = options.fetch :output, $stdout
    
    @translation_unit = nil
    @declarations = nil
  end
  
  def translation_unit
    return @translation_unit unless @translation_unit.nil?
    
    args = []
    @headers.each do |header|
      args.push "-include", header
    end
    args.concat @cflags
    args_ptr = FFI::MemoryPointer.new :pointer, args.size
    pointers = args.map { |arg| FFI::MemoryPointer.from_string arg }
    args_ptr.write_array_of_pointer pointers
    
    index = Clang.create_index 0, 0
    @translation_unit = Clang.parse_translation_unit index, File.join(File.dirname(__FILE__), "ffi_gen/empty.h"), args_ptr, args.size, nil, 0, 0
    
    Clang.get_num_diagnostics(@translation_unit).times do |i|
      diag = Clang.get_diagnostic @translation_unit, i
      $stderr.puts Clang.format_diagnostic(diag, Clang.default_diagnostic_display_options).to_s_and_dispose
    end
    
    @translation_unit
  end
  
  def declarations
    return @declarations unless @declarations.nil?
    
    header_files = []
    Clang.get_inclusions translation_unit, proc { |included_file, inclusion_stack, include_length, client_data|
      filename = Clang.get_file_name(included_file).to_s_and_dispose
      header_files << included_file if @headers.any? { |header| filename.end_with? header }
    }, nil
    
    @declarations = {}
    unit_cursor = Clang.get_translation_unit_cursor translation_unit
    previous_declaration_end = Clang.get_cursor_location unit_cursor
    Clang.get_children(unit_cursor).each do |declaration|
      file_ptr = FFI::MemoryPointer.new :pointer
      Clang.get_spelling_location Clang.get_cursor_location(declaration), file_ptr, nil, nil, nil
      file = file_ptr.read_pointer
      
      extent = Clang.get_cursor_extent declaration
      comment_range = Clang.get_range previous_declaration_end, Clang.get_range_start(extent)
      unless declaration[:kind] == :enum_decl or declaration[:kind] == :struct_decl # keep comment for typedef_decl
        previous_declaration_end = Clang.get_range_end extent
      end 
      
      next if not header_files.include? file
      
      name = Clang.get_cursor_spelling(declaration).to_s_and_dispose
      next if blacklist.include? name
      
      comment = extract_comment translation_unit, comment_range
      
      case declaration[:kind]
      when :enum_decl, :struct_decl
        read_named_declaration declaration, name, comment unless name.empty?
      
      when :function_decl
        function = Function.new self, name, false, comment
        function.return_type = Clang.get_cursor_result_type declaration
        @declarations[name] = function
        
        Clang.get_children(declaration).each do |function_child|
          next if function_child[:kind] != :parm_decl
          param_name = Clang.get_cursor_spelling(function_child).to_s_and_dispose
          param_type = Clang.get_cursor_type function_child
          function.parameters << [param_name, param_type]
        end
      
      when :typedef_decl
        typedef_children = Clang.get_children declaration
        if typedef_children.size == 1
          read_named_declaration typedef_children.first, name, comment unless @declarations.has_key? name
          
        elsif typedef_children.size > 1
          callback = Function.new self, name, true, comment
          callback.return_type = Clang.get_cursor_type typedef_children.first
          @declarations[name] = callback
          
          typedef_children[1..-1].each do |param_decl|
            param_name = Clang.get_cursor_spelling(param_decl).to_s_and_dispose
            param_type = Clang.get_cursor_type param_decl
            callback.parameters << [param_name, param_type]
          end
        end
        
      end
    end

    @declarations
  end
  
  def generate
    content = "# Generated by ffi_gen. Please do not change this file by hand.\n\nrequire 'ffi'\n\nmodule #{@ruby_module}\n  extend FFI::Library\n  ffi_lib '#{@ffi_lib}'\n\n#{declarations.values.join("\n\n")}\n\nend"
    if @output.is_a? String
      File.open(@output, "w") { |file| file.write content }
      puts "ffi_gen: #{@output}"
    else
      @output.write content
    end
  end
  
  def read_named_declaration(declaration, name, comment)
    case declaration[:kind]
    when :enum_decl
      enum = Enum.new self, name, comment
      @declarations[name] = enum
      
      previous_constant_location = Clang.get_cursor_location declaration
      Clang.get_children(declaration).each do |enum_constant|
        constant_name = Clang.get_cursor_spelling(enum_constant).to_s_and_dispose
        
        constant_value = nil
        value_cursor = Clang.get_children(enum_constant).first
        constant_value = value_cursor && case value_cursor[:kind]
        when :integer_literal
          tokens_ptr_ptr = FFI::MemoryPointer.new :pointer
          num_tokens_ptr = FFI::MemoryPointer.new :uint
          Clang.tokenize translation_unit, Clang.get_cursor_extent(value_cursor), tokens_ptr_ptr, num_tokens_ptr
          token = Clang::Token.new tokens_ptr_ptr.read_pointer
          literal = Clang.get_token_spelling translation_unit, token
          Clang.dispose_tokens translation_unit, tokens_ptr_ptr.read_pointer, num_tokens_ptr.read_uint
          literal
        else
          next # skip those entries for now
        end
        
        constant_location = Clang.get_cursor_location enum_constant
        constant_comment_range = Clang.get_range previous_constant_location, constant_location
        constant_comment = extract_comment translation_unit, constant_comment_range
        previous_constant_location = constant_location
        
        enum.constants << [constant_name, constant_value, constant_comment]
      end
      
    when :struct_decl
      struct = Struct.new self, name, comment
      @declarations[name] = struct
      
      previous_field_location = Clang.get_cursor_location declaration
      Clang.get_children(declaration).each do |field_decl|
        field_name = Clang.get_cursor_spelling(field_decl).to_s_and_dispose
        field_type = Clang.get_cursor_type field_decl
        
        field_location = Clang.get_cursor_location field_decl
        field_comment_range = Clang.get_range previous_field_location, field_location
        field_comment = extract_comment translation_unit, field_comment_range
        previous_field_location = field_location
        
        struct.fields << [field_name, field_type, field_comment]
      end
    end
  end
  
  def extract_comment(translation_unit, range)
    tokens_ptr_ptr = FFI::MemoryPointer.new :pointer
    num_tokens_ptr = FFI::MemoryPointer.new :uint
    Clang.tokenize translation_unit, range, tokens_ptr_ptr, num_tokens_ptr
    num_tokens = num_tokens_ptr.read_uint
    tokens_ptr = FFI::Pointer.new Clang::Token, tokens_ptr_ptr.read_pointer
    (num_tokens - 1).downto(0) do |i|
      token = Clang::Token.new tokens_ptr[i]
      return Clang.get_token_spelling(translation_unit, token).to_s_and_dispose if Clang.get_token_kind(token) == :comment
    end
    ""
  end
  
  def to_ffi_type(full_type)
    declaration = Clang.get_type_declaration full_type
    name = Clang.get_cursor_spelling(declaration).to_s_and_dispose
    return @declarations[name].reference if @declarations.has_key? name
    
    canonical_type = Clang.get_canonical_type full_type
    case canonical_type[:kind]
    when :void then ":void"
    when :bool then ":bool"
    when :u_char then ":uchar"
    when :u_short then ":ushort"
    when :u_int then ":uint"
    when :u_long then ":ulong"
    when :u_long_long then ":ulong_long"
    when :char_s then ":char"
    when :short then ":short"
    when :int then ":int"
    when :long then ":long"
    when :long_long then ":long_long"
    when :float then ":float"
    when :double then ":double"
    when :pointer
      pointee_type = Clang.get_pointee_type canonical_type
      pointee_type[:kind] == :char_s ? ":string" : ":pointer"
    when :constant_array
      element_type = Clang.get_array_element_type canonical_type
      size = Clang.get_array_size canonical_type
      "[#{to_ffi_type element_type}, #{size}]"
    else
      raise NotImplementedError, "No translation for values of type #{canonical_type[:kind]}"
    end
  end
  
  def to_type_name(full_type, short = false)
    declaration = Clang.get_type_declaration full_type
    name = Clang.get_cursor_spelling(declaration).to_s_and_dispose
    return @declarations[name].type_name(short) if @declarations.has_key? name
    
    canonical_type = Clang.get_canonical_type full_type
    case canonical_type[:kind]
    when :void then "nil"
    when :bool then "Boolean"
    when :u_char, :u_short, :u_int, :u_long, :u_long_long, :char_s, :short, :int, :long, :long_long then "Integer"
    when :float, :double then "Float"
    when :pointer
      pointee_type = Clang.get_pointee_type canonical_type
      if pointee_type[:kind] == :char_s
        "String"
      else
        pointer_depth = 0
        pointer_target_name = ""
        current_type = full_type
        loop do
          declaration = Clang.get_type_declaration current_type
          pointer_target_name = to_ruby_camelcase Clang.get_cursor_spelling(declaration).to_s_and_dispose
          break if not pointer_target_name.empty?

          case current_type[:kind]
          when :pointer
            pointer_depth += 1
            current_type = Clang.get_pointee_type current_type
          when :unexposed
            break
          else
            pointer_target_name = Clang.get_type_kind_spelling(current_type[:kind]).to_s_and_dispose
            break
          end
        end
        short ? pointer_target_name : "FFI::Pointer(#{'*' * pointer_depth}#{pointer_target_name})"
      end
    when :constant_array
      element_type = Clang.get_array_element_type canonical_type
      "Array<#{to_type_name element_type}>"
    else
      raise NotImplementedError, "No type name for type #{canonical_type[:kind]}"
    end
  end
  
  def to_ruby_lowercase(str)
    str = str.dup
    str.sub! /^(#{@prefixes.join('|')})/, '' # remove prefixes
    str.gsub! /([A-Z][a-z])/, '_\1' # add underscores before word beginnings
    str.gsub! /([a-z])([A-Z])/, '\1_\2' # add underscores after word endings
    str.sub! /^_*/, '' # remove underscores at the beginning
    str.gsub! /__+/, '_' # replace multiple underscores by only one
    str.downcase!
    str
  end
  
  def to_ruby_camelcase(str)
    str = str.dup
    str.sub! /^(#{@prefixes.join('|')})/, '' # remove prefixes
    str
  end
  
  def prepare_comment_line(line)
    line = line.dup
    line.sub! /\ ?\*+\/\s*$/, ''
    line.sub! /^\s*\/?\*+ ?/, ''
    line.gsub! /\\(brief|determine) /, ''
    line.gsub! '[', '('
    line.gsub! ']', ')'
    line
  end
  
  def create_description_comment(description, line_prefix, inline_mode = false)
    if description.is_a? String
      description = description.split("\n").map { |line| prepare_comment_line(line) }
    end
    
    description.shift while not description.empty? and description.first.strip.empty?
    description.pop while not description.empty? and description.last.strip.empty?
    description << "(Not documented)" if not inline_mode and description.empty?
    
    str = ""
    description.each_with_index do |line, index|
      str << line_prefix if not inline_mode or index > 0
      str << line
      str << "\n" if not inline_mode or index < description.size - 1
    end
    str
  end
  
  def self.generate(options = {})
    self.new(options).generate
  end
  
end

if __FILE__ == $0
  FFIGen.generate(
    ruby_module: "Clang",
    ffi_lib:     "clang",
    headers:     ["clang-c/Index.h"],
    cflags:      `llvm-config --cflags`.split(" "),
    prefixes:    ["clang_", "CX"],
    blacklist:   ["clang_getExpansionLocation"],
    output:      File.join(File.dirname(__FILE__), "ffi_gen/clang.rb")
  )
end
