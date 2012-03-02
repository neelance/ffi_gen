ffi_gen - A Generator for Ruby FFI bindings
===========================================

*Author:* Richard Musiol  
*Contributors:* Jeremy Voorhis (thanks for the initial idea)


Features
--------
* Generation of FFI methods, structures, enums and callbacks
* Generation of YARD documentation comments
* Tested with headers of the following libraries:
  * Clang
  * LLVM


Requirements
------------

* Ruby 1.9
* Clang 3.0 ([Download](http://llvm.org/releases/download.html#3.0), use the binaries or configure with ``--enable-shared``)

*These requirements are only for running the generator. The generated files are Ruby 1.8 compatible and do not need Clang.*


Example
-------
Use the following interface in a script or Rake task:

    FFIGen.generate(
      ruby_module: "Clang",
      ffi_lib:     "clang",
      headers:     ["clang-c/Index.h"],
      cflags:      `llvm-config --cflags`.split(" "),
      prefixes:    ["clang_", "CX"],
      blacklist:   ["clang_getExpansionLocation"],
      output:      "clang.rb"
    )

Output: [clang.rb](https://github.com/neelance/ffi_gen/blob/master/clang.rb)

Roadmap
-------

* Improved YARD documentation comments
* Support for more libraries:
  * OpenGL
  * Cairo
  * (Write me if you have a whish)


Hints
-----

You may need to set additional include directories:

    export CPATH=/usr/lib/gcc/x86_64-linux-gnu/4.6.1/include

Your GCC include paths can be seen with:

    `gcc -print-prog-name=cc1` -v