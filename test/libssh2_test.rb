require "test_utils"

run_test(
  library_name:  "LibSSH2",
  ffi_lib:       "libssh2",
  prefixes:      ["libssh2_", "LIBSSH2"],
  files:         ["libssh2.h"]
)
