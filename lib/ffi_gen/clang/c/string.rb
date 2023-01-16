module FFIGen
  module Clang
    module C

      # this extends the auto generated class
      class String

        def to_s
          C.get_c_string(self)
        end

        def to_s_and_dispose
          str = to_s
          C.dispose_string(self)
          str
        end

      end

    end
  end
end
