module FFIGen
  module Clang
    class String

      def to_s
        Clang.get_c_string self
      end

      def to_s_and_dispose
        str = to_s
        Clang.dispose_string self
        str
      end

    end
  end
end
