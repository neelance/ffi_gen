require "test_utils"

run_test(
  library_name:  "MacroExpression",
  prefixes:      [],
  file_mappings: {
    File.join(
      File.dirname(__FILE__),
      "header/macro_expression.h"
    ) => "macro_expression.rb"
  }
)
