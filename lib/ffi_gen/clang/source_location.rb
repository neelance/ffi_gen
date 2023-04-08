module FFIGen
  module Clang

    # Identifies a specific source location within a translation unit.
    #
    # It will map a source location to a particular file, line, and column.
    class SourceLocation

      # @api private
      def self.from_c(**args)
        new(**args)
      end

      # @api private
      def self.from_cursor(cursor: )
        c = C.get_cursor_location(cursor.c)
        new(translation_unit: cursor.translation_unit, c: c)
      end

      attr_reader :c, :translation_unit

      # @api private
      def initialize(translation_unit: , c: )
        @translation_unit = translation_unit
        @c = c
      end

      def file
        String.from_c(C.get_file_name(get_spelling_location_data[:file])).to_s
      end

      def line
        get_spelling_location_data[:line]
      end

      def column
        get_spelling_location_data[:column]
      end

      def offset
        get_spelling_location_data[:offset]
      end

      # @api private
      def get_spelling_location_data
        file_ptr = FFI::MemoryPointer.new(:pointer)
        line_ptr = FFI::MemoryPointer.new(:uint)
        column_ptr = FFI::MemoryPointer.new(:uint)
        offset_ptr = FFI::MemoryPointer.new(:uint)
        C.get_spelling_location(@c, file_ptr, line_ptr, column_ptr, offset_ptr)
        { file: file_ptr.read_pointer, line: line_ptr.read_uint, column: column_ptr.read_uint, offset: offset_ptr.read_uint }
      end

      def ==(other)
        other.is_a?(self.class) && C.equal_locations(@c, other.c) != 0
      end

      def eql?(other)
        self == other
      end

      def to_s
        "#{file}:#{line}:#{column}"
      end

      def inspect
        "#<#{self.class.name}:#{object_id} tu:#{translation_unit.object_id} file:#{file} line:#{line} column:#{column} >"
      end

    end

  end
end
