add_library(z6502_core
    z6502.c
    # Add other source files here
)
target_include_directories(z6502_core PRIVATE ${CMAKE_SOURCE_DIR}/include)