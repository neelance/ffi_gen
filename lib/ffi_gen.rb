class FFIGen
  require "ffi_gen/clang"
  require "ffi_gen/ruby_output"
  require "ffi_gen/java_output"

  class << Clang
    def get_children(declaration)
      children = []
      visit_children declaration, lambda { |child, child_parent, child_client_data|
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
  
  class Enum
    attr_accessor :name
    attr_reader :constants, :comment
    
    def initialize(generator, name, comment)
      @generator = generator
      @name = name
      @comment = comment
      @constants = []
    end
    
    def shorten_names
      return if @constants.size < 2
      names = @constants.map { |constant| constant[:name] }
      names.each(&:shift) while names.map(&:first).uniq.size == 1 and @name.map(&:downcase).include? names.first.first.downcase
      names.each(&:pop) while names.map(&:last).uniq.size == 1 and @name.map(&:downcase).include? names.first.last.downcase
    end
  end
  
  class StructOrUnion
    attr_accessor :name, :comment
    attr_reader :fields, :oo_functions, :written
    
    def initialize(generator, name, is_union)
      @generator = generator
      @name = name
      @is_union = is_union
      @comment = ""
      @fields = []
      @oo_functions = []
      @written = false
    end
  end
  
  class FunctionOrCallback
    attr_reader :name, :c_name, :parameters, :comment
    attr_accessor :return_type
    
    def initialize(generator, name, c_name, is_callback, blocking, comment)
      @generator = generator
      @name = name
      @c_name = c_name
      @parameters = []
      @is_callback = is_callback
      @blocking = blocking
      @comment = comment
    end
  end
  
  class Constant
    def initialize(generator, name, value)
      @generator = generator
      @name = name
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
    
    def prepare_comment_line(line)
      line = line.dup
      line.sub!(/\ ?\*+\/\s*$/, '')
      line.sub!(/^\s*\/?\*+ ?/, '')
      line.gsub!(/\\(brief|determine) /, '')
      line.gsub!('[', '(')
      line.gsub!(']', ')')
      line
    end
    
    def write_description(description, not_documented_message = true, first_line_prefix = "", other_lines_prefix = "")
      if description.is_a? String
        description = description.split("\n").map { |line| prepare_comment_line(line) }
      end

      description.shift while not description.empty? and description.first.strip.empty?
      description.pop while not description.empty? and description.last.strip.empty?
      description.map! { |line| line.gsub "\t", "    " }
      space_prefix_length = description.map{ |line| line.index(/\S/) }.compact.min
      description.map! { |line| line[space_prefix_length..-1] }
      description << (not_documented_message ? "(Not documented)" : "") if description.empty?
      
      write_array description, "", first_line_prefix, other_lines_prefix
    end
  end
  
  attr_reader :module_name, :ffi_lib, :headers, :output, :blacklist, :cflags

  def initialize(options = {})
    @module_name   = options[:module_name] or fail "No module name given."
    @ffi_lib       = options[:ffi_lib] or fail "No FFI library given."
    @headers       = options[:headers] or fail "No headers given."
    @cflags        = options.fetch :cflags, []
    @prefixes      = options.fetch :prefixes, []
    @blacklist     = options.fetch :blacklist, []
    @blocking      = options.fetch :blocking, []
    @ffi_lib_flags = options.fetch :ffi_lib_flags, nil
    @output        = options.fetch :output, $stdout
    
    blacklist = @blacklist
    @blacklist = lambda { |name| blacklist.include? name } if @blacklist.is_a? Array
    
    @translation_unit = nil
    @declarations = nil
  end
  
  def generate
    code = send "generate_#{File.extname(@output)[1..-1]}"
    if @output.is_a? String
      File.open(@output, "w") { |file| file.write code }
      puts "ffi_gen: #{@output}"
    else
      @output.write code
    end
  end
  
  def translation_unit
    return @translation_unit unless @translation_unit.nil?
    
    args = []
    @headers.each do |header|
      args.push "-include", header unless header.is_a? Regexp
    end
    args.concat @cflags
    args_ptr = FFI::MemoryPointer.new :pointer, args.size
    pointers = args.map { |arg| FFI::MemoryPointer.from_string arg }
    args_ptr.write_array_of_pointer pointers
    
    index = Clang.create_index 0, 0
    @translation_unit = Clang.parse_translation_unit index, File.join(File.dirname(__FILE__), "ffi_gen/empty.h"), args_ptr, args.size, nil, 0, Clang.enum_type(:translation_unit_flags)[:detailed_preprocessing_record]
    
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
      header_files << included_file if @headers.any? { |header| header.is_a?(Regexp) ? header =~ filename : filename.end_with?(header) }
    }, nil
    
    @declarations = {}
    unit_cursor = Clang.get_translation_unit_cursor translation_unit
    previous_declaration_end = Clang.get_cursor_location unit_cursor
    Clang.get_children(unit_cursor).each do |declaration|
      file = Clang.get_spelling_location_data(Clang.get_cursor_location(declaration))[:file]
      
      extent = Clang.get_cursor_extent declaration
      comment_range = Clang.get_range previous_declaration_end, Clang.get_range_start(extent)
      unless [:enum_decl, :struct_decl, :union_decl].include? declaration[:kind] # keep comment for typedef_decl
        previous_declaration_end = Clang.get_range_end extent
      end 
      
      next if not header_files.include? file
      
      name = Clang.get_cursor_spelling(declaration).to_s_and_dispose
      name = nil if name.empty?
      next if @blacklist[name]
      
      comment = extract_comment translation_unit, comment_range
      
      read_named_declaration declaration, comment
    end

    @declarations
  end
  
  def split_name(name)
    name.sub(/^(#{@prefixes.join('|')})/, '').split(/_|(?=[A-Z][a-z])|(?<=[a-z])(?=[A-Z])/).reject(&:empty?)
  end
  
  def read_named_declaration(declaration, comment)
    c_name = Clang.get_cursor_spelling(declaration).to_s_and_dispose
    name = split_name c_name

    case declaration[:kind]
    when :enum_decl
      enum = Enum.new self, name, comment
      @declarations[Clang.get_cursor_type(declaration)] = enum
      
      previous_constant_location = Clang.get_cursor_location declaration
      Clang.get_children(declaration).each do |enum_constant|
        constant_name = split_name Clang.get_cursor_spelling(enum_constant).to_s_and_dispose
        
        constant_value = nil
        value_cursor = Clang.get_children(enum_constant).first
        constant_value = value_cursor && case value_cursor[:kind]
        when :integer_literal
          tokens_ptr_ptr = FFI::MemoryPointer.new :pointer
          num_tokens_ptr = FFI::MemoryPointer.new :uint
          Clang.tokenize translation_unit, Clang.get_cursor_extent(value_cursor), tokens_ptr_ptr, num_tokens_ptr
          token = Clang::Token.new tokens_ptr_ptr.read_pointer
          literal = Clang.get_token_spelling(translation_unit, token).to_s_and_dispose
          Clang.dispose_tokens translation_unit, tokens_ptr_ptr.read_pointer, num_tokens_ptr.read_uint
          literal
        else
          next # skip those entries for now
        end
        
        constant_location = Clang.get_cursor_location enum_constant
        constant_comment_range = Clang.get_range previous_constant_location, constant_location
        constant_comment = extract_comment translation_unit, constant_comment_range
        previous_constant_location = constant_location
        
        enum.constants << { name: constant_name, value: constant_value, comment: constant_comment }
      end
      
    when :struct_decl, :union_decl
      struct = @declarations.delete(Clang.get_cursor_type(declaration)) || StructOrUnion.new(self, name, (declaration[:kind] == :union_decl))
      raise if not struct.fields.empty?
      struct.comment << "\n#{comment}"
      
      struct_children = Clang.get_children declaration
      previous_field_end = Clang.get_cursor_location declaration
      until struct_children.empty?
        nested_declaration = [:struct_decl, :union_decl].include?(struct_children.first[:kind]) ? struct_children.shift : nil
        field = struct_children.shift
        raise if field[:kind] != :field_decl
        
        field_name = split_name Clang.get_cursor_spelling(field).to_s_and_dispose
        field_extent = Clang.get_cursor_extent field
        
        field_comment_range = Clang.get_range previous_field_end, Clang.get_range_start(field_extent)
        field_comment = extract_comment translation_unit, field_comment_range
        
        # check for comment starting on same line
        next_field_start = struct_children.first ? Clang.get_cursor_location(struct_children.first) : Clang.get_range_end(Clang.get_cursor_extent(declaration))
        following_comment_range = Clang.get_range Clang.get_range_end(field_extent), next_field_start
        following_comment_token = extract_comment translation_unit, following_comment_range, false, false
        if following_comment_token and Clang.get_spelling_location_data(Clang.get_token_location(translation_unit, following_comment_token))[:line] == Clang.get_spelling_location_data(Clang.get_range_end(field_extent))[:line]
          field_comment = Clang.get_token_spelling(translation_unit, following_comment_token).to_s_and_dispose
          previous_field_end = Clang.get_range_end Clang.get_token_extent(translation_unit, following_comment_token)
        else
          previous_field_end = Clang.get_range_end field_extent
        end
        
        if nested_declaration
          read_named_declaration nested_declaration, ""
          decl = @declarations[Clang.get_cursor_type(nested_declaration)]
          decl.name = name + field_name if decl and decl.name.empty?
        end
        
        field_type = Clang.get_cursor_type field
        struct.fields << { name: field_name, type: field_type, comment: field_comment }
      end
      
      @declarations[Clang.get_cursor_type(declaration)] = struct
    
    when :function_decl
      function = FunctionOrCallback.new self, name, c_name, false, @blocking.include?(c_name), comment
      function.return_type = Clang.get_cursor_result_type declaration
      @declarations[declaration] = function
      
      Clang.get_children(declaration).each do |function_child|
        next if function_child[:kind] != :parm_decl
        param_name = Clang.get_cursor_spelling(function_child).to_s_and_dispose
        param_type = Clang.get_cursor_type function_child
        function.parameters << { name: split_name(param_name), c_name: param_name, type: param_type }
      end
      
      pointee_declaration = function.parameters.first && get_pointee_declaration(function.parameters.first[:type])
      if pointee_declaration && name.map(&:downcase)[0, pointee_declaration.name.size] == pointee_declaration.name.map(&:downcase)
        pointee_declaration.oo_functions << [name[pointee_declaration.name.size..-1], function, get_pointee_declaration(function.return_type)]
      end
    
    when :typedef_decl
      typedef_children = Clang.get_children declaration
      if typedef_children.size == 1
        child_declaration = @declarations[Clang.get_cursor_type(typedef_children.first)]
        child_declaration.name = name if child_declaration and child_declaration.name.empty?
        
      elsif typedef_children.size > 1
        callback = FunctionOrCallback.new self, name, nil, true, false, comment
        callback.return_type = Clang.get_cursor_type typedef_children.first
        @declarations[Clang.get_cursor_type(declaration)] = callback
        
        typedef_children[1..-1].each do |param_decl|
          param_name = Clang.get_cursor_spelling(param_decl).to_s_and_dispose
          param_type = Clang.get_cursor_type param_decl
          callback.parameters << { name: split_name(param_name), type: param_type }
        end
      end
        
    when :macro_definition
      tokens_ptr_ptr = FFI::MemoryPointer.new :pointer
      num_tokens_ptr = FFI::MemoryPointer.new :uint
      
      Clang.tokenize translation_unit, Clang.get_cursor_extent(declaration), tokens_ptr_ptr, num_tokens_ptr
      num_tokens = num_tokens_ptr.read_uint
      tokens_ptr = FFI::Pointer.new Clang::Token, tokens_ptr_ptr.read_pointer
      
      if num_tokens == 3
        token = Clang::Token.new tokens_ptr[1]
        if Clang.get_token_kind(token) == :literal
          value = Clang.get_token_spelling(translation_unit, token).to_s_and_dispose
          value.sub!(/[A-Za-z]+$/, '') unless value.start_with? '0x' # remove number suffixes
          @declarations[name] ||= Constant.new self, name, value
        end 
      end
      
    end
  end
  
  def get_pointee_declaration(type)
    canonical_type = Clang.get_canonical_type type
    return nil if canonical_type[:kind] != :pointer
    pointee_type = Clang.get_pointee_type canonical_type
    return nil if pointee_type[:kind] != :record
    @declarations[Clang.get_cursor_type(Clang.get_type_declaration(pointee_type))]
  end
  
  def extract_comment(translation_unit, range, search_backwards = true, return_spelling = true)
    tokens_ptr_ptr = FFI::MemoryPointer.new :pointer
    num_tokens_ptr = FFI::MemoryPointer.new :uint
    Clang.tokenize translation_unit, range, tokens_ptr_ptr, num_tokens_ptr
    num_tokens = num_tokens_ptr.read_uint
    tokens_ptr = FFI::Pointer.new Clang::Token, tokens_ptr_ptr.read_pointer
    indices = search_backwards ? (num_tokens - 1).downto(0) : 0.upto(num_tokens - 1)
    indices.each do |i|
      token = Clang::Token.new tokens_ptr[i]
      if Clang.get_token_kind(token) == :comment
        return return_spelling ? Clang.get_token_spelling(translation_unit, token).to_s_and_dispose : token
      end
    end
    ""
  end
  
  def self.generate(options = {})
    self.new(options).generate
  end
  
end

if __FILE__ == $0
  FFIGen.generate(
    module_name: "FFIGen::Clang",
    ffi_lib:     "clang",
    headers:     ["clang-c/Index.h"],
    cflags:      `llvm-config --cflags`.split(" "),
    prefixes:    ["clang_", "CX"],
    blacklist:   ["clang_getExpansionLocation"],
    output:      File.join(File.dirname(__FILE__), "ffi_gen/clang.rb")
  )
end
