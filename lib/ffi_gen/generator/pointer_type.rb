module FFIGen
  class Generator
    class PointerType < Type

      attr_reader :pointee_name, :depth

      def initialize(pointee_name, depth)
        @pointee_name = pointee_name
        @depth = depth
      end

      def name
        @pointee_name
      end

    end
  end
end
