require "test_utils"

run_test(
  library_name:  "SimilarEnums",
  prefixes:      [],
  no_shorten_names:true,
  file_mappings: {
    File.join(
      File.dirname(__FILE__),
      "header/similar_enums.h"
    ) => "similar_enums.rb"
  }
)
