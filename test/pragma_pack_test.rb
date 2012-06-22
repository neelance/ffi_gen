require "test_utils"

run_test(
  library_name:  "PragmaPack",
  prefixes:      [],
  file_mappings: {
    File.join(
      File.dirname(__FILE__),
      "header/pragma_pack.h"
    ) => "pragma_pack.rb"
  }
)
