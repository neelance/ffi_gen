ffi_gen - A Generator for Ruby FFI bindings
===========================================

Requirements
------------

* Clang 3.0 ([Download](http://llvm.org/releases/download.html#3.0), use the binaries or configure with ``--enable-shared``)


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