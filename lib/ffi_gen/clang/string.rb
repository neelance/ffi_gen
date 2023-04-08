module FFIGen
  module Clang

    # A character string.
    # The String type is used to return strings from the interface when
    # the ownership of that string might differ from one call to the next.
    class String

      # @api private
      def self.from_c(c)
        return new(c)
      end

      # @api private
      def self.finalizer(c)
        proc { C.dispose_string(c) }
      end

      # @api private
      attr_reader :c

      # @api private
      def initialize(c)
        @c = c
        ObjectSpace.define_finalizer(self, self.class.finalizer(@c))
      end

      def to_s
        C.get_c_string(c)
      end

      def inspect
        "#<#{self.class.name} value:#{to_s.inspect} >"
      end

    end

  end
end
