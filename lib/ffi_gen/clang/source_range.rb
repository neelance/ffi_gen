module FFIGen
  module Clang

    # Identifies a half-open character range in the source code.
    #
    # Use +#start+ and +#end+ to retrieve the start and end locations from a source range, respectively.
    class SourceRange

      # @api private
      def self.from_c(**args)
        new(**args)
      end

      def self.get(start: , end: )
        _end = binding.local_variable_get(:end) # reserved name
        c = C.get_range(start.c, _end.c)
        unless start.translation_unit == _end.translation_unit
          raise(ArgumentError, 'start and end locations are from different translation units')
        end
        new(translation_unit: start.translation_unit, c: c)
      end

      attr_reader :c, :translation_unit

      # @api private
      def initialize(translation_unit: , c: )
        @translation_unit = translation_unit
        @c = c
      end

      def start
        SourceLocation.from_c(translation_unit: @translation_unit, c: C.get_range_start(@c))
      end

      def end
        SourceLocation.from_c(translation_unit: @translation_unit, c: C.get_range_end(@c))
      end

      def ==(other)
        other.is_a?(self.class) && C.equal_ranges(@c, other.c) != 0
      end

      def eql?(other)
        self == other
      end

      def inspect
        "#<#{self.class.name}:#{object_id} tu:#{translation_unit.object_id} start:#{start.to_s} end:#{self.end.to_s} >"
      end

    end

  end
end
