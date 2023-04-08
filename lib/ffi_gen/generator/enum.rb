module FFIGen
  class Generator
    class Enum < Type

      attr_accessor :name

      def initialize(generator, name, constants, description)
        @generator = generator
        @name = name
        @constants = constants
        @description = description
      end

      def shorten_names
        return if @constants.size < 2
        names = @constants.map { |constant| constant[:name].parts }
        names.each(&:shift) while names.map(&:first).uniq.size == 1 && @name.parts.map(&:downcase).include?(names.first.first.downcase)
        names.each(&:pop) while names.map(&:last).uniq.size == 1 && @name.parts.map(&:downcase).include?(names.first.last.downcase)
      end

    end
  end
end
