module FFIGen
  module Clang

    # Describes a single preprocessing token.
    #
    # Represents a raw lexical token within a translation unit.
    class Token

      # @api private
      def self.from_c(**args)
        new(**args)
      end

      attr_reader :c, :translation_unit

      # @api private
      def initialize(translation_unit: , c: )
        @translation_unit = translation_unit
        @c = c
      end

      # Determine the spelling of the given token.
      #
      # The spelling of a token is the textual representation of that token, e.g., the text of an identifier or keyword.
      def spelling
        String.from_c(C.get_token_spelling(@translation_unit.c, @c)).to_s
      end

      # Retrieve the source location of the given token.
      def location
        SourceLocation.from_c(translation_unit: @translation_unit, c: C.get_token_location(@translation_unit.c, @c))
      end

      # Retrieve a source range that covers the given token.
      def extent
        SourceRange.from_c(translation_unit: @translation_unit, c: C.get_token_extent(@translation_unit.c, @c))
      end

      # Determine the kind of the given token.
      def kind
        C.get_token_kind(@c)
      end

      def inspect
        "#<#{self.class.name}:#{object_id} tu:#{translation_unit.object_id} location:#{location.to_s} spelling:#{spelling.inspect} kind:#{kind} >"
      end

    end

  end
end
