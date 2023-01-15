module FFIGen
  class Generator
    class UnknownType < Type

      def name
        Name.new(["unknown"])
      end

    end
  end
end
