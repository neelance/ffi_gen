module FFIGen
  class Generator
    class StringType < Type

      def name
        Name.new(["string"])
      end

    end
  end
end
