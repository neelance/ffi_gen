module FFIGen
  module Clang
    class Type

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
  end
end
