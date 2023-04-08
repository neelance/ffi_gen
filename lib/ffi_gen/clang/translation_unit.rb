module FFIGen
  module Clang

    # A single translation unit, which resides in an index.
    # A translation unit represents a single source file (eg. file.c) after preprocessing (all #included *.h files instantiated, all macro are expanded, all comments are skipped, and file is ready for tokenizing).
    # see: https://stackoverflow.com/questions/7146425/llvm-translation-unit
    class TranslationUnit

      # @api private
      def self.parse(**args)
        return new(**args)
      end

      attr_reader :c, :index

      # @api private
      def initialize(index: , **args)
        @index = index
        @c = create(**args)
        @c.autorelease = false # we must call clang_disposeTranslationUnit to free it
      end

      # @api private
      def create(source_files: , arguments: )
        args = []
        args.concat(arguments)
        source_files.each { |file| args.push("-include", file) }

        args_ptr = FFI::MemoryPointer.new(:pointer, args.size)
        pointers = args.map { |arg| FFI::MemoryPointer.from_string(arg) }
        args_ptr.write_array_of_pointer(pointers)

        # TODO: use clang_parseTranslationUnit2 instead for a better error output?
        c = C.parse_translation_unit(@index.c, File.join(File.dirname(__FILE__), "../empty.h"), args_ptr, args.size, nil, 0, Clang::C.enum_type(:translation_unit_flags)[:detailed_preprocessing_record])
        raise 'failed to parse translation unit' if c == FFI::Pointer::NULL

        return c
      end

      # Destroy the given translation unit
      # TODO: replace with a finalizer
      def dispose
        return if @c == FFI::Pointer::NULL
        C.dispose_translation_unit(@c)
        @c = FFI::Pointer::NULL
      end

      def get_diagnostics
        string = ''
        C.get_num_diagnostics(@c).times do |i|
          diagnostic = C.get_diagnostic(@c, i)
          string_c = C.format_diagnostic(diagnostic, C.default_diagnostic_display_options)
          string += String.from_c(string_c).to_s
          C.dispose_diagnostic(diagnostic)
        end
        return string
      end

      def included_files
        files = []
        visitor = proc do |included_file, inclusion_stack, include_length, client_data|
          string_c = C.get_file_name(included_file)
          files << String.from_c(string_c).to_s
        end
        C.get_inclusions(@c, visitor, nil)

        return files
      end

      def get_cursor
        Cursor.get(translation_unit: self)
      end

      def inspect
        "#<#{self.class.name}:#{object_id} index:#{index.inspect} >"
      end

    end

  end
end
