module FFIGen
  module Clang

    # Provides a shared context for creating translation units.
    # An "index" that consists of a set of translation units that would
    # typically be linked together into an executable or library.
    class Index

      def self.create
        new
      end

      attr_reader :c

      # @api private
      def initialize
        @c = Clang::C.create_index(0, 0)
        @c.autorelease = false # we must call clang_disposeIndex to free it
      end

      # Destroy the given index.
      # The index must not be destroyed until all of the translation units created
      # within that index have been destroyed.
      # TODO: replace with a finalizer
      def dispose
        return if @c == FFI::Pointer::NULL
        C.dispose_index(@c)
        @c = FFI::Pointer::NULL
      end

      def parse_translation_unit(**args)
        TranslationUnit.parse(index: self, **args)
      end

      def inspect
        "#<#{self.class.name}:#{object_id}>"
      end

    end

  end
end
