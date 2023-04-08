module FFIGen
  module Clang
    module C

      # this extends the auto generated class
      class Type

        def ==(other)
          other.is_a?(C::Type) && C.equal_types(self, other) == 1
        end

        def eql?(other)
          self == other
        end

        def hash
          0 # no hash available
        end

      end

    end
  end
end
