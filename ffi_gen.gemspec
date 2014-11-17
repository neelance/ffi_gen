Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY

  s.name = "ffi-gen"
  s.version = "1.1.0"
  s.summary = "A generator for Ruby FFI bindings"
  s.description = "A generator for Ruby FFI bindings, directly from header files via LLVM's Clang compiler"
  s.author = "Richard Musiol"
  s.email = "mail@richard-musiol.de"
  s.homepage = "https://github.com/neelance/ffi-gen"

  s.add_dependency "ffi", ">= 1.0.0"
  s.files = Dir["lib/**/*.rb"] + ["LICENSE", "README.md", "lib/ffi/gen/empty.h"]
  s.require_path = "lib"
end