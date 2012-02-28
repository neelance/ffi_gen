ffi_gen - A Generator for Ruby FFI bindings
===========================================

Roadmap
-------

* Rake Task
* Generation of YARD documentation comments
* Support for more libraries:
  * LLVM
  * OpenGL
  * Cairo
  * (Write me if you have a whish)


Hints
-----

You may need to set additional include directories:

    export CPATH=/usr/lib/gcc/x86_64-linux-gnu/4.6.1/include

Your GCC include paths can be seen with:

    `gcc -print-prog-name=cc1` -v