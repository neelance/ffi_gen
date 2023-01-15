module FFIGen
  module Clang
    class Cursor

      def ==(other)
        other.is_a?(Clang::Cursor) && Clang.equal_cursors(self, other) == 1
      end

      def eql?(other)
        self == other
      end

      def hash
        Clang.hash_cursor(self)
      end

    end
  end
end
