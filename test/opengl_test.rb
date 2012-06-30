require "test_utils"

run_test(
  library_name:  "GL",
  ffi_lib:       "GL",
  prefixes:      ["gl", "GL_"],
  files:         ["GL/gl.h"]
)

run_test(
  library_name:  "GLU",
  ffi_lib:       "GLU",
  prefixes:      ["glu", "GLU_"],
  files:         ["GL/glu.h"]
)

run_test(
  library_name:  "GLUT",
  ffi_lib:       "glut",
  prefixes:      ["glut", "GLUT_"],
  files:         ["GL/freeglut_std.h"]
)