set(TESTS_BIN_DIR "${CMAKE_BINARY_DIR}/tests/bin")

# On Windows we need to point the tests to the Matlab dlls. Define a
# TEST_ENV_PATH variable that has the location prepended to the system path.
# When adding tests, this can be set as the system path for those tests.
if(WIN32)
    file(TO_CMAKE_PATH "$ENV{PATH}" SYS_PATH)
    set(TEST_ENV_PATH "${SYS_PATH};${Matlab_DLL_DIR}")
    string(REPLACE ";" "\;" TEST_ENV_PATH "${TEST_ENV_PATH}")
endif()

# This must be included only after the variables TESTS_BIN_DIR and (on Windows)
# TEST_ENV_PATH have been defined
include(horace_AddUnitTest)

set(TEST_DIRECTORIES
    "combine_sqw.tests"
)

foreach(_test_dir ${TEST_DIRECTORIES})
    add_subdirectory("${_test_dir}")
endforeach(_test_dir)