include_directories(include)

add_subdirectory(lib)

if(ENABLE_EXAMPLE)
    add_subdirectory(example)
endif(ENABLE_EXAMPLE)

if(ENABLE_TEST)
    add_subdirectory(test)
endif(ENABLE_TEST)

if(ENABLE_SWIG)
    add_subdirectory(swig)
endif(ENABLE_SWIG)