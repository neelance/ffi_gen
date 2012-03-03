task :test do
  $: << File.join(File.dirname(__FILE__), "lib")
  
  require File.join(File.dirname(__FILE__), "test/llvm_test")
  
  system "git status test/gen"
end