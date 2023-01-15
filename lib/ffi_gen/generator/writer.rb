module FFIGen
  class Generator
    class Writer

      attr_reader :output

      def initialize(indentation_prefix, comment_prefix, comment_start = nil, comment_end = nil)
        @indentation_prefix = indentation_prefix
        @comment_prefix = comment_prefix
        @comment_start = comment_start
        @comment_end = comment_end
        @current_indentation = ""
        @output = ""
      end

      def indent(prefix = @indentation_prefix)
        previous_indentation = @current_indentation
        @current_indentation += prefix
        yield
        @current_indentation = previous_indentation
      end

      def comment(&block)
        puts(@comment_start) unless @comment_start.nil?
        indent(@comment_prefix, &block)
        puts(@comment_end) unless @comment_end.nil?
      end

      def puts(*lines)
        lines.each do |line|
          @output << "#{@current_indentation}#{line}\n"
        end
      end

      def write_array(array, separator = "", first_line_prefix = "", other_lines_prefix = "")
        array.each_with_index do |entry, index|
          entry = yield(entry) if block_given?
          puts("#{index == 0 ? first_line_prefix : other_lines_prefix}#{entry}#{index < array.size - 1 ? separator : ''}")
        end
      end

      def write_description(description, not_documented_message = true, first_line_prefix = "", other_lines_prefix = "")
        description.shift while !description.empty? && description.first.strip.empty?
        description.pop while !description.empty? && description.last.strip.empty?
        description.map! { |line| line.gsub("\t", "    ") }
        space_prefix_length = description.map{ |line| line.index(/\S/) }.compact.min
        description.map! { |line| line[space_prefix_length..-1] }
        description << (not_documented_message ? "(Not documented)" : "") if description.empty?

        write_array(description, "", first_line_prefix, other_lines_prefix)
      end
    end

  end
end
