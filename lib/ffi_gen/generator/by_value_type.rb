module FFIGen
  class Generator
    class ByValueType < Type

      def initialize(inner_type)
        @inner_type = inner_type
      end

      def name
        @inner_type.name
      end

    end
  end
end
