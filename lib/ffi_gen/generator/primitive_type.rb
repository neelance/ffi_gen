module FFIGen
  class Generator
    class PrimitiveType < Type

      def initialize(clang_type)
        @clang_type = clang_type
      end

      def name
        Name.new([@clang_type.to_s])
      end

    end
  end
end
