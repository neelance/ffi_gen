require "test_utils"

run_test(
  library_name:  "SQLite3",
  ffi_lib:       "sqlite3",
  prefixes:      ["sqlite3_", "SQLITE_"],
  files:         ["sqlite3.h"]
)
