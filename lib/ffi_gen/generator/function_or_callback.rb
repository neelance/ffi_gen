module FFIGen
  class Generator
    class FunctionOrCallback < Type

      attr_reader :name, :parameters, :return_type, :function_description, :return_value_description

      def initialize(generator, name, parameters, return_type, is_callback, blocking, function_description, return_value_description)
        @generator = generator
        @name = name
        @parameters = parameters
        @return_type = return_type
        @is_callback = is_callback
        @blocking = blocking
        @function_description = function_description
        @return_value_description = return_value_description
      end

    end
  end
end
