module FFIGen
  class Generator
    class ArrayType < Type

      def initialize(element_type, constant_size)
        @element_type = element_type
        @constant_size = constant_size
      end

      def name
        Name.new(["array"])
      end

    end
  end
end
