module FFIGen
  class Generator
    class StructOrUnion < Type

      attr_accessor :name, :description
      attr_reader :fields, :oo_functions, :written

      def initialize(generator, name, is_union)
        @generator = generator
        @name = name
        @is_union = is_union
        @description = []
        @fields = []
        @oo_functions = []
        @written = false
      end

    end
  end
end
