add_subdirectory(z6502)

add_executable(z6502_emulator
    emulator_utility.cpp
    main.cpp
    # Add other source files here
)
target_link_libraries(z6502_emulator PRIVATE z6502_core)
target_include_directories(z6502_emulator PRIVATE ${CMAKE_SOURCE_DIR}/include)
