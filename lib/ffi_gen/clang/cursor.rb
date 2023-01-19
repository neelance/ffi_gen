module FFIGen
  module Clang

    # A cursor representing some element in the abstract syntax tree for
    # a translation unit.
    #
    # The cursor abstraction unifies the different kinds of entities in a
    # program (declaration, statements, expressions, references to declarations,
    # etc.) under a single "cursor" abstraction with a common set of operations.
    # Common operation for a cursor include: getting the physical location in
    # a source file where the cursor points, getting the name associated with a
    # cursor, and retrieving cursors for any child nodes of a particular cursor.
    #
    # Cursors can be produced from +TranslationUnit#cursor+ which produces a
    # cursor for a translation unit, from which one can use +#children+
    # to explore the rest of the translation unit.
    class Cursor

      def self.get(**args)
        new(**args)
      end

      def self.from_c(**args)
        new(**args)
      end

      attr_reader :c, :translation_unit

      # @api private
      def initialize(translation_unit: , c: nil)
        @translation_unit = translation_unit
        @c = c || create
      end

      def create
        C.get_translation_unit_cursor(@translation_unit.c)
      end

      def children
        children = []
        visitor = proc do |visit_result, child, child_parent, child_client_data|
          children << self.class.from_c(translation_unit: @translation_unit, c: child)
          :continue
        end
        C.visit_children(@c, visitor, nil)
        return children
      end

      # Retrieve the physical location of the source constructor referenced by the given cursor.
      #
      # The location of a declaration is typically the location of the name of that declaration,
      # where the name of that declaration would occur if it is unnamed, or some keyword that
      # introduces that particular declaration.
      # The location of a reference is where that reference occurs within the source code.
      def location
        SourceLocation.from_cursor(cursor: self)
      end

      def kind
        @c[:kind]
      end

      def spelling
        String.from_c(C.get_cursor_spelling(@c)).to_s
      end

      def ==(other)
        other.is_a?(self.class) && C.equal_cursors(@c, other.c) == 1
      end

      def eql?(other)
        self == other
      end

      def hash
        C.hash_cursor(@c)
      end

      def inspect
        "#<#{self.class.name}:#{object_id} tu:#{translation_unit.object_id} locaiton:#{location.to_s} spelling:#{spelling.inspect} kind:#{kind} children:#{children.count} >"
      end

    end

  end
end
