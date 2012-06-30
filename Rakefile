task :test do
  $: << File.join(File.dirname(__FILE__), "lib")
  $: << File.join(File.dirname(__FILE__), "test")
  
  require "cairo_test"
  require "cef_test"
  require "clang_test"
  require "libssh2_test"
  require "llvm_test"
  require "opengl_test"
  require "sqlite3_test"
  
  system "git status test/output"
end