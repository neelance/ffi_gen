require "test_utils"

run_test(
  library_name:  "LibSSH2",
  ffi_lib:       "libssh2",
  prefixes:      ["libssh2_", "LIBSSH2"],
  file_mappings: {
    "libssh2.h" => "libssh2.rb"
  }
)
