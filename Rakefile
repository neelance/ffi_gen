task :test do
  $: << File.join(File.dirname(__FILE__), "lib")
  $: << File.join(File.dirname(__FILE__), "test")
  
  require "clang_test"
  require "llvm_test"
  require "opengl_test"
  require "sqlite3_test"
  require "cairo_test"
  require "pragma_pack_test"
  require "similar_enums_test"
  require "const_variable_test"
  require "macro_expression_test"
  
  system "git status test/gen"
end
