require "test_utils"

run_test(
  library_name:  "ConstVariable",
  prefixes:      [],
  file_mappings: {
    File.join(
      File.dirname(__FILE__),
      "header/const_variable.h"
    ) => "const_variable.rb"
  }
)
