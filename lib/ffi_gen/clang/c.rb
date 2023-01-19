module FFIGen
  module Clang
    module C

      def self.get_tokens(translation_unit, range)
        tokens_ptr_ptr = FFI::MemoryPointer.new(:pointer)
        num_tokens_ptr = FFI::MemoryPointer.new(:uint)
        C.tokenize(translation_unit, range, tokens_ptr_ptr, num_tokens_ptr)
        num_tokens = num_tokens_ptr.read_uint
        tokens_ptr = FFI::Pointer.new(C::Token, tokens_ptr_ptr.read_pointer)
        (num_tokens - 1).times.map { |i| C::Token.new(tokens_ptr[i]) }
      end

    end
  end
end
