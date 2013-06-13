require 'ffi'

class FFI::Gen
  require "ffi/gen/clang"

  class << Clang
    def get_children(cursor)
      children = []
      visit_children cursor, lambda { |child, child_parent, child_client_data|
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
  
  attr_reader :module_name, :ffi_lib, :headers, :prefixes, :output, :cflags

  def initialize(options = {})
    @module_name   = options[:module_name] or fail "No module name given."
    @ffi_lib       = options.fetch :ffi_lib, nil
    @headers       = options[:headers] or fail "No headers given."
    @cflags        = options.fetch :cflags, []
    @prefixes      = options.fetch :prefixes, []
    @suffixes      = options.fetch :suffixes, []
    @blocking      = options.fetch :blocking, []
    @ffi_lib_flags = options.fetch :ffi_lib_flags, nil
    @output        = options.fetch :output, $stdout
    
    @translation_unit = nil
    @declarations = nil
  end
  
  def generate
    code = send "generate_#{File.extname(@output)[1..-1]}"
    if @output.is_a? String
      File.open(@output, "w") { |file| file.write code }
      puts "ffi-gen: #{@output}"
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
    @translation_unit = Clang.parse_translation_unit index, File.join(File.dirname(__FILE__), "gen/empty.h"), args_ptr, args.size, nil, 0, Clang.enum_type(:translation_unit_flags)[:detailed_preprocessing_record]
    
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
    
    unit_cursor = Clang.get_translation_unit_cursor translation_unit
    declaration_cursors = Clang.get_children unit_cursor
    declaration_cursors.delete_if { |cursor| [:macro_expansion, :inclusion_directive, :var_decl].include? cursor[:kind] }
    declaration_cursors.delete_if { |cursor| !header_files.include?(Clang.get_spelling_location_data(Clang.get_cursor_location(cursor))[:file]) }
    
    is_nested_declaration = []
    min_offset = Clang.get_spelling_location_data(Clang.get_cursor_location(declaration_cursors.last))[:offset]
    declaration_cursors.reverse_each do |declaration_cursor|
      offset = Clang.get_spelling_location_data(Clang.get_cursor_location(declaration_cursor))[:offset]
      is_nested_declaration.unshift(offset > min_offset)
      min_offset = offset if offset < min_offset
    end
    
    @declarations = []
    @declarations_by_name = {}
    @declarations_by_type = {}
    previous_declaration_end = Clang.get_cursor_location unit_cursor
    declaration_cursors.each_with_index do |declaration_cursor, index|
      comment = []
      unless is_nested_declaration[index]
        comment_range = Clang.get_range previous_declaration_end, Clang.get_cursor_location(declaration_cursor)
        comment, _ = extract_comment translation_unit, comment_range
        previous_declaration_end = Clang.get_range_end Clang.get_cursor_extent(declaration_cursor)
      end
      
      read_declaration declaration_cursor, comment
    end

    @declarations
  end
  
  def read_declaration(declaration_cursor, comment)
    name = read_name declaration_cursor
    
    declaration = case declaration_cursor[:kind]
    when :enum_decl
      enum_description = []
      constant_descriptions = {}
      current_description = enum_description
      comment.each do |line|
        if line.gsub!(/@(.*?): /, '')
          current_description = []
          constant_descriptions[$1] = current_description
        end
        current_description = enum_description if line.strip.empty?
        current_description << line
      end
      
      constants = []
      previous_constant_location = Clang.get_cursor_location declaration_cursor
      next_constant_value = 0
      Clang.get_children(declaration_cursor).each do |enum_constant|
        constant_name = read_name enum_constant
        
        constant_location = Clang.get_cursor_location enum_constant
        constant_comment_range = Clang.get_range previous_constant_location, constant_location
        constant_description, _ = extract_comment translation_unit, constant_comment_range
        constant_description.concat(constant_descriptions[constant_name.raw] || [])
        previous_constant_location = constant_location
        
        begin
          value_cursor = Clang.get_children(enum_constant).first
          constant_value = if value_cursor
            parts = []
            Clang.get_tokens(translation_unit, Clang.get_cursor_extent(value_cursor)).each do |token|
              spelling = Clang.get_token_spelling(translation_unit, token).to_s_and_dispose
              case Clang.get_token_kind(token)
              when :literal
                parts << spelling
              when :punctuation
                case spelling
                when "+", "-", "<<", ">>", "(", ")"
                  parts << spelling
                else
                  raise ArgumentError
                end
              else
                raise ArgumentError
              end
            end
            eval parts.join
          else
            next_constant_value
          end
          
          constants << { name: constant_name, value: constant_value, comment: constant_description }
          next_constant_value = constant_value + 1
        rescue ArgumentError
          puts "Warning: Could not process value of enum constant \"#{constant_name.raw}\""
        end
      end

      Enum.new self, name, constants, enum_description
      
    when :struct_decl, :union_decl
      struct = @declarations_by_type[Clang.get_cursor_type(declaration_cursor)] || StructOrUnion.new(self, name, (declaration_cursor[:kind] == :union_decl))
      raise if not struct.fields.empty?
      struct.description.concat comment
      
      struct_children = Clang.get_children declaration_cursor
      previous_field_end = Clang.get_cursor_location declaration_cursor
      last_nested_declaration = nil
      until struct_children.empty?
        child = struct_children.shift
        case child[:kind]
        when :struct_decl, :union_decl
          last_nested_declaration = read_declaration child, []
        when :field_decl
          field_name = read_name child
          field_extent = Clang.get_cursor_extent child
          
          field_comment_range = Clang.get_range previous_field_end, Clang.get_range_start(field_extent)
          field_comment, _ = extract_comment translation_unit, field_comment_range
          
          # check for comment starting on same line
          next_field_start = struct_children.first ? Clang.get_cursor_location(struct_children.first) : Clang.get_range_end(Clang.get_cursor_extent(declaration_cursor))
          following_comment_range = Clang.get_range Clang.get_range_end(field_extent), next_field_start
          following_comment, following_comment_token = extract_comment translation_unit, following_comment_range, false
          if following_comment_token and Clang.get_spelling_location_data(Clang.get_token_location(translation_unit, following_comment_token))[:line] == Clang.get_spelling_location_data(Clang.get_range_end(field_extent))[:line]
            field_comment = following_comment
            previous_field_end = Clang.get_range_end Clang.get_token_extent(translation_unit, following_comment_token)
          else
            previous_field_end = Clang.get_range_end field_extent
          end
          
          field_type = resolve_type Clang.get_cursor_type(child)
          last_nested_declaration.name ||= Name.new(name.parts + field_name.parts) if last_nested_declaration
          last_nested_declaration = nil
          struct.fields << { name: field_name, type: field_type, comment: field_comment }
        else
          raise
        end
      end
      
      struct
    
    when :function_decl
      function_description = []
      return_value_description = []
      parameter_descriptions = {}
      current_description = function_description
      comment.each do |line|
        if line.gsub!(/\\param (.*?) /, '')
          current_description = []
          parameter_descriptions[$1] = current_description
        end
        current_description = return_value_description if line.gsub! '\\returns ', ''
        current_description << line
      end
      
      return_type = resolve_type Clang.get_cursor_result_type(declaration_cursor)
      parameters = []
      first_parameter_type = nil
      Clang.get_children(declaration_cursor).each do |function_child|
        next if function_child[:kind] != :parm_decl
        param_name = read_name function_child
        tokens = Clang.get_tokens translation_unit, Clang.get_cursor_extent(function_child)
        is_array = tokens.any? { |t| Clang.get_token_spelling(translation_unit, t).to_s_and_dispose == "[" }
        param_type = resolve_type Clang.get_cursor_type(function_child), is_array
        param_name ||= param_type.name
        param_name ||= Name.new []
        first_parameter_type ||= Clang.get_cursor_type function_child
        parameters << { name: param_name, type: param_type }
      end
      
      parameters.each_with_index do |parameter, index|
        parameter[:description] = parameter[:name] && parameter_descriptions[parameter[:name].raw]
        parameter[:description] ||= parameter_descriptions.values[index] if parameter_descriptions.size == parameters.size # workaround for wrong names
        parameter[:description] ||= []
      end
      
      function = FunctionOrCallback.new self, name, parameters, return_type, false, @blocking.include?(name.raw), function_description, return_value_description
      
      pointee_declaration = first_parameter_type && get_pointee_declaration(first_parameter_type)
      if pointee_declaration
        type_prefix = pointee_declaration.name.parts.join.downcase
        function_name_parts = name.parts.dup
        while fn_name = function_name_parts.first and type_prefix.start_with?(fn_name.downcase)
          type_prefix = type_prefix[function_name_parts.first.size..-1]
          function_name_parts.shift
        end
        if type_prefix.empty?
          pointee_declaration.oo_functions << [Name.new(function_name_parts), function]
        end
      end
      
      function
    
    when :typedef_decl
      typedef_children = Clang.get_children declaration_cursor
      if typedef_children.size == 1
        child_declaration = @declarations_by_type[Clang.get_cursor_type(typedef_children.first)]
        child_declaration.name = name if child_declaration and child_declaration.name.nil?
        nil
      elsif typedef_children.size > 1
        return_type = resolve_type Clang.get_cursor_type(typedef_children.first)
        parameters = []
        typedef_children[1..-1].each do |param_decl|
          param_name = read_name param_decl
          param_type = resolve_type Clang.get_cursor_type(param_decl)
          param_name ||= param_type.name
          parameters << { name:param_name, type: param_type, description: [] }
        end
        FunctionOrCallback.new self, name, parameters, return_type, true, false, comment, []
      else
        nil
      end
        
    when :macro_definition
      tokens = Clang.get_tokens(translation_unit, Clang.get_cursor_extent(declaration_cursor)).map { |token|
        [Clang.get_token_kind(token), Clang.get_token_spelling(translation_unit, token).to_s_and_dispose]
      }
      if tokens.size > 1
        tokens.shift
        begin
          parameters = nil
          if tokens.first[1] == "("
            tokens_backup = tokens.dup
            begin
              parameters = []
              tokens.shift
              loop do
                kind, spelling = tokens.shift
                case kind
                when :identifier
                  parameters << spelling
                when :punctuation
                  break if spelling == ")"
                  raise ArgumentError unless spelling == ","
                else
                  raise ArgumentError
                end
              end
            rescue ArgumentError
              parameters = nil
              tokens = tokens_backup
            end
          end
          value = []
          until tokens.empty?
            kind, spelling = tokens.shift
            case kind
            when :literal
              value << spelling
            when :punctuation
              case spelling
              when "+", "-", "<<", ">>", ")"
                value << spelling
              when ","
                value << ", "
              when "("
                if tokens[1][1] == ")"
                  tokens.delete_at 1
                else
                  value << spelling
                end
              else
                raise ArgumentError
              end
            when :identifier
              raise ArgumentError unless parameters
              if parameters.include? spelling
                value << spelling
              elsif spelling == "NULL"
                value << "nil"
              else
                if not tokens.empty? and tokens.first[1] == "("
                  tokens.shift
                  if spelling == "strlen"
                    argument_kind, argument_spelling = tokens.shift
                    second_token_kind, second_token_spelling = tokens.shift
                    raise ArgumentError unless argument_kind == :identifier and second_token_spelling == ")"
                    value << "#{argument_spelling}.length"
                  else
                    value << [:method, read_name(spelling)]
                    value << "("
                  end
                else
                  value << [:constant, read_name(spelling)]
                end
              end
            when :keyword
              raise ArgumentError unless spelling == "sizeof" and tokens[0][1] == "(" and tokens[1][0] == :literal and tokens[2][1] == ")"
              tokens.shift
              argument_kind, argument_spelling = tokens.shift
              value << "#{argument_spelling}.length"
              tokens.shift
            else
              raise ArgumentError
            end
          end
          Define.new(self, name, parameters, value)
        rescue ArgumentError
          puts "Warning: Could not process value of macro \"#{name.raw}\""
          nil
        end
      else
        nil
      end
    
    else
      raise declaration_cursor[:kind].to_s

    end
    
    return nil if declaration.nil?
    @declarations.delete declaration
    @declarations << declaration
    @declarations_by_name[name] = name.raw unless name.nil?
    type = Clang.get_cursor_type declaration_cursor
    @declarations_by_type[type] = declaration unless type.nil?
    
    declaration
  end
  
  def resolve_type(full_type, is_array = false)
    canonical_type = Clang.get_canonical_type full_type
    data_array = case canonical_type[:kind]
    when :void, :bool, :u_char, :u_short, :u_int, :u_long, :u_long_long, :char_s, :s_char, :short, :int, :long, :long_long, :float, :double
      PrimitiveType.new canonical_type[:kind]
    when :pointer
      if is_array
        ArrayType.new resolve_type(Clang.get_pointee_type(canonical_type)), nil
      else
        pointee_type = Clang.get_pointee_type canonical_type
        type = case pointee_type[:kind]
        when :char_s
          StringType.new
        when :record
          @declarations_by_type[Clang.get_cursor_type(Clang.get_type_declaration(pointee_type))]
        when :function_proto
          @declarations_by_type[full_type]
        else
          nil
        end
        
        if type.nil?
          pointer_depth = 0
          pointee_name = ""
          current_type = full_type
          loop do
            declaration_cursor = Clang.get_type_declaration current_type
            pointee_name = read_name declaration_cursor
            break if pointee_name
  
            case current_type[:kind]
            when :pointer
              pointer_depth += 1
              current_type = Clang.get_pointee_type current_type
            when :unexposed
              break
            else
              pointee_name = Name.new Clang.get_type_kind_spelling(current_type[:kind]).to_s_and_dispose.split("_")
              break
            end
          end
          type = PointerType.new pointee_name, pointer_depth
        end
        
        type
      end
    when :record
      type = @declarations_by_type[canonical_type]
      type &&= ByValueType.new(type)
      type || UnknownType.new # TODO
    when :enum
      @declarations_by_type[canonical_type] || UnknownType.new # TODO
    when :constant_array
      ArrayType.new resolve_type(Clang.get_array_element_type(canonical_type)), Clang.get_array_size(canonical_type)
    when :unexposed, :function_proto
      UnknownType.new
    else
      raise NotImplementedError, "No translation for values of type #{canonical_type[:kind]}"
    end
  end
  
  def read_name(source)
    source = Clang.get_cursor_spelling(source).to_s_and_dispose if source.is_a? Clang::Cursor
    return nil if source.empty?
    trimmed = source.sub(/^(#{@prefixes.join('|')})/, '')
    trimmed = trimmed.sub(/(#{@suffixes.join('|')})$/, '')
    parts = trimmed.split(/_|(?=[A-Z][a-z])|(?<=[a-z])(?=[A-Z])/).reject(&:empty?)
    Name.new parts, source
  end
  
  def get_pointee_declaration(type)
    canonical_type = Clang.get_canonical_type type
    return nil if canonical_type[:kind] != :pointer
    pointee_type = Clang.get_pointee_type canonical_type
    return nil if pointee_type[:kind] != :record
    @declarations_by_type[Clang.get_cursor_type(Clang.get_type_declaration(pointee_type))]
  end
  
  def extract_comment(translation_unit, range, search_backwards = true)
    tokens = Clang.get_tokens translation_unit, range
    
    iterator = search_backwards ? tokens.reverse_each : tokens.each
    comment_lines = []
    comment_token = nil
    comment_block = false
    iterator.each do |token|
      next if Clang.get_token_kind(token) != :comment
      comment = Clang.get_token_spelling(translation_unit, token).to_s_and_dispose
      lines = comment.split("\n").map { |line|
        line.sub!(/\ ?\*+\/\s*$/, '')
        line.sub!(/^\s*\/?[*\/]+ ?/, '')
        line.gsub!(/\\(brief|determine) /, '')
        line.gsub!('[', '(')
        line.gsub!(']', ')')
        line
      }
      comment_lines = lines + comment_lines
      comment_token = token
      comment_block = !comment_block if comment == "///"
      break unless comment_block and search_backwards
    end

    return comment_lines, comment_token
  end
  
  def self.generate(options = {})
    self.new(options).generate
  end
  
  require "ffi/gen/ruby_output"
  require "ffi/gen/java_output"
end

if __FILE__ == $0
  FFI::Gen.generate(
    module_name: "FFI::Gen::Clang",
    ffi_lib:     "clang",
    headers:     ["clang-c/Index.h"],
    cflags:      `llvm-config --cflags`.split(" "),
    prefixes:    ["clang_", "CX"],
    output:      File.join(File.dirname(__FILE__), "gen/clang.rb")
  )
end
