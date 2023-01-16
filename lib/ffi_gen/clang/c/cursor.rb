module FFIGen
  module Clang
    module C

      # this extends the auto generated class
      class Cursor

        def ==(other)
          other.is_a?(C::Cursor) && C.equal_cursors(self, other) == 1
        end

        def eql?(other)
          self == other
        end

        def hash
          C.hash_cursor(self)
        end

      end

    end
  end
end
