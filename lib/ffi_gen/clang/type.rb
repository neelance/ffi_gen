module FFIGen
  module Clang

    # The type of an element in the abstract syntax tree.
    class Type

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

      # Return the canonical type for a CXType.
      # 
      # Clang's type system explicitly models typedefs and all the ways
      # a specific type can be represented.  The canonical type is the underlying
      # type with all the "sugar" removed.  For example, if 'T' is a typedef
      # for 'int', the canonical type for 'T' would be 'int'.
      def canonical
        Type.from_c(translation_unit: @translation_unit, c: C.get_canonical_type(@c))
      end

      # For pointer types, returns the type of the pointee.
      def pointee
        Type.from_c(translation_unit: @translation_unit, c: C.get_pointee_type(@c))
      end

      # Return the element type of an array type.
      #
      # If a non-array type is passed in, an invalid type is returned.
      def array_element
        Type.from_c(translation_unit: @translation_unit, c: C.get_array_element_type(@c))
      end

      # Return the array size of a constant array.
      #
      # If a non-array type is passed in, -1 is returned.
      def array_size
        C.get_array_size(@c)
      end

      # Return the cursor for the declaration of the given type.
      def declaration
        Cursor.from_c(translation_unit: @translation_unit, c: C.get_type_declaration(@c))
      end

      # Describes the kind of type
      def kind
        @c[:kind]
      end

      # Retrieve the spelling of a given CXTypeKind.
      def kind_spelling
        String.from_c(C.get_type_kind_spelling(kind)).to_s
      end

      def ==(other)
        other.is_a?(self.class) && C.equal_types(@c, other.c) != 0
      end

      def eql?(other)
        self == other
      end

      def hash
        # We have overridden #eql? so we must override #hash.
        # Unfortunately, the clang API does not have a clang_hashType like its clang_hashCursor.
        # We don't know how clang_equalTypes works as it would be a implementation detail with respect to the API.
        # We must always return 0 to be safe.
        0
      end

      def inspect
        "#<#{self.class.name}:#{object_id} tu:#{translation_unit.object_id} kind:#{kind} >"
      end

    end

  end
end
